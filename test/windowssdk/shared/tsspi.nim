import strutils

import .. / .. / .. / src / windowssdk / anysize_array

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

block enumerateSecurityPackages:
  var
    sec_status = sec_e_ok
    packagesLen: uint32
    packages: AnySizeArrayPtr[SecPkgInfo]
  sec_status = sspiEnumerateSecurityPackages(packagesLen, packages)
  assert(sec_status == sec_e_ok, $sec_status)
  echo "Number of returned security packages: $#" % [$packagesLen]
  assert(not packages.isNil, "packages pointer is nil")
  try:
    for i in 0..<packagesLen:
      echo packages[i]
  finally:
    sec_status = sspiFreeContextBuffer(packages)
    assert(sec_status == sec_e_ok, $sec_status)
    packages = nil
