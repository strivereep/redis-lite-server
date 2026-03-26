from .base import BaseCommand
from src.resp.serializer import RespSerializer

class Exists(BaseCommand):
  @classmethod
  def command(cls) -> bytes:
    return b'exists'
  
  def run(self) -> bytes:
    exists: int = 0
    store_keys: list[bytes] = self.store.keys()
    for arg in self.args:
      exists += 1 if arg in store_keys else 0
    
    return RespSerializer.serialize(exists)
  