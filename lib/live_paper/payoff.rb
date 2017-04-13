require_relative 'base_object'

module LivePaper
  class Payoff < BaseObject
    attr_accessor :type, :url, :data

    TYPE = {
      WEB: 'url',
      RICH: 'richpayoff',
      CUSTOM_DATA: 'customData'
    }

    def parse(data)
      data = JSON.parse(data, symbolize_names: true)[self.class.item_key]
      assign_attributes(data)
      if present?(data[:richPayoff])
        method = :parse_richpayoff
      elsif data[:type] == TYPE[:CUSTOM_DATA]
        method = :parse_customdata_payoff
      else
        method = :parse_webpayoff
      end
      send(method, data)
      self
    end

    def self.list_key
      :payoffs
    end

    def self.item_key
      :payoff
    end

    def self.api_url project_id=nil
      project_id = $project_id if project_id.nil?
      "#{LivePaper::Configuration.lpp_api_host}/api/v2/projects/#{project_id}/payoffs"
    end

    private
    def validate_attributes!
      raise ArgumentError, 'Required Attributes needed: name, type' unless all_present? [@name, @type]
      raise ArgumentError, 'Required Attribute needed: url.' if @type == TYPE[:WEB] and !present? @url
      raise ArgumentError, 'Required Attribute needed: data.' if @type == TYPE[:RICH] and !present? @data
    end

    def parse_richpayoff(data)
      rich_data = data[:richPayoff]
      @type = data[:type]
      @url = rich_data[:public][:url]
      @data = JSON.parse(Base64.decode64(rich_data[:private][:data]), symbolize_names: true) rescue nil
    end

    def parse_customdata_payoff(data)
      @type = data[:type]
      @url = data[:public][:url]
      @name = data[:name]
      @data = data[:privateData][:data]
    end

    def parse_webpayoff(data)
      @type = data[:type]
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
          when TYPE[:CUSTOM_DATA]
            create_customdata_payoff_body
          else
            raise ArgumentError, 'Type unknown.'
        end
      }
    end

    def create_webpayoff_body
      {
        name: @name,
        type: TYPE[:WEB],
        url: @url
      }
    end

    def create_customdata_payoff_body
      {
        name: @name,
        version: "2.0",
        type: TYPE[:CUSTOM_DATA],
        public: {
          url: @url
        },
        privateData:{
          data: @data
        }
      }
    end

    def create_richpayoff_body
      {
        name: @name,
        type: TYPE[:RICH],
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
