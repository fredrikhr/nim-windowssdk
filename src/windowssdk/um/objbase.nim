import .. / shared / winerror

import dynlib

proc coInitialize(pvReserved: pointer): HResult {.stdcall, importc: "CoInitialize", dynlib: "Ole32.dll".}
  ## ref.: https://msdn.microsoft.com/en-us/library/ms678543.aspx
proc coInitialize*(): HResult = coInitialize(nil)
  ## ref.: https://msdn.microsoft.com/en-us/library/ms678543.aspx
