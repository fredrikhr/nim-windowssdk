type
  AnySizeArray* {.unchecked.} [T] = array[0, T]
  AnySizeArrayRef*[T] = ref AnySizeArray[T]
  AnySizeArrayPtr*[T] = ptr AnySizeArray[T]
