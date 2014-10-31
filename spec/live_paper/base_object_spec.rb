require 'spec_helper'

def stub_unimplemented_methods
  allow_any_instance_of(LivePaper::BaseObject).to receive(:validate_attributes!)
  allow_any_instance_of(LivePaper::BaseObject).to receive(:create_body).and_return(@data)
  allow_any_instance_of(LivePaper::BaseObject).to receive(:parse) { |data| data }
  allow(LivePaper::BaseObject).to receive(:api_url).and_return(@api_url)
end

describe LivePaper::BaseObject do
  before do
    @api_url = "#{LivePaper::LP_API_HOST}/objects"
    stub_request(:post, /.*livepaperapi.com\/auth\/token.*/).to_return(:body => lpp_auth_response_json, :status => 200)
    stub_request(:post, @api_url).to_return(:body => lpp_richpayoff_response_json, :status => 200)

    @data = {
      name: 'name',
      date_created: 'date_created',
      date_modified: 'date_modified'
    }

  end

  describe '#initialize' do
    before do
      @data = {
        id: 'id',
        name: 'name',
        date_created: 'date_created',
        date_modified: 'date_modified'
      }
      @object = LivePaper::BaseObject.new @data
    end

    it 'should map the id attribute.' do
      expect(@object.id).to eq @data[:id]
    end

    it 'should map the name attribute.' do
      expect(@object.name).to eq @data[:name]
    end

    it 'should map the date_created attribute.' do
      expect(@object.date_created).to eq @data[:date_created]
    end

    it 'should map the date_modified attribute.' do
      expect(@object.date_modified).to eq @data[:date_modified]
    end
  end

  describe '#save' do
    before do
      stub_unimplemented_methods
      @data = {
        name: 'name',
        date_created: 'date_created',
        date_modified: 'date_modified'
      }
      @obj = LivePaper::BaseObject.new @data
    end

    it 'should not make a POST if the object has already an id.' do
      @obj.id = 'id'
      @obj.save
      assert_not_requested :post, @api_url
    end

    it 'should re-assign the current object attributes.' do
      @obj.save
      expect(@obj.name).to eq @data[:name]
      expect(@obj.date_created).to eq @data[:date_created]
      expect(@obj.date_modified).to eq @data[:date_modified]
    end

    it 'should return the object instance.' do
      obj = @obj.save
      expect(obj).to eq @obj
    end

    it 'should make a POST to the api_url with the body provided.' do
      @obj.save
      assert_requested :post, @api_url, :body => @data.to_json
    end
  end

  describe '.create' do
    before do
      stub_unimplemented_methods
      @obj = LivePaper::BaseObject.create @data
    end

    it 'should return a object instance.' do
      expect(@obj.class).to eq LivePaper::BaseObject
    end

    it 'should return the object instance with the provided + updated data.' do
      expect(@obj.name).to eq @data[:name]
      expect(@obj.date_created).to eq @data[:date_created]
      expect(@obj.date_modified).to eq @data[:date_modified]
    end
  end

  describe '.find' do
    before do
      allow(LivePaper::BaseObject).to receive(:api_url).and_return(@api_url)
      @data = '"id": "id", "name": "name"'
      stub_request(:get, "#{@api_url}/base_object").to_return(:body => @data, :status => 200)
      stub_request(:get, "#{@api_url}/base_object_not_existent").to_return(:body => '{}', :status => 404)
    end
    context 'the requested base_object exists.' do
      it 'should return the requested base object.' do
        allow(@data).to receive(:body).and_return(@data)
        expect(LivePaper::BaseObject).to receive(:parse).with(@data)
        LivePaper::BaseObject.find('base_object')
      end
    end

    context 'the requested base object does not exist or some error happened.' do
      it 'should not raise error.' do
        expect { LivePaper::BaseObject.find('base_object_not_existent') }.to_not raise_error
      end

      it 'should return nil.' do
        expect(LivePaper::BaseObject.find('base_object_not_existent')).to eq nil
      end
    end
  end

  describe '#rel' do
    before do
      stub_unimplemented_methods
            @data = {
              name: 'name',
              date_created: 'date_created',
              date_modified: 'date_modified',
              link: [
                { :rel => "self", :href => "/api/v1/payoffs/payoff_id" },
                { :rel => "analytics", :href => "/analytics/v1/payoffs/payoff_id" }
              ]
            }
            @obj = LivePaper::BaseObject.create @data
    end

    it 'should return href for rel link' do
      puts "obj is #{@obj.to_yaml}"
      expect(@obj.rel('self')).to eq '/api/v1/payoffs/payoff_id'
    end

    it 'should return nil for unknown rel link' do
      expect(@obj.rel('invalid')).to be_nil
    end
  end

  describe '#all_present?' do
    before do
      @all = [1, 2, {k: 'v'}, [1, 2]]
      @some = [1, 2, {k: 'v'}, []]
      @none = nil
    end

    it 'should return true if all elements are present.' do
      expect(LivePaper::BaseObject.new.send(:all_present?, @all)).to eq true
    end

    it 'should return false if some element is not present.' do
      expect(LivePaper::BaseObject.new.send(:all_present?, @some)).to eq false
    end

    it 'should return false if there is no array.' do
      expect(LivePaper::BaseObject.new.send(:all_present?, @none)).to eq false
    end
  end

  describe '#all_keys_present?' do
    before do
      @keys = [:x, :y, :z]
      @all = {x: 10, y: 20, z: 30}
      @some = {x: 10, y: 20}
      @none = nil
    end

    it 'should return true if all keys are present.' do
      expect(LivePaper::BaseObject.new.send(:all_keys_present?, @all, @keys)).to eq true
    end

    it 'should return false if some key is not present.' do
      expect(LivePaper::BaseObject.new.send(:all_keys_present?, @some, @keys)).to eq false
    end

    it 'should return false if there is no hash.' do
      expect(LivePaper::BaseObject.new.send(:all_keys_present?, @none, @keys)).to eq false
    end
  end

  describe '#parse' do
    it 'should raise exception' do
      expect { LivePaper::BaseObject.parse('') }.to raise_error
    end
  end

  describe '#save' do
    it 'should raise exception' do
      expect { LivePaper::BaseObject.new.save }.to raise_error
    end
  end

  describe '#api_url' do
    it 'should raise exception' do
      expect { LivePaper::BaseObject.api_url }.to raise_error
    end
  end

  describe '#validate_attributes!' do
    it 'should raise exception' do
      expect { LivePaper::BaseObject.new.send :validate_attributes! }.to raise_error
    end
  end

  describe '#create_body' do
    it 'should raise exception' do
      expect { LivePaper::BaseObject.new.send :create_body }.to raise_error
    end
  end
end