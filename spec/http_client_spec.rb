require 'spec_helper'

module LivePaper
  class DummyHTTP
    include HttpClient
  end
end

describe LivePaper::HttpClient do
  before do
    @http_client = LivePaper::DummyHTTP.new
    stub_request(:post, /.*livepaperapi.com\/auth\/token.*/).to_return(:body => lpp_auth_response_json, :status => 200)
  end

  describe '#send_request' do

    before(:each) do
      @http = double('Http mock')
      @http.stub(:request)
      @http_client.instance_variable_set(:@http, @http)
      @request = double('Request mock')
      @http_client.stub(:check_response)
    end

    it 'should add the content type to the request' do
      @request.should_receive(:[]=).with('Content-type', 'image/jpg')
      @request.stub(:body=)
      @http_client.send_request @request, 'image/jpg', 'body'
    end

    it 'should add the body to the request' do
      @request.should_receive(:body=).with('body')
      @request.stub(:[]=)
      @http_client.send(:send_request, @request, 'image/jpg', 'body')
    end

    it 'should call the request method from the http instance' do
      @request.stub(:body=)
      @request.stub(:[]=)
      @http.should_receive(:request)
      @http_client.send(:send_request, @request, 'image/jpg', 'body')
    end

    it 'should check the response' do
      @request.stub(:body=)
      @request.stub(:[]=)
      @http_client.should_receive(:check_response)
      @http_client.send(:send_request, @request, 'image/jpg', 'body')
    end
  end

  describe 'check_response' do

    before(:each) do
      @response = double('A mock for a response')
      @response.stub(:body)
    end

    it 'should raise NotAuthenticatedError if the response code is 401' do
      @response.stub(:code).and_return('401')
      expect { @http_client.send(:check_response, @response) }.to raise_error NotAuthenticatedError
    end

    it 'should not raise any exception if the response code is 200..201' do
      @response.stub(:code).and_return('201')
      expect { @http_client.send(:check_response, @response) }.to_not raise_error
    end

    it 'should raise exception if the response code is other than 200..201|401' do
      @response.stub(:code).and_return('500')
      expect { @http_client.send(:check_response, @response) }.to raise_error
    end
  end

  describe 'request_handling_auth' do

    before(:each) do
      @url = 'https://dev.livepaperapi.com/auth/token'
    end

    context 'when there is no access token' do

      before(:each) do
        @http_client.instance_variable_set(:@access_token, nil)
      end

      it 'should request the access token' do
        @http_client.should_receive(:request_access_token)
        @http_client.send(:request_handling_auth, @url, "POST") { |request|}
      end
    end

    context 'when there is access token' do

      before(:each) do
        @http_client.instance_variable_set(:@access_token, 'TOPSECRET')
      end

      it 'should yield the given block' do
        a_mock = double('Some mock')
        a_mock.should_receive(:a_message)
        @http_client.send(:request_handling_auth, @url, 'POST') do |request|
          a_mock.a_message
        end
      end

      context 'when the access token is invalid' do

        before(:each) do
          @http_client.instance_variable_set(:@access_token, 'INVALID')
        end

        it 'should retry max 3 times' do
          a_mock = double('Some mock')
          a_mock.should_receive(:a_message).at_least(:twice).at_most(3).times
          begin
            @http_client.send(:request_handling_auth, @url, 'POST') do |request|
              a_mock.a_message
              raise NotAuthenticatedError.new
            end
          rescue NotAuthenticatedError => e
          end
        end

        it 'should raise exception if retried more than 3 times' do
          @http_client.stub(:request_access_token)
          expect {
            @http_client.send(:request_handling_auth, @url, 'POST') do |request|
              raise NotAuthenticatedError.new
            end
          }.to raise_error
        end
      end
    end
  end

  describe 'request_access_token' do

    it 'should parse the response getting the accessToken entry' do
      @http_client.send :request_access_token
      @http_client.instance_variable_get(:@access_token).should == 'SECRETTOKEN'
    end
  end

  describe 'http_request' do

    before do
      @host = 'https://dev.livepaperapi.com/auth/token'
      @http = double('Http mock')
      @http.stub(:verify_mode=)
      @http.stub(:use_ssl=)
    end
    it 'should create and return a Net::HTTP::Post instance if POST method is chosen.' do
      Net::HTTP::Post.should_receive(:new).and_call_original
      @http_client.send(:http_request, @host, 'POST')
    end

    it 'should create and return a Net::HTTP::Get instance if GET method is chosen.' do
      Net::HTTP::Get.should_receive(:new).and_call_original
      @http_client.send(:http_request, @host, 'GET')
    end

    it 'should use ssl' do
      Net::HTTP.stub(:new).and_return(@http)
      @http.should_receive(:use_ssl=)
      @http_client.send(:http_request, @host, 'POST')
    end

    it 'should handle proxy settings' do
      ENV['HTTP_PROXY'] = 'http://proxy.com:1234'
      Net::HTTP.should_receive(:new).with('dev.livepaperapi.com', 443, 'proxy.com', '1234').and_return(@http)
      @http_client.send(:http_request, @host, 'POST')
    end

    it 'should raise exception if the method provided is not supported.' do
      expect { @http_client.send(:http_request, @host, 'NOT_SUPPORTED') }.to raise_error
    end

  end

end