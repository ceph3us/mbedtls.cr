require "./lib/lib_mbedcrypto"

module MbedTLS
  # Superclass of all exceptions raised from error states
  # returned by the mbed TLS libraries. We are good
  class MbedTLSError < Exception
    # Error code used internally by libmbedcrypto.
    getter err

    # The error message returned by mbedtls_strerror.
    getter err_msg

    ERR_BUF_SIZE = 128

    def initialize(@err : LibMbedCrypto::CInt, msg = nil)
      err_msg_buf = uninitialized LibC::Char[ERR_BUF_SIZE]
      unless @err == 0
        LibMbedCrypto.strerror(@err, err_msg_buf, ERR_BUF_SIZE)
        @err_msg = String.new(err_msg_buf.to_slice)
        msg = msg ? "#{msg}: #{@err_msg}" : @err_msg
      end
      super(msg)
    end
  end
end

require "./digest/*"
