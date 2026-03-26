# frozen_string_literal: true
#
require_relative './base'

module Redis
  module Commands
    class Set < Base
      EX = 'EX'
      PX = 'PX'
      EXAT = 'EXAT'
      PXAT = 'PXAT'

      def self.command
        'set'
      end
      
      def run
        @mutex.synchronize do
          key = args[0]
          value = args[1]
          # Add the key to the expire keys hash
          if args.size > 2
            expire_type = args[2]
            expire_value = args[3].to_i
            add_expire_keys(key, expire_type, expire_value.to_i)
          end
          
          @store[key] = value
          Resp::Serializer.serialize(:OK)
        end
      end

      private

      def add_expire_keys(expire_key, expire_type, expire_value)
        if expire_value.negative?
          return '-ERR value is not an integer or out of range'
        end
        
        standard_expired_value = \
          case expire_type.upcase
          when EX # seconds
            (Time.now.to_i + expire_value) * 1000
          when PX # milliseconds
            Time.now.to_i * 1000 + expire_value
          when EXAT # Unix time in seconds
            expire_value * 1000
          when PXAT # Unix time in milliseconds
            expire_value
          else
            return "-ERR Unknown expire type options #{expire_type}"
          end
        
        @expire_keys[expire_key] = standard_expired_value
      end
    end
  end
end