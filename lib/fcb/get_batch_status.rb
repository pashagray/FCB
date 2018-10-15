# frozen_string_literal: true

module FCB
  class GetBatchStatus
    TEST_API_PATH = 'http://www-test2.1cb.kz:80/DataPumpService/DataPumpService'.freeze
    PROD_API_PATH = 'https://secure.1cb.kz/DataPump/DataPumpService'.freeze

    def initialize(env: :production, culture: 'ru-RU', user_name:, password:)
      @env = env.to_sym
      @culture = culture
      @user_name = user_name
      @password = password
    end

    def call(batch_id)
      uri = URI(@env == :production ? PROD_API_PATH : TEST_API_PATH)
      request = Net::HTTP::Post.new(uri)
      request.body = xml(batch_id)
      request.content_type = 'text/xml; charset=utf-8'
      response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
      parser = Nori.new
      hash = parser.parse(response.body)
      error = hash.dig('S:Envelope', 'S:Body', 'S:Fault')
      return M.Failure(:request_error) if error

      data = hash['S:Envelope']['S:Body']['GetBatchStatus2Response']['GetBatchStatus2Result']['CigResult']['Result']
      return M.Failure(:no_data) unless data

      M.Success(hash['S:Envelope']['S:Body']['GetBatchStatus2Response']['GetBatchStatus2Result']['CigResult']['Result'])
    end

    private

    def xml(batch_id)
      xml = Builder::XmlMarkup.new
      xml.instruct!(:xml, encoding: 'UTF-8')
      xml.x(:Envelope,
            'xmlns:x' => 'http://schemas.xmlsoap.org/soap/envelope/',
            'xmlns:ws' => 'https://ws.creditinfo.com') do
        xml.x :Header do
          xml.ws :CigWsHeader do
            xml.ws :Culture, @culture
            xml.ws :UserName, @user_name
            xml.ws :Password, @password
          end
        end
        xml.x :Body do
          xml.ws :GetBatchStatus2 do
            xml.ws :batchId, batch_id
          end
        end
      end
    end
  end
end
