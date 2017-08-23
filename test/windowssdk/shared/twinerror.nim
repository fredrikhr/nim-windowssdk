import .. / .. / .. / src / windowssdk / shared / winerror

block `WinError.$`:
  assert($ error_success == "ERROR_SUCCESS", $ error_success)

block `HResult.$`:
  assert($ e_notimpl == "E_NOTIMPL", $e_notimpl)
