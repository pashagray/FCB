RSpec.describe FCB::BehavioralScoring do
  describe "#call" do

    it "returns behavioral scoring" do
      request = FCB::BehavioralScoring.new(user_name: "87717813345", password: "910913401920")
      result = request.call(iin: "820108350867")
      expect(result).to eq("Version: 4.0.246; Server: www-test2.1cb.kz; SQL Server: TEST2DB2012 Transaction OFF")
    end
  end
end
