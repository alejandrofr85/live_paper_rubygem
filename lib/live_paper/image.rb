require_relative 'base_object'
require 'rest-client'

module LivePaper
  class Image

    attr_accessor :url

    API_URL = 'https://storage.livepaperapi.com/objects/v2/projects/PROJECTID/files'

    def self.upload(image_uri, project_id=nil)
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
      if project_id.nil?
        BaseObject.request_project_id unless $project_id
        project_id = $project_id
      end
      begin
        response = RestClient.post API_URL.gsub(/PROJECTID/,project_id),
                                   image_bytes,
                                   authorization: "Bearer #{$lpp_access_token}",
                                   content_type: 'image/jpeg',
                                   accept: '*/*'
      rescue Exception => e
        puts e.message
      end
      response.headers[:location]

    end
  end
end
