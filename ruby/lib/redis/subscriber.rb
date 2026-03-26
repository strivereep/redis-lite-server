require_relative '../redis/resp/deserializer'
require_relative '../redis/resp/serializer'

module Redis
  class Subscriber
    def self.subscribe(socket:, subscribed_channels:, mutex:, channel_name:)
      client_addr = socket.peeraddr[3]
      puts "[PUBSUB] Client #{client_addr} subscribed to '#{channel_name}'"

      loop do
        readable = IO.select([socket], nil, [socket], 1.0)
        if readable
          # check error IO
          break if readable[2].include?(socket)
          
          # read IO ready
          if readable[0].include?(socket)
            begin
              input = socket.readpartial(4096)
              deserialized_data = Redis::Resp::Deserializer.deserialize(input)
              command = deserialized_data[0]
              if command&.downcase == 'unsubscribe'
                mutex.synchronize do
                  subscribed_channels[channel_name]&.delete(socket)
                end
                
                socket.write(Redis::Resp::Serializer.serialize(['unsubscribe', channel_name, 0]))
                break
              end
            rescue EOFError, Errno::ECONNRESET, Errno::EPIPE
              break 
            end
          end
        end
      end
    ensure
      mutex.synchronize do
        subscribed_channels[channel_name]&.delete(socket)
      end
    end
  end
end