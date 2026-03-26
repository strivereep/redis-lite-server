require 'socket'
require 'timeout'
require_relative 'resp/deserializer'
require_relative 'resp/serializer'

module Redis
  class Client
    MAX_RETRIES = 3
    TIMEOUT = 5

    def self.call(args)
      new.call(args)
    rescue => e
      puts e.message
      exit(1)
    end
  
    def initialize(host = '127.0.0.1', port = 6379)
      @host = host
      @port = port
      connect
    end

    def connect
      retries = 0

      begin
        Timeout.timeout(TIMEOUT) do
          @socket = TCPSocket.new(@host, @port)
        end
      rescue Errno::ECONNREFUSED, Timeout::Error => e
        retries += 1
        if retries < MAX_RETRIES
          puts "Connection failed, retrying #{retries}/#{MAX_RETRIES}..."
          sleep(2 ** retries) # exponential retries
          retry
        else
          raise "Failed to connect to server after #{MAX_RETRIES}, error: #{e.message}"
        end
      end
    end
    
    def call(args)
      raise "Server not connected" unless @socket
      
      serialized_data = Redis::Resp::Serializer.serialize(args)
      socket.write(serialized_data)
      socket.flush
      
      handle_response
      close
    end
    
    private
    
    attr_reader :socket
    
    def handle_response
      data = @socket.readpartial(1024)
      puts Redis::Resp::Deserializer.deserialize(data)
    end

    def close
      socket&.close
    end
  end
end
