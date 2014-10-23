require_relative 'base_object'

module LivePaper
  class Link < BaseObject
    attr_accessor :payoff_id, :trigger_id, :analytics

    def parse(data)
      data = JSON.parse(data, symbolize_names: true)[:link]
      p data
      assign_attributes data
      @analytics = get_link_for data, 'analytics'
      self
    end

    def payoff
      @payoff ||= LivePaper::Payoff.find @payoff_id
    end

    def trigger
      @trigger ||= LivePaper::Trigger.find @trigger_id
    end

    def self.api_url
      "#{LP_API_HOST}/api/v1/links"
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

    def get_link_for(data, rel)
      data[:link].find { |obj| obj[:rel] == rel }[:href] rescue ''
    end
  end
end