require 'spec_helper'


RSpec.describe BridgeStats::Builder do
  describe '#initialize' do
    it "Doesn't throw an error" do
      expect { BridgeStats::Builder.new }.not_to raise_error
    end
  end
end
