import .. / ansiwide

import .. / shared / windef

import winnt

ansiWideAll(CredUi_Info, CredUi_InfoA, CredUi_InfoW,
  LPTStr, LPStr, LPWStr):
  type CredUi_Info* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/aa375183.aspx
    size: uint32
    parent: HWnd
    messageText, captionText: LPTStr
    banner: HBitmap
