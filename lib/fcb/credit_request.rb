module FCB
  class CreditRequest
    TEST_API_PATH = "http://test1.1cb.kz/CreditApp/CreditAppService".freeze
    PROD_API_PATH = "https://secure2.1cb.kz/CreditApp/CreditAppService".freeze
    ERRORS = {
      "-1000" => :authentication_error,
      "-1001" => :address_save_error,
      "-1002" => :phone_save_error,
      "-1053" => :no_data,
      "-1056" => :document_not_provided,
      "-1050" => :wrong_location,
      "-1051" => :wrong_credit_purpose,
      "-1060" => :valdiation_error
    }

    def initialize(env: :production, culture: "ru-RU", user_name:, password:)
      @culture = culture
      @user_name = user_name
      @password = password
      @parser = Nori.new
      @env = env.to_sym
    end

    def call(args={})
      args[:addresses] = [] unless args[:addresses]
      uri = URI(@env == :production ? PROD_API_PATH : TEST_API_PATH)
      request = Net::HTTP::Post.new(uri)
      request.body = xml(transform_args(args))
      request.content_type = "text/xml; charset=utf-8"
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.port == 443
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.port == 443
      response = http.start do |_|
        _.request(request)
      end
      hash = @parser.parse(response.body)
      error = hash.dig("S:Envelope", "S:Body", "S:Fault")
      return M.Failure(:request_error) if error
      data = hash["S:Envelope"]["S:Body"]["StoreCreditApplicationResponse"]["return"]
      return M.Failure(ERRORS[data["errorCode"]]) unless data["errorCode"] == "0"
      M.Success(data)
    end

    private

    def transform_args(args)
      args.reduce({}) do |acc, elem|
        if elem[0] == :marital_status
          acc[elem[0]] = MARITAL_STATUSES[elem[1]]
        else
          acc[elem[0]] = elem[1]
        end
        acc
      end
    end

    def xml(args)
      xml = Builder::XmlMarkup.new 
      xml.instruct!(:xml, :encoding => "UTF-8")
      xml.x(:Envelope, {
        "xmlns:x" => "http://schemas.xmlsoap.org/soap/envelope/",
        "xmlns:ws" => "http://creditapp.ws.creditinfo.com/"
        }) do
        xml.x :Header do
          xml.ws :CigWsHeader do
            xml.ws :Culture,  @culture
            xml.ws :UserName, @user_name
            xml.ws :Password, @password
          end
        end
        xml.x :Body do
          xml.ws :StoreCreditApplication do
            xml.ws :application do
              xml.ws :IIN, args[:iin]
              xml.ws :lastName, args[:last_name]
              xml.ws :firstName, args[:first_name]
              xml.ws :fatherName, args[:middle_name]
              xml.ws :creditLocation, 1
              xml.ws :creditKatoId, 0
              xml.ws :creditPuspose, 1
              xml.ws :sumApplication, args[:amount]
              xml.ws :currencyApplication, 398
              xml.ws :dateApplication, args[:date].strftime("%FT%T")
              xml.ws :dateOfBirth, args[:dob].strftime("%FT%T")
              xml.ws :Phones do
                args[:phones].map { |phone| xml.ws :PhoneNumber, phone }
              end
              xml.ws :Addresses do
                xml.ws :Location, 0
                xml.ws :KatoId, 0
              end
              xml.ws :IsReport, 365
              xml.ws :OnlyReport, 0
              xml.ws :consentConfirmed, 1
            end
          end
        end 
      end
    end

    def parse(body)
      M.Maybe(body).bind do |body|
        M.Maybe(body["get_reports_response".to_sym]).bind do |r|
          M.Maybe(r["get_reports_result".to_sym])
        end
      end
    end
  end
end
