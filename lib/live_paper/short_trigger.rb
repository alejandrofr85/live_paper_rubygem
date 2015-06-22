require_relative 'base_object'

module LivePaper
  class ShortTrigger < Trigger
    attr_accessor :short_url

    def parse(data)
      data = JSON.parse(data, symbolize_names: true)[:trigger]
      assign_attributes data
      self.short_url=data[:link].select { |item| item[:rel] == "shortURL" }.first[:href]
      self
    end

    private
    def create_body
      {
        trigger: {
          name: @name,
          type: "shorturl",
          startDate: @start_date || default_start_date,
          endDate: @end_date || default_end_date
        }
      }
    end
  end
end
