RSpec.describe FCB::CreditRequest do
  describe "#call" do
    it "returns credit request info" do
      request = FCB::CreditRequest.new(env: :test, user_name: ENV["FCB_TEST_USERNAME"], password: ENV["FCB_TEST_PASSWORD"])
      result = request.call(
        iin: "730724301968",
        last_name: "Ivanov",
        first_name: "Ivan",
        date: Date.today,
        dob: Date.new(1988, 1, 1),
        phones: ["77014929242"],
        amount: 30000,
        location_id: 267,
        purpose: 8
      )
      expect(result).to be_a(Dry::Monads::Result::Success)
    end
  end
end
