require_relative '../../../lib/redis/resp/serializer'

RSpec.describe Redis::Resp::Serializer do
  describe '#serialize' do
    let(:crlf) { described_class::CRLF }
    subject(:method) { described_class.serialize(data) }

    context 'when data is simple string' do
      let(:data) { :PING }

      it { expect(method).to eq "+#{data}#{crlf}" }
    end

    context 'when data is bulk string' do
      let(:data) { 'Hello World' }

      it { expect(method).to eq "$11\r\nHello World\r\n" }
    end

    context 'when data is integer' do
      let(:data) { 25 }

      it { expect(method).to eq ":25\r\n" }
    end

    context 'when data is array' do
      let(:data) { ['GET', 10, 'VALUE'] }

      it { expect(method).to eq "*3\r\n$3\r\nGET\r\n:10\r\n$5\r\nVALUE\r\n" }
    end

    context 'when data is simple error' do
      let(:data) { StandardError.new('Error message') }

      it { expect(method).to eq "-Error message\r\n" }
    end
  end
end
