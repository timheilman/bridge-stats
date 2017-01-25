require 'spec_helper'

RSpec.describe Bridge::Pbn::BeforeTagValue do
  describe('#process_char') do
    let(:parser) { double }
    let(:described_object) { described_class.new(parser) }
    it('should skip whitespace') do
      expect(described_object.process_char("\v")).to be(described_object)
    end

    it('should raise an error for any non-whitespace and non-double-quote token string') do
      expect(parser).to receive(:raise_error).with(match '.*whitespace.*double quote.*;')
      described_object.process_char(';')
    end

  end
end