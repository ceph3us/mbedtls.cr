require "../mbedtls"
require "./digest_base"

require "base64"

module MbedTLS
  # Abstract base class for using the mbed TLS crypto library to
  # produce digests for given data.
  # NOTE: The Digest class cannot be directly instantiated. Use one of it's subclasses instead.
  abstract class Digest
    # Exception thrown when the mbed TLS library throws an exception during a
    class DigestError < MbedTLSError; end

    alias Type = LibMbedCrypto::MDType

    # Hacky; you can't macro iterate enums without type access, so cheat!
    private module DigestClassBuilder
      private module DigestClassBuilderIntl(T)
        macro included
          {% for c in T.constants %}
            {% if c == "None" %}
            {% else %}
              # A binding to the mbed TLS implementation of the {{c}} digest algorithm.
              {% if c == "MD2" || c == "MD4" %}
              # NOTE: The {{c}} digest algorithm is old and most vendors do not
              # build mbed TLS with support for it.
              {% end %}
              {% if c == "MD2" || c == "MD4" || c == "MD5" || c == "SHA1" || c == "RIPEMD160" %}
              # DEPRECATED: The {{c}} digest algorithm is no longer considered
              # cryptographically secure. Restrict its use to backwards compatibile applications,
              # and plan to halt its use entirely in the future.
              {% end %}
              class {{c}} < Digest

                @@md_info : LibMbedCrypto::MDInfo
                @@md_info = LibMbedCrypto.md_info_from_type({{T}}::{{c}})
                @@digest_size = UInt8.new(LibMbedCrypto.md_get_size(@@md_info))

                # Whether the linked libmbedcrypto supports the {{c}} digest.
                def self.is_supported?
                  Digest.supported_types.includes?({{T}}::{{c}})
                end

                # The `Type` enum of this Digest algorithm.
                def md_type_of : Type
                  {{T}}::{{c}}
                end

                # Creates a new `{{c}}` instance with the same internal state.
                # Raises a `DigestError` if a library issue happens during the clone operation.
                def clone : {{c}}
                  ctx = Digest.create_md_ctx(md_type_of)
                  ctx_ptr = pointerof(ctx)

                  unless (err = LibMbedCrypto.md_clone(ctx_ptr, self)) == 0
                    raise DigestError.new(err, "Error cloning Digest::{{c}} instance")
                  end

                  typeof(self).new_internal(ctx)
                end

                # The size of the digest's output, in bytes.
                # This is the size of the raw digest, not it's hex representation.
                def digest_size : UInt8
                  @@digest_size
                end

                # Creates a new instance for hashing data with {{c}}.
                # Raises a `DigestError` if the linked copy of libmbedcrypto was not
                # compiled with support for the {{c}} digest algorithm.
                def self.new
                  if @@md_info.null?
                    raise DigestError.new(0, "Digest type {{c}} is unknown to libmbedcrypto")
                  end
                  new("{{c}}", create_md_ctx({{T}}::{{c}}))
                end

                protected def self.new_internal(ctx : LibMbedCrypto::MDContext)
                  new("{{c}}", ctx)
                end

                private def initialize(name : String, ctx : LibMbedCrypto::MDContext)
                  super(name, ctx)
                end
              end
            {% end %}
          {% end %}
        end
      end

      macro included
        include DigestClassBuilderIntl(Type)
      end
    end

    include DigestBase
    include DigestClassBuilder

    # The readable name of this Digest algorithm.
    getter name

    # The `Type` enum of this Digest algorithm.
    def md_type_of : Type
      Type::None
    end

    @@supported_types = [] of Type
    c_typelist = LibMbedCrypto.md_list
    i = 0

    while (typeid = c_typelist[i]) != Type::None
      @@supported_types.push(typeid)
      i += 1
    end

    # Returns a tuple of types supported by the linked libmbedcrypto.
    def self.supported_types
      @@supported_types
    end

    private def initialize(@name : String, @ctx : LibMbedCrypto::MDContext)
      @used = false
      raise DigestError.new(0, "Invalid MDContext") unless @ctx
    end

    protected def self.create_md_ctx(md_type)
      md_info = LibMbedCrypto.md_info_from_type(md_type)
      if md_info.null?
        raise DigestError.new(0, "Digest type #{md_type} is unknown to libmbedcrypto")
      end
      ctx = LibMbedCrypto::MDContext.new
      ctx_ptr = pointerof(ctx)

      # Init the ctx struct
      LibMbedCrypto.md_init(ctx_ptr)

      unless (err = LibMbedCrypto.md_setup(ctx_ptr, md_info, 0)) == 0
        raise DigestError.new(err, "Error constructing Digest::#{md_type} instance")
      end

      unless (err = LibMbedCrypto.md_starts(ctx_ptr)) == 0
        raise DigestError.new(err, "Error constructing Digest::#{md_type} instance")
      end

      ctx
    end

    # Handles the cleanup of the mbed TLS library handles associated with this `Digest` instance.
    def finalize
      LibMbedCrypto.md_free(pointerof(@ctx))
    end

    # Create an instance of the Digest object with it's internal state copied from this instance.
    abstract def clone : Digest

    # Clear the buffer and reset the internal state of the digest context.
    def reset
      unless (err = LibMbedCrypto.md_starts(self)) == 0
        raise DigestError.new(err, "Error constructing Digest::#{md_type_of} instance")
      end
      self
    end

    # Add data to the buffer for hashing.
    # NOTE: This method is an implementation detail. Use the more user friendly `DigestBase.<<`
    # to hash data, or the `DigestBase.file` method to hash files.
    def update(data : String | Slice)
      unless (err = LibMbedCrypto.md_update(self, data, LibC::SizeT.new(data.bytesize))) == 0
        raise DigestError.new(err, "Error updating buffer of Digest::#{@name} instance")
      end
      self
    end

    # Produces the digest from the state buffer.
    protected def finish : Slice(UInt8)
      data = Slice(UInt8).new(digest_size)
      LibMbedCrypto.md_finish(self, data)
      reset
      data
    end

    # The length of the digest message this algorithm produces, in bytes.
    abstract def digest_size : UInt8

    # Returns a pointer to the internal context used by the library.
    def to_unsafe : Pointer(LibMbedCrypto::MDContext)
      pointerof(@ctx)
    end

    # Hash the buffer and return the raw bytes returned by the digest algorithm without
    # allocating a new instance.
    # NOTE: The `Digest` instance is reset after use.
    def digest!
      self.finish
    end

    # Hash the buffer and return the Base64 encoded representation of the
    # digest without allocating a new instance.
    # NOTE: The `Digest` instance is reset after use.
    def base64digest!
      Base64.encode(digest!)
    end

    # Hash the buffer and return the hexadecimal representation of the
    # digest without allocating a new instance.
    # NOTE: The `Digest` instance is reset after use.
    def hexdigest!
      DigestBase.hexdump(digest!)
    end
  end
end
