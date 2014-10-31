require 'spec_helper'

DOWNLOAD_URL = "https://watermark.livepaperapi.com/watermark/v1/triggers"

describe LivePaper::WmTrigger do
  before do
    stub_request(:post, /.*livepaperapi.com\/auth\/token.*/).to_return(:body => lpp_auth_response_json, :status => 200)
    stub_request(:post, LivePaper::WmTrigger.api_url).to_return(:body => lpp_trigger_response_json, :status => 200)
    stub_request(:get, 'https://fileapi/id/image').to_return(:body => lpp_watermark_response, :status => 200)
    stub_request(:get, "#{LivePaper::WmTrigger.api_url}/trigger_id").to_return(:body => lpp_trigger_response_json, :status => 200)
    stub_request(:get, "#{LivePaper::WmTrigger.api_url}/trigger_not_existent").to_return(:body => '{}', :status => 404)

    @data = {
      id: 'id',
      name: 'name',
      watermark: {strength: 10, imageURL: 'url'},
      subscription: 'subscription'
    }
  end

  describe '#initialize' do
    before do
      @trigger = LivePaper::WmTrigger.new @data
    end

    it 'should map the watermark attribute.' do
      expect(@trigger.watermark).to eq @data[:watermark]
    end

    it 'should map the subscription attribute.' do
      expect(@trigger.subscription).to eq @data[:subscription]
    end
  end

  describe '#save' do
    context 'when all needed attributes are provided,' do
      before do
        @data.delete :id
        @trigger = LivePaper::WmTrigger.new @data
      end

      it 'should make a POST to the trigger URL with body.' do
        @trigger.save
        assert_requested :post, LivePaper::WmTrigger.api_url, :body => {
          trigger: {
            name: 'name',
            watermark: {
              outputImageFormat: 'JPEG',
              resolution: 75,
              strength: 10,
              imageURL: 'url'
            },
            subscription: {package: 'month'}
          }
        }.to_json
      end
    end

    context 'when we do not have all needed data,' do
      it 'should raise exception if the name is no provided.' do
        @data.delete :name
        trigger = LivePaper::WmTrigger.new @data
        expect { trigger.save }.to raise_error
      end

      it 'should raise exception if the watermark is no provided.' do
        @data.delete :watermark
        trigger = LivePaper::WmTrigger.new @data
        expect { trigger.save }.to raise_error
      end
    end
  end

  describe '#parse' do
    before do
      @trigger = LivePaper::WmTrigger.parse(lpp_trigger_response_json)
    end

    it 'should return a Trigger object.' do
      expect(@trigger.class).to eq LivePaper::WmTrigger
    end

    it 'should map the id attribute.' do
      expect(@trigger.id).to eq 'trigger_id'
    end
    it 'should map the name attribute.' do
      expect(@trigger.name).to eq 'name'
    end

    it 'should map the watermark attribute.' do
      expect(@trigger.watermark).to eq 'watermark'
    end

    it 'should map the subscription attribute.' do
      expect(@trigger.subscription).to eq 'subscription'
    end
  end

  describe '.get' do
    context 'the requested trigger exists.' do
      before do
        @trigger = LivePaper::WmTrigger.get('trigger_id')
      end

      it 'should return the requested trigger.' do
        expect(@trigger.id).to eq 'trigger_id'
        expect(@trigger.name).to eq 'name'
        expect(@trigger.watermark).to eq 'watermark'
        expect(@trigger.subscription).to eq 'subscription'
      end
    end

    context 'the requested trigger does not exist or some error happened.' do
      it 'should not raise error.' do
        expect { LivePaper::WmTrigger.get('trigger_not_existent') }.to_not raise_error
      end

      it 'should return nil.' do
        expect(LivePaper::WmTrigger.get('trigger_not_existent')).to eq nil
      end
    end
  end

  describe '#download_watermark' do
    before do
      @trigger = LivePaper::WmTrigger.new @data
      @trigger.wm_url='https://fileapi/id/image'
    end

    it 'should return the watermark image data.' do
      expect(@trigger.download_watermark).to eq 'watermark_data'
    end
  end
end