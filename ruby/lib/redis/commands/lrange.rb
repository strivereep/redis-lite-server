require_relative './base'

module Redis
  module Commands
    class LRange < Base
      def self.command
        'lrange'
      end
      
      def run
        @mutex.synchronize do
          @key = args[0]
          @range = args[1..]
  
          return '-ERR wrong number of arguments for command' if invalid_command?
          return '-ERR value is not an integer or out of range' unless is_range_numeric?
          
          @range = @range.map(&:to_i)
          @store[@key] ||= []

          result = @store[@key][@range.first..@range.last]
          if result.empty?
            return Redis::Resp::Serializer.serialize('empty array')
          end

          Redis::Resp::Serializer.serialize(result)
        end  
      end

      private

      def invalid_command?
        return true if @key.empty? || @range.empty?
        return true if @range.size != 2  
        
        false
      end

      def is_range_numeric?
        valid = @range.map do |val|
          true if Integer(val)
          rescue
            false
        end

        !valid.any?(false)
      end
    end
  end
end