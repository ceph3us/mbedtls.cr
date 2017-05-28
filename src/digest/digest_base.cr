require "base64"

module MbedTLS
  # Describes common utility methods for working with message digests.
  module DigestBase
    # Utility method to read a file into the internal buffer of the
    # `Digest` instance.
    def file(file_name)
      File.open(file_name) do |io|
        self << io
      end
    end

    # Adds the contents of the `io` I/O buffer to the internal buffer
    # of the `Digest` instance.
    # You can call `update` until the buffer contains the full data for
    # hashing; the contents of the buffer get appended with each call.
    def update(io : IO)
      buffer = uninitialized UInt8[2048]
      while (read_bytes = io.read(buffer.to_slice)) > 0
        self << buffer.to_slice
      end
      self
    end

    # Shorthand operator for `update`.
    # You can chain the `<<` operator to concatenate data into the
    # internal buffer of the `Digest` instance for hashing.
    # ```
    # require "mbedtls"
    # digest = MbedTLS::Digest::SHA256.new
    # digest << "Hello, world"
    # puts "SHA256(Hello, world) = #{digest}"
    # ```
    # Output:
    # ```plain
    # SHA256(Hello, world) = 4ae7c3b6ac0beff671efa8cf57386151c06e58ca53a78d83f36107316cec125f
    # ```
    def <<(data)
      update(data)
    end

    # Hash the buffer and return the raw bytes returned by the digest algorithm.
    def digest
      self.clone.finish
    end

    # Returns the Base64 encoded representation of the digest.
    def base64digest
      Base64.encode(digest)
    end

    # Returns the hexadecimal representation of the digest.
    def hexdigest
      DigestBase.hexdump(digest)
    end

    # Utility method, converts a buffer slice to a hexadecimal representation.
    def self.hexdump(digest)
      String.build do |buffer|
        digest.each do |i|
          buffer.printf("%02x", i)
        end
      end
    end

    # Converts digest instance to a string by creating it's hexadecimal representation.
    def to_s(io)
      io << hexdigest
    end
  end
end
