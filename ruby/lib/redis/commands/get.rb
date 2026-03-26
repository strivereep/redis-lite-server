require_relative './base'

module Redis
  module Commands
    class Get < Base
      def self.command
        'get'
      end
      
      def run
        @mutex.synchronize do 
          key = args[0]
          value = @store[key]
          return Resp::Serializer.serialize(nil) unless value
          
          # Passive expire
          if key_expired?(key)
            @store.delete(key)
            Resp::Serializer.serialize(nil)
          else
            Resp::Serializer.serialize(value)
          end
        end
      end

      private

      def key_expired?(key)
        # key = key.to_sym
        if @expire_keys[key] && @expire_keys[key] < Time.now.to_i * 1000
          @expire_keys.delete(key)
          return true
        end
  
        false
      end
    end
  end
end