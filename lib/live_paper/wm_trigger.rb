require_relative 'base_object'

module LivePaper
  class WmTrigger < Trigger
    attr_accessor :watermark, :wm_url
    WATERMARK_RESOLUTION = 75
    WATERMARK_STRENGTH = 10
    DEFAULT_SUBSCRIPTION = :month

    def parse(data)
      data = JSON.parse(data, symbolize_names: true)[:trigger]
      assign_attributes data
      self.wm_url=data[:link].select { |item| item[:rel] == "image" }.first[:href]
      self
    end

    def download_watermark
      response = WmTrigger.rest_request( self.wm_url, :get, accept: "image/jpg" )
      response.body.empty? ? nil : response.body
    rescue Exception => e
      puts 'Exception!\n'
      puts e.response
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
