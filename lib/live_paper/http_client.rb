require 'open-uri'
require 'net/https'

class NotAuthenticatedError < Exception
end

module LivePaper
  module HttpClient
    AUTH_URL = "#{LPP_API_HOST}/auth/token"
    AUTH_HEADER = "Basic #{LPP_API_CLIENT_AUTH}"

    def send_request(request, content_type = nil, body = nil)
      request['Content-type'] = content_type if content_type
      request.body = body if body
      response = @http.request(request)
      check_response(response)
      response
    end

    def check_response(response)
      status = response.code.to_i
      raise NotAuthenticatedError.new("Unauthorized") if status == 401
      unless Array(200..201).include?(status)
        raise "Request failed with code #{status}"
      end
    end

    def request_handling_auth(url, method)
      tries = 0
      begin
        request_access_token unless @access_token
        request = http_request(url, method)
        request['Authorization'] = "Bearer #{@access_token}"
        yield request
      rescue NotAuthenticatedError => e
        tries += 1
        if tries < 3
          @access_token = nil
          retry
        else
          raise e
        end
      end
    end

    def request_access_token
      request = http_request(AUTH_URL, "POST")
      request['Authorization'] = AUTH_HEADER
      request['Content-Type'] = 'application/x-www-form-urlencoded'
      request.body = 'grant_type=client_credentials&scope=all'
      response = @http.request(request)
      parsed = JSON.parse(response.body)
      @access_token = parsed['accessToken']
    end

    def http_request(url, method)
      uri = URI.parse(url)
      set_http uri

      case method.to_s.upcase
        when 'POST'
          Net::HTTP::Post.new(uri.request_uri)
        when 'GET'
          Net::HTTP::Get.new(uri.request_uri)
        else
          raise "Method '#{method}' not supported."
      end
    end

    private
    def set_http(uri)
      http_params = [uri.host, uri.port]
      http_params.concat ENV['HTTP_PROXY'].gsub('http://', '').split(':') if ENV['HTTP_PROXY'].present?

      @http = Net::HTTP.new(*http_params)
      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
  end
end