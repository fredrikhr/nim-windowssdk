import importc_helpers

type 
  Lcid* = distinct uint32
    ## ref.: https://msdn.microsoft.com/en-us/library/aa383751.aspx#LCID
  LangId* = distinct uint32
    ## ref.: https://msdn.microsoft.com/en-us/library/aa383751.aspx#LANGID

type BStr* = distinct WideCString
  ## A BSTR (Basic string or binary string) is a string data type that is used
  ## by COM, Automation, and Interop functions. Use the BSTR data type in all
  ## interfaces that will be accessed from script.
  ##
  ## ref.: https://msdn.microsoft.com/en-us/library/ms221069.aspx

type Variant_Bool* = distinct int16
implementDistinctEnum(Variant_Bool):
  const
    variant_true* = (-1).Variant_Bool ## MUST indicate a Boolean value of true.
    variant_false* = 0.Variant_Bool ## MUST indicate a Boolean value of false.
converter toBool*(v: Variant_Bool): bool = (v.int16 != 0)
converter toVariantBool*(b: bool): Variant_Bool = (if b: variant_true else: variant_false)
