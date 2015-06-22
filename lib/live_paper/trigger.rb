require_relative 'base_object'
require 'active_support/time'

module LivePaper
  class Trigger < BaseObject
    attr_accessor :state, :start_date, :end_date

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

    def default_start_date
      Time.now.iso8601
      "2014-10-08T20:40:26.376+0000"
    end

    def default_end_date
      Time.now.advance(years: 1).iso8601
      "2015-10-09T02:29:12.376+0000"
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