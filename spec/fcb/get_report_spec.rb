# frozen_string_literal: true

RSpec.describe FCB::GetReport do
  describe "#call" do
    context 'basic report(reportImportCode: 2)' do
      it "returns credit report" do
        request = FCB::GetReport.new(env: :test, user_name: ENV["FCB_TEST_USERNAME"], password: ENV["FCB_TEST_PASSWORD"])
        result = request.call(
          iin: '730724301968',
          report_import_code: '2'
        )
        expect(result).to be_a(Dry::Monads::Result::Success)
      end
    end
  end
end
