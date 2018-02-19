RSpec.describe FCB::BehavioralScoring do
  describe "#call" do

    it "returns behavioral scoring" do
      request = FCB::BehavioralScoring.new(env: :test, user_name: ENV["FCB_TEST_USERNAME"], password: ENV["FCB_TEST_PASSWORD"])
      result = request.call(iin: "820108350867")
      expect(result).to eq(Dry::Monads::Success)
    end
  end
end
