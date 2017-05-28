require "./spec_helper"

describe MbedTLS::Digest do
  # TODO: Write tests

  it "should be able to perform a SHA1 hash" do
    digest = MbedTLS::Digest::SHA1.new
    digest << "test string"
    digest.base64digest.should eq("ZhKVycv51rL2QoQUUEqN7tMCBkE=\n")
    digest.hexdigest.should eq("661295c9cbf9d6b2f6428414504a8deed3020641")
  end
end
