require_relative '../resp/serializer'

module Redis
  module Commands
    class Base
      private attr_reader :args, :mutex

      def self.run(options)
        new(options).run
      end

      def self.command
        raise NotImplementedError
      end
      
      def initialize(options)
        @args = options[:args]
        @mutex = options[:mutex]
        @store = options[:store]
        @expire_keys = options[:expire_keys]
        @save_pid = options[:save_pid]
        @subscribed_channels = options[:subscribed_channels]
        @socket = options[:socket]
      end

      def run
        raise NotImplementedError
      end
    end
  end
end