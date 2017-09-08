##
##
## | Microsoft Windows
## | Copyright (c) Microsoft Corporation. All rights reserved.
##
## :File:       combaseapi.h
##
## :Contents:   Base Component Object Model defintions.
##
##


import unknwn
import .. / shared / guiddef, .. / shared / wtypesbase, .. / shared / winerror

import os, dynlib

proc coGetClassObject*[T](
  rclsid: ptr ClsId,
  dwClsContext: ClsCtx,
  pvReserved: pointer,
  riid: ptr Iid,
  ppt: var ptr T
  ): HResult {.stdcall, importc: "CoGetClassObject", dynlib: "Ole32.dll".}
  ## Provides a pointer to an interface on a class object associated with a specified CLSID.
  ## CoGetClassObject locates, and if necessary, dynamically loads the executable code required to do this.
  ## 
  ## ref.: https://msdn.microsoft.com/en-us/library/ms684007.aspx
proc coGetClassObject*[T](
  rclsid: ptr ClsId,
  dwClsContext: ClsCtx,
  riid: ptr Iid,
  ppt: var ptr T
  ): HResult = coGetClassObject(rclsid, dwClsContext, nil, riid, ppt)
  ## Provides a pointer to an interface on a class object associated with a specified CLSID.
  ## CoGetClassObject locates, and if necessary, dynamically loads the executable code required to do this.
  ## 
  ## ref.: https://msdn.microsoft.com/en-us/library/ms684007.aspx
proc coGetClassObject*[T](
  clsid: ClsId,
  dwClsContext: ClsCtx,
  iid: Iid,
  ppt: var ptr T
  ): HResult = 
  ## Provides a pointer to an interface on a class object associated with a specified CLSID.
  ## CoGetClassObject locates, and if necessary, dynamically loads the executable code required to do this.
  ## 
  ## ref.: https://msdn.microsoft.com/en-us/library/ms684007.aspx
  ## 
  ## Overload that accepts the CLSID and IID as values instead of pointers.
  result = coGetClassObject(clsid.unsafeAddr, dwClsContext, nil, iid.unsafeAddr, ppt)
proc coGetClassObject*[T](
  rclsid: ptr ClsId,
  dwClsContext: ClsCtx,
  pvReserved: pointer,
  riid: ptr Iid): ptr T =
  ## Returns a pointer to an interface on a class object associated with a specified CLSID.
  ## CoGetClassObject locates, and if necessary, dynamically loads the executable code required to do this.
  ## 
  ## ref.: https://msdn.microsoft.com/en-us/library/ms684007.aspx
  let hr = coGetClassObject(rclsid, dwClsContext, pvReserved, riid, result)
  if hr.failed: raiseOSError(hr)
proc coGetClassObject*[T](
  rclsid: ptr ClsId,
  dwClsContext: ClsCtx,
  riid: ptr Iid
  ): ptr T = coGetClassObject(rclsid, dwClsContext, nil, riid)
  ## Returns a pointer to an interface on a class object associated with a specified CLSID.
  ## CoGetClassObject locates, and if necessary, dynamically loads the executable code required to do this.
  ## 
  ## ref.: https://msdn.microsoft.com/en-us/library/ms684007.aspx
proc coGetClassObject*[T](
  clsid: ClsId,
  dwClsContext: ClsCtx,
  pvReserved: pointer,
  iid: Iid
  ): ptr T = coGetClassObject(clsid.unsafeAddr, dwClsContext, pvReserved, iid.unsafeAddr)
  ## Returns a pointer to an interface on a class object associated with a specified CLSID.
  ## CoGetClassObject locates, and if necessary, dynamically loads the executable code required to do this.
  ## 
  ## ref.: https://msdn.microsoft.com/en-us/library/ms684007.aspx
  ## 
  ## Overload that accepts the CLSID and IID as values instead of pointers.
