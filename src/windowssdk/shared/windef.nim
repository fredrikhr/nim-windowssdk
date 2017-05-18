##
##                                                                         
## windef.h -- Basic Windows Type Definitions                            
##                                                                        
## Copyright (c) Microsoft Corporation. All rights reserved.             
##                                                                         
##

import .. / um / winnt

type
  HWnd* = Handle
    ## ref.: https://msdn.microsoft.com/en-us/library/aa383751.aspx#HWND
  HHook* = Handle
    ## ref.: https://msdn.microsoft.com/en-us/library/aa383751.aspx#HHOOK

  HBitmap* = Handle
    ## ref.: https://msdn.microsoft.com/en-us/library/aa383751.aspx#HBITMAP
