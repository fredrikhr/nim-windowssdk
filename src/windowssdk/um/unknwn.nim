import .. / shared / guiddef
import winnt
import .. / importc_windowssdk

when defined(useWindowsSdk):
  const sdkHeader = "<Unknwn.h>"
  {.pragma: sdkHeader, header: "<Unknwn.h>".}
  {.pragma: typeImportc, importc, sdkHeader.}
else:
  {.pragma: sdkHeader.}
  {.pragma: typeImportc.}

whenUseWindowsSdk:
  {.importc: "IID_IUnknown", sdkHeader.}
  const iid_IUnknown* : Iid = Iid(data1: 0x00000000, data2: 0x0000, data3: 0x0000, data4: [0xC0'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x46'u8])

type
  IUnknownVtbl* {.typeImportc.} = object
    queryInterface {.importc: "QueryInterface".}: proc(this: ptr IUnknown, riid: ptr Iid, ppvObject: pointer): HResult {.stdcall.}
    addRef {.importc: "AddRef".}: proc(this: ptr IUnknown): HResult {.stdcall.}
    release {.importc: "Release".}: proc(this: ptr IUnknown): HResult {.stdcall.}
  IUnknown* {.typeImportc.} = object
    lpVtbl {.importc.}: ptr IUnknownVtbl

whenUseWindowsSdk:
  {.importc: "IUnknown_QueryInterface", sdkHeader.}
  proc queryInterface*(this: ptr IUnknown, riid: ptr Iid, ppvObject: pointer): HResult = 
    this.lpVtbl.queryInterface(this, riid, ppvObject)
  {.importc: "IUnknown_AddRef", sdkHeader.}
  proc addRef*(this: ptr IUnknown): HResult = 
    this.lpVtbl.addRef(this)
  {.importc: "IUnknown_Release", sdkHeader.}
  proc release*(this: ptr IUnknown): HResult = 
    this.lpVtbl.release(this)

whenUseWindowsSdk:
  {.importc: "IID_AsyncIUnknown", sdkHeader.}
  const iid_AsyncIUnknown* : Iid = Iid(data1: 0x000e0000, data2: 0x0000, data3: 0x0000, data4: [0xC0'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x46'u8])

type
  AsyncIUnknownVtbl* {.typeImportc.} = object
    vtbl_IUnknown: IUnknownVtbl
    begin_QueryInterface {.importc: "Begin_QueryInterface".}: proc(this: ptr AsyncIUnknown, riid: ptr Iid): HResult {.stdcall.}
    finish_QueryInterface {.importc: "Finish_QueryInterface".}: proc(this: ptr AsyncIUnknown, ppvObject: pointer): HResult {.stdcall.}
    begin_AddRef {.importc: "Begin_AddRef".}: proc(this: ptr AsyncIUnknown): HResult {.stdcall.}
    finish_AddRef {.importc: "Finish_AddRef".}: proc(this: ptr AsyncIUnknown): HResult {.stdcall.}
    begin_Release {.importc: "Begin_Release".}: proc(this: ptr AsyncIUnknown): HResult {.stdcall.}
    finish_Release {.importc: "Finish_Release".}: proc(this: ptr AsyncIUnknown): HResult {.stdcall.}
  AsyncIUnknown* {.typeImportc.} = object
    lpVtbl {.importc.}: ptr AsyncIUnknownVtbl

converter toIUnknown*(x: ptr AsyncIUnknown): ptr IUnknown = cast[ptr IUnknown](x)

whenUseWindowsSdk:
  {.importc: "AsyncIUnknown_Begin_QueryInterface", sdkHeader.}
  proc begin_QueryInterface*(this: ptr AsyncIUnknown, riid: ptr Iid): HResult =
    this.lpVtbl.begin_QueryInterface(this, riid)
  {.importc: "AsyncIUnknown_Finish_QueryInterface", sdkHeader.}
  proc finish_QueryInterface*(this: ptr AsyncIUnknown, ppvObject: pointer): HResult =
    this.lpVtbl.finish_QueryInterface(this, ppvObject)
  {.importc: "AsyncIUnknown_Begin_AddRef", sdkHeader.}
  proc begin_AddRef*(this: ptr AsyncIUnknown): HResult =
    this.lpVtbl.begin_AddRef(this)
  {.importc: "AsyncIUnknown_Finish_AddRef", sdkHeader.}
  proc finish_AddRef*(this: ptr AsyncIUnknown): HResult =
    this.lpVtbl.finish_AddRef(this)
  {.importc: "AsyncIUnknown_Begin_Release", sdkHeader.}
  proc begin_Release*(this: ptr AsyncIUnknown): HResult =
    this.lpVtbl.begin_Release(this)
  {.importc: "AsyncIUnknown_Finish_Release", sdkHeader.}
  proc finish_Release*(this: ptr AsyncIUnknown): HResult =
    this.lpVtbl.finish_Release(this)
