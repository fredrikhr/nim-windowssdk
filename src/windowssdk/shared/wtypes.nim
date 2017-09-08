type
  BstrObj = object
    len*: int32
    data*: UncheckedArray[Utf16Char]
  BStr* = ptr BstrObj
