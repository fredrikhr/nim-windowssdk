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

import dynlib

proc coGetClassObject*(
  rclsid: ptr ClsId,
  dwClsContext: ClsCtx,
  pvReserved: pointer,
  riid: ptr Iid,
  ppv: var pointer
  ): HResult {.stdcall, importc: "CoGetClassObject", dynlib: "Ole32.dll".}
proc coGetClassObject*(
  clsid: ClsId,
  dwClsContext: ClsCtx,
  pvReserved: pointer,
  iid: Iid,
  ppv: var pointer
  ): HResult = coGetClassObject(clsid.unsafeAddr, dwClsContext, pvReserved, iid.unsafeAddr, ppv)
proc coGetClassObject*(
  clsid: ClsId,
  dwClsContext: ClsCtx,
  iid: Iid,
  ppv: var pointer
  ): HResult = coGetClassObject(clsid.unsafeAddr, dwClsContext, nil, iid.unsafeAddr, ppv)
proc coGetClassObject*[T](
  rclsid: ptr ClsId,
  dwClsContext: ClsCtx,
  pvReserved: pointer,
  riid: ptr Iid,
  ppt: var ptr T
  ): HResult = 
  var ppv: pointer
  result = coGetClassObject(rclsid, dwClsContext, pvReserved, riid, ppv)
  ppt = cast[ptr T](ppv)
proc coGetClassObject*[T](
  clsid: ClsId,
  dwClsContext: ClsCtx,
  pvReserved: pointer,
  iid: Iid,
  ppt: var ptr T
  ): HResult = 
  var ppv: pointer
  result = coGetClassObject(clsid.unsafeAddr, dwClsContext, pvReserved, iid.unsafeAddr, ppv)
  ppt = cast[ptr T](ppv)
proc coGetClassObject*[T](
  clsid: ClsId,
  dwClsContext: ClsCtx,
  iid: Iid,
  ppt: var ptr T
  ): HResult = 
  var ppv: pointer
  result = coGetClassObject(clsid.unsafeAddr, dwClsContext, nil, iid.unsafeAddr, ppv)
  ppt = cast[ptr T](ppv)

proc coCreateInstance*(
  rclsid: ptr ClsId,
  pUnkOuter: ptr IUnknown,
  dwClsContext: ClsCtx,
  riid: ptr Iid,
  ppv: var pointer
  ): HResult {.stdcall, importc: "CoCreateInstance", dynlib: "Ole32.dll".}
proc coCreateInstance*(
  clsid: ClsId,
  pUnkOuter: ptr IUnknown,
  dwClsContext: ClsCtx,
  iid: Iid,
  ppv: var pointer
  ): HResult = coCreateInstance(clsid.unsafeAddr, pUnkOuter, dwClsContext, iid.unsafeAddr, ppv)
proc coCreateInstance*(
  clsid: ClsId,
  dwClsContext: ClsCtx,
  iid: Iid,
  ppv: var pointer
  ): HResult = coCreateInstance(clsid.unsafeAddr, nil, dwClsContext, iid.unsafeAddr, ppv)
proc coCreateInstance*[T](
  rclsid: ptr ClsId,
  pUnkOuter: ptr IUnknown,
  dwClsContext: ClsCtx,
  riid: ptr Iid,
  ppt: var ptr T
  ): HResult =
  var ppv: pointer
  result = coCreateInstance(rclsid, pUnkOuter, dwClsContext, riid, ppv)
  ppt = cast[ptr T](ppv)
proc coCreateInstance*[T](
  clsid: ClsId,
  pUnkOuter: ptr IUnknown,
  dwClsContext: ClsCtx,
  iid: Iid,
  ppt: var ptr T
  ): HResult =
  var ppv: pointer
  result = coCreateInstance(clsid.unsafeAddr, pUnkOuter, dwClsContext, iid.unsafeAddr, ppv)
  ppt = cast[ptr T](ppv)
proc coCreateInstance*[T](
  clsid: ClsId,
  dwClsContext: ClsCtx,
  iid: Iid,
  ppt: var ptr T
  ): HResult =
  var ppv: pointer
  result = coCreateInstance(clsid.unsafeAddr, nil, dwClsContext, iid.unsafeAddr, ppv)
  ppt = cast[ptr T](ppv)
