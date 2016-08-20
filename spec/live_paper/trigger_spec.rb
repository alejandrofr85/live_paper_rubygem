require 'spec_helper'

DOWNLOAD_URL = "https://watermark.livepaperapi.com/watermark/v1/triggers"

describe LivePaper::WmTrigger do
  let(:start_date) { "my_start_date" }
  let(:end_date) { "my_end_date" }
  let(:data) {
    {
      id: 'id',
      name: 'name',
      start_date: start_date,
      end_date: end_date
    }
  }

  before do
    stub_request(:post, /.*livepaperapi.com\/auth\/token.*/).to_return(:body => lpp_auth_response_json, :status => 200)
    stub_request(:post, LivePaper::WmTrigger.api_url).to_return(:body => lpp_trigger_response_json, :status => 200)
    stub_request(:get, "#{LivePaper::WmTrigger.api_url}/trigger_id").to_return(:body => lpp_trigger_response_json, :status => 200)
    stub_request(:get, "#{LivePaper::WmTrigger.api_url}/trigger_not_existent").to_return(:body => '{}', :status => 404)
    stub_request(:post, LivePaper::BaseObject::LivePaper::Configuration.auth_validation_url).to_return(:status => 201, :body => "", :headers => { project_id: 'pid'})
end

  describe '#initialize without specifying start_date end_date' do
    let(:data){
      {
        id: 'id',
        name: 'name'
      }
    }
    before do
      @trigger = LivePaper::WmTrigger.new data
    end

    it 'should set startDate attribute to nil by default.' do
      expect(@trigger.start_date).to be_nil
    end

    it 'should set endDate attribute to nil by default.' do
      expect(@trigger.end_date).to be_nil
    end

  end

  describe '#initialize with specifying start_date and end_date' do
    before do
      @trigger = LivePaper::WmTrigger.new data
    end

    it 'should set startDate attribute.' do
      expect(@trigger.start_date).to eq(start_date)
    end

    it 'should set endDate attribute.' do
      expect(@trigger.end_date).to eq(end_date)
    end
  end

  describe '#save' do
    context 'when all needed attributes are provided,' do
      before do
        data.delete :id
        @trigger = LivePaper::WmTrigger.new data
      end

      it 'should make a POST to the trigger URL with body.' do
        @trigger.save
        assert_requested :post, LivePaper::WmTrigger.api_url, :body => {
          trigger: {
            name: 'name',
            type: 'watermark',
            startDate: start_date,
            endDate: end_date
          }
        }.to_json
      end
    end

    context 'when we do not have all needed data,' do
      it 'should raise exception if the name is no provided.' do
        data.delete :name
        trigger = LivePaper::WmTrigger.new data
        expect { trigger.save }.to raise_error
      end
    end
  end

  describe '#parse' do
    let(:lpp_start_date_response_json) { JSON.parse(lpp_trigger_response_json)['trigger']['startDate'] }
    let(:lpp_end_date_response_json) { JSON.parse(lpp_trigger_response_json)['trigger']['endDate'] }
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

    it 'should map the start_date attribute.' do
      expect(@trigger.start_date).to eq lpp_start_date_response_json
    end

    it 'should map the end_date attribute.' do
      expect(@trigger.end_date).to eq lpp_end_date_response_json
    end
  end

  describe '.get' do
    context 'the requested trigger exists.' do
      let(:lpp_start_date_response_json) { JSON.parse(lpp_trigger_response_json)['trigger']['startDate'] }
      let(:lpp_end_date_response_json) { JSON.parse(lpp_trigger_response_json)['trigger']['endDate'] }

      before do
        @trigger = LivePaper::Trigger.get('trigger_id')
      end

      it 'should return the requested trigger.' do
        expect(@trigger.id).to eq 'trigger_id'
        expect(@trigger.name).to eq 'name'
        expect(@trigger.class).to eq LivePaper::WmTrigger
        expect(@trigger.start_date).to eq lpp_start_date_response_json
        expect(@trigger.end_date).to eq lpp_end_date_response_json
      end

      context 'qr trigger' do
        before do
          stub_request(:get, "#{LivePaper::Trigger.api_url}/qr_trigger_id").to_return(:body => lpp_trigger_response_json('qrcode'), :status => 200)
        end
        it 'should create a QrTrigger' do
          qr_trigger = LivePaper::Trigger.get('qr_trigger_id')
          expect(qr_trigger).to be_a LivePaper::QrTrigger
        end
      end

      context 'short trigger' do
        it 'should return a ShortTrigger' do
          stub_request(:get, "#{LivePaper::Trigger.api_url}/short_trigger_id").to_return(:body => lpp_trigger_response_json('shorturl'), :status => 200)
          my_trigger = LivePaper::Trigger.get('short_trigger_id')
          expect(my_trigger).to be_a LivePaper::ShortTrigger
        end
      end
    end

    context 'the requested trigger does not exist or some error happened.' do
      it 'should not raise error.' do
        expect { LivePaper::Trigger.get('trigger_not_existent') }.to_not raise_error
      end

      it 'should return nil.' do
        expect(LivePaper::Trigger.get('trigger_not_existent')).to eq nil
      end
    end
  end

  describe '#download_watermark' do
    let(:image_url) { 'http://lpp.com/image/mine.jpg' }
    let(:encoded_image_url) { CGI.escape(image_url) }
    let(:wpi) { LivePaper::WmTrigger::WATERMARK_RESOLUTION }
    let(:strength) { LivePaper::WmTrigger::WATERMARK_STRENGTH }
    let(:ppi) { LivePaper::WmTrigger::DEFAULT_IMAGE_RESOLUTION }

    before do
      stub_request(:get, "https://fileapi/id/image?imageURL=#{encoded_image_url}&wpi=#{wpi}&ppi=#{ppi}&strength=#{strength}").to_return(:body => lpp_watermark_response, :status => 200)
      image_file_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_assets', 'Bear.jpg'))
      image_bytes = File.binread(image_file_path)
      stub_request(:get, "#{image_url}?access_token=#{$lpp_access_token}").to_return(:body => image_bytes, :status => 200)
      @trigger = LivePaper::WmTrigger.new data
      @trigger.wm_url='https://fileapi/id/image'
    end

    it 'should return the watermark image data.' do
      expect(@trigger.download_watermark(image_url)).to eq 'watermark_data'
    end
  end
end
