def valid_integer(value: bytes) -> bool:
  try:
    int(value)
    return True
  except ValueError:
    return False