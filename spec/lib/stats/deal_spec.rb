require 'spec_helper'

RSpec.describe BridgeStats::Deal do
  describe 'with board 26 its methods' do
    let(:deal_under_test) do
      BridgeStats::Deal.new(e: { c: 'J7', d: 'T4', h: 'T987432', s: 'K7' },
                            s: { c: 'T654', d: 'K62', h: 'AK6', s: 'T83' },
                            w: { c: '92', d: '753', h: 'QJ', s: 'AJ9652' },
                            n: { c: 'AKQ83', d: 'AQJ98', h: '5', s: 'Q4' })
    end
    it 'return the correct high card point count for NS' do
      expect(deal_under_test.hcp(:ns)).to eq 28
    end
    it 'return the correct long point count for N' do
      expect(deal_under_test.hand(:n).long_points).to eq 2
    end
    it 'return the correct short point count for S in clubs' do
      expect(deal_under_test.hand(:s).short_points(:c)).to eq 0
    end
    it 'return the correct total partnership point count for N decl in clubs' do
      expect(deal_under_test.total_partnership_points(:n, :c)).to eq 30
    end
    it 'return the correct fit for NS in clubs' do
      expect(deal_under_test.fit(:ns, :c)).to eq 9
    end
    it 'return the correct count for voids, 1-tons, 2-tons, 6+ers in NS' do
      expect(deal_under_test.blankleton_count(0, :ns)).to eq 0
      expect(deal_under_test.blankleton_count(1, :ns)).to eq 1
      expect(deal_under_test.blankleton_count(2, :ns)).to eq 1
      expect((6..13).inject(0) do |sum, length|
        sum + deal_under_test.blankleton_count(length, :ns)
      end).to eq 0
    end
    it 'return the correct count of unstopped suits in NS' do
      expect(deal_under_test.unstopped_suit_count(:ns)).to eq 1
    end
  end

  describe 'with board 29 its methods' do
    let(:deal_under_test) do
      BridgeStats::Deal.new(n: { c: '64', d: 'AKJT3', h: 'A4', s: 'J973' },
                            e: { c: 'AT9', d: 'Q2', h: '862', s: 'KQT82' },
                            s: { c: 'KJ8532', d: '864', h: 'K973', s: '' },
                            w: { c: 'Q7', d: '975', h: 'QJT5', s: 'A654' })
    end
    it 'return the correct high card point count for NS' do
      expect(deal_under_test.hcp(:ns)).to eq 20
    end
    it 'return the correct long point count for S' do
      expect(deal_under_test.hand(:s).long_points).to eq 2
    end
    it 'return the correct short point count for N in clubs' do
      expect(deal_under_test.hand(:n).short_points(:c)).to eq 1
    end
    it 'return the correct total partnership point count for S decl in clubs' do
      # Zack's spreadsheet incorrectly counted short points in trump
      expect(deal_under_test.total_partnership_points(:s, :c)).to eq 23
    end
    it 'return the correct fit for NS in clubs' do
      expect(deal_under_test.fit(:ns, :c)).to eq 8
    end
    it 'return the correct count for voids, 1-tons, 2-tons, 6+ers in NS' do
      expect(deal_under_test.blankleton_count(0, :ns)).to eq 1
      expect(deal_under_test.blankleton_count(1, :ns)).to eq 0
      expect(deal_under_test.blankleton_count(2, :ns)).to eq 2
      expect((6..13).inject(0) do |sum, length|
        sum + deal_under_test.blankleton_count(length, :ns)
      end).to eq 1
    end
    it 'return the correct count of unstopped suits in NS' do
      expect(deal_under_test.unstopped_suit_count(:ns)).to eq 1 # i.e. Jxxx is not a stopper
    end
  end
end
