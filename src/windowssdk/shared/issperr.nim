##
##
## | Microsoft Windows
## | Copyright (C) Microsoft Corporation, 1992-1999.
##
## :File:      issperr.h
##
## :Contents:  Constant definitions for OLE HRESULT values.
##
## :History:   dd-mmm-yy Author    Comment
##
## :Notes:
##     This is a generated file. Do not modify directly.
##     The MC tool generates this file from dsyserr.mc
##
##

import .. / cdefine_to_string

import sspi

const
  sec_e_insufficient_memory* = 0x1300.SecurityStatus
    ## Not enough memory is available to complete this request

  sec_e_invalid_handle* = 0x1301.SecurityStatus
    ## The handle specified is invalid

  sec_e_unsupported_function* = 0x1302.SecurityStatus
    ## The function requested is not supported


  sec_e_target_unknown* = 0x1303.SecurityStatus
    ## The specified target is unknown or unreachable

  sec_e_internal_error* = 0x1304.SecurityStatus
    ## The Local Security Authority cannot be contacted

  sec_e_secpkg_not_found* = 0x1305.SecurityStatus
    ## The requested security package does not exist


  sec_e_not_owner* = 0x1306.SecurityStatus
    ## The caller is not the owner of the desired credentials

  sec_e_cannot_install* = 0x1307.SecurityStatus
    ## The security package failed to initialize, and cannot be installed

  sec_e_invalid_token* = 0x1308.SecurityStatus
    ## The token supplied to the function is invalid

  sec_e_cannot_pack* = 0x1309.SecurityStatus
    ## The security package is not able to marshall the logon buffer,
    ## so the logon attempt has failed

  sec_e_qop_not_supported* = 0x130A.SecurityStatus
    ## The per-message Quality of Protection is not supported by the
    ## security package

  sec_e_no_impersonation* = 0x130B.SecurityStatus
    ## The security context does not allow impersonation of the client

  sec_e_logon_denied* = 0x130C.SecurityStatus
    ## The logon attempt failed

  sec_e_unknown_credentials* = 0x130D.SecurityStatus
    ## The credentials supplied to the package were not
    ## recognized

  sec_e_no_credentials* = 0x130E.SecurityStatus
    ## No credentials are available in the security package

  sec_e_message_altered* = 0x130F.SecurityStatus
    ## The message supplied for verification has been altered

  sec_e_out_of_sequence* = 0x1310.SecurityStatus
    ## The message supplied for verification is out of sequence

  sec_e_no_authenticating_authority* = 0x1311.SecurityStatus
    ## No authority could be contacted for authentication.

  sec_e_context_expired* = 0x1312.SecurityStatus
    ## The context has expired and can no longer be used.

  sec_e_incomplete_message* = 0x1313.SecurityStatus
    ## The supplied message is incomplete.  The signature was not verified.

  sec_i_continue_needed* = 0x1012.SecurityStatus
    ## The function completed successfully, but must be called
    ## again to complete the context

  sec_i_complete_needed* = 0x1013.SecurityStatus
    ## The function completed successfully, but CompleteToken
    ## must be called

  sec_i_complete_and_continue* = 0x1014.SecurityStatus
    ## The function completed successfully, but both CompleteToken
    ## and this function must be called to complete the context

  sec_i_local_logon* = 0x1015.SecurityStatus
    ## The logon was completed, but no network authority was
    ## available.  The logon was made using locally known information

  sec_e_ok* = 0x0000.SecurityStatus
    ## Call completed successfully


  # Older error names for backwards compatibility
  sec_e_not_supported* = sec_e_unsupported_function
  sec_e_no_spm* = sec_e_internal_error
  sec_e_bad_pkgid* = sec_e_secpkg_not_found

defineDistinctToStringProc(SecurityStatus, uint32,
  sec_e_insufficient_memory, sec_e_invalid_handle, sec_e_unsupported_function,
  sec_e_target_unknown, sec_e_internal_error, sec_e_secpkg_not_found,
  sec_e_not_owner, sec_e_cannot_install, sec_e_invalid_token, sec_e_cannot_pack,
  sec_e_qop_not_supported, sec_e_no_impersonation, sec_e_logon_denied,
  sec_e_unknown_credentials, sec_e_no_credentials, sec_e_message_altered,
  sec_e_out_of_sequence, sec_e_no_authenticating_authority,
  sec_e_context_expired, sec_e_incomplete_message, sec_i_continue_needed,
  sec_i_complete_needed, sec_i_complete_and_continue, sec_i_local_logon,
  sec_e_ok)
