import .. / shared / guiddef
import .. / shared / winerror
import .. / importc_windowssdk

import os

when defined(useWindowsSdk):
  {.pragma: sdkHeader, header: "<Unknwn.h>".}
else:
  {.pragma: sdkHeader.}

whenUseWindowsSdk:
  {.importc: "IID_IUnknown", sdkHeader.}
  const iid_IUnknown*: Iid = newIid("00000000-0000-0000-C000-000000000046")

type
  IUnknownVtbl* = object
    queryInterface: proc(this: ptr IUnknown, riid: ptr Iid, ppvObject: var pointer): HResult {.stdcall.}
    addRef: proc(this: ptr IUnknown): HResult {.stdcall.}
    release: proc(this: ptr IUnknown): HResult {.stdcall.}
  IUnknown* = object
    lpVtbl: ptr IUnknownVtbl

proc queryInterface*(this: ptr IUnknown, riid: ptr Iid, ppvObject: var pointer): HResult = 
  this.lpVtbl.queryInterface(this, riid, ppvObject)
proc queryInterface*(this: ptr IUnknown, iid: Iid, ppvObject: var pointer): HResult =
  queryInterface(this, iid.unsafeAddr, ppvObject)
proc queryInterface*[T](this: ptr IUnknown, riid: ptr Iid, pptObject: var ptr T): HResult =
  var ppvObject: pointer
  result = queryInterface(this, riid, ppvObject)
  pptObject = cast[ptr T](ppvObject)
proc queryInterface*[T](this: ptr IUnknown, iid: Iid, pptObject: var ptr T): HResult =
  queryInterface[T](this, iid.unsafeAddr, pptObject)
proc queryInterface*[T](this: ptr IUnknown, riid: ptr Iid): ptr T =
  let hr = queryInterface[T](this, riid, result)
  if hr.failed: raiseOSError(hr)
proc queryInterface*[T](this: ptr IUnknown, iid: Iid): ptr T =
  queryInterface[T](this, iid.unsafeAddr)
proc addRef_HResult*(this: ptr IUnknown): HResult = 
  this.lpVtbl.addRef(this)
proc addRef*(this: ptr IUnknown) = 
  let hr = addRef_HResult(this)
  if hr.failed: raiseOSError(hr)
proc release_HResult*(this: ptr IUnknown): HResult = 
  this.lpVtbl.release(this)
proc release*(this: ptr IUnknown) =
  let hr = release_HResult(this)
  if hr.failed: raiseOSError(hr)

whenUseWindowsSdk:
  {.importc: "IID_AsyncIUnknown", sdkHeader.}
  var iid_AsyncIUnknown* : Iid = newIid("000e0000-0000-0000-C000-000000000046")

type
  AsyncIUnknownVtbl* = object
    vtbl_IUnknown: IUnknownVtbl
    begin_QueryInterface: proc(this: ptr AsyncIUnknown, riid: ptr Iid): HResult {.stdcall.}
    finish_QueryInterface: proc(this: ptr AsyncIUnknown, ppvObject: var pointer): HResult {.stdcall.}
    begin_AddRef: proc(this: ptr AsyncIUnknown): HResult {.stdcall.}
    finish_AddRef: proc(this: ptr AsyncIUnknown): HResult {.stdcall.}
    begin_Release: proc(this: ptr AsyncIUnknown): HResult {.stdcall.}
    finish_Release: proc(this: ptr AsyncIUnknown): HResult {.stdcall.}
  AsyncIUnknown* = object
    lpVtbl: ptr AsyncIUnknownVtbl

converter toIUnknown*(x: ptr AsyncIUnknown): ptr IUnknown = cast[ptr IUnknown](x)

proc begin_QueryInterface*(this: ptr AsyncIUnknown, riid: ptr Iid): HResult =
  this.lpVtbl.begin_QueryInterface(this, riid)
proc begin_QueryInterface*(this: ptr AsyncIUnknown, iid: Iid): HResult =
  begin_QueryInterface(this, iid.unsafeAddr)
proc finish_QueryInterface*(this: ptr AsyncIUnknown, ppvObject: var pointer): HResult =
  this.lpVtbl.finish_QueryInterface(this, ppvObject)
proc finish_QueryInterface*(this: ptr AsyncIUnknown): pointer =
  let hr = finish_QueryInterface(this, result)
  if hr.failed: raiseOSError(hr)
proc finish_QueryInterface*[T](this: ptr AsyncIUnknown, pptObject: var ptr T): HResult =
  var ppvObject: pointer
  result = finish_QueryInterface(this, ppvObject)
  pptObject = cast[ptr T](ppvObject)
proc finish_QueryInterface*[T](this: ptr AsyncIUnknown): ptr T =
  let hr = finish_QueryInterface[T](this, result)
  if hr.failed: raiseOSError(hr)
proc begin_AddRef_HResult*(this: ptr AsyncIUnknown): HResult =
  this.lpVtbl.begin_AddRef(this)
proc begin_AddRef*(this: ptr AsyncIUnknown) =
  let hr = begin_AddRef_HResult(this)
  if hr.failed: raiseOSError(hr)
proc finish_AddRef_HResult*(this: ptr AsyncIUnknown): HResult =
  this.lpVtbl.finish_AddRef(this)
proc finish_AddRef*(this: ptr AsyncIUnknown): HResult =
  let hr = finish_AddRef_HResult(this)
  if hr.failed: raiseOSError(hr)
proc begin_Release_HResult*(this: ptr AsyncIUnknown): HResult =
  this.lpVtbl.begin_Release(this)
proc begin_Release*(this: ptr AsyncIUnknown) =
  let hr = begin_Release_HResult(this)
  if hr.failed: raiseOSError(hr)
proc finish_Release_HResult*(this: ptr AsyncIUnknown): HResult =
  this.lpVtbl.finish_Release(this)
proc finish_Release*(this: ptr AsyncIUnknown) =
  let hr = finish_Release_HResult(this)
  if hr.failed: raiseOSError(hr)
