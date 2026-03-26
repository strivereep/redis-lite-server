require_relative './base'

module Redis
  module Commands
    class Del < Base
      def self.command
        'del'
      end
      
      def run
        del_count = 0
        args.each do |arg|
          if @store[arg]
            @store.delete(arg)
            @expire_keys.delete(arg)
            del_count += 1
          end
        end

        Redis::Resp::Serializer.serialize(del_count)
      end 
    end
  end
end