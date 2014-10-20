require 'spec_helper'

describe LivePaper::LivePaperSession do

  describe '#say_hi' do
    it 'should respond with greeting' do
      allow_any_instance_of(LivePaper::LivePaperSession).to receive(:authorize).and_return(true)

      @lps=LivePaper::LivePaperSession.new(nil)
      expect(@lps.say_hi).to eq("hello")
    end
  end
end