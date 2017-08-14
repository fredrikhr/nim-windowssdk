import winnt

import dynlib

proc comInitialize(pvReserved: pointer): HResult {.stdcall, importc: "CoInitialize", dynlib: "Ole32.dll".}
  ## ref.: https://msdn.microsoft.com/en-us/library/ms678543.aspx
proc comInitialize*(): HResult = comInitialize(nil)
  ## ref.: https://msdn.microsoft.com/en-us/library/ms678543.aspx
