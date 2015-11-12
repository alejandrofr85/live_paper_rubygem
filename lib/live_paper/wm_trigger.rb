require_relative 'base_object'
require 'mini_magick'

module LivePaper
  class WmTrigger < Trigger
    attr_accessor :wm_url
    WATERMARK_RESOLUTION = 75
    WATERMARK_STRENGTH = 10
    DEFAULT_IMAGE_RESOLUTION = 72

    def parse(data)
      data = JSON.parse(data, symbolize_names: true)[:trigger]
      assign_attributes data
      self.wm_url=data[:link].select { |item| item[:rel] == "download" }.first[:href]
      self
    end

    def download_watermark(image_url, options = {})
      wpi = options[:wpi] || WATERMARK_RESOLUTION
      strength = options[:strength] || WATERMARK_STRENGTH
      ppi = options[:ppi]
      if ppi.blank?
        image = MiniMagick::Image.open(image_url + "?access_token=" + $lpp_access_token)
        ppiArray = image.resolution("PixelsPerInch") #This returns the [xResolution, yResolution]
        ppi = ppiArray[0] if (ppiArray.present? && ppiArray.length > 0)
      end
      if ppi.blank?
        ppi = DEFAULT_IMAGE_RESOLUTION
      end
      
      url = "#{self.wm_url}?imageURL=#{CGI.escape(image_url)}&wpi=#{wpi}&ppi=#{ppi}&strength=#{strength}"
      begin
        response = WmTrigger.rest_request( url, :get, accept: "image/jpg" )
        response.body.empty? ? nil : response.body
      rescue Exception => e
        puts "Exception : #{e.to_s}\n"
      end
    end

    private
    def create_body
      {
        trigger: {
          name: @name,
          type: "watermark",
          startDate: @start_date || default_start_date,
          endDate: @end_date || default_end_date
        }
      }
    end

  end
end
