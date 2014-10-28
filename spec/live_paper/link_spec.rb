require 'spec_helper'

describe LivePaper::WmTrigger do
  before do
    stub_request(:post, /.*livepaperapi.com\/auth\/token.*/).to_return(:body => lpp_auth_response_json, :status => 200)
    stub_request(:post, LivePaper::Link.api_url).to_return(:body => lpp_link_response_json, :status => 200)
    stub_request(:get, "#{LivePaper::Link.api_url}/link_id").to_return(:body => lpp_link_response_json, :status => 200)
    stub_request(:get, "#{LivePaper::Link.api_url}/link_not_existent").to_return(:body => '{}', :status => 404)

    @data = {
      id: 'id',
      name: 'name',
      analytics: 'analytics',
      trigger_id: 'trigger_id',
      payoff_id: 'payoff_id'
    }
  end

  describe '#initialize' do
    before do
      @link = LivePaper::Link.new @data
    end

    it 'should map the analytics attribute.' do
      expect(@link.analytics).to eq @data[:analytics]
    end

    it 'should map the trigger_id attribute.' do
      expect(@link.trigger_id).to eq @data[:trigger_id]
    end

    it 'should map the payoff_id attribute.' do
      expect(@link.payoff_id).to eq @data[:payoff_id]
    end
  end

  describe '#save' do
    context 'when all needed attributes are provided,' do
      before do
        @data.delete :id
        @link = LivePaper::Link.new @data
      end

      it 'should make a POST to the link URL with body.' do
        @link.save
        assert_requested :post, LivePaper::Link.api_url, :body => {
          link: {
            name: 'name',
            triggerId: 'trigger_id',
            payoffId: 'payoff_id'
          }
        }.to_json
      end
    end

    context 'when we do not have all needed data,' do
      it 'should raise exception if the trigger_id is no provided.' do
        @data.delete :trigger_id
        link = LivePaper::Link.new @data
        expect { link.save }.to raise_error
      end

      it 'should raise exception if the payoff_id is no provided.' do
        @data.delete :payoff_id
        link = LivePaper::Link.new @data
        expect { link.save }.to raise_error
      end
    end
  end

  describe '#parse' do
    before do
      @link = LivePaper::Link.parse(lpp_link_response_json)
    end

    it 'should return a Link object.' do
      expect(@link.class).to eq LivePaper::Link
    end

    it 'should map the id attribute.' do
      expect(@link.id).to eq 'link_id'
    end

    it 'should map the name attribute.' do
      expect(@link.name).to eq 'name'
    end

    it 'should map the analytics attribute.' do
      expect(@link.analytics).to eq 'analytics'
    end

    it 'should map the trigger_id attribute.' do
      expect(@link.trigger_id).to eq 'trigger_id'
    end

    it 'should map the payoff_id attribute.' do
      expect(@link.payoff_id).to eq 'payoff_id'
    end
  end

  describe '.find' do
    context 'the requested Link exists.' do
      before do
        @link = LivePaper::Link.find('link_id')
      end

      it 'should return the requested link.' do
        expect(@link.id).to eq 'link_id'
        expect(@link.name).to eq 'name'
        expect(@link.analytics).to eq 'analytics'
        expect(@link.trigger_id).to eq 'trigger_id'
        expect(@link.payoff_id).to eq 'payoff_id'
      end
    end

    context 'the requested link does not exist or some error happened.' do
      it 'should not raise error.' do
        expect { LivePaper::Link.find('link_not_existent') }.to_not raise_error
      end

      it 'should return nil.' do
        expect(LivePaper::Link.find('link_not_existent')).to eq nil
      end
    end
  end

  describe '#trigger' do
    before do
      stub_request(:get, "#{LivePaper::WmTrigger.api_url}/trigger_id").to_return(:body => lpp_trigger_response_json, :status => 200)
      stub_request(:get, "#{LivePaper::WmTrigger.api_url}/trigger_not_existent").to_return(:body => '{}', :status => 404)
    end

    context 'the trigger_id attribute is from a valid trigger.' do
      before do
        @link = LivePaper::Link.new @data
      end

      it 'should return a Trigger Object.' do
        expect(@link.trigger.class).to eq LivePaper::WmTrigger
      end
    end

    context 'the trigger_id attribute is not valid.' do
      before do
        @data[:trigger_id] = 'trigger_not_existent'
        @link = LivePaper::Link.new @data
      end

      it 'should return nil.' do
        expect(@link.trigger).to eq nil
      end
    end
  end

  describe '#payoff' do
    before do
      stub_request(:get, "#{LivePaper::Payoff.api_url}/payoff_id").to_return(:body => lpp_payoff_response_json, :status => 200)
      stub_request(:get, "#{LivePaper::Payoff.api_url}/payoff_not_existent").to_return(:body => '{}', :status => 404)
    end

    context 'the payoff_id attribute is from a valid payoff.' do
      before do
        @link = LivePaper::Link.new @data
      end

      it 'should return a Payoff Object.' do
        expect(@link.payoff.class).to eq LivePaper::Payoff
      end
    end

    context 'the payoff_id attribute is not valid.' do
      before do
        @data[:payoff_id] = 'payoff_not_existent'
        @link = LivePaper::Link.new @data
      end

      it 'should return nil.' do
        expect(@link.payoff).to eq nil
      end
    end
  end

end
