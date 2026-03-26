import pytest
from src.resp.deserializer import RespDeserializer

@pytest.mark.parametrize("data, expected", [
  (b"+PING\r\n", b"PING"),
  (b"+OK\r\n", b"OK"),
  (b":25\r\n", 25),
  (b"$11\r\nHello World\r\n", b"Hello World"),
  (b"*3\r\n$3\r\nGET\r\n:10\r\n$5\r\nVALUE\r\n", [b'GET', 10, b'VALUE']),
  (b"$-1\r\n", None),
  (b"*1\r\n$4\r\nping\r\n", [b'ping']),
  (b"*2\r\n$4\r\necho\r\n$11\r\nhello world\r\n", [b'echo', b'hello world']),
  (b"*2\r\n$3\r\nget\r\n$3\r\nkey\r\n", [b'get', b'key']),
  (b"+OK\r\n", b"OK"),
  (b"$0\r\n\r\n", b""),
  (b"+hello world\r\n", b"hello world")
])
def test_deserialize(data, expected):
  assert RespDeserializer(data=data).deserialize() == expected

def test_exceptions():
  data = b"-Error message\r\n"
  assert type(RespDeserializer(data).deserialize()) == Exception