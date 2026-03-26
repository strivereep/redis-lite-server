from abc import ABC, abstractmethod, abstractclassmethod

class BaseCommand(ABC):
  @abstractclassmethod
  def command(cls) -> bytes:
    pass

  def __init__(self, **kwargs) -> None:
    self.args: list = kwargs.get('args')
    self.store: dict = kwargs.get('store')
    self.expire_store: dict = kwargs.get('expire_store')
    self.saved_pid: int = kwargs.get('saved_pid')
    self.subscribed_channels: dict = kwargs.get('subscribed_channels')
  
  @abstractmethod
  def run(self):
    pass
