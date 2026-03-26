from .base import BaseCommand
from src.resp.serializer import RespSerializer

class Echo(BaseCommand):
  @classmethod
  def command(cls) -> str:
    return b'echo'
  
  def run(self) -> bytes:
    combined_args = b''.join(self.args)
    return RespSerializer.serialize(data=combined_args)
  