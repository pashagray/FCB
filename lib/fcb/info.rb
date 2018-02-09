module FCB
  class Info
    def initialize(wsdl: WSDL_PATH)
      @client = Savon.client(wsdl: wsdl)
      @operation = :get_version
    end

    def call
      response = @client.call(@operation)
      parse(response.body)
    end

    def parse(body)
      M.Maybe(body).bind do |body|
        M.Maybe(body[:get_version_response]).bind do |r|
          result = M.Maybe(r[:get_version_result])
          if result.success?
            M.Success(result.value)
          else
            M.Failure(:get_version_error)
          end
        end
      end
    end
  end
end
