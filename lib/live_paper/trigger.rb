require_relative 'base_object'

module LivePaper
  class Trigger < BaseObject
    attr_accessor :subscription, :state

    def self.api_url
      "#{LP_API_HOST}/api/v1/triggers"
    end

    def self.item_key
      :trigger
    end

    def self.list_key
      :triggers
    end

    def self.parse(data_in)
      data = JSON.parse(data_in, symbolize_names: true)[item_key]
      trigger_class = case data[:type]
        when "shorturl"
          ShortTrigger
        when "qrcode"
          QrTrigger
        when "watermark"
          WmTrigger
        else
          raise "UnsupportedTriggerType"
      end
      trigger_class.new.parse(data_in)
    end

    private
    def validate_attributes!
      raise ArgumentError, 'Required Attributes needed: name' unless all_present? [@name]
    end
 
    def update_body
      {
        trigger: {
          name: @name
        }
      }
    end
  end

end