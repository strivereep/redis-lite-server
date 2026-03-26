from .base import BaseCommand
from src.resp.serializer import RespSerializer

class Ping(BaseCommand):
  @classmethod
  def command(cls) -> str:
    return b'ping'
  
  def run(self) -> bytes:
    return RespSerializer.serialize(b'PONG')