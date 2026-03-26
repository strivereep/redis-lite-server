from .resp.deserializer import RespDeserializer
from .resp.serializer import RespSerializer
from .command import RedisCommand
from .commands.save import Save
import asyncio
from ast import literal_eval
from .active_expire import RedisActiveExpire
from .bg_save import bg_save
from typing import Union

class RedisServer:
  def __init__(self, host: str = '127.0.0.1', port: int = 6379) -> None:
    self.host: str = host
    self.port: int = port
    self.store: dict = {}
    self.expire_store: dict = {}
    self.saved_pid: Union[None|int] = None
    self.subscribed_channels: dict = {}
    self._load_snapshot()
  
  def _load_snapshot(self):
    with open(Save.SAVE_PATH) as f:
      saved: str = f.read().rstrip().split('\n')
      for val in saved:
        key, value = val.split(':')
        self.store[literal_eval(key)] = literal_eval(value)
  
  async def handle_client(self, reader: asyncio.StreamReader, writer: asyncio.StreamWriter):
    addr = writer.get_extra_info('peername')
    print(f"Connection established with {addr}")
    try:
      while True:
        data: bytes = await reader.read(4096)
        if not data:
          break

        deserializer: RespDeserializer = RespDeserializer(data=data)
        deserializer_data: list[bytes] = deserializer.deserialize()
        command: bytes = deserializer_data[0]
        if command:
          command = command.lower()
        
        if command == b'subscribe':
          channel_name: bytes = deserializer_data[1]
          if not self.subscribed_channels.get(channel_name):
            self.subscribed_channels[channel_name] = []
          
          self.subscribed_channels[channel_name].append(writer)
          payload: bytes = RespSerializer.serialize(data=[b'subscribe', channel_name, 1])
          writer.write(payload)
          await writer.drain()

          # Enter pub/sub loop, wait for disconnect
          # waits for client to close the connection
          await reader.read(4096)

          self.subscribed_channels[channel_name].remove(writer)
          break
        else:
          args: list[bytes] = deserializer_data[1:]
          response = RedisCommand.run(command=command, args=args, store=self.store, expire_store=self.expire_store, saved_pid=self.saved_pid, subscribed_channels=self.subscribed_channels)
          writer.write(response)
          await writer.drain()
    except ConnectionResetError:
      print(f"Client {addr} disconnected.")
    finally:
      print(f"Closing connection for clien {addr}")
      writer.close()
      await writer.wait_closed()

  async def start(self):
    server = await asyncio.start_server(self.handle_client, self.host, self.port)
    addr = server.sockets[0].getsockname()
    print(f"Async Server listening on {addr}")

    asyncio.create_task(RedisActiveExpire.run(store=self.store, expire_store=self.expire_store))
    asyncio.create_task(bg_save(store=self.store, saved_pid=self.saved_pid))
    async with server:
      await server.serve_forever()

if __name__ == "__main__":
  server = RedisServer()
  try:
    asyncio.run(server.start())
  except KeyboardInterrupt:
    print('Shutting down server...')