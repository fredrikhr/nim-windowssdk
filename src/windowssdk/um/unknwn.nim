import .. / shared / guiddef
import .. / shared / winerror
import .. / importc_windowssdk

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
proc addRef*(this: ptr IUnknown): HResult = 
  this.lpVtbl.addRef(this)
proc release*(this: ptr IUnknown): HResult = 
  this.lpVtbl.release(this)

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
proc finish_QueryInterface*[T](this: ptr AsyncIUnknown, pptObject: var ptr T): HResult =
  var ppvObject: pointer
  result = finish_QueryInterface(this, ppvObject)
  pptObject = cast[ptr T](ppvObject)
proc begin_AddRef*(this: ptr AsyncIUnknown): HResult =
  this.lpVtbl.begin_AddRef(this)
proc finish_AddRef*(this: ptr AsyncIUnknown): HResult =
  this.lpVtbl.finish_AddRef(this)
proc begin_Release*(this: ptr AsyncIUnknown): HResult =
  this.lpVtbl.begin_Release(this)
proc finish_Release*(this: ptr AsyncIUnknown): HResult =
  this.lpVtbl.finish_Release(this)
