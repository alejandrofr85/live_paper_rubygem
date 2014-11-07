require 'open-uri'
require 'net/https'

class NotAuthenticatedError < Exception
end

module LivePaper
  module HttpClient
    LP_API_HOST="https://www.livepaperapi.com"
    AUTH_URL = "#{LP_API_HOST}/auth/token"

    def send_request(request, options={})
      request['Content-type'] = options[:content_type] if options[:content_type]
      request.body = options[:body] if options[:body]
      options[:allow_codes] ||= [200,201]
      response = @http.request(request)
      check_response(response, options[:allow_codes])
      response
    end

    def check_response(response, allow_codes)
      status = response.code.to_i
      raise NotAuthenticatedError.new("Unauthorized") if status == 401
      unless allow_codes.include?(status)
        raise "Request failed with code #{status}"
      end
    end

    def request_handling_auth(url, method)
      tries = 0
      begin
        request_access_token unless @access_token
        request = http_request(url, method)
        request['Authorization'] = "Bearer #{@access_token}"
        request['Accept'] = "application/json"
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
      request = http_request(AUTH_URL, 'POST')
      request['Authorization'] = "Basic #{$lpp_basic_auth}"
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
        when 'PUT'
          Net::HTTP::Put.new(uri.request_uri)
        when 'DELETE'
          Net::HTTP::Delete.new(uri.request_uri)
        else
          raise "Method '#{method}' not supported."
      end
    end

    private
    def set_http(uri)
      http_params = [uri.host, uri.port]
      http_params.concat ENV['HTTP_PROXY'].gsub('http://', '').split(':') unless ENV['HTTP_PROXY'].to_s.empty?

      @http = Net::HTTP.new(*http_params)
      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
  end
end