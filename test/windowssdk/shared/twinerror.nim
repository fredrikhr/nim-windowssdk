import .. / .. / .. / src / windowssdk / shared / winerror

when defined(useWinErrorStringify):
  block `WinError.$`:
    assert($ error_success == "error_success", $ error_success)

  block `HResult.$`:
    assert($ e_notimpl == "e_notimpl", $e_notimpl)
