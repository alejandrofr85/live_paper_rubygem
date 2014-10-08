require "live_paper/*"
require 'base64'
require 'rest-client'

module LivePaper

  LP_API_HOST="https://www.livepaperapi.com"

  def self.auth(auth_hash)
    LivePaperSession.new(auth_hash)
  end

  class LivePaperSession
    def initialize(auth)
      authorize(auth)
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
      #returns shortened url
      trig = trigger "shorturl"
      payoff = url_payoff dest
      link(trig, payoff)

      trig["link"].select { |item| item["rel"] == "shortURL" }.first["href"]
    end

    def qr_bytes(dest)
      #returns shortened url
      trig = trigger "qrcode"
      payoff = url_payoff dest
      link(trig, payoff)

      img_loc = trig["link"].select { |item| item["rel"] == "image" }.first["href"]
      resp = RestClient.get(img_loc, {Authorization: api_headers[:Authorization], Accept: 'image/png'})
      resp.body
    end

    def watermark_bytes(dest, image_url)
      image = upload_image image_url

      trig = trigger "watermark", watermark: {imageURL: image, resolution: "75", strength: "10"}
      payoff = url_payoff dest
      link(trig, payoff)

      img_loc = trig["link"].select { |item| item["rel"] == "image" }.first["href"]
      resp = RestClient.get(img_loc, Authorization: api_headers[:Authorization])
      resp.body
    rescue Exception => e
      puts "Exception!"
      puts e.response
    end

    private
    def upload_image(img)
      uri='https://storage.livepaperapi.com/objects/v1/files'
      # return the original img uri if it is LPP storage
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

    def trigger(type="shorturl", options={})
      body = {
          trigger: {
              name: "trigger",
              type: type,
              expiryDate: Time.now + (365 * 24 * 60 * 60)
          }.merge(options)
      }
      create_resource('trigger', body)
    end

    def url_payoff(dest)
      body = {
          payoff: {
              name: "payoff",
              URL: dest
          }
      }
      create_resource('payoff', body)
    end

    def link(trigger, payoff)
      body = {
          link: {
              name: "link",
              payoffId: payoff["id"],
              triggerId: trigger["id"]
          }
      }
      create_resource('link', body)
    end

    def authorize(auth)
      uri = "#{LP_API_HOST}/auth/token"
      body = "grant_type=client_credentials&scope=all"

      basic_auth = Base64.strict_encode64("#{auth[:id]}:#{auth[:secret]}")

      begin
        response = RestClient.post uri, body,
                                   :content_type => 'application/x-www-form-urlencoded',
                                   Accept: 'application/json',
                                   Authorization: "Basic #{basic_auth}"
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

    def create_resource(resource, body)
      uri= "https://www.livepaperapi.com/api/v1/#{resource}s"
      response = RestClient.post uri, body.to_json, api_headers
      JSON.parse(response.body)[resource]
    rescue Exception => e
      puts "Exception!"
      puts e.response
      nil
    end

  end

end
