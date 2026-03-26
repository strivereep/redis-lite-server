require_relative '../../../lib/redis/resp/deserializer'
require 'pry'

describe Redis::Resp::Deserializer do
  describe '#deserialize' do
    subject(:method) { described_class.deserialize(data) }

    context 'when data is of type simple string' do
      let(:data) { "+OK\r\n" }

      it { expect(method).to eq 'OK' }
    end

    context do
      let(:data) { "*2\r\n$4\r\necho\r\n$11\r\nhello world\r\n" }

      it { expect(method).to eq ['echo', 'hello world'] }
    end

    context do
      let(:data) { "*2\r\n$3\r\nget\r\n$3\r\nkey\r\n" }

      it { expect(method).to eq ['get', 'key'] }
    end

    context do
      let(:data) { "-Error message\r\n" }

      it { expect(method).to eq StandardError.new('Error: Error message') }
    end

    context do
      let(:data) { "$0\r\n\r\n" }

      it { expect(method).to eq '' }
    end
  end
end