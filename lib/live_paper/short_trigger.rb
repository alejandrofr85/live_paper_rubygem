require_relative 'base_object'

module LivePaper
  class ShortTrigger < Trigger
    attr_accessor :subscription, :short_url

    DEFAULT_SUBSCRIPTION = :month

    def parse(data)
      data = JSON.parse(data, symbolize_names: true)[:trigger]
      assign_attributes data
      self.short_url=data[:link].select { |item| item[:rel] == "shortURL" }.first[:href]
      self
    end

    private
    def validate_attributes!
      raise ArgumentError, 'Required Attributes needed: name' unless all_present? [@name]
    end

    def create_body
      {
        trigger: {
          name: @name,
          type: "shorturl",
          subscription: {
            package: DEFAULT_SUBSCRIPTION.to_s
          }
        }
      }
    end
  end
end
