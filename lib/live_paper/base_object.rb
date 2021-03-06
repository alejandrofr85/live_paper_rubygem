require 'json'
# require_relative 'configuration'

class NotAuthenticatedError < Exception
end

module LivePaper
  class BaseObject

    attr_accessor :project_id
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
      unless present? @id
        response = BaseObject.rest_request( self.class.api_url(self.project_id), :post, body: create_body.to_json )
        parse(response.body)
      end
      self
    end

    def self.get(id, project_id=nil)
      project_id = $project_id if project_id.nil?
      response = rest_request( "#{api_url(project_id)}/#{id}", :get )
      case response.code
        when 200
          parse response.body
        else #when 404
          nil
      end
    end

    def self.list(project_id=nil)
      objects=[]
      project_id = $project_id if project_id.nil?
      response = rest_request( api_url(project_id), :get )
      JSON.parse(response.body, symbolize_names: true)[list_key].each do |linkdata|
        objects << self.parse({item_key => linkdata}.to_json)
      end
      objects
    end

    def update
      response_code = 'Object Invalid'
      if self.id
        response = BaseObject.rest_request( "#{self.class.api_url(self.project_id)}/#{id}", :put, body: update_body.to_json )
        response_code = case response.code
          when 200
            parse(response.body)
            '200 OK'
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
      response_code
    end

    def delete
      if self.id
        response = BaseObject.rest_request( "#{self.class.api_url(self.project_id)}/#{id}", :delete )
        response_code = case response.code
          when 200
            '200 OK'
          when 409
            @errors=response.body
            'Conflict'
          else
            'unknown'
        end
      else
        response_code = "Object Invalid"
      end
      response_code
    end

    def self.rest_request(url, method, options={})
      tries = 0
      verb = (method||"get").downcase.to_sym
      raise "Method '#{verb}' not supported." unless [:get, :post, :put, :delete].include?(verb)

      request_access_token unless $lpp_access_token
      request_project_id unless $project_id
      headers = {}
      headers[:authorization] = "Bearer #{$lpp_access_token}"
      headers[:accept] = options[:accept] || "application/json"
      headers[:"X-user-info"] = 'app=rubygem'
      headers[:content_type] = 'application/json' unless options[:body].nil?

      h = {:method => verb, :url => url.to_s, :headers => headers}
      h.merge!({:payload => options[:body]}) unless options[:body].nil?

      begin
        response = RestClient::Request.execute(h) { |response, request, result| response }
        raise NotAuthenticatedError if response.code == 401
      rescue NotAuthenticatedError => e
        tries += 1
        if tries < 3
          request_access_token
          request_project_id
          headers[:authorization] = "Bearer #{$lpp_access_token}"
          retry
        else
          raise e
        end
      end
      response
    end

    def self.request_access_token
      h = { method: :post,
            url: LivePaper::Configuration.auth_url,
            headers: { authorization: "Basic #{$lpp_basic_auth}",
                       content_type: 'application/x-www-form-urlencoded',
                       accept: 'application/json' },
            payload: 'grant_type=client_credentials&scope=all'
          }

      response = RestClient::Request.execute(h) { |response, request, result| response }

      parsed = JSON.parse(response.body)
      @access_token = parsed['accessToken']
      $lpp_access_token = @access_token
    end

    def self.request_project_id
      project = nil

      RestClient.proxy = ENV['HTTP_PROXY'] || ENV['http_proxy']
      request = {}.to_json
      res = RestClient.post LivePaper::Configuration.auth_validation_url, request, { :Authorization => "Bearer #{$lpp_access_token}", :Accept => 'application/json'}
      @project = res.headers[:project_id]

      if @project.nil?
        raise "Project id not in response header"
      end

      $project_id = @project
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

    def self.api_url project_id=nil
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
