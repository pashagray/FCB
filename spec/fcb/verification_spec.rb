RSpec.describe FCB::Verification do
  describe "#call" do

    it "returns verificated data" do
      request = FCB::Verification.new(env: :test, user_name: ENV["FCB_TEST_USERNAME"], password: ENV["FCB_TEST_PASSWORD"])
      result = request.call(iin: "820108350867", first_name: "Алексей", gov_id_number: '035319625', phones: ['7014929242', '7026385550'])
      expect(result).to be_a(Dry::Monads::Result::Success)
    end
  end
end
