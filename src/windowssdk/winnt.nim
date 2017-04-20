#[++ BUILD Version: 0073     Increment this if a change has global effects

Copyright (c) Microsoft Corporation. All rights reserved.

Module Name:

    winnt.h

Abstract:

    This module defines the 32-Bit Windows types and constants that are
    defined by NT, but exposed through the Win32 API.

Revision History:

--]#

#include <ctype.h>  
#include <winapifamily.h>  

#include <specstrings.h>
#include <kernelspecs.h>

#include <basetsd.h>

type 
  WChar* = Utf16Char

type
  ## UCS (Universal Character Set) types
  UcsChar* = uint32

const
  ##
  ## Even pre-Unicode agreement, UCS values are always in the
  ## range U+00000000 to U+7FFFFFFF, so we'll pick an obvious
  ## value.
  ##
  ucschar_invalid_character* = (0xffffffff).UcsChar

  min_ucschar* = (0).UcsChar

  ##
  ## We'll assume here that the ISO-10646 / Unicode agreement
  ## not to assign code points after U+0010FFFF holds so that
  ## we do not have to have separate "UCSCHAR" and "UNICODECHAR"
  ## types.
  ##
  max_ucschar* = (0x0010FFFF).UcsChar

type 
  LargeInteger* = int64
  PLargeInteger* = ptr LargeInteger
  ULargeInteger* = uint64
  PULargeInteger* = ptr ULargeInteger

  ## Locally Unique Identifier
  Luid* = object
    lowPart: uint32
    highPart: int32
  PLuid* = ptr Luid

const
  ansi_null* = (0).char
  unicode_null* = (0).WChar
  unicode_string_max_bytes* = 65534.uint16
  unicode_string_max_chars* = 32767
type
  Boolean* = byte
  PBoolean* = ptr Boolean

converter toBoolean*(v: bool): Boolean = result = if v: 1 else: 0
