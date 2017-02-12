require 'spec_helper'


RSpec.describe Bridge::Stats::Builder do
  describe '#initialize' do
    it "Doesn't throw an error" do
      expect {Bridge::Stats::Builder.new}.not_to raise_error
    end
  end
end
