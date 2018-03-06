module FCB
  class Verification
    TEST_API_PATH = "http://www-test2.1cb.kz/VerService/VerificationService".freeze
    PROD_API_PATH = "https://secure2.1cb.kz/VerService/VerificationService".freeze
    ERRORS = {
      "-1000" => :authentication_error,
      "-1011" => :duplication_error,
      "-1012" => :subject_not_found,
      "-1013" => :subject_is_not_physical,
      "-1014" => :contracts_not_found,
      "-1015" => :not_enough_information,
      "-1017" => :subject_consent_needed,
      "-1018" => :active_contracts_not_found
    }

    MARITAL_STATUSES = {
      "single" => 1,
      "married" => 2,
      "divorced" => 3,
      "widow" => 4,
      "civil_marriage" => 5
    }

    def initialize(env: :production, culture: "ru-RU", user_name:, password:)
      @culture = culture
      @user_name = user_name
      @password = password
      @parser = Nori.new
      @env = env.to_sym
    end

    def call(args={})
      uri = URI(@env == :production ? PROD_API_PATH : TEST_API_PATH)
      request = Net::HTTP::Post.new(uri)
      request.body = xml(transform_args(args))
      puts xml(transform_args(args))
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
      data = hash["S:Envelope"]["S:Body"]["StoreVerificationReqResponse"]["return"]
      return M.Failure(ERRORS[data["ErrorCode"]]) unless data["errorCode"] == "1"
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
        "xmlns:ws" => "http://verification.ws.creditinfo.com/"
        }) do
        xml.x :Header do
          xml.ws :CigWsHeader do
            xml.ws :Culture,  @culture
            xml.ws :UserName, @user_name
            xml.ws :Password, @password
          end
        end
        xml.x :Body do
          xml.ws :StoreVerificationReq do
            xml.ws :application do
              xml.ws :IIN, args[:iin]
              xml.ws :lastName, args[:last_name]
              xml.ws :firstName, args[:first_name]
              xml.ws :fatherName, args[:middle_name]
              xml.ws :email, args[:email]
              xml.ws :maritalstatus, args[:marital_status] if args[:marital_status]
              xml.ws :Documents do
                xml.ws :Typeid, 7
                xml.ws :Number, args[:gov_id_number]
                xml.ws :IssueDate, args[:gov_id_issued_at]
                xml.ws :ExpirationDate, args[:gov_id_expire_at]
              end
              xml.ws :Phones do
                args[:phones].map { |phone| xml.ws :PhoneNumber, phone }
              end
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
