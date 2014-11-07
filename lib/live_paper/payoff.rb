require_relative 'base_object'

module LivePaper
  class Payoff < BaseObject
    attr_accessor :type, :url, :data_type, :data

    TYPE = {
      WEB: 'WEB_PAYOFF',
      RICH: 'RICH_PAYOFF'
    }

    def parse(data)
      data = JSON.parse(data, symbolize_names: true)[self.class.item_key]
      assign_attributes(data)
      send(present?(data[:richPayoff]) ? :parse_richpayoff : :parse_webpayoff, data)
      self
    end

    def self.list_key
      :payoffs
    end

    def self.item_key
      :payoff
    end

    def self.api_url
      "#{LP_API_HOST}/api/v1/payoffs"
    end

    private
    def validate_attributes!
      raise ArgumentError, 'Required Attributes needed: name, type, url.' unless all_present? [@name, @type, @url]
      raise ArgumentError, 'Required Attributes needed: data_type, data.' if @type == TYPE[:RICH] and !all_present? [@data_type, @data]
    end

    def parse_richpayoff(data)
      data = data[:richPayoff]

      @type = TYPE[:RICH]
      @url = data[:public][:url]
      @data_type = data[:private][:'content-type']
      @data = JSON.parse(Base64.decode64(data[:private][:data]), symbolize_names: true) rescue nil
    end

    def parse_webpayoff(data)
      @type = TYPE[:WEB]
      @url = data[:URL]
    end

    def update_body
      create_body
    end

    def create_body
      {
        payoff: case @type
          when TYPE[:WEB]
            create_webpayoff_body
          when TYPE[:RICH]
            create_richpayoff_body
          else
            raise ArgumentError, 'Type unknown.'
        end
      }
    end

    def create_webpayoff_body
      {
        name: @name,
        URL: @url
      }
    end

    def create_richpayoff_body
      {
        name: @name,
        richPayoff: {
          version: 1,
          private: {
            :'content-type' => @data_type,
            :data => Base64.encode64(@data.to_json)
          },
          public: {url: @url}
        }
      }
    end

  end
end
