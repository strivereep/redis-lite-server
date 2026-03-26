require_relative './base'

module Redis
  module Commands
    class Exists < Base
      def self.command
        'exists'
      end
      
      def run
        exist_count = 0
        args.each do |arg|
          if @store[arg]
            exist_count += 1
          end
        end

        Redis::Resp::Serializer.serialize(exist_count)
      end 
    end
  end
end