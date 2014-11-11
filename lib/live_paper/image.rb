require_relative 'base_object'
require 'rest-client'

module LivePaper
  class Image
    extend HttpClient

    attr_accessor :url

    API_URL = 'https://storage.livepaperapi.com/objects/v1/files'

    def self.upload(img)
      # return the original img uri if it is LivePaper storage
      if img.include? API_URL
        return img
      end
      begin
        src_image = RestClient.get(img, Accept: 'image/jpg')
        request_access_token unless @access_token
        response = RestClient.post API_URL,
                                   src_image.body,
                                   Authorization: "Bearer #{@access_token}",
                                   content_type: 'image/jpg'
        response.headers[:location]
      rescue Exception => e
        puts "Exception! ******\n#{e}"
        img
      end
    end

  end
end
