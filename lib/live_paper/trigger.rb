require_relative 'base_object'
require 'active_support/all'

module LivePaper
  class Trigger < BaseObject
    attr_accessor :state, :start_date, :end_date

    def self.api_url project_id=nil
      project_id = $project_id if project_id.nil?
      "#{LivePaper::Configuration.lpp_api_host}/api/v2/projects/#{project_id}/triggers"
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
      Time.now.to_s(:live_paper_date_format)
    end

    def default_end_date
      Time.now.advance(years: 1).to_s(:live_paper_date_format)
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
