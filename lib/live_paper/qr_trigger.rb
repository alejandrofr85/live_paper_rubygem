require_relative 'base_object'

module LivePaper
  class QrTrigger < BaseObject
    attr_accessor :subscription, :qrcode_url

    DEFAULT_SUBSCRIPTION = :month

    def parse(data)
      data = JSON.parse(data, symbolize_names: true)[:trigger]
      assign_attributes data
      self.qrcode_url=data[:link].select { |item| item[:rel] == "image" }.first[:href]
      self
    end

    def self.api_url
      "#{LP_API_HOST}/api/v1/triggers"
    end

    def download_qrcode
      QrTrigger.request_handling_auth(self.qrcode_url, 'GET') do |request|
        response = QrTrigger.send_request(request)
        response.body.empty? ? nil : response.body
      end
    end

    private
    def validate_attributes!
      raise ArgumentError, 'Required Attributes needed: name' unless all_present? [@name]
    end

    def create_body
      {
        trigger: {
          name: @name,
          type: "qrcode",
          subscription: {
            package: DEFAULT_SUBSCRIPTION.to_s
          }
        }
      }
    end
  end
end
