module Redis
  module Resp
    class Deserializer
      CRLF = "\r\n".freeze
      CRLF_SIZE = CRLF.size.freeze

      # @params [String] data: serialized (RESP)
      def self.deserialize(data)
        new(data).deserialize
      end

      def initialize(data)
        @buffer = data
        @cursor = 0
      end

      def deserialize
        first_byte = @buffer[@cursor]
        @cursor += 1
        
        case first_byte
        when '+'
          read_line
        when '$'
          read_bulk_string
        when ':'
          read_line.to_i
        when '*'
          read_array
        when '-'
          StandardError.new("Error: #{read_line}")
        end
      end

      private
      
      def read_bulk_string
        byte_length = read_line.to_i
        return nil if byte_length == -1
        
        value = @buffer.byteslice(@cursor, byte_length)
        @cursor += byte_length + CRLF_SIZE
        return value
      end
      
      def read_array
        array_length = read_line.to_i
        return nil if array_length == -1
        
        Array.new(array_length) { deserialize }
      end

      def read_line
        crlf_index = @buffer.index(CRLF, @cursor)
        value = @buffer.byteslice(@cursor, crlf_index - @cursor)
        @cursor = crlf_index + CRLF_SIZE
        value
      end
    end
  end
end