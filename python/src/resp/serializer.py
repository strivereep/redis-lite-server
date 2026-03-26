class RespSerializer:
  CRLF = '\r\n'
  
  @classmethod
  def serialize(cls, data: any) -> bytes:
    # Consider bulk string
    # Ignore simple strings
    result:str = ''
    if data is None:
      result = f'$-1{cls.CRLF}'
    elif type(data) == bytes:
      result = f'${len(data)}{cls.CRLF}{data.decode('utf-8')}{cls.CRLF}'
    elif type(data) == int:
      result = f':{data}{cls.CRLF}'
    elif type(data) == list:
      header: str = f'*{len(data)}{cls.CRLF}'.encode('UTF-8')
      payload: str = b''.join([cls.serialize(datum) for datum in data])
      return b''.join([header, payload])
    elif type(data) == Exception:
      result = f'-{data}{cls.CRLF}'
    else:
      raise Exception(f"RESP Serialization failed. Invalid class: {type(data)}")
    
    return result.encode('UTF-8')