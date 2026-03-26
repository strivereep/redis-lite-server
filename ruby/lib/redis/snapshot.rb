require 'json'

module Redis
  class Snapshot
    def self.load_on_start(store:)
      puts "Loading keys from snapshot..."

      path = Redis::Commands::Save::SNAPSHOT_PATH
      if File.exist?(path)
        snapshot = File.read(path)
        unless snapshot.empty?
          snapshot.split("\n").each do |ss|
            splited_ss = ss.split(":")
            key = splited_ss[0]
            value = store_value(splited_ss[1])
            store[key] = value
          end
        end
      end
    end

    private

    def store_value(value)
      JSON.parse(value)
    rescue
      value
    end
  end
end