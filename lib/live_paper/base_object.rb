require_relative 'http_client'
require 'json'

module LivePaper
  class BaseObject
    extend HttpClient
    attr_accessor :id, :name, :date_created, :date_modified, :link

    def assign_attributes(data)
      data.each do |key, value|
        method = "#{underscore key.to_s}="
        public_send(method, value) if respond_to?(method)
      end unless data.empty?
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
      end unless present? @id
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

    def rel(key)
      link.find { |obj| obj[:rel] == key }[:href] rescue nil
    end

    protected
    def all_present?(array)
      array.all? { |e| present? e } rescue false
    end

    def all_keys_present?(hash, keys)
      keys.all? { |e| present? hash[e] } rescue false
    end

    def present?(obj)
      !(obj.respond_to?(:empty?) ? obj.empty? : !obj)
    end

    def underscore(camel_cased_word)
      camel_cased_word.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
        gsub(/([a-z\d])([A-Z])/, '\1_\2').
        tr("-", "_").
        downcase
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