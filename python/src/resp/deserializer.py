from typing import Union

class RespDeserializer:
  CRLF = b'\r\n'
  CRLF_SIZE = len(CRLF)

  def __init__(self, data: bytes) -> None:
    self.data = data
    self.cursor = 0
  
  def deserialize(self):
    first_byte: bytes = self.data[self.cursor:self.cursor+1]
    self.cursor += 1
    if first_byte == b'+':
      return self._read_line()
    elif first_byte == b':':
      return int(self._read_line())
    elif first_byte == b'$':
      return self._read_bulk_string()
    elif first_byte == b'*':
      return self._read_array()
    elif first_byte == b'-':
      return Exception(self._read_line())
  
  def _read_bulk_string(self) -> bytes:
    string_len: int = int(self._read_line())
    if string_len == -1:
      return None
    
    crlf_index: int = self.data.find(self.CRLF, self.cursor)
    value: bytes = self.data[self.cursor:crlf_index]
    self.cursor = crlf_index + self.CRLF_SIZE
    return value
  
  def _read_array(self) -> list[bytes]:
    array_size: int = int(self._read_line())
    if array_size == -1:
      return None
    
    result: list = []
    for i in range(0, array_size):
      result.append(self.deserialize())
    
    return result

  def _read_line(self) -> bytes:
    crlf_index: int = self.data.find(self.CRLF, self.cursor)
    value: bytes = self.data[self.cursor:crlf_index]
    self.cursor = crlf_index + self.CRLF_SIZE
    return value
