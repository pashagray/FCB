# frozen_string_literal: true

RSpec.describe FCB::GetBatchStatus do
  describe '#call' do
    it 'returns failure if no_data' do
      request = FCB::GetBatchStatus.new(env: :test,
                                        user_name: ENV['FCB_TEST_USERNAME'],
                                        password: ENV['FCB_TEST_PASSWORD'])
      result = request.call(0)
      expect(result).to be_a(Dry::Monads::Result::Failure)
    end

    it 'returns result of UploadZippedData by batch_id' do
      request = FCB::GetBatchStatus.new(env: :test,
                                        user_name: ENV['FCB_TEST_USERNAME'],
                                        password: ENV['FCB_TEST_PASSWORD'])
      result = request.call(105_300)
      puts result
      expect(result).to be_a(Dry::Monads::Result::Success)
    end
  end
end
