require_relative './base'

module Redis
  module Commands
    class Config < Base
      def self.command
        'config'
      end

      def run
        config = args[-1]
        if config.downcase == 'save'
          # "*2\r\n$4\r\nsave\r\n$0\r\n\r\n"
          return Resp::Serializer.serialize(['save', ''])
        elsif config.downcase == 'appendonly'
          # "*2\r\n$10\r\nappendonly\r\n$2\r\no\r\n"
          return Resp::Serializer.serialize(['appendonly', 'no'])
        end
      end
    end
  end
end