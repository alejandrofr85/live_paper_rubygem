require_relative 'base_object'
require 'byebug'
module LivePaper
  class Configuration

    LP_API_HOST="https://www.livepaperapi.com"
    LP_API_HOST_STAGE="https://stage.livepaperapi.com"
    LP_API_HOST_DEV="https://dev.livepaperapi.com"

    class << self
      attr_accessor :lpp_api_host

      def lpp_api_host=(lpp_api_host)
        @lpp_api_host = lpp_api_host
      end

      def lpp_api_host
        @lpp_api_host || LP_API_HOST
      end

      def auth_url
        "#{self.lpp_api_host}/auth/token"
      end

      def auth_validation_url
        "#{self.lpp_api_host}/auth/v1/validate"
      end

      def environment env
        case env.downcase
        when /^.*dev.*/
          self.lpp_api_host = LivePaper::Configuration::LP_API_HOST_DEV
        when /^.*stag.*/
          self.lpp_api_host = LivePaper::Configuration::LP_API_HOST_STAGE
        when /^.*prod.*/
          self.lpp_api_host = LivePaper::Configuration::LP_API_HOST
        else
          self.lpp_api_host = LivePaper::Configuration::LP_API_HOST
        end
      end

    end

  end
end
