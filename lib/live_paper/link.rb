require_relative 'base_object'

module LivePaper
  class Link < BaseObject
    attr_accessor :payoff_id, :trigger_id

    def parse(jsondata)
      puts "parsing data and it is #{jsondata}"
      data = JSON.parse(jsondata, symbolize_names: true)[self.class.item_key]
      assign_attributes data
      self
    end

    def payoff
      @payoff ||= LivePaper::Payoff.get @payoff_id
    end

    def trigger
      #todo: need to get the right object created here!!!
      @trigger ||= LivePaper::WmTrigger.get @trigger_id
    end

    def self.api_url
      "#{LP_API_HOST}/api/v1/links"
    end

    def self.list_key
      :links
    end

    def self.item_key
      :link
    end

    private
    def validate_attributes!
      raise ArgumentError, 'Required Attributes needed: name, payoff_id and trigger_id.' unless all_present? [@name, @payoff_id, @trigger_id]
    end

    def create_body
      {
        link: {
          name: @name,
          triggerId: @trigger_id,
          payoffId: @payoff_id
        }
      }
    end

    def update_body
      {
        link: {
          name: @name
        }
      }
    end

  end
end