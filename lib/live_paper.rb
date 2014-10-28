require "live_paper/base_object"
require "live_paper/http_client"
require "live_paper/link"
require "live_paper/payoff"
require "live_paper/wm_trigger"
require "live_paper/qr_trigger"
require "live_paper/short_trigger"
require "live_paper/version"
require 'base64'
require 'rest-client'
require 'json'

module LivePaper

  LP_API_HOST="https://www.livepaperapi.com"

  def self.auth(auth_hash)
    LivePaperSession.new(auth_hash)
  end

  class LivePaperSession
    def initialize(auth)
      #todo: tdd, verify hash
      puts auth.to_yaml
      $lpp_basic_auth = Base64.strict_encode64("#{auth[:id]}:#{auth[:secret]}")
      authorize #reqd for image_upload still
    end

    def say_hi
      "hello"
    end

    def smart_link(dest, image=nil)
      uber = {}
      uber[:short] = shorten dest

      qr_data = qr_bytes dest
      File.open("uber-qr.png", "w") { |f| f.write(qr_data) }
      uber[:qr] = "./uber-qr.png"

      if image
        wm_bytes = watermark_bytes(dest, image)
        File.open("uber-wm.jpg", "w") { |f| f.write(wm_bytes) }
        uber[:wm] = 'uber-wm.jpg'
      end
      uber
    end

    def shorten(dest)
      t=ShortTrigger.create(name:'short trigger')
      p=Payoff.create(name: 'name', type: Payoff::TYPE[:WEB], url: dest)
      Link.create(payoff_id: p.id, trigger_id: t.id, name: "link")
      t.short_url
    end

    def qr_bytes(dest)
      t=QrTrigger.create(name:'QR code trigger')
      p=Payoff.create(name: 'name', type: Payoff::TYPE[:WEB], url: dest)
      Link.create(payoff_id: p.id, trigger_id: t.id, name: "link")
      t.download_qrcode
    end

    def watermark_bytes(dest, image_url)
      image = upload_image image_url

      t=WmTrigger.create(name: 'watermark', watermark: {strength: 10, resolution: 75, imageURL: image})
      p=Payoff.create(name: 'name', type: Payoff::TYPE[:WEB], url: dest)
      Link.create(payoff_id: p.id, trigger_id: t.id, name: "link")
      t.download_watermark
    rescue Exception => e
      puts "Exception!"
      puts e.response
    end

    private
    def upload_image(img)
      uri='https://storage.livepaperapi.com/objects/v1/files'
      # return the original img uri if it is LivePaper storage
      if img.include? uri
        return img
      end
      begin
        src_image = RestClient.get(img, Accept: 'image/jpg')
        response = RestClient.post uri,
                                   src_image.body,
                                   Authorization: api_headers[:Authorization],
                                   content_type: 'image/jpg'
        response.headers[:location]
      rescue Exception => e
        puts "Exception! ******\n#{e}"
        img
      end
    end

    def authorize
      uri = "#{LP_API_HOST}/auth/token"
      body = "grant_type=client_credentials&scope=all"

      begin
        response = RestClient.post uri, body,
                                   :content_type => 'application/x-www-form-urlencoded',
                                   Accept: 'application/json',
                                   Authorization: "Basic #{$lpp_basic_auth}"
      rescue Exception => e
        puts "Exception!"
        puts e.response
      end

      body = JSON.parse(response.body)
      @token=body["accessToken"]
    end

    def api_headers
      {Authorization: "Bearer #{@token}",
       content_type: 'application/json',
       Accept: 'application/json'
      }
    end
  end
end
