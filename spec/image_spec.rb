require 'spec_helper'

describe LivePaper::Image do
  before :each do
    @image_width = 10
    @image_height = 20
    @image_blob = 'image_blob'
    @image = double('image')
    @image.stub(:resize)
    @image.stub(:'[]').with(:width).and_return(@image_width)
    @image.stub(:'[]').with(:height).and_return(@image_height)
    @image.stub(:'[]').with(:format).and_return('JPEG')
    @image.stub(:format)
    @image.stub(:level)
    @image.stub(:density)
    @image.stub(:to_blob).and_return(@image_blob)
    MiniMagick::Image.stub(:open).and_return(@image)
    @lpp_image = LivePaper::Image.new 'image'
  end

  describe 'histogram_compression' do
    it 'should call level method from MiniMagick.' do
      @image.should_receive(:level)
      @lpp_image.histogram_compression(3)
    end

    xit 'should call level method with the correct values, and their sum must be 100.' do
      @image.should_receive(:level).at_least(1) do |with|
        bps, wps = with.split(',')
        (bps.to_f + wps.to_f).should == 100.0
      end
      1.upto(10) do |strength|
        @lpp_image.histogram_compression(strength)
      end
    end

    it 'should call level method with the bps always lower than the wps value.' do
      @image.should_receive(:level).at_least(1) do |with|
        bps, wps = with.split(',')
        (bps.to_f < wps.to_f).should == true
      end
      1.upto(10) do |strength|
        @lpp_image.histogram_compression(strength)
      end
    end

  end

  describe 'density' do
    it 'should call MiniMagick format method with the parameter provided.' do
      @image.should_receive(:density).with(300)
      @lpp_image.density 300
    end

    it 'should log the operation.' do
      @lpp_image.density 300
      @lpp_image.logs.last[:method].should == :density
      @lpp_image.logs.last[:input].should == [300]
    end
  end

  describe 'format' do
    it 'should call MiniMagick format method with the parameter provided.' do
      @image.should_receive(:format).with('PNG')
      @lpp_image.format 'PNG'
    end

    it 'should log the operation.' do
      @lpp_image.format 'PNG'
      @lpp_image.logs.last[:method].should == :format
      @lpp_image.logs.last[:input].should == ['PNG']
    end
  end

  describe 'resize' do
    it 'should just return the image if there is no width and height' do
      @image.should_not_receive(:resize)
      @lpp_image.resize('', nil)
    end

    it 'should only return the image if the width and height are the same of the original image.' do
      @image.should_not_receive(:resize)
      @lpp_image.resize(@image_width, @image_height)
    end

    it 'should call the resize the image if there is a width or height different from the original image.' do
      @image.should_receive(:resize)
      @lpp_image.resize(@image_height, @image_width)
    end

    it 'should resize the image proportionally if only the width of the height is used.' do
      width = (@image_width * 0.5).to_i
      height = (@image_height * 0.5).to_i

      @image.should_receive(:resize).with("#{width}x#{height}\!")
      @lpp_image.resize(width, nil)
    end

    it 'should log the operation.' do
      @lpp_image.resize 10, 10
      @lpp_image.logs.last[:method].should == :resize
      @lpp_image.logs.last[:input].should == [10, 10]
    end
  end

  describe 'to_blob' do
    it 'should call MiniMagick to_blob method.' do
      @image.should_receive(:to_blob)
      @lpp_image.to_blob
    end

    it 'should return its content.' do
      @lpp_image.to_blob.should == @image_blob
    end
  end

  describe 'upload' do
    before do
      stub_request(:post, /.*livepaperapi.com\/auth\/token.*/).to_return(:body => lpp_auth_response_json, :status => 200)
      stub_request(:post, LivePaper::Image::STORAGE_URL).to_return(:headers => {location: 'url'}, :status => 200)
    end

    it 'should make a POST to the storage URL with the image as the body.' do
      @lpp_image.upload_image
      assert_requested :post, LivePaper::Image::STORAGE_URL, :body => @image_blob
    end

    it 'should return the location of the uploaded image.' do
      @lpp_image.upload_image.should == 'url'
    end

    it 'should set the @storage_url with the location of the uploaded image.' do
      @lpp_image.upload_image
      @lpp_image.storage_url.should == 'url'
    end
  end

end