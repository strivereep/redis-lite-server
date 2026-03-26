from .base import BaseCommand
from src.resp.serializer import RespSerializer
import asyncio

class Publish(BaseCommand):
  @classmethod
  def command(cls) -> bytes:
    return b'publish'
  
  def run(self):
    channel_name: bytes = self.args[0]
    message: bytes = self.args[1]
    count: int = 0

    stream_writers: list[asyncio.StreamWriter] = self.subscribed_channels[channel_name] or []
    if channel_name and message:
      if stream_writers:
        payload = RespSerializer.serialize(data=[b'message', channel_name, message])
        for stream_writer in stream_writers:
          stream_writer.write(payload)
          asyncio.create_task(stream_writer.drain())
          count += 1
    
    return RespSerializer.serialize(data=count)
      