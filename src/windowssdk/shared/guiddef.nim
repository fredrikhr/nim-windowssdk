##
##
## | Microsoft Windows
## | Copyright (c) Microsoft Corporation.  All rights reserved.
##
## :File:       guiddef.h
##
## :Contents:   GUID definition
##
##

type Guid* = object
  ## ref.: https://msdn.microsoft.com/en-us/library/aa373931.aspx
  data1*: uint32
  data2*, data3*: uint16
  data4*: array[8, byte]

const guid_size = sizeof(uint32) + 2 * sizeof(uint16) + 8 * sizeof(byte)

type Iid* = Guid
type ClsId* = Guid
type FmtId* = Guid

proc newGuid*(guid: string): Guid {.compileTime.} =
  var
    byteChars: array[guid_size * 2, byte]
    i = 0
    j = 0
  while j < len(byteChars):
    var inc_j = 1
    case guid[i]
    of '0': byteChars[j] = 0
    of '1': byteChars[j] = 1
    of '2': byteChars[j] = 2
    of '3': byteChars[j] = 3
    of '4': byteChars[j] = 4
    of '5': byteChars[j] = 5
    of '6': byteChars[j] = 6
    of '7': byteChars[j] = 7
    of '8': byteChars[j] = 8
    of '9': byteChars[j] = 9
    of 'A', 'a': byteChars[j] = 10
    of 'B', 'b': byteChars[j] = 11
    of 'C', 'c': byteChars[j] = 12
    of 'D', 'd': byteChars[j] = 13
    of 'E', 'e': byteChars[j] = 14
    of 'F', 'f': byteChars[j] = 15
    else: inc_j = 0
    inc(j, inc_j)
    inc i
  j = 0
  proc convertToValue[T: (uint32 | uint16 | byte)](bytes: openarray[byte], i: var int): T =
    const
      size = sizeof(T)
      hexes = size * 2
    for j in 0 ..< hexes:
      let b = bytes[i + j]
      let shift = (hexes - 1 - j) * 4
      let v: T = b.T shl shift
      result = result or v
    inc(i, hexes)
  let d1 = convertToValue[uint32](byteChars, j)
  let d2 = convertToValue[uint16](byteChars, j)
  let d3 = convertToValue[uint16](byteChars, j)
  var d4: array[8, byte]
  for k in 0 ..< len(d4):
    d4[k] = convertToValue[byte](byteChars, j)
  result = Guid(data1: d1, data2: d2, data3: d3, data4: d4)
proc newIid*(iid: string): Iid {.compileTime.} = newGuid(iid).Iid
proc newClsId*(iid: string): ClsId {.compileTime.} = newGuid(iid).ClsId
proc newFmtId*(iid: string): FmtId {.compileTime.} = newGuid(iid).FmtId