proc coGetClassObject*[T](
  clsid: ClsId,
  dwClsContext: ClsCtx,
  iid: Iid
  ): ptr T = coGetClassObject(clsid.unsafeAddr, dwClsContext, nil, iid.unsafeAddr)
  ## Returns a pointer to an interface on a class object associated with a specified CLSID.
  ## CoGetClassObject locates, and if necessary, dynamically loads the executable code required to do this.
  ## 
  ## ref.: https://msdn.microsoft.com/en-us/library/ms684007.aspx
  ## 
  ## Overload that accepts the CLSID and IID as values instead of pointers.

proc coCreateInstance*[T](
  rclsid: ptr ClsId,
  pUnkOuter: ptr IUnknown,
  dwClsContext: ClsCtx,
  riid: ptr Iid,
  ppt: var ptr T
  ): HResult {.stdcall, importc: "CoCreateInstance", dynlib: "Ole32.dll".}
  ## Creates a single uninitialized object of the class associated with a specified CLSID.
  ##
  ## ref.: https://msdn.microsoft.com/en-us/library/ms686615.aspx
proc coCreateInstance*[T](
  clsid: ClsId,
  pUnkOuter: ptr IUnknown,
  dwClsContext: ClsCtx,
  iid: Iid,
  ppt: var ptr T
  ): HResult = coCreateInstance[T](clsid.unsafeAddr, pUnkOuter, dwClsContext, iid.unsafeAddr, ppt)
  ## Creates a single uninitialized object of the class associated with a specified CLSID.
  ##
  ## ref.: https://msdn.microsoft.com/en-us/library/ms686615.aspx
proc coCreateInstance*[T](
  rclsid: ptr ClsId,
  dwClsContext: ClsCtx,
  riid: ptr Iid,
  ppt: var ptr T
  ): HResult = coCreateInstance[T](rclsid, nil, dwClsContext, riid, ppt)
  ## Creates a single uninitialized object of the class associated with a specified CLSID.
  ##
  ## ref.: https://msdn.microsoft.com/en-us/library/ms686615.aspx
proc coCreateInstance*[T](
  clsid: ClsId,
  dwClsContext: ClsCtx,
  iid: Iid,
  ppt: var ptr T
  ): HResult = coCreateInstance[T](clsid.unsafeAddr, nil, dwClsContext, iid.unsafeAddr, ppt)
  ## Creates a single uninitialized object of the class associated with a specified CLSID.
  ##
  ## ref.: https://msdn.microsoft.com/en-us/library/ms686615.aspx
proc coCreateInstance*[T](
  rclsid: ptr ClsId,
  pUnkOuter: ptr IUnknown,
  dwClsContext: ClsCtx,
  riid: ptr Iid
  ): ptr T =
  ## Returns a single uninitialized object of the class associated with a specified CLSID.
  ##
  ## ref.: https://msdn.microsoft.com/en-us/library/ms686615.aspx
  let hr = coCreateInstance[T](rclsid, pUnkOuter, dwClsContext, riid, result)
  if hr.failed: raiseOSError(hr)
proc coCreateInstance*[T](
  clsid: ClsId,
  pUnkOuter: ptr IUnknown,
  dwClsContext: ClsCtx,
  iid: Iid
  ): ptr T = coCreateInstance[T](clsid.unsafeAddr, pUnkOuter, dwClsContext, iid.unsafeAddr)
  ## Returns a single uninitialized object of the class associated with a specified CLSID.
  ##
  ## ref.: https://msdn.microsoft.com/en-us/library/ms686615.aspx
proc coCreateInstance*[T](
  rclsid: ptr ClsId,
  dwClsContext: ClsCtx,
  riid: ptr Iid
  ): ptr T = coCreateInstance[T](rclsid, nil, dwClsContext, riid)
  ## Returns a single uninitialized object of the class associated with a specified CLSID.
  ##
  ## ref.: https://msdn.microsoft.com/en-us/library/ms686615.aspx
proc coCreateInstance*[T](
  clsid: ClsId,
  dwClsContext: ClsCtx,
  iid: Iid
  ): ptr T = coCreateInstance[T](clsid.unsafeAddr, nil, dwClsContext, iid.unsafeAddr)
  ## Returns a single uninitialized object of the class associated with a specified CLSID.
  ##
  ## ref.: https://msdn.microsoft.com/en-us/library/ms686615.aspx
