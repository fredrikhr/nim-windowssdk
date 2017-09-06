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

proc coGetClassObject*(
  rclsid: ptr ClsId,
  dwClsContext: ClsCtx,
  pvReserved: pointer,
  riid: ptr Iid,
  ppv: var pointer
  ): HResult {.stdcall, importc: "CoGetClassObject", dynlib: "Ole32.dll".}
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
proc coGetClassObject*(
  rclsid: ptr ClsId,
  dwClsContext: ClsCtx,
  riid: ptr Iid,
  ppv: var pointer
  ): HResult = coGetClassObject(rclsid, dwClsContext, nil, riid, ppv)
proc coGetClassObject*[T](
  rclsid: ptr ClsId,
  dwClsContext: ClsCtx,
  riid: ptr Iid,
  ppt: var ptr T
  ): HResult = coGetClassObject[T](rclsid, dwClsContext, nil, riid, ppt)
proc coGetClassObject*(
  clsid: ClsId,
  dwClsContext: ClsCtx,
  iid: Iid,
  ppv: var pointer
  ): HResult = 
  result = coGetClassObject(clsid.unsafeAddr, dwClsContext, nil, iid.unsafeAddr, ppv)
proc coGetClassObject*[T](
  clsid: ClsId,
  dwClsContext: ClsCtx,
  iid: Iid,
  ppt: var ptr T
  ): HResult = 
  result = coGetClassObject[T](clsid.unsafeAddr, dwClsContext, nil, iid.unsafeAddr, ppt)

proc coCreateInstance*(
  rclsid: ptr ClsId,
  pUnkOuter: ptr IUnknown,
  dwClsContext: ClsCtx,
  riid: ptr Iid,
  ppv: var pointer
  ): HResult {.stdcall, importc: "CoCreateInstance", dynlib: "Ole32.dll".}
proc coCreateInstance*[T](rclsid: ptr ClsId, pUnkOuter: ptr IUnknown,
  dwClsContext: ClsCtx, riid: ptr Iid, ppt: var ptr T): HResult =
  var ppv: pointer
  result = coCreateInstance(rclsid, pUnkOuter, dwClsContext, riid, ppv)
  ppt = cast[ptr T](ppv)
proc coCreateInstance*(clsid: ClsId, pUnkOuter: ptr IUnknown, clsContext: ClsCtx, iid: Iid, ppv: var pointer): HResult =
  result = coCreateInstance(clsid.unsafeAddr, pUnkOuter, clsContext, iid.unsafeAddr, ppv)
proc coCreateInstance*[T](clsid: ClsId, pUnkOuter: ptr IUnknown, clsContext: ClsCtx, iid: Iid, ppt: var ptr T): HResult =
  var ppv: pointer
  result = coCreateInstance(clsid.unsafeAddr, pUnkOuter, clsContext, iid.unsafeAddr, ppv)
  ppt = cast[ptr T](ppv)
proc coCreateInstance*(clsid: ClsId, clsContext: ClsCtx, iid: Iid, ppv: var pointer): HResult = coCreateInstance(clsid, nil, clsContext, iid, ppv)
proc coCreateInstance*[T](clsid: ClsId, clsContext: ClsCtx, iid: Iid, ppt: var ptr T): HResult = coCreateInstance[T](clsid, nil, clsContext, iid, ppt)
