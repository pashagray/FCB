# frozen_string_literal: true

module FCB
  class GetReport
    TEST_API_PATH = "http://www-test2.1cb.kz:80/FCBServices/Service".freeze
    PROD_API_PATH = "https://secure.1cb.kz/FCBServices/Service".freeze
    IIN_DOC_CODE = "14"

    # reportId => reportImportCode
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

    ERRORS = {
      "1101" => :something_went_wrong,
      "1102" => :subject_not_found,
      "1103" => :culture_error,
      "1104" => :login_error,
      "1105" => :report_code_error,
      "1106" => :rights_error,
      "1107" => :document_not_found,
      "1108" => :report_not_found,
      "1109" => :subject_type_for_report_error,
      "1110" => :pass_ip_etc_error,
      "1111" => :pkb_inside_error,
      "1112" => :many_subject_found_error,
      "1115" => :setted_documents_error,
      "1116" => :search_code_error
    }

    def initialize(env: :production, culture: "ru-RU", user_name:, password:)
      @culture = culture
      @user_name = user_name
      @password = password
      @env = env.to_sym
    end

    def call(iin:, report_import_code:)
      return M.Failure(:report_import_code_not_found) unless REPORTS.select{ |_k, v| v == report_import_code }.any?
      uri = URI(@env == :production ? PROD_API_PATH : TEST_API_PATH)
      request = Net::HTTP::Post.new(uri)
      request.body = xml(iin: iin, report_import_code: report_import_code)
      request.content_type = "text/xml; charset=utf-8"
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.port == 443
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.port == 443
      response = http.start do |_|
        _.request(request)
      end
      parser = Nori.new
      hash = parser.parse(response.body)
      request_error = hash.dig("S:Envelope", "S:Body", "S:Fault")
      return M.Failure(:request_error) if request_error
      response_error = hash.dig("S:Envelope", "S:Body", "GetReportResponse", "GetReportResult", "CigResultError", "Errmessage")
      return M.Failure(ERRORS[response_error.attributes["code"]]) if response_error
      data = hash.dig("S:Envelope", "S:Body", "GetReportResponse", "GetReportResult", "CigResult", "Result", "Root")
      return M.Failure(:no_data) unless data
      M.Success(data)
    end

    private

    def xml(iin:, report_import_code:)
      xml = Builder::XmlMarkup.new 
      xml.instruct!(:xml, :encoding => "UTF-8")
      xml.x(:Envelope, {
        "xmlns:x" => "http://schemas.xmlsoap.org/soap/envelope/",
        "xmlns:ws" => "http://ws.creditinfo.com/"
      }) do
        xml.x :Header do
          xml.ws(:CigWsHeader) do
            xml.ws :Culture, @culture
            xml.ws :UserName, @user_name
            xml.ws :Password, @password
          end
        end
        xml.x :Body do
          xml.ws(:GetReport, { "xmlns:ws" => "http://ws.creditinfo.com/" }) do
            xml.ws :doc do |a|
              a.keyValue do |b|
                b.reportImportCode(report_import_code)
                b.idNumber(iin)
                b.idNumberType(IIN_DOC_CODE)
                b.ConsentConfirmed(1)
              end
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
