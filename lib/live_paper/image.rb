require_relative 'http_client'
require_relative 'loggable'
require 'mini_magick'

module LivePaper
  class Image < Loggable
    extend HttpClient
    attr_accessor :original_url, :storage_url

    STORAGE_URL="#{LPP_STORAGE_HOST}/objects/files"

    def initialize(image_path)
      super()
      @original_url = image_path
      @image_data = MiniMagick::Image.open @original_url
    end

    def upload_image
      Image.request_handling_auth(STORAGE_URL, 'POST') do |request|
        response = Image.send_request(request, 'image/jpg', to_blob)
        @storage_url = response.header['location']
      end
    end

    def histogram_compression(strength)
      shift = histogram_compression_shift strength
      @image_data.level "#{shift[:bps]}%,#{shift[:wps]}%!"
    end

    def width
      @image_data[:width].to_i
    end

    def height
      @image_data[:height].to_i
    end

    def density(density)
      @image_data.density density
    end

    def format(format)
      @image_data.format format
    end

    def resize(width, height)
      if need_resize?(width, height)
        width = self.width * height.to_i / self.height unless width.present?
        height = self.height * width.to_i / self.width unless height.present?
        @image_data.resize "#{width}x#{height}!"
      end
    end

    def to_blob
      @image_data.to_blob
    end

    def to_log
      [:histogram_compression, :density, :format, :resize, :histogram_compression_shift]
    end

    private
    def need_resize?(width, height)
      (width.present? and width.to_i != self.width) or (height.present? and height.to_i != self.height)
    end

    def histogram_compression_shift(strength)
      case strength
        when 1 then
          {bps: 1.6, wps: 98.4}
        when 2 then
          {bps: 2.0, wps: 98.0}
        when 3 then
          {bps: 2.4, wps: 97.6}
        when 4 then
          {bps: 2.8, wps: 97.2}
        when 5 then
          {bps: 3.2, wps: 96.8}
        when 6 then
          {bps: 3.5, wps: 96.5}
        when 7 then
          {bps: 3.9, wps: 96.1}
        when 8 then
          {bps: 6.3, wps: 94.1}
        when 9 then
          {bps: 7.4, wps: 92.6}
        else
          {bps: 8.6, wps: 92.2}
      end
    end
  end
end