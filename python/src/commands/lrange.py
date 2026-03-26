from .base import BaseCommand
from src.resp.serializer import RespSerializer

class LRange(BaseCommand):
  @classmethod
  def command(cls) -> bytes:
    return b'lrange'
  
  def run(self) -> bytes:
    key: bytes = self.args[0]
    if len(self.args[1:]) != 2:
      return b'-ERR wrong number of arguments for command'
    
    if not isinstance(self.store[key], list):
      return b'-ERR Invalid datatype'
    
    start_range: int = int(self.args[1])
    end_range: int = int(self.args[2])
    if end_range == -1:
      return RespSerializer.serialize(data=self.store[key][start_range:])
    else:
      return RespSerializer.serialize(data=self.store[key][start_range:end_range + 1])
