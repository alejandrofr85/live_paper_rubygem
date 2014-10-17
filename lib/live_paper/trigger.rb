require_relative 'base_object'

module LivePaper
  class Trigger < BaseObject
    attr_accessor :watermark, :subscription
    WATERMARK_RESOLUTION = 75
    WATERMARK_STRENGTH = 10
    SUBSCRIPTION = {
      week: 1.week,
      twoweeks: 2.week,
      month: 1.month,
      quarter: 3.months,
      halfyear: 6.months,
      year: 1.year
    }
    DEFAULT_SUBSCRIPTION = (Rails.env == 'production') ? :month : :month
    DOWNLOAD_URL = "#{LPP_DOWNLOAD_HOST}/watermark/v1/triggers"

    def parse(data)
      data = JSON.parse(data, symbolize_names: true)[:trigger]
      assign_attributes data
      self
    end

    def self.api_url
      "#{LPP_API_HOST}/api/v1/triggers"
    end

    def download_watermark
      Trigger.request_handling_auth("#{DOWNLOAD_URL}/#{@id}/image", 'GET') do |request|
        response = Trigger.send_request(request)
        response.body.present? ? response.body : nil
      end
    end

    private
    def validate_attributes!
      raise ArgumentError, 'Required Attributes needed: name and watermark.' unless all_present? [@name, @watermark]
      raise ArgumentError, 'Required Attributes needed: watermark[:strength] and watermark[:imageURL].' unless all_keys_present? @watermark, [:strength, :imageURL]
    end

    def create_body
      {
        trigger: {
          name: @name,
          watermark: {
            outputImageFormat: 'JPEG',
            resolution: WATERMARK_RESOLUTION,
            strength: @watermark[:strength],
            imageURL: @watermark[:imageURL]
          },
          subscription: {
            package: DEFAULT_SUBSCRIPTION.to_s
          }
        }
      }
    end

  end
end
