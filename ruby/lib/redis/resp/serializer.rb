module Redis
  module Resp
    class Serializer
      CRLF = "\r\n"
       
      def self.serialize(data)
        case data
        when NilClass
          "$-1#{CRLF}"
        when Symbol # Simple string
          "+#{data}#{CRLF}"
        when String # Bulk Strings
          "$#{data.bytesize}#{CRLF}#{data}#{CRLF}"
        when Integer
          ":#{data}#{CRLF}"
        when Array
          header = "*#{data.size}#{CRLF}"
          payload = data.map { |datum| serialize(datum) }.join
          "#{header}#{payload}"
        when StandardError
          "-#{data}#{CRLF}"
        else
          raise "RESP Serialization failed. Invalid class: #{data.class}"
        end
      end
    end
  end
end