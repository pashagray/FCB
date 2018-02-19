RSpec.describe FCB::Reports do
  describe "#call" do

    it "returns available reports" do
      request = FCB::Reports.new(wsdl: "spec/fixtures/wsdl.xml", log: true, password: "910913401920", user_name: "87717813345")
      result = request.call
      expect(result).to eq("Version: 4.0.246; Server: www-test2.1cb.kz; SQL Server: TEST2DB2012 Transaction OFF")
    end
  end
end
