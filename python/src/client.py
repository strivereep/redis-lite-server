import socket
from argparse import ArgumentParser
from .resp.serializer import RespSerializer
from .resp.deserializer import RespDeserializer
import asyncio

class RedisClient:
  def __init__(self, host: str = '127.0.0.1', port: int = 6379) -> None:
    self.host = host
    self.port = port
    self.socket = None

  async def run(self):
    parser = ArgumentParser(prog="redis-cli")
    parser.add_argument("inputs", nargs="+", help="Arguments for running redis cli")
    args = parser.parse_args()
    inputs: list[bytes] = [input.encode('UTF-8') if isinstance(input, str) else input for input in args.inputs]
    reader, writer = await asyncio.open_connection(host=self.host, port=self.port)
    serialized_data: bytes = RespSerializer.serialize(data=inputs)
    writer.write(serialized_data)
    await writer.drain()

    data: bytes = await reader.read(4096)
    deserializer: RespDeserializer = RespDeserializer(data=data)
    response = deserializer.deserialize()
    if isinstance(response, bytes):
      print(response.decode('UTF-8'))
    elif isinstance(response, list):
      print([ele.decode('UTF-8') if isinstance(ele, bytes) else ele for ele in response])
    else:
      print(response)
    
    writer.close()
    await writer.wait_closed()

if __name__ == "__main__":
  client = RedisClient()
  asyncio.run(client.run())