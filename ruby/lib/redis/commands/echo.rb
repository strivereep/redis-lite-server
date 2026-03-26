require_relative './base'

module Redis
  module Commands
    class Echo < Base
      def self.command
        'echo'
      end
      
      def run
        combined_args = args.join(' ')
        Redis::Resp::Serializer.serialize(combined_args)
      end
    end
  end
end