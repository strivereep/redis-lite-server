import asyncio
import time
import random

class RedisActiveExpire:
  CYCLE_INTERVAL = 5
  TIME_BUDGET = 0.25 * CYCLE_INTERVAL

  @classmethod
  async def run(cls, store: dict, expire_store):
    while True:
      start_time: float = time.monotonic()
      aggressive_loop_done: bool = False

      while not aggressive_loop_done:
        # if expire_store is empty
        # break the inner loop
        if not expire_store:
          break

        # sample 20 pairs from the store
        sample_pairs: dict = {}
        if len(expire_store) > 20:
          sample_list: list = random.sample(sorted(expire_store), 20)
          sample_pairs = { k:v for k,v in expire_store.items() if k in sample_list }
        else:
          sample_pairs = expire_store
        
        # use current time in ms
        current_time: float = time.time() * 1000
        expire_keys: list = [k for k, v in sample_pairs.items() if current_time > v]

        # check if num of expire keys from sample pairs is greater than 25%
        expired_keys_above_threshold: bool = len(expire_keys) / len(sample_pairs) >= 0.25
        aggressive_loop_done = False if expired_keys_above_threshold else True

        # delete the keys from the store
        for key in expire_keys:
          print(f"Deleting {len(expire_keys)} expired keys")
          store.pop(key)
          expire_store.pop(key)
        
        # check the time budget
        elapsed_time: float = time.monotonic()
        executed_time: float = elapsed_time - start_time
        if executed_time > cls.TIME_BUDGET:
          aggressive_loop_done = True
      
      execution_time:float = time.monotonic()
      # get sleep time
      sleep_time: float = max([0, cls.CYCLE_INTERVAL - execution_time])
      
      await asyncio.sleep(sleep_time)
      
