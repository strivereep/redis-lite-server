require_relative './base'

module Redis
  module Commands
    class LPush < Base
      def self.command
        'lpush'
      end

      def run
        key = args[0]
        values = args[1..]
        if key.empty? || values.empty?
          return '-ERR wrong number of arguments for command'
        end

        @store[key] ||= []
        @mutex.synchronize do
          values.each do |value|
            @store[key] = @store[key].unshift(value)
          end
        end

        Redis::Resp::Serializer.serialize(@store[key].size)
      end
    end
  end
end