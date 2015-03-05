require_relative 'base_object'
require 'rest-client'

module LivePaper
  class Image

    attr_accessor :url

    API_URL = 'https://storage.livepaperapi.com/objects/v1/files'

    def self.upload(image_uri)
      # return the original img uri if it is LivePaper storage
      if image_uri.include? API_URL
        return image_uri
      end
      image_bytes = case
        when image_uri.include?('http://') || image_uri.include?('https://')
          RestClient.get(image_uri, Accept: 'image/jpg').body
        else
          File.binread(image_uri)
      end

      BaseObject.request_access_token unless $lpp_access_token
      response = RestClient.post API_URL,
                                 image_bytes,
                                 authorization: "Bearer #{$lpp_access_token}",
                                 content_type: 'image/jpg'
      response.headers[:location]

    end
  end
end
