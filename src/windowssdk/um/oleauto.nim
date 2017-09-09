##   Microsoft Windows
##
##   Copyright (c) Microsoft Corporation. All rights reserved.
## 
##   :File:       oleauto.h
##   :Contents:   Defines Ole Automation support function prototypes, constants

import .. / shared / winerror
import .. / shared / wtypes

import dynlib

{.pragma: oleautodll, dynlib: "OleAut32.dll" .}

#[
  /*---------------------------------------------------------------------*/
  /*                            BSTR API                                 */
  /*---------------------------------------------------------------------*/
]#
proc sysAllocString*(psz: WideCString
  ): BStr {.stdcall, importc: "SysAllocString", oleautodll.}
  ## Allocates a new string and copies the passed string into it.
  ##
  ## ref.: https://msdn.microsoft.com/en-us/library/ms221458.aspx
proc sysReAllocString_Int(pbstr: var BStr, psz: WideCString
  ): int32 {.stdcall, importc: "SysReAllocString", oleautodll.}
  ## Reallocates a previously allocated string to be the size of a second
  ## string and copies the second string into the reallocated memory.
  ##
  ## ref.: https://msdn.microsoft.com/en-us/library/ms220986.aspx
proc sysReAllocString*(pbstr: var BStr, psz: WideCString
  ): bool = (sysReAllocString_Int(pbstr, psz) != 0)
  ## Reallocates a previously allocated string to be the size of a second
  ## string and copies the second string into the reallocated memory.
  ##
  ## ref.: https://msdn.microsoft.com/en-us/library/ms220986.aspx
proc SysAllocStringLen*(strIn: WideCString, ui: uint32): BStr {.
  stdcall, importc: "SysAllocStringLen", oleautodll.}
  ## Allocates a new string, copies the specified number of characters from
  ## the passed string, and appends a null-terminating character.
  ##
  ## ref.: https://msdn.microsoft.com/en-us/library/ms221639.aspx
proc sysReAllocStringLen_Int(pbstr: var BStr, psz: WideCString, len: uint32
  ): int32 {.stdcall, importc: "SysAllocStringLen", oleautodll.}
  ## Creates a new BSTR containing a specified number of characters from an
  ## old BSTR, and frees the old BSTR.
  ##
  ## ref.: https://msdn.microsoft.com/en-us/library/ms221533.aspx
proc sysReAllocStringLen*(pbstr: var BStr, psz: WideCString, len: uint32
  ): bool = (sysReAllocStringLen_Int(pbstr, psz, len) != 0)
  ## Creates a new BSTR containing a specified number of characters from an
  ## old BSTR, and frees the old BSTR.
  ##
  ## ref.: https://msdn.microsoft.com/en-us/library/ms221533.aspx
proc sysAddRefString*(bstrString: BStr): HResult {.
  stdcall, importc: "SysAddRefString", oleautodll.}
  ## Increases the pinning reference count for the specified string by one.
  ##
  ## ref.: https://msdn.microsoft.com/en-us/library/mt492452.aspx
proc sysReleaseString*(bstrString: BStr) {.
  stdcall, importc: "SysReleaseString", oleautodll.}
  ## Decreases the pinning reference count for the specified string by one.
  ## When that count reaches 0, the memory for that string is no longer
  ## prevented from being freed.
  ##
  ## ref.: https://msdn.microsoft.com/en-us/library/mt492453.aspx
proc sysFreeString*(bstrString: BStr) {.
  stdcall, importc: "SysFreeString", oleautodll.}
  ## Deallocates a string allocated previously by sysAllocString,
  ## sysAllocStringByteLen, sysReAllocString, sysAllocStringLen, or
  ## sysReAllocStringLen.
  ##
  ## ref.: https://msdn.microsoft.com/en-us/library/ms221481.aspx
proc sysStringLen*(bstrString: BStr): uint32 {.
  stdcall, importc: "SysStringLen", oleautodll.}
  ## Returns the length of a BSTR.
  ##
  ## ref.: https://msdn.microsoft.com/en-us/library/ms221240.aspx
proc len*(bstr: BStr): uint32 = sysStringLen(bstr)
  ## Returns the length of a BSTR.
proc sysStringByteLen*(bstr: BStr): uint32 {.
  stdcall, importc: "SysStringByteLen", oleautodll.}
  ## Returns the length (in bytes) of a BSTR.
  ##
  ## ref.: https://msdn.microsoft.com/en-us/library/ms221097.aspx
proc size*(bstr: BStr): uint32 = sysStringByteLen(bstr)
  ## Returns the length (in bytes) of a BSTR.
proc sysAllocStringByteLen*(psz: cstring, len: uint32): BStr {.
  stdcall, importc: "SysAllocStringByteLen", oleautodll.}
  ## Takes an ANSI string as input, and returns a BSTR that contains an ANSI
  ## string. Does not perform any ANSI-to-Unicode translation.
  ##
  ## ref.: https://msdn.microsoft.com/en-us/library/ms221637.aspx
