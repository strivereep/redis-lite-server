from .echo import Echo
from .ping import Ping
from .set import Set
from .get import Get
from .config import Config
from .exists import Exists
from .delete import Delete
from .increment import Increment
from .decrement import Decrement
from .lpush import LPush
from .lrange import LRange
from .rpush import RPush
from .save import Save
from .publish import Publish

class RegistryCommands:
  @classmethod
  def commands(cls) -> list:
    return [
      Config,
      Decrement,
      Delete,
      Echo,
      Exists,
      Get,
      Increment,
      LPush,
      LRange,
      Ping,
      Publish,
      RPush,
      Save,
      Set
    ]
