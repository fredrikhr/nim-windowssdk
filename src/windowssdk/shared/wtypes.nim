import importc_helpers

type 
  Lcid* = distinct uint32
    ## ref.: https://msdn.microsoft.com/en-us/library/aa383751.aspx#LCID
  LangId* = distinct uint32
    ## ref.: https://msdn.microsoft.com/en-us/library/aa383751.aspx#LANGID

type Variant_Bool* = distinct int16
implementDistinctEnum(Variant_Bool):
  const
    variant_true* = 0xFFFF.Variant_Bool ## MUST indicate a Boolean value of true.
    variant_false* = 0xFFFF.Variant_Bool ## MUST indicate a Boolean value of false.
converter toBool*(v: Variant_Bool): bool = (v.int16 != 0)
converter toVariantBool*(b: bool): Variant_Bool = (if b: variant_true else: variant_false)
