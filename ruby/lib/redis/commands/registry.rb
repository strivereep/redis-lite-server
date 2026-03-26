require_relative './config'
require_relative './decr'
require_relative './del'
require_relative './echo'
require_relative './exists'
require_relative './get'
require_relative './incr'
require_relative './lpush'
require_relative './lrange'
require_relative './ping'
require_relative './publish'
require_relative './rpush'
require_relative './save'
require_relative './set'

module Redis
  module Commands
    module Registry
      REGISTERED_COMMANDS = [
        Redis::Commands::Config,
        Redis::Commands::Decr,
        Redis::Commands::Del,
        Redis::Commands::Echo,
        Redis::Commands::Exists,
        Redis::Commands::Get,
        Redis::Commands::Incr,
        Redis::Commands::LPush,
        Redis::Commands::LRange,
        Redis::Commands::Ping,
        Redis::Commands::Publish,
        Redis::Commands::RPush,
        Redis::Commands::Save,
        Redis::Commands::Set
    ].freeze
    end
  end
end