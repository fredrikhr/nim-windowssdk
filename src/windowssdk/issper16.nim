## +-------------------------------------------------------------------------
## 
##   Microsoft Windows
##   Copyright (C) Microsoft Corporation, 1992-1999.
## 
##   File:      issperr.h
## 
##   Contents:  Constant definitions for OLE HRESULT values.
## 
##   History:   dd-mmm-yy Author    Comment
## 
##   Notes:
##      This is a generated file. Do not modify directly.
##      The MC tool generates this file from dsyserr.mc
## 
## --------------------------------------------------------------------------

import sspi

##  Define the severities
## 
##   Values are 32 bit values layed out as follows:
## 
##    3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
##    1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
##   +---+-+-+-----------------------+-------------------------------+
##   |Sev|C|R|     Facility          |               Code            |
##   +---+-+-+-----------------------+-------------------------------+
## 
##   where
## 
##       Sev - is the severity code
## 
##           00 - Success
##           01 - Informational
##           10 - Warning
##           11 - Error
## 
##       C - is the Customer code flag
## 
##       R - is a reserved bit
## 
##       Facility - is the facility code
## 
##       Code - is the facility's status code
## 
## 
##  Define the facility codes
## 
const
  FACILITY_SECURITY* = 0x00000009
  FACILITY_NULL* = 0
## 
##  Define the severity codes
## 
const
  STATUS_SEVERITY_SUCCESS* = 0x00000000
  STATUS_SEVERITY_COERROR* = 0x00000002
## 
##  MessageId: SEC_E_INSUFFICIENT_MEMORY
## 
##  MessageText:
## 
##   Not enough memory is available to complete this request
## 
const
  SEC_E_INSUFFICIENT_MEMORY* = (0x00001300).SecurityStatus
## 
##  MessageId: SEC_E_INVALID_HANDLE
## 
##  MessageText:
## 
##   The handle specified is invalid
## 
const
  SEC_E_INVALID_HANDLE* = (0x00001301).SecurityStatus
## 
##  MessageId: SEC_E_UNSUPPORTED_FUNCTION
## 
##  MessageText:
## 
##   The function requested is not supported
## 
const
  SEC_E_UNSUPPORTED_FUNCTION* = (0x00001302).SecurityStatus
## 
##  MessageId: SEC_E_TARGET_UNKNOWN
## 
##  MessageText:
## 
##   The specified target is unknown or unreachable
## 
const
  SEC_E_TARGET_UNKNOWN* = (0x00001303).SecurityStatus
## 
##  MessageId: SEC_E_INTERNAL_ERROR
## 
##  MessageText:
## 
##   The Local Security Authority cannot be contacted
## 
const
  SEC_E_INTERNAL_ERROR* = (0x00001304).SecurityStatus
## 
##  MessageId: SEC_E_SECPKG_NOT_FOUND
## 
##  MessageText:
## 
##   The requested security package does not exist
## 
const
  SEC_E_SECPKG_NOT_FOUND* = (0x00001305).SecurityStatus
## 
##  MessageId: SEC_E_NOT_OWNER
## 
##  MessageText:
## 
##   The caller is not the owner of the desired credentials
## 
const
  SEC_E_NOT_OWNER* = (0x00001306).SecurityStatus
## 
##  MessageId: SEC_E_CANNOT_INSTALL
## 
##  MessageText:
## 
##   The security package failed to initialize, and cannot be installed
## 
const
  SEC_E_CANNOT_INSTALL* = (0x00001307).SecurityStatus
## 
##  MessageId: SEC_E_INVALID_TOKEN
## 
##  MessageText:
## 
##   The token supplied to the function is invalid
## 
const
  SEC_E_INVALID_TOKEN* = (0x00001308).SecurityStatus
## 
##  MessageId: SEC_E_CANNOT_PACK
## 
##  MessageText:
## 
##   The security package is not able to marshall the logon buffer,
##   so the logon attempt has failed
## 
const
  SEC_E_CANNOT_PACK* = (0x00001309).SecurityStatus
## 
##  MessageId: SEC_E_QOP_NOT_SUPPORTED
## 
##  MessageText:
## 
##   The per-message Quality of Protection is not supported by the
##   security package
## 
const
  SEC_E_QOP_NOT_SUPPORTED* = (0x0000130A).SecurityStatus
