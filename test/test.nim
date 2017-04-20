import .. / src / windowssdk / security, .. / src / anysize_array, .. / src / ansiwide

var secHandle: SecHandle
secInvalidateHandle(addr secHandle)
assert(not secIsValidHandle(addr secHandle))
secHandle.upper = secDeletedHandle
secHandle.lower = secDeletedHandle

var
  pkgLen: uint32
  pkgs: AnySizeArrayRef[SecPkgInfo]

## ref.: https://msdn.microsoft.com/en-us/library/aa375397.aspx
var secStatus = enumerateSecurityPackages(pkgLen, pkgs)
echo secStatus
echo pkgLen
if secStatus == 0:
  for i in 0..(pkgLen - 1):
    echo pkgs[i]
secStatus = freeContextBuffer(cast[pointer](pkgs))
echo secStatus

var pSecFnTable = initSecurityInterface()
if pSecFnTable.isNil():
  echo "nil"
else:
  echo pSecFnTable[]

ansiWideWhen(LPTStr, cstring, WideCString):
  var saslProfileList: AnySizeArrayRef[LPTStr]
var saslProfileCount: uint32

secStatus = saslEnumerateProfiles(saslProfileList, saslProfileCount)
echo secStatus
echo saslProfileCount
if secStatus == 0:
  for i in 0..(saslProfileCount - 1):
    echo saslProfileList[i]
