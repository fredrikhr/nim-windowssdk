import importc_helpers

type SafeArrayBound* = object
  ## Represents the bounds of one dimension of the array.
  len*: uint32 ## The number of elements in the dimension.
  lBound*: int32 ## The lower bound of the dimension.

type Fadf* = distinct uint16
implementDistinctEnum(Fadf):
  const
    fadf_auto* = 0x1.Fadf ## An array that is allocated on the stack.
    fadf_static* = 0x2.Fadf ## An array that is statically allocated.
    fadf_embedded* = 0x4.Fadf ## An array that is embedded in a structure.
    fadf_fixedsize* = 0x10.Fadf ## An array that may not be resized or reallocated.
    fadf_record* = 0x20.Fadf ## An array that contains records. When set, there will be a pointer to the IRecordInfo interface at negative offset 4 in the array descriptor.
    fadf_haveiid* = 0x40.Fadf ## An array that has an IID identifying interface. When set, there will be a GUID at negative offset 16 in the safe array descriptor. Flag is set only when FADF_DISPATCH or FADF_UNKNOWN is also set.
    fadf_havevartype* = 0x80.Fadf ## An array that has a variant type. The variant type can be retrieved with safeArrayGetVartype.
    fadf_bstr* = 0x100.Fadf ## An array of BSTRs.
    fadf_unknown* = 0x200.Fadf ## An array of IUnknown*.
    fadf_dispatch* = 0x400.Fadf ## An array of IDispatch*.
    fadf_variant* = 0x800.Fadf ## An array of VARIANTs.
    fadf_reserved* = 0xf008.Fadf ## Bits reserved for future use.

type SafeArray* = object
  dims: uint16 ## The number of dimensions.
  features: Fadf ## Flags.
  element_size: uint32 ## The size of an array element.
  lock_count: uint32 ## The number of times the array has been locked without a corresponding unlock.
  data: pointer ## The data.
  rgsabound: UncheckedArray[SafeArrayBound] ## One bound for each dimension.
