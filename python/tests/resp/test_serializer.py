import pytest
from src.resp.serializer import RespSerializer

@pytest.mark.parametrize("data, expected", [
  (b"Hello World", b"$11\r\nHello World\r\n"),
  (25, b":25\r\n"),
  ([b'GET', 10, b'VALUE'], b"*3\r\n$3\r\nGET\r\n:10\r\n$5\r\nVALUE\r\n"),
  (Exception('Error message'), b'-Error message\r\n')
])
def test_serialize(data, expected):
  assert RespSerializer.serialize(data) == expected