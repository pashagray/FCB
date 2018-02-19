module FCB
  class Report
    API_PATH = "http://www-test2.1cb.kz:80/FCBServices/Service"
    PDF_FORMAT_CODE = "609"
    IIN_DOC_CODE = "14"
    REPORTS = {
      "99993"  => "1",
      "200000" => "2",
      "200014" => "3",
      "200017" => "4",
      "200018" => "5",
      "200019" => "6",
      "200004" => "7",
      "200066" => "13",
      "200067" => "14",
      "600051" => "21",
      "600052" => "22",
      "600053" => "23",
      "600054" => "24"
    }

    def initialize(culture: "ru-RU", user_name:, password:)
      @culture = culture
      @user_name = user_name
      @password = password
    end

    def call(iin, *reports)
      uri = URI(API_PATH)
      request = Net::HTTP::Post.new(uri)
      request.body = xml(iin, reports)
      request.content_type = "text/xml; charset=utf-8"
      response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
      parser = Nori.new
      hash = parser.parse(response.body)
      error = hash.dig("S:Envelope", "S:Body", "S:Fault")
      return M.Failure(:request_error) if error
      data = hash["S:Envelope"]["S:Body"]["GetReportsResponse"]["GetReportsResult"]
      return M.Failure(:no_data) unless data
      file = Tempfile.new(["reports.#{iin}.#{Time.now.strftime("%Y%m%d%H%S")}", ".zip"])
      file.write(Base64.decode64(data))
      M.Success(file)
    end

    private

    def xml(iin, reports)
      xml = Builder::XmlMarkup.new 
      xml.instruct!(:xml, :encoding => "UTF-8")
      xml.x(:Envelope, {
        "xmlns:x" => "http://schemas.xmlsoap.org/soap/envelope/",
        "xmlns:ws" => "http://ws.creditinfo.com/"
        }) do
        xml.x :Header do
          xml.ws :CigWsHeader do
            xml.ws :Culture, @culture
            xml.ws :UserName, @user_name
            xml.ws :Password, @password
          end
        end
        xml.x :Body do
          xml.ws :GetReports do
            xml.ws :xmlDoc do
              xml.identifiers({ "xmlns" => "" }) do
                reports.each do |r|
                  xml.identifier(
                    {
                      "reportImportCode" => REPORTS[r],
                      "idTypeImportCode" => IIN_DOC_CODE,
                      "ConsentConfirmed" => "1"
                    },
                    iin
                  )
                end
              end
            end
            xml.ws :outputFormat, PDF_FORMAT_CODE
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
