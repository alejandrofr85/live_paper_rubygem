require 'spec_helper'

describe LivePaper::Trigger do
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
      @link.analytics.should == @data[:analytics]
    end

    it 'should map the trigger_id attribute.' do
      @link.trigger_id.should == @data[:trigger_id]
    end

    it 'should map the payoff_id attribute.' do
      @link.payoff_id.should == @data[:payoff_id]
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
      @link.should be_a LivePaper::Link
    end

    it 'should map the id attribute.' do
      @link.id.should == 'link_id'
    end

    it 'should map the name attribute.' do
      @link.name.should == 'name'
    end

    it 'should map the analytics attribute.' do
      @link.analytics.should == 'analytics'
    end

    it 'should map the trigger_id attribute.' do
      @link.trigger_id.should == 'trigger_id'
    end

    it 'should map the payoff_id attribute.' do
      @link.payoff_id.should == 'payoff_id'
    end
  end

  describe '.find' do
    context 'the requested Link exists.' do
      before do
        @link = LivePaper::Link.find('link_id')
      end

      it 'should return the requested link.' do
        @link.id.should == 'link_id'
        @link.name.should == 'name'
        @link.analytics.should == 'analytics'
        @link.trigger_id.should == 'trigger_id'
        @link.payoff_id.should == 'payoff_id'
      end
    end

    context 'the requested link does not exist or some error happened.' do
      it 'should not raise error.' do
        expect { LivePaper::Link.find('link_not_existent') }.to_not raise_error
      end

      it 'should return nil.' do
        LivePaper::Link.find('link_not_existent').should be_nil
      end
    end
  end

  describe '#trigger' do
    before do
      stub_request(:get, "#{LivePaper::Trigger.api_url}/trigger_id").to_return(:body => lpp_trigger_response_json, :status => 200)
      stub_request(:get, "#{LivePaper::Trigger.api_url}/trigger_not_existent").to_return(:body => '{}', :status => 404)
    end

    context 'the trigger_id attribute is from a valid trigger.' do
      before do
        @link = LivePaper::Link.new @data
      end

      it 'should return a Trigger Object.' do
        @link.trigger.should be_a LivePaper::Trigger
      end
    end

    context 'the trigger_id attribute is not valid.' do
      before do
        @data[:trigger_id] = 'trigger_not_existent'
        @link = LivePaper::Link.new @data
      end

      it 'should return nil.' do
        @link.trigger.should be_nil
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
        @link.payoff.should be_a LivePaper::Payoff
      end
    end

    context 'the payoff_id attribute is not valid.' do
      before do
        @data[:payoff_id] = 'payoff_not_existent'
        @link = LivePaper::Link.new @data
      end

      it 'should return nil.' do
        @link.payoff.should be_nil
      end
    end
  end

end
