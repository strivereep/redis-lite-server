from src.commands.registry import RegistryCommands
from typing import Union

class RedisCommand:
  @classmethod
  def run(cls, **kwargs):
    command: bytes = kwargs.get('command')
    registered_commands: dict = cls._registered_commands()
    redis_command = registered_commands.get(command)
    if redis_command:
      return redis_command(**kwargs).run()
    else:
      return '-ERR unknown command'

  @classmethod
  def _registered_commands(cls) -> dict:
    registry: dict = {}
    for command in RegistryCommands.commands():
      registry[command.command()] = command
    
    return registry