# frozen_string_literal: true

require_relative './resp/deserializer'
require_relative './resp/serializer'
require_relative './commands/registry'
require 'pry'

module Redis
  class Command
    def self.run(options = {})
      new(options).run
    end
    
    def initialize(options)
      @input = options[:input]
      @options = options
    end
    
    def run
      if (!input.is_a?(Array) || input.compact.empty?)
        return "-ERR no command provided" 
      end
      
      command = input[0].downcase
      @options[:args] = input[1..]
      
      unless registered_commands.keys.include?(command)
        return "-ERR unknown command #{command}"     
      end

      redis_command = registered_commands[command]
      redis_command.run(@options)
    end

    private
    
    attr_reader :input

    def registered_commands
      @registered_commands ||= Redis::Commands::Registry::REGISTERED_COMMANDS.each_with_object({}) do |registered_command, hash|
        hash[registered_command.command] = registered_command
      end
    end
  end
end