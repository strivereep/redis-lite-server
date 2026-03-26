module Redis
  class ActiveExpire
    CYCLE_INTERVAL = 5.freeze
    TIME_BUDGET = 0.25 * CYCLE_INTERVAL
    
    def self.run(expire_keys:, store:, mutex:)
      Thread.new do
        loop do
          start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          aggressive_loop_done = false

          until aggressive_loop_done      
            keys_to_delete = mutex.synchronize do
              break [] if expire_keys.empty?

              current_time_ms = Time.now.to_i * 1000
              # pick up random keys and check if they need to expire
              sampled_pairs = expire_keys.to_a.sample(20).to_h
              expired_sample = sampled_pairs.select { |_, v| v < current_time_ms }

              # check the expired key from sample hash
              # is greater than 25% threshold
              expired_key_ratio_above_threshold = (expired_sample.size / sampled_pairs.size) > 0.25
              if expired_key_ratio_above_threshold
                aggressive_loop_done = false
              else
                aggressive_loop_done = true
              end

              expired_sample.map(&:first)
            end
            
            
            mutex.synchronize do
              # delete the key from the hash
              puts "Keys deleted: #{keys_to_delete.size}" unless keys_to_delete.empty?
              
              keys_to_delete.each do |key|
                expire_keys.delete(key)
                store.delete(key)
              end
            end
    
            elapsed_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time
            # break the loop clean up task >= TIME_BUDGET
            if elapsed_time > TIME_BUDGET
              aggressive_loop_done = true
            end
          end
    
          execution_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time
          # calcuate sleep time
          # max of 0 and cycle interval - total executed time
          sleep_time = [0, CYCLE_INTERVAL - execution_time].max
          sleep(sleep_time)
        end
      end
    end
  end
end