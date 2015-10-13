require_relative 'base_object'

module LivePaper
  class WmTrigger < Trigger
    attr_accessor :wm_url
    WATERMARK_RESOLUTION = 75
    WATERMARK_STRENGTH = 10
    ADJUST_IMAGE_LEVELS = false

    def parse(data)
      data = JSON.parse(data, symbolize_names: true)[:trigger]
      assign_attributes data
      self.wm_url=data[:link].select { |item| item[:rel] == "image" }.first[:href]
      self
    end

    def download_watermark(image_url, options = {})
      resolution = options[:resolution] || WATERMARK_RESOLUTION
      strength = options[:strength] || WATERMARK_STRENGTH
      adjustImageLevels = (options[:adjustImageLevels].nil? ? ADJUST_IMAGE_LEVELS : options[:adjustImageLevels])
      url = "#{self.wm_url}?imageUrl=#{CGI.escape(image_url)}&resolution=#{resolution}&strength=#{strength}&adjustImageLevels=#{adjustImageLevels}"
      puts "URL=#{url}" if (!options[:showUrl].nil?)
      begin
        response = WmTrigger.rest_request( url, :get, accept: "image/jpg" )
        response.body.empty? ? nil : response.body
      rescue Exception => e
        puts 'Exception!\n'
        puts e.response
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
