require 'spec_helper'

RSpec.describe BridgeStats::CachingWrapper do
  describe '#initialize' do
    let(:deal_under_test) do
      BridgeStats::Deal.new(e: { c: 'J7', d: 'T4', h: 'T987432', s: 'K7' },
                            s: { c: 'T654', d: 'K62', h: 'AK6', s: 'T83' },
                            w: { c: '92', d: '753', h: 'QJ', s: 'AJ9652' },
                            n: { c: 'AKQ83', d: 'AQJ98', h: '5', s: 'Q4' })
    end
    let(:cache_under_test) do
      BridgeStats::CachingWrapper.new(deal_under_test)
    end
    it "Doesn't throw an error" do
      expect(cache_under_test.total_partnership_points(:n, :c)).to eq 30
      expect(cache_under_test.total_partnership_points(:n, :c)).to eq 30
    end
  end
end
