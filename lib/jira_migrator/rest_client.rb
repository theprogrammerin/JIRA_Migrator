module JIRAMigrator
  class RestClient

    require 'restclient'
    require 'base64'

    def initialize(base_url, auth)

    @base_url = base_url
    @auth = Base64.encode64("#{auth}")

    end

    def get(url)
      RestClient.get("#{@base_url}#{url}", {authorization: "Basic #{@auth}", content_type: :json })
    end

  end
end
