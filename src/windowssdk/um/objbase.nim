import .. / shared / winerror

import os

proc coInitialize_HResult(pvReserved: pointer): HResult {.stdcall, importc: "CoInitialize", dynlib: "Ole32.dll".}
  ## ref.: https://msdn.microsoft.com/en-us/library/ms678543.aspx
proc coInitialize_HResult*(): HResult = coInitialize_HResult(nil)
  ## ref.: https://msdn.microsoft.com/en-us/library/ms678543.aspx
proc coInitialize*(pvReserved: pointer) =
  ## ref.: https://msdn.microsoft.com/en-us/library/ms678543.aspx
  let hr = coInitialize_HResult(pvReserved)
  if hr.failed: raiseOSError(hr)
proc coInitialize*() = coInitialize(nil)
  ## ref.: https://msdn.microsoft.com/en-us/library/ms678543.aspx
