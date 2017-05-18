## | minwindef.h -- Basic Windows Type Definitions for minwin partition      
## | Copyright (c) Microsoft Corporation. All rights reserved.               

const max_path* = 260

type Bool* = distinct int32
const
  False* = 0.Bool
  True* = 1.Bool

proc toWinBool*(b: bool): Bool {.inline.} = 
  if b: True else: False
proc toBool*(b: Bool): bool {.inline.} = 
  if b.int32 == 0: false else: true

when defined(useWinSdk):
  proc makeWord*(a, b: byte): uint16 {.header: "<minwindef.h>", importc: "MAKEWORD".}
  proc makeLong*(a, b: uint16): uint32 {.header: "<minwindef.h>", importc: "MAKELONG".}
  proc lowWord*(long: uint32): uint16 {.header: "<minwindef.h>", importc: "LOWORD".}
  proc highWord*(long: uint32): uint16 {.header: "<minwindef.h>", importc: "HIWORD".}
  proc lowByte*(w: uint32): byte {.header: "<minwindef.h>", importc: "LOBYTE".}
  proc highByte*(w: uint32): byte {.header: "<minwindef.h>", importc: "HIBYTE".}
else:
  proc makeWord*(a, b: byte): auto = (a or (b shl 8)).uint16
  proc makeLong*(a, b: uint16): auto = (a or (b shl 16)).uint32
  proc lowWord*(long: uint32): auto = (long and 0xffff).uint16
  proc highWord*(long: uint32): auto = ((long shr 16) and 0xffff).uint16
  proc lowByte*(w: uint32): auto = (w and 0xff).byte
  proc highByte*(w: uint32): auto = ((w shr 8) and 0xff).byte
