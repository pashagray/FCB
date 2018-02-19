module FCB
  class BehavioralScoring
    API_PATH = "http://www-test2.1cb.kz:80/ScoreService/ScoreService"
    ERRORS = {
      "-1000" => :authentication_error
    }

    def initialize(culture: "ru-RU", user_name:, password:)
      @culture = culture
      @user_name = user_name
      @password = password
      @parser = Nori.new
    end

    def call(iin:)
      uri = URI(API_PATH)
      request = Net::HTTP::Post.new(uri)
      request.body = xml(iin)
      puts xml(iin)
      request.content_type = "text/xml; charset=utf-8"
      response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
      hash = @parser.parse(response.body)
      error = hash.dig("S:Envelope", "S:Body", "S:Fault")
      return M.Failure(:request_error) if error
      data = hash["S:Envelope"]["S:Body"]["ScoreResponse"]["return"]
      return M.Failure(ERRORS[data["ErrorCode"]]) unless data["ErrorCode"] == "0"
      M.Success(data)
    end

    private

    def xml(iin)
      xml = Builder::XmlMarkup.new 
      xml.instruct!(:xml, :encoding => "UTF-8")
      xml.x(:Envelope, {
        "xmlns:x" => "http://schemas.xmlsoap.org/soap/envelope/",
        "xmlns:ws" => "http://score.ws.creditinfo.com/"
        }) do
        xml.x :Header do
          xml.ws :CigWsHeader do
            xml.ws :Culture,  @culture
            xml.ws :UserName, @user_name
            xml.ws :Password, @password
          end
        end
        xml.x :Body do
          xml.ws :Score do
            xml.ws :ScoreCard, "BehaviorScoring"
            xml.ws :attributes do
              xml.ws :name, "ConsentConfirmed"
              xml.ws :value, 1
            end
            xml.ws :attributes do
              xml.ws :name, "IIN"
              xml.ws :value, iin
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
