require_relative './base'

module Redis
  module Commands
    class Ping < Base
      def self.command
        'ping'
      end
      
      def run
        Redis::Resp::Serializer.serialize(:PONG)
      end
    end
  end
end