require 'spec_helper'

describe LivePaper::Payoff do
  before do
    stub_request(:post, /.*livepaperapi.com\/auth\/token.*/).to_return(:body => lpp_auth_response_json, :status => 200)
    stub_request(:post, LivePaper::Payoff.api_url).to_return(:body => lpp_richpayoff_response_json, :status => 200)
    stub_request(:get, "#{LivePaper::Payoff.api_url}/payoff_id").to_return(:body => lpp_payoff_response_json, :status => 200)
    stub_request(:get, "#{LivePaper::Payoff.api_url}/payoff_not_existent").to_return(:body => '{}', :status => 404)
    stub_request(:post, LivePaper::BaseObject::LivePaper::Configuration.auth_validation_url).to_return(:status => 201, :body => "", :headers => { project_id: 'pid'})
end

  let(:data) {
    {
      id: 'id',
      name: 'name',
      type: 'type',
      url: 'url',
      data: 'data'
    }
  }
  let(:payoff) { LivePaper::Payoff.new data }

  describe '#initialize' do

    it 'should map the type attribute.' do
      expect(payoff.type).to eq data[:type]
    end

    it 'should map the url attribute.' do
      expect(payoff.url).to eq data[:url]
    end

    it 'should map the data attribute.' do
      expect(payoff.data).to eq data[:data]
    end
  end

  describe '#save' do
    context 'all needed attributes are provided.' do
      context 'payoff type is RICH_PAYOFF.' do
        let(:rich_data) {
          {
            type: "content action layout",
            version: 1,
            data: {
              content: {
                type: "image",
                label: "Movember!",
                data: {URL: "http://static.movember.com/uploads/2014/profiles/ef4/ef48a53fb031669fe86e741164d56972-546b9b5c56e15-hero.jpg"}
              },
              actions: [
                {
                  type: "webpage",
                  label: "Donate!",
                  icon: {id: "533"},
                  data: {URL: "http://MOBRO.CO/oamike"}
                },
                {
                  type: "share",
                  label: "Share!",
                  icon: {id: "527"},
                  data: {URL: "Help Mike get the prize of most donations on his team! MOBRO.CO/oamike"}
                }
              ]
            }
          }
        }
        let(:data) {
          {
            name: 'name',
            type: LivePaper::Payoff::TYPE[:RICH],
            url: 'url',
            data: rich_data
          }
        }

        it 'should make a POST to the payoff URL with the richpayoff options hash.' do
          payoff.save
          assert_requested :post, LivePaper::Payoff.api_url, :body => {
                                  payoff: {
                                    name: 'name',
                                    type: 'richPayoff',
                                    richPayoff: {
                                      version: 1,
                                      private: {
                                        :'content-type' => 'custom-base64',
                                        :data => Base64.encode64(rich_data.to_json)
                                      },
                                      public: {
                                        url: 'url'
                                      }
                                    }
                                  }
                                }.to_json
        end
      end

      context 'payoff type is WEB_PAYOFF.' do
        let(:data) {
          {
            name: 'name',
            type: LivePaper::Payoff::TYPE[:WEB],
            url: 'url'
          }
        }

        it 'should make a POST to the payoff URL with the webpayoff options hash.' do
          payoff.save
          assert_requested :post, LivePaper::Payoff.api_url, :body => {
                                  payoff: {
                                    name: data[:name],
                                    type: 'url',
                                    url: data[:url]
                                  }
                                }.to_json
        end
      end

    end

    context 'when we do not have all needed data.' do
      let(:data) {
        {
          name: 'name',
          type: LivePaper::Payoff::TYPE[:WEB],
          url: 'url'
        }
      }
      it 'should raise an exception if the name was not provided.' do
        payoff.name = nil
        expect { payoff.save }.to raise_error ArgumentError
      end

      it 'should raise an exception if the type was not provided.' do
        payoff.type = nil
        expect { payoff.save }.to raise_error ArgumentError
      end

      it 'should raise an exception a unsupported type was provided.' do
        payoff.type = 'unsupported type'
        expect { payoff.save }.to raise_error ArgumentError
      end

      it 'should raise an exception if the url was not provided.' do
        payoff.url = nil
        expect { payoff.save }.to raise_error ArgumentError
      end

      context 'payoff type is RICH_PAYOFF.' do
        let(:data) {
          {
            name: 'name',
            type: LivePaper::Payoff::TYPE[:RICH],
            url: 'url',
            data: 'data'
          }
        }

        it 'should raise an exception if the data was not provided.' do
          payoff.data = nil
          expect { payoff.save }.to raise_error ArgumentError
        end
      end
    end
  end

  describe '#parse' do
    let(:payoff) { LivePaper::Payoff.parse(lpp_payoff_response_json) }

    it 'should return a Payoff object.' do
      expect(payoff.class).to eq LivePaper::Payoff
    end

    it 'should map the id attribute.' do
      expect(payoff.id).to eq 'payoff_id'
    end
    it 'should map the name attribute.' do
      expect(payoff.name).to eq 'name'
    end

    it 'should map the url attribute.' do
      expect(payoff.url).to eq 'url'
    end

    context 'when the data is from a web payoff.' do
      it 'should map the payoff type attribute.' do
        expect(payoff.type).to eq LivePaper::Payoff::TYPE[:WEB]
      end
    end

    context 'when the data is from a rich payoff.' do
      let(:payoff) { LivePaper::Payoff.parse(lpp_richpayoff_response_json) }

      it 'should map the payoff type attribute.' do
        expect(payoff.type).to eq LivePaper::Payoff::TYPE[:RICH]
      end

      it 'should map the data attribute.' do
        expect(payoff.data).to eq ({field: 1})
      end
    end
  end

  describe '.get' do
    context 'the requested payoff exists.' do
      let(:payoff) { LivePaper::Payoff.get('payoff_id') }

      it 'should return the requested payoff.' do
        expect(payoff.id).to eq 'payoff_id'
        expect(payoff.name).to eq 'name'
        expect(payoff.url).to eq 'url'
      end

    end

    context 'the requested payoff does not exist or some error happened.' do
      it 'should not raise error.' do
        expect { LivePaper::Payoff.get('payoff_not_existent') }.to_not raise_error
      end

      it 'should return nil.' do
        expect(LivePaper::Payoff.get('payoff_not_existent')).to eq nil
      end
    end
  end

end
