from .base import BaseCommand
from src.resp.serializer import RespSerializer
from time import time

class Get(BaseCommand):
  @classmethod
  def command(cls) -> bytes:
    return b'get'
  
  def run(self) -> bytes:
    key: bytes = self.args[0]
    if self._has_key_expired(key=key):
      self.expire_store.pop(key)
      self.store.pop(key)
      return RespSerializer.serialize(data=None)

    return RespSerializer.serialize(data=self.store.get(key))

  def _has_key_expired(self, key: bytes) -> bool:
    ttl = self.expire_store.get(key)
    if ttl:
      return True if time() * 1000 > ttl else False

    return False
  