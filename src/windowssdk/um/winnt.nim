##[
++ BUILD Version: 0073     Increment this if a change has global effects

Copyright (c) Microsoft Corporation. All rights reserved.

Module Name:

    winnt.h

Abstract:

    This module defines the 32-Bit Windows types and constants that are
    defined by NT, but exposed through the Win32 API.

Revision History:

--
]##

import .. / ansiwide

type
  WChar* = Utf16Char
    ## ref.: https://msdn.microsoft.com/en-us/library/aa383751.aspx#WCHAR
  Char* = cchar
    ## ref.: https://msdn.microsoft.com/en-us/library/aa383751.aspx#CHAR

type
  LPWStr* = WideCString
    ## ref.: https://msdn.microsoft.com/en-us/library/aa383751.aspx#LPWSTR

type
  LPStr* = cstring
    ## ref.: https://msdn.microsoft.com/en-us/library/aa383751.aspx#LPSTR

ansiWideWhen(tIdent = AnsiWideChar, ansiIdent = Char, wideIdent = WChar):
  type TChar* = AnsiWideChar
    ## ref.: https://msdn.microsoft.com/en-us/library/aa383751.aspx#TCHAR
ansiWideWhen(tIdent = AnsiWideStr, ansiIdent = LPStr, wideIdent = LPWStr):
  type LPTStr* = AnsiWideStr
    ## ref.: https://msdn.microsoft.com/en-us/library/aa383751.aspx#LPTSTR

type
  LargeInteger* = int64
  PLargeInteger* = ptr LargeInteger

  ULargeInteger* = uint64
  PULargeInteger* = ptr ULargeInteger

type
  Luid* = object
    ## Locally Unique Identifier
    ## ref.: https://msdn.microsoft.com/en-us/library/aa379261.aspx
    lowPart: uint32
    highPart: int32
  PLuid* = ptr Luid

type Boolean* = distinct byte
proc toBoolean*(b: bool): Boolean {.inline.} = 
  if b: 1.Boolean else: 0.Boolean
proc toBool*(b: Boolean): bool {.inline.} =
  if b.byte == 0: false else: true
