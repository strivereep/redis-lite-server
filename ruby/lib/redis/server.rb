require 'socket'
require_relative 'resp/deserializer'
require_relative 'active_expire'
require_relative 'bg_save'
require_relative 'command'
require_relative 'subscriber'
require_relative 'snapshot'

module Redis
  class Server
    def self.start
      new.start
    end

    def initialize(host = '127.0.0.1', port = 6379)
      @host = host
      @port = port
      @store = {}
      @expire_keys = {}
      @server = nil
      @mutex = Mutex.new
      @save_pid = nil
      @subscribed_channels = {}
    end

    def start
      # Expire the keys in the background
      Redis::ActiveExpire.run(
        expire_keys: @expire_keys,
        store: @store,
        mutex: @mutex
      )

      # # # Save the keys to the file in the background
      Redis::BgSave.run(
        store: @store,
        save_pid: @save_pid
      )

      @server = TCPServer.new(host, port)
      puts "Redis Server is listening on host: #{host} and port: #{port}"
      
      Redis::Snapshot.load_on_start(store: @store)
      unless @store.empty?
        puts "Loaded #{@store.keys.size} keys"
      end

      trap('INT') { shutdown }
      
      loop do
        puts "--- New client connected ---"
        Thread.start(@server.accept) do |client|
          handle_client(client)
        end
      end
    rescue Interrupt
      shutdown
    end
    
    def shutdown
      puts "Shutting down server..."
      exit(0)
    end
      
    private
    
    attr_reader :host, :port
    
    def handle_client(client)
      client_addr = client.peeraddr[3]
      puts "Client connected: #{client_addr}"

      puts "Connected at #{Time.now}"

      while (input = client.readpartial(4096))
        while !input.empty?
          deserialized_data = Redis::Resp::Deserializer.deserialize(input)
          command = deserialized_data[0]
          if command&.downcase == 'subscribe'
            channel_name = deserialized_data[1]

            @mutex.synchronize do
              @subscribed_channels[channel_name] ||= []
              @subscribed_channels[channel_name] << client
            end

            client.write(Redis::Resp::Serializer.serialize(['subscribe', channel_name, 1]))
            Redis::Subscriber.subscribe(socket: client, subscribed_channels: @subscribed_channels, mutex: @mutex, channel_name: channel_name)
            return
          else
            response = Redis::Command.run(
              store: @store,
              expire_keys: @expire_keys,
              input: deserialized_data,
              mutex: @mutex,
              save_pid: @save_pid,
              subscribed_channels: @subscribed_channels,
              socket: client
            )
            if response
              client.write(response)
              client.flush
            else
              puts "[SERVER] No response to send (e.g., SUBSCRIBE mode)"
            end
          end
        end
      end
    rescue EOFError, Errno::ECONNRESET, Errno::EPIPE
      puts 'Client disconnected.'
    ensure
      client&.close
    end
  end
end