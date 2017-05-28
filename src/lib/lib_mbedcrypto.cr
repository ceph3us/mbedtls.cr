# Wrapper around the libmbedcrypto library.
@[Link("mbedcrypto")]
lib LibMbedCrypto
  # common types
  alias CStr = LibC::Char*
  alias CSize = LibC::SizeT
  alias CInt = LibC::Int
  alias CUInt = LibC::UInt
  alias CByteStr = LibC::UChar*
  alias CByte = LibC::UChar

  # # error.h # #
  # buffer is an outparam
  fun strerror = mbedtls_strerror(errnum : CInt, buffer : CStr, buflen : CSize)

  # # version.h # #
  fun version_get_feature = mbedtls_version_get_feature(feature : CStr) : CInt
  fun version_get_number = mbedtls_version_get_number : CUInt
  # buffer is an outparam, must be at least 9 bytes
  fun version_get_string = mbedtls_version_get_string(buffer : CStr)
  # buffer is an outparam, must be at least 18 bytes
  fun version_get_string_full = mbedtls_version_get_string_full(buffer : CStr)

  # # md.h - Message Digest (hashing) ##
  ERR_MD_FEATURE_UNAVAILABLE = -0x5080
  ERR_MD_BAD_INPUT_DATA      = -0x5100
  ERR_MD_ALLOC_FAILED        = -0x5180
  ERR_MD_FILE_IO_ERROR       = -0x5200

  # Digest types. Accurate as of mbed TLS 2.4.2.
  enum MDType
    # Placeholder for applications in which no digest algorithm is wanted.
    None = 0
    # The MD2 algorithm.
    MD2
    # The MD4 algorithm.
    MD4
    # The MD5 algorithm.
    MD5
    # The SHA1 algorithm.
    SHA1
    # The SHA224 algorithm.
    SHA224
    # The SHA256 algorithm.
    SHA256
    # The SHA384 algorithm.
    SHA384
    # The SHA512 algorithm.
    SHA512
    # The RIPEMD160 algorithm.
    RIPEMD160
  end

  # md_info_t is opaque to consumers
  type MDInfo = Void*

  struct MDContext
    md_info : MDInfo
    md_ctx : Void*
    hmac_ctx : Void*
  end

  # utility methods
  fun md_init = mbedtls_md_init(ctx : MDContext*)
  # mbedtls_md_init_ctx is deprecated, no need to include
  fun md_setup = mbedtls_md_setup(ctx : MDContext*, md_info : MDInfo, hmac : CInt) : CInt
  fun md_free = mbedtls_md_free(ctx : MDContext*)
  fun md_clone = mbedtls_md_clone(dest : MDContext*, src : MDContext*) : CInt

  # hash types
  fun md_list = mbedtls_md_list : MDType*
  fun md_info_from_type = mbedtls_md_info_from_type(md_type : MDType) : MDInfo
  fun md_info_from_string = mbedtls_md_info_from_string(md_name : CStr) : MDInfo
  fun md_get_name = mbedtls_md_get_name(md_info : MDInfo) : CStr
  fun md_get_size = mbedtls_md_get_size(md_info : MDInfo) : CByte
  fun md_get_type = mbedtls_md_get_type(md_info : MDInfo) : MDType

  # digest state machine
  fun md_starts = mbedtls_md_starts(ctx : MDContext*) : CInt
  fun md_update = mbedtls_md_update(ctx : MDContext*, input : CByteStr, input_len : CSize) : CInt
  fun md_finish = mbedtls_md_finish(ctx : MDContext*, output : CByteStr)

  # hmac state machine
  fun md_hmac_starts = mbedtls_md_hmac_starts(ctx : MDContext*) : CInt
  fun md_hmac_update = mbedtls_md_hmac_update(ctx : MDContext*, input : CByteStr, input_len : CSize) : CInt
  fun md_hmac_reset = mbedtls_md_hmac_reset(ctx : MDContext*) : CInt
  fun md_hmac_finish = mbedtls_md_hmac_finish(ctx : MDContext*, output : CByteStr) : CInt

  # oneshot functions
  fun md = mbedtls_md(md_info : MDInfo, input : CByteStr, input_len : CSize, output : CByteStr) : CInt
  fun md_hmac = mbedtls_md_hmac(md_info : MDInfo, key : CByteStr, key_len : CSize,
                                input : CByteStr, input_len : CSize, output : CByteStr) : CInt
end
