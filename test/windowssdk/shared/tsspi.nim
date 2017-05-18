import .. / .. / .. / src / windowssdk / shared / sspi
import .. / .. / .. / src / windowssdk / shared / issperr

block acquireCredentialsHandle:
  var
    credHandle: CredHandle
    timeStamp: TimeStamp
    sec_status = sec_e_ok
  sec_status = sspiAcquireCredentialsHandle(
    principal = nil,
    package = nil,
    credentialUse = 0.SecPkg_Cred_Use,
    logonId = nil,
    authData = nil,
    getKeyFn = nil,
    getKeyArgument = nil,
    credential = credHandle,
    expiry = timeStamp
    )
  echo "sec_status: " & $sec_status & " (" & $(sec_status.uint32) & ")"
