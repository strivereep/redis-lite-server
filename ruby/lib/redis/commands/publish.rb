require_relative './base'

module Redis
  module Commands
    class Publish < Base
      def self.command
        'publish'
      end

      def run
        channel_name = args[0]
        message = args[1]

        sockets = []
        @mutex.synchronize do
          sockets = @subscribed_channels[channel_name]&.dup || []
        end

        count = 0
        sockets.each do |socket|
          begin
            payload = Redis::Resp::Serializer.serialize(['message', channel_name, message])
            socket.write(payload)
            socket.flush
            count += 1
          rescue Errno::EPIPE, Errno::ECONNRESET, IOError => e
            puts "Failed to publish message: #{e.message}"
            @mutex.synchronize { @subscribed_channels[channel_name]&.delete(socket) }
          end
        end

        Redis::Resp::Serializer.serialize(count)
      end
    end
  end
end