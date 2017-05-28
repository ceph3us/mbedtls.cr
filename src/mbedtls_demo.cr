require "./mbedtls"

cstr_ptr = uninitialized LibC::Char[18]

LibMbedCrypto.version_get_string_full(cstr_ptr)
verstring = String.new(cstr_ptr.to_slice)

puts verstring

if MbedTLS::Digest::MD4.is_supported?
  puts "MD4 is supported."
  md4hasher = MbedTLS::Digest::MD4.new
  md4hasher << "The quick brown fox jumps over the lazy dog"
  md4hash = md4hasher.hexdigest
  puts "MD4(\"The quick brown fox jumps over the lazy dog\") = #{md4hash}"
  md4hasher << "test"
  md4hash = md4hasher.hexdigest
  puts "MD4(\"The quick brown fox jumps over the lazy dog\") = #{md4hash}"
else
  puts "MD4 is not supported."
end

if MbedTLS::Digest::SHA1.is_supported?
  puts "SHA1 is supported."
  sha1hasher = MbedTLS::Digest::SHA1.new
  sha1hasher << "The quick brown fox jumps over the lazy dog"
  puts "SHA1(\"The quick brown fox jumps over the lazy dog\") = #{sha1hasher}"
  sha1hasher << "test"
  puts "SHA1(\"The quick brown fox jumps over the lazy dog\") = #{sha1hasher}"
  sha1hash = sha1hasher.to_s
  sha1hasher.reset
  sha1hasher << sha1hash
  sha1hasher << "test"
  puts "SHA1(\"The quick brown fox jumps over the lazy dog\") = #{sha1hasher}"
else
  puts "SHA1 is not supported."
end

puts MbedTLS::Digest.supported_types
