require_relative 'base_object'

module LivePaper
  class QrTrigger < Trigger
    attr_accessor :qrcode_url

    def parse(data)
      data = JSON.parse(data, symbolize_names: true)[:trigger]
      assign_attributes data
      self.qrcode_url=data[:link].select { |item| item[:rel] == "download" }.first[:href]
      self
    end

    def download_qrcode
      response = QrTrigger.rest_request( "#{self.qrcode_url}?width=200", :get, accept: "image/jpg" )
      response.body.empty? ? nil : response.body
    end

    private
    def create_body
      {
        trigger: {
          name: @name,
          type: "qrcode",
          startDate: @start_date || default_start_date,
          endDate: @end_date || default_end_date
        }
      }
    end
  end
end
