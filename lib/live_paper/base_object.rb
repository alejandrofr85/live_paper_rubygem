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
        response = BaseObject.send_request(request, content_type: 'application/json', body: create_body.to_json)
        parse(response.body)
      end unless present? @id
      self
    end

    def self.get(id)
      request_handling_auth("#{api_url}/#{id}", 'GET') do |request|
        response = send_request(request, content_type: 'application/json')
        parse response.body
      end rescue nil
    end

    def self.list
      objects=[]
      request_handling_auth("#{api_url}", 'GET') do |request|
        response = send_request(request, content_type: 'application/json')
        JSON.parse(response.body, symbolize_names: true)[list_key].each do |linkdata|
          objects << self.parse({item_key => linkdata}.to_json)
        end
      end #rescue nil
      objects
    end

    def update
      response_code = 'Object Invalid'
      if self.id
        BaseObject.request_handling_auth("#{self.class.api_url}/#{id}", 'PUT') do |request|
          response = BaseObject.send_request(request,
                                             content_type: 'application/json',
                                             body: update_body.to_json,
                                             allow_codes: [200, 400, 404, 409])
          response_code = case response.code.to_i
            when 200
              parse(response.body)
              'OK'
            when 400
              @errors=response.body
              'Bad Request'
            when 409
              @errors=response.body
              'Conflict'
            else
              'Object Invalid'
          end
        end
      end
      response_code
    end

    def delete
      response_code = nil
      if self.id
        BaseObject.request_handling_auth("#{self.class.api_url}/#{id}", 'DELETE') do |request|
          response = BaseObject.send_request(request, content_type: 'application/json', allow_codes: [200, 204, 409])
          response_code = case response.code.to_i
            when 200
              'OK'
            when 204
              'OK'
            when 409
              @errors=response.body
              'Conflict'
          end
        end
      else
        response_code = "Object Invalid"
      end
      response_code
    end

    def errors
      begin
        JSON.parse(@errors)
      rescue
        @errors
      end
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

    def self.list_key
      raise NotImplementedError
    end

    def self.item_key
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

    def update_body
      raise NotImplementedError
    end
  end
end
