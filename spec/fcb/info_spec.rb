RSpec.describe FCB::Info do
  describe "#call" do

    it "returns version of API and server info" do
      request = FCB::Info.new(wsdl: "spec/fixtures/wsdl.xml")
      result = request.call
      expect(result.value).to eq("Version: 4.0.246; Server: www-test2.1cb.kz; SQL Server: TEST2DB2012 Transaction OFF")
    end
  end
end
