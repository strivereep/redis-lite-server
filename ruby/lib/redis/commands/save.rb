require_relative './base'

module Redis
  module Commands
    class Save < Base
      SNAPSHOT_PATH = 'snapshot/dump.rdb'.freeze
      
      def self.command
        'save'
      end
      
      def run
        @save_pid = Process.fork do
          File.open(SNAPSHOT_PATH, 'w') do |f|
            @store.each do |key, value|
              f.write("#{key}:#{value}\n")
            end
          end
        end
        
        Redis::Resp::Serializer.serialize(:OK)
      end
    end
  end
end