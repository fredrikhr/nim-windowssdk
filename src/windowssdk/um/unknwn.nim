import .. / shared / guiddef
import .. / shared / winerror
import .. / importc_windowssdk

when defined(useWindowsSdk):
  {.pragma: sdkHeader, header: "<Unknwn.h>".}
else:
  {.pragma: sdkHeader.}

whenUseWindowsSdk:
  {.importc: "IID_IUnknown", sdkHeader.}
  const iid_IUnknown* : Iid = Iid(data1: 0x00000000, data2: 0x0000, data3: 0x0000, data4: [0xC0'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x46'u8])

type
  IUnknownVtbl* = object
    queryInterface: proc(this: ptr IUnknown, riid: ptr Iid, ppvObject: pointer): HResult {.stdcall.}
    addRef: proc(this: ptr IUnknown): HResult {.stdcall.}
    release: proc(this: ptr IUnknown): HResult {.stdcall.}
  IUnknown* = object
    lpVtbl: ptr IUnknownVtbl

proc queryInterface*(this: ptr IUnknown, riid: ptr Iid, ppvObject: pointer): HResult = 
  this.lpVtbl.queryInterface(this, riid, ppvObject)
proc addRef*(this: ptr IUnknown): HResult = 
  this.lpVtbl.addRef(this)
proc release*(this: ptr IUnknown): HResult = 
  this.lpVtbl.release(this)

whenUseWindowsSdk:
  {.importc: "IID_AsyncIUnknown", sdkHeader.}
  const iid_AsyncIUnknown* : Iid = Iid(data1: 0x000e0000, data2: 0x0000, data3: 0x0000, data4: [0xC0'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x46'u8])

type
  AsyncIUnknownVtbl* = object
    vtbl_IUnknown: IUnknownVtbl
    begin_QueryInterface: proc(this: ptr AsyncIUnknown, riid: ptr Iid): HResult {.stdcall.}
    finish_QueryInterface: proc(this: ptr AsyncIUnknown, ppvObject: pointer): HResult {.stdcall.}
    begin_AddRef: proc(this: ptr AsyncIUnknown): HResult {.stdcall.}
    finish_AddRef: proc(this: ptr AsyncIUnknown): HResult {.stdcall.}
    begin_Release: proc(this: ptr AsyncIUnknown): HResult {.stdcall.}
    finish_Release: proc(this: ptr AsyncIUnknown): HResult {.stdcall.}
  AsyncIUnknown* = object
    lpVtbl: ptr AsyncIUnknownVtbl

converter toIUnknown*(x: ptr AsyncIUnknown): ptr IUnknown = cast[ptr IUnknown](x)

proc begin_QueryInterface*(this: ptr AsyncIUnknown, riid: ptr Iid): HResult =
  this.lpVtbl.begin_QueryInterface(this, riid)
proc finish_QueryInterface*(this: ptr AsyncIUnknown, ppvObject: pointer): HResult =
  this.lpVtbl.finish_QueryInterface(this, ppvObject)
proc begin_AddRef*(this: ptr AsyncIUnknown): HResult =
  this.lpVtbl.begin_AddRef(this)
proc finish_AddRef*(this: ptr AsyncIUnknown): HResult =
  this.lpVtbl.finish_AddRef(this)
proc begin_Release*(this: ptr AsyncIUnknown): HResult =
  this.lpVtbl.begin_Release(this)
proc finish_Release*(this: ptr AsyncIUnknown): HResult =
  this.lpVtbl.finish_Release(this)
