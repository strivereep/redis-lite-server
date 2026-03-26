from .base import BaseCommand
from src.resp.serializer import RespSerializer
from datetime import datetime
from time import time

class Set(BaseCommand):
  @classmethod
  def command(cls) -> bytes:
    return b'set'
  
  def run(self) -> bytes:
    key: bytes = self.args[0]
    value: bytes = self.args[1]
    if len(self.args) > 2:
      expire_type: bytes = self.args[2]
      if expire_type:
        expire_type = expire_type.lower()
        expire_time: bytes = self.args[3]
        if not expire_time:
          return RespSerializer.serialize(Exception('No Expire time'))

      self._register_expire_keys(key=key, expire_type=expire_type, expire_time=expire_time)

    self.store[key] = value
    return RespSerializer.serialize(b'OK')
  
  def _register_expire_keys(self, key: bytes, expire_type: bytes, expire_time: bytes):
    ttl: int = int(expire_time.decode('UTF-8'))
    expire_at: int = 0
    if expire_type == b'ex':
      expire_at = (time() + ttl) * 1000
    elif expire_type == b'px':
      expire_at = time() * 1000 + ttl
    elif expire_type == b'exat':
      expire_at = ttl * 1000
    elif expire_type == b'pxat':
      expire_at = ttl
    
    self.expire_store[key] = expire_at