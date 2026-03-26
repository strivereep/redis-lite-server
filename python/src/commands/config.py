from .base import BaseCommand
from src.resp.serializer import RespSerializer

class Config(BaseCommand):
  @classmethod
  def command(cls) -> bytes:
    return b'config'
  
  def run(self) -> bytes:
    config = self.args[-1]
    if config.downcase == b'save':
      # "*2\r\n$4\r\nsave\r\n$0\r\n\r\n"
      return RespSerializer.serialize([b'save', b''])
    elif config.downcase == b'appendonly':
      # "*2\r\n$10\r\nappendonly\r\n$2\r\nno\r\n"
      return RespSerializer.serialize([b'appendonly', b'no'])
    