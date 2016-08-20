require_relative 'base_object'

module LivePaper
  class Payoff < BaseObject
    attr_accessor :type, :url, :data

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
      "#{LivePaper::Configuration.lpp_api_host}/api/v2/projects/#{$project_id}/payoffs"
    end

    private
    def validate_attributes!
      raise ArgumentError, 'Required Attributes needed: name, type' unless all_present? [@name, @type]
      raise ArgumentError, 'Required Attribute needed: url.' if @type == TYPE[:WEB] and !present? @url
      raise ArgumentError, 'Required Attribute needed: data.' if @type == TYPE[:RICH] and !present? @data
    end

    def parse_richpayoff(data)
      data = data[:richPayoff]
      @type = TYPE[:RICH]
      @url = data[:public][:url]
      @data = JSON.parse(Base64.decode64(data[:private][:data]), symbolize_names: true) rescue nil
    end

    def parse_webpayoff(data)
      @type = TYPE[:WEB]
      @url = data[:url]
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
        type: 'url',
        url: @url
      }
    end

    def create_richpayoff_body
      {
        name: @name,
        type: 'richPayoff',
        richPayoff: {
          version: 1,
          private: {
            :'content-type' => 'custom-base64',
            :data => Base64.encode64(@data.to_json)
          },
          public: {url: @url}
        }
      }
    end

  end
end