## 
##  MessageId: SEC_E_NO_IMPERSONATION
## 
##  MessageText:
## 
##   The security context does not allow impersonation of the client
## 
const
  SEC_E_NO_IMPERSONATION* = (0x0000130B).SecurityStatus
## 
##  MessageId: SEC_E_LOGON_DENIED
## 
##  MessageText:
## 
##   The logon attempt failed
## 
const
  SEC_E_LOGON_DENIED* = (0x0000130C).SecurityStatus
## 
##  MessageId: SEC_E_UNKNOWN_CREDENTIALS
## 
##  MessageText:
## 
##   The credentials supplied to the package were not
##   recognized
## 
const
  SEC_E_UNKNOWN_CREDENTIALS* = (0x0000130D).SecurityStatus
## 
##  MessageId: SEC_E_NO_CREDENTIALS
## 
##  MessageText:
## 
##   No credentials are available in the security package
## 
const
  SEC_E_NO_CREDENTIALS* = (0x0000130E).SecurityStatus
## 
##  MessageId: SEC_E_MESSAGE_ALTERED
## 
##  MessageText:
## 
##   The message supplied for verification has been altered
## 
const
  SEC_E_MESSAGE_ALTERED* = (0x0000130F).SecurityStatus
## 
##  MessageId: SEC_E_OUT_OF_SEQUENCE
## 
##  MessageText:
## 
##   The message supplied for verification is out of sequence
## 
const
  SEC_E_OUT_OF_SEQUENCE* = (0x00001310).SecurityStatus
## 
##  MessageId: SEC_E_NO_AUTHENTICATING_AUTHORITY
## 
##  MessageText:
## 
##   No authority could be contacted for authentication.
## 
const
  SEC_E_NO_AUTHENTICATING_AUTHORITY* = (0x00001311).SecurityStatus
##  MessageId: SEC_E_CONTEXT_EXPIRED
## 
##  MessageText:
## 
##   The context has expired and can no longer be used.
## 
const
  SEC_E_CONTEXT_EXPIRED* = (0x00001312).SecurityStatus
## 
##  MessageId: SEC_E_INCOMPLETE_MESSAGE
## 
##  MessageText:
## 
##   The supplied message is incomplete.  The signature was not verified.
## 
const
  SEC_E_INCOMPLETE_MESSAGE* = (0x00001313).SecurityStatus
## 
##  MessageId: SEC_I_CONTINUE_NEEDED
## 
##  MessageText:
## 
##   The function completed successfully, but must be called
##   again to complete the context
## 
const
  SEC_I_CONTINUE_NEEDED* = (0x00001012).SecurityStatus
## 
##  MessageId: SEC_I_COMPLETE_NEEDED
## 
##  MessageText:
## 
##   The function completed successfully, but CompleteToken
##   must be called
## 
const
  SEC_I_COMPLETE_NEEDED* = (0x00001013).SecurityStatus
## 
##  MessageId: SEC_I_COMPLETE_AND_CONTINUE
## 
##  MessageText:
## 
##   The function completed successfully, but both CompleteToken
##   and this function must be called to complete the context
## 
const
  SEC_I_COMPLETE_AND_CONTINUE* = (0x00001014).SecurityStatus
## 
##  MessageId: SEC_I_LOCAL_LOGON
## 
##  MessageText:
## 
##   The logon was completed, but no network authority was
##   available.  The logon was made using locally known information
## 
const
  SEC_I_LOCAL_LOGON* = (0x00001015).SecurityStatus
## 
##  MessageId: SEC_E_OK
## 
##  MessageText:
## 
##   Call completed successfully
## 
const
  SEC_E_OK* = (0x00000000).SecurityStatus
## 
##  Older error names for backwards compatibility
## 
const
  SEC_E_NOT_SUPPORTED* = SEC_E_UNSUPPORTED_FUNCTION
  SEC_E_NO_SPM* = SEC_E_INTERNAL_ERROR
  SEC_E_BAD_PKGID* = SEC_E_SECPKG_NOT_FOUND
