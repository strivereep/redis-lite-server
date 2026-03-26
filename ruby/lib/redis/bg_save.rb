require_relative '../redis/commands/save'

module Redis
  class BgSave
    SLEEP_INTERVAL = 5.freeze
    
    # @params [Hash]
    # keys: store [Hash], save_pid [Integer(pid)]
    def self.run(store:, save_pid:)
      Thread.new do
        loop do
          begin
            Process.getpgid(save_pid)
          rescue Errno::ESRCH
          rescue
            unless store.size.zero?
              puts "Saving keys: #{store.size}"
              Redis::Commands::Save.run(store: store)
            end
          end

          # sleep the thread for 5 seconds
          sleep(SLEEP_INTERVAL)
        end
      end
    end
  end
end