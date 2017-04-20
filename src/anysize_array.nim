type
  AnySizeArray* {.unchecked.} [T] = array[0..0, T]
  PAnySizeArray*[T] = ptr AnySizeArray[T]
  AnySizeArrayRef*[T] = ref AnySizeArray[T]
