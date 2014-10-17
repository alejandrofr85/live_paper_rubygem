require 'spec_helper'
describe LivePaper::Loggable do
  context 'when a class uses it and redefines methods to be logged.' do
    class DummyLog < LivePaper::Loggable
      def to_log
        [:dummy1, :dummy2]
      end

      def dummy1(*args)
        args.reverse
      end

      def dummy2(*args)
        args.reverse
      end
    end

    before do
      @args = [1, 2, 3]
      @dummy_log = DummyLog.new
    end

    it 'should log the requested method once per call.' do
      @dummy_log.dummy1 *@args
      @dummy_log.logs.count.should == 1
    end

    it 'should log the requested method name.' do
      @dummy_log.dummy1 *@args
      @dummy_log.logs.last[:method].should == :dummy1
    end

    it 'should log the requested method input parameters.' do
      @dummy_log.dummy1 *@args
      @dummy_log.logs.last[:input].should == @args
    end

    it 'should log the requested method output.' do
      @dummy_log.dummy1 *@args
      @dummy_log.logs.last[:output].should == @args.reverse
    end
  end

  context 'when there is no method to log' do
    class DummyLog2 < LivePaper::Loggable
      def dummy1(*args)
        args.reverse
      end
    end

    before do
      @args = [1, 2, 3]
      @dummy_log = DummyLog2.new
    end

    it 'should not log.' do
      @dummy_log.dummy1 *@args
      @dummy_log.logs.should be_empty
    end
  end

end