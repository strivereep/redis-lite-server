from .base import BaseCommand
from src.resp.serializer import RespSerializer

class RPush(BaseCommand):
  @classmethod
  def command(cls) -> bytes:
    return b'rpush'
  
  def run(self) -> bytes:
    if len(self.args) < 2:
      return b'ERR wrong number of arguments for command'
    
    key: bytes = self.args[0]
    values: list[bytes] = self.args[1:]
    store_list: list[bytes] = self.store.get(key, [])
    if not isinstance(store_list, list):
      return b'-ERR Invalid datatype'

    for value in values:
      store_list.append(value)
    
    self.store[key] = store_list
    return RespSerializer.serialize(data=len(self.store[key]))
