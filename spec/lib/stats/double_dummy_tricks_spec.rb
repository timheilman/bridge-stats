require 'spec_helper'

RSpec.describe BridgeStats::DoubleDummyTricks do
  describe '#best_making_contract' do
    context 'with board 1' do
      let(:ddt_under_test) { BridgeStats::DoubleDummyTricks.new('63b3c63b3c492a0492a0') }
      context 'and N' do
        it 'works' do
          expect(ddt_under_test.best_minimal_contracts(:n)).to eq ['6c'].to_set
        end
      end
      context 'and E' do
        it 'works' do
          expect(ddt_under_test.best_minimal_contracts(:e)).to eq ['1s'].to_set
        end
      end
    end
    context 'with board 26' do
      let(:ddt_under_test) { BridgeStats::DoubleDummyTricks.new('776bb776bb1671116711') }
      context 'and N' do
        it 'works' do
          expect(ddt_under_test.best_minimal_contracts(:n)).to eq %w(5c 5d).to_set
        end
      end
      context 'and E' do
        it 'works' do
          expect(ddt_under_test.best_minimal_contracts(:e)).to eq ['1h'].to_set
        end
      end
    end
  end
end
