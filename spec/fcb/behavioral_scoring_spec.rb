RSpec.describe FCB::BehavioralScoring do
  describe "#call" do

    it "returns behavioral scoring" do
      request = FCB::BehavioralScoring.new(env: :test, user_name: ENV["FCB_TEST_USERNAME"], password: ENV["FCB_TEST_PASSWORD"])
      result = request.call(iin: "820108350867")
      expect(result).to be_a(Dry::Monads::Result::Success)
    end
  end
end
