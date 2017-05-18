##############################################################################
##
## | Microsoft Windows
## | Copyright (c) Microsoft Corporation.  All rights reserved.
##
##  :File:       guiddef.h
##
##  :Contents:   GUID definition
##
##############################################################################

type Guid* = object
  ## ref.: https://msdn.microsoft.com/en-us/library/aa373931.aspx
  data1*: uint32
  data2*, data3*: uint16
  data4*: array[8, byte]

template define_Guid*(name: untyped, long: uint32, w1, w2: uint16, b1, b2, b3, b4, b5, b6, b7, b8: byte): typed =
  const name = Guid(data1: long, data2: w1, data3: w2, data4: [b1, b2, b3, b4, b5, b6, b7, b8])

template define_OleGuid*(name: untyped, long: uint32, w1, w2: uint16): typed =
  const name = Guid(data1: long, data2: w1, data3: w2, data4: [0xC0, 0, 0, 0, 0, 0, 0, 0x46])

type Iid* = Guid
type ClsId* = Guid
type FmtId* = Guid
