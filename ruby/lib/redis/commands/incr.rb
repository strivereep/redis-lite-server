require_relative './base'

module Redis
  module Commands
    class Incr < Base
      def self.command
        'incr'
      end
      
      def run
        arg = args[0]
        return Redis::Resp::Serializer.serialize(nil) unless @store[arg]
        return '-ERR value is not an integer or out of range' unless is_integer?(arg)

        @mutex.synchronize do
          @store[arg] = @store[arg].next
          Redis::Resp::Serializer.serialize(@store[arg].to_i)
        end
      end

      private

      def is_integer?(arg)
        true if Integer(@store[arg])
      rescue
        false
      end
    end
  end
end