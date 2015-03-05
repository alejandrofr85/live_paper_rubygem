require 'spec_helper'

describe LivePaper::Image do
  let(:srcBytes) { 'YOURIMAGEBYTES' }
  let(:lpp_img_uri) { 'ALLYOURBYTESAREBELONGTOUS' }
  before do
    $lpp_access_token = "YouBeenHacked"

    stub_request(:post, LivePaper::Image::API_URL).
      with(:body => "YOURIMAGEBYTES",
           :headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'Authorization'=>'Bearer YouBeenHacked', 'Content-Length'=>'14', 'Content-Type'=>'image/jpg', 'User-Agent'=>'Ruby'}).
      to_return(:status => 201, :body => "", :headers => {location: lpp_img_uri})
  end

  context 'local file' do
    let(:source_uri) { 'foo.jpg' }

    before do
      expect(File).to receive(:binread).with(source_uri).and_return(srcBytes)
    end

    it 'upload should return stored image url' do
      expect(LivePaper::Image.upload(source_uri)).to eq(lpp_img_uri)
    end
  end

  context 'web file' do
      let(:source_uri) { 'http://anythingbutapiurl.com/anypath/internetphoto.jpg' }

      before do
        receiver = double('receiver')
        expect(receiver).to receive(:body).and_return(srcBytes)
        expect(RestClient).to receive(:get).with(source_uri, Accept: 'image/jpg').and_return(receiver)
      end

      it 'upload should return stored image url' do
        expect(LivePaper::Image.upload(source_uri)).to eq(lpp_img_uri)
      end
    end
  context 'lpp stored image file' do
      let(:source_uri) { "#{LivePaper::Image::API_URL}/path/already_uploaded.jpg" }

      it 'upload should return original image url' do
        expect(LivePaper::Image.upload(source_uri)).to eq(source_uri)
      end
    end

end
