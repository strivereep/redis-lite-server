from .base import BaseCommand
from src.resp.serializer import RespSerializer
import os

class Save(BaseCommand):
  SAVE_PATH = 'snapshot/save.rdb'

  @classmethod
  def command(cls) -> bytes:
    return b'save'
  
  def run(self) -> bytes:
    self.saved_pid = os.fork()
    if self.saved_pid == 0:
      with open(self.SAVE_PATH, 'w') as f:
        for key, value in self.store.items():
          f.write(f'{key}:{value}\n')
      os._exit(0)

      # return RespSerializer.serialize(b'OK')
