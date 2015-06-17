require "live_paper/base_object"
require "live_paper/image"
require "live_paper/link"
require "live_paper/payoff"
require "live_paper/trigger"
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
      $lpp_basic_auth = Base64.strict_encode64("#{auth[:id]}:#{auth[:secret]}")
      @remote_resources={}
    end

    def resources
      @remote_resources
    end

    def smart_link(dest, image=nil)
      uber = {}
      uber[:short] = shorten dest

      qr_data = qr_bytes dest
      File.open("uber-qr.png", "wb") { |f| f.write(qr_data) }
      uber[:qr] = "./uber-qr.png"

      if image
        wm_bytes = watermark_bytes(dest, image)
        File.open("uber-wm.jpg", "wb") { |f| f.write(wm_bytes) }
        uber[:wm] = 'uber-wm.jpg'
      end
      uber
    end

    def shorten(dest)
      t=ShortTrigger.create(name: 'short trigger')
      p=Payoff.create(name: 'name', type: Payoff::TYPE[:WEB], url: dest)
      l=Link.create(payoff_id: p.id, trigger_id: t.id, name: "link")
      @remote_resources={link: l, payoff: p, trigger: t}
      t.short_url
    end

    def qr_bytes(dest)
      t=QrTrigger.create(name: 'QR code trigger')
      p=Payoff.create(name: 'name', type: Payoff::TYPE[:WEB], url: dest)
      l=Link.create(payoff_id: p.id, trigger_id: t.id, name: "link")
      @remote_resources={link: l, payoff: p, trigger: t}
      t.download_qrcode
    end

    def watermark_bytes(dest, image_uri)
      image = Image.upload image_uri

      t=WmTrigger.create(name: 'watermark')
      p=Payoff.create(name: 'name', type: Payoff::TYPE[:WEB], url: dest)
      l=Link.create(payoff_id: p.id, trigger_id: t.id, name: "link")
      @remote_resources={link: l, payoff: p, trigger: t}
      t.download_watermark(image)
    rescue Exception => e
      puts "Exception!"
      puts e.response
    end

  end
end
