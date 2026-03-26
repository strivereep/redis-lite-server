from .base import BaseCommand
from src.resp.serializer import RespSerializer

class Delete(BaseCommand):
  @classmethod
  def command(cls) -> bytes:
    return b'del'
  
  def run(self) -> bytes:
    keys_deleted: int = 0
    for arg in self.args:
      if arg in self.store.keys():
        self.store.pop(arg)
        keys_deleted += 1
    
    return RespSerializer.serialize(data=keys_deleted)
