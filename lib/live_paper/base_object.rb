require_relative 'http_client'
require 'json'

module LivePaper
  class BaseObject
    extend HttpClient
    attr_accessor :id, :name, :date_created, :date_modified

    def assign_attributes(data)
      data.each do |key, value|
        method = "#{key.to_s.underscore}="
        public_send(method, value) if respond_to?(method)
      end if data.present?
    end

    def initialize(data={})
      assign_attributes data
    end

    def self.create(data)
      self.new(data).save
    end

    def save
      validate_attributes!
      BaseObject.request_handling_auth(self.class.api_url, 'POST') do |request|
        response = BaseObject.send_request(request, 'application/json', create_body.to_json)
        parse(response.body)
      end unless @id.present?
      self
    end

    def self.find(id)
      request_handling_auth("#{api_url}/#{id}", 'GET') do |request|
        response = send_request(request, 'application/json')
        parse response.body
      end rescue nil
    end

    def self.parse(data)
      self.new().parse(data)
    end

    def parse(data)
      raise NotImplementedError
    end

    def self.api_url
      raise NotImplementedError
    end

    protected
    def all_present?(array)
      array.all? { |e| e.present? } rescue false
    end

    def all_keys_present?(hash, keys)
      keys.all? { |e| hash[e].present? } rescue false
    end

    private
    def validate_attributes!
      raise NotImplementedError
    end

    def create_body
      raise NotImplementedError
    end
  end
end