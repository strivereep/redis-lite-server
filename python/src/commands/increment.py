from .base import BaseCommand
from src.resp.serializer import RespSerializer
from .valid_integer import valid_integer

class Increment(BaseCommand):
  @classmethod
  def command(cls) -> bytes:
    return b'incr'
  
  def run(self) -> bytes:
    key: bytes = self.args[0]
    value = self.store.get(key, None)
    if value:
      if valid_integer(value=value):
        self.store[key] = int(value) + 1
      else:
        return b'-ERR value is not an integer or out of range'
    else:
      self.store[key] = 1

    return RespSerializer.serialize(data=self.store[key])
