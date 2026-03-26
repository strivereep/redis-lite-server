from src.commands.save import Save
import os
import asyncio

SLEEP_INTERVAL = 5

async def bg_save(store: dict, saved_pid: int):
  while True:
    try:
      child_id, _ = os.waitpid(saved_pid, os.WNOHANG)
      if child_id == 0:
        pass
    except TypeError:
      print(f"Saving keys: {len(store)}")
      Save(store=store).run()
    
    await asyncio.sleep(SLEEP_INTERVAL)
