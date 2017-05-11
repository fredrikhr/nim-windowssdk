##
##
##  Microsoft Windows
##  Copyright (C) Microsoft Corporation, 1992-1999.
##
##  File:       sspi.h
##
##  Contents:   Security Support Provider Interface
##              Prototypes and structure definitions
##
##  Functions:  Security Support Provider API
##
##
##

import .. / ansiwide
import .. / anysize_array

import .. / um / winnt

import dynlib

type
  SecWChar* = WChar
  SecChar* = Char

type
  SecurityStatus* = distinct uint32

type
  SecHandle* = object
    lower, upper: int
  PSecHandle* = ptr SecHandle

type
  CredHandle* = SecHandle
  PCredHandle* = ptr CredHandle

  CtxtHandle* = SecHandle
  PCtxtHandle* = ptr CtxtHandle

type
  SecurityInteger* = LargeInteger
    ## ref.: https://msdn.microsoft.com/en-us/library/aa380127.aspx
  PSecurityInteger* = ptr SecurityInteger

type
  TimeStamp* = SecurityInteger
  PTimeStamp* = ptr TimeStamp

type
  SecPkg_Flag* = distinct uint32
  SecPkg_Id* = distinct uint16
ansiWideAll(SecPkgInfo, SecPkgInfoA, SecPkgInfoW, LPTStr, LPSTr, LPWStr):
  type SecPkgInfo* = object
    ## Provides general information about a security provider
    ## ref.: https://msdn.microsoft.com/en-us/library/aa380104.aspx
    capabilities: SecPkg_Flag
      ## Capability bitmask
    version: uint16
      ## Version of driver
    rpcId: SecPkg_Id
      ## ID for RPC Runtime
    tokenMaxSize: uint32
      ## Size of authentication token (max)
    name: LPTStr
      ## Text name
    comment: LPTStr
      ## Comment
type
  PSecPkgInfoA* = ptr SecPkgInfoA
  PSecPkgInfoW* = ptr SecPkgInfoW
  PSecPkgInfo* = ptr SecPkgInfo

# Security Package Capabilities
const
  secpkg_flag_integrity* = 0x00000001.SecPkg_Flag ## Supports integrity on messages
  secpkg_flag_privacy* = 0x00000002.SecPkg_Flag ## Supports privacy (confidentiality)
  secpkg_flag_token_only* = 0x00000004.SecPkg_Flag ## Only security token needed
  secpkg_flag_datagram* = 0x00000008.SecPkg_Flag ## Datagram RPC support
  secpkg_flag_connection* = 0x00000010.SecPkg_Flag ## Connection oriented RPC support
  secpkg_flag_multi_required* = 0x00000020.SecPkg_Flag ## Full 3-leg required for re-auth.
  secpkg_flag_client_only* = 0x00000040.SecPkg_Flag ## Server side functionality not available
  secpkg_flag_extended_error* = 0x00000080.SecPkg_Flag ## Supports extended error msgs
  secpkg_flag_impersonation* = 0x00000100.SecPkg_Flag ## Supports impersonation
  secpkg_flag_accept_win32_name* = 0x00000200.SecPkg_Flag ## Accepts Win32 names
  secpkg_flag_stream* = 0x00000400.SecPkg_Flag ## Supports stream semantics
  secpkg_flag_negotiable* = 0x00000800.SecPkg_Flag ## Can be used by the negotiate package
  secpkg_flag_gss_compatible* = 0x00001000.SecPkg_Flag ## GSS Compatibility Available
  secpkg_flag_logon* = 0x00002000.SecPkg_Flag ## Supports common LsaLogonUser
  secpkg_flag_ascii_buffers* = 0x00004000.SecPkg_Flag ## Token Buffers are in ASCII
  secpkg_flag_fragment* = 0x00008000.SecPkg_Flag ## Package can fragment to fit
  secpkg_flag_mutual_auth* = 0x00010000.SecPkg_Flag ## Package can perform mutual authentication
  secpkg_flag_delegation* = 0x00020000.SecPkg_Flag ## Package can delegate
  secpkg_flag_readonly_with_checksum* = 0x00040000.SecPkg_Flag ## Package can delegate
  secpkg_flag_restricted_tokens* = 0x00080000.SecPkg_Flag ## Package supports restricted callers
  secpkg_flag_nego_extender* = 0x00100000.SecPkg_Flag ## this package extends SPNEGO, there is at most one
  secpkg_flag_negotiable2* = 0x00200000.SecPkg_Flag ## this package is negotiated under the NegoExtender
  secpkg_flag_appcontainer_passthrough* = 0x00400000.SecPkg_Flag ## this package receives all calls from appcontainer apps
  secpkg_flag_appcontainer_checks* = 0x00800000.SecPkg_Flag 
    ## this package receives calls from appcontainer apps
    ## if the following checks succeed
    ## 1. Caller has domain auth capability or
    ## 2. Target is a proxy server or
    ## 3. The caller has supplied creds
  secpkg_flag_credential_isolation_enabled* = 0x01000000.SecPkg_Flag ## this package is running with Credential Guard enabled

  secpkg_id_none* = 0xFFFF.SecPkg_Id

type
  SecBufferType* = distinct uint32

  SecBuffer* = object
    ## Generic memory descriptors for buffers passed in to the security
    ## API
    ## ref.: https://msdn.microsoft.com/en-us/library/aa379814.aspx
    size: uint32
    typ: SecBufferType
    buf: pointer
  PSecBuffer* = ptr SecBuffer

type 
  SecBufferVersion* = distinct uint32

  SecBufferDesc* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/aa379815.aspx
    version: SecBufferVersion
    len: uint32
    buffers: AnySizeArrayPtr[SecBuffer]
  PSecBufferDesc* = ptr SecBufferDesc

const secbuffer_version* = 0.SecBufferVersion

const
  secbuffer_empty* = 0.SecBufferType ## Undefined, replaced by provider
  secbuffer_data* = 1.SecBufferType ## Packet data
  secbuffer_token* = 2.SecBufferType ## Security token
  secbuffer_pkg_params* = 3.SecBufferType ## Package specific parameters
  secbuffer_missing* = 4.SecBufferType ## Missing Data indicator
  secbuffer_extra* = 5.SecBufferType ## Extra data
  secbuffer_stream_trailer* = 6.SecBufferType ## Security Trailer
  secbuffer_stream_header* = 7.SecBufferType ## Security Header
  secbuffer_negotiation_info* = 8.SecBufferType ## Hints from the negotiation pkg
  secbuffer_padding* = 9.SecBufferType ## non-data padding
  secbuffer_stream* = 10.SecBufferType ## whole encrypted message
  secbuffer_mechlist* = 11.SecBufferType
  secbuffer_mechlist_signature* = 12.SecBufferType
  secbuffer_target* {.deprecated.} = 13.SecBufferType ## obsolete
  secbuffer_channel_bindings* = 14.SecBufferType
  secbuffer_change_pass_response* = 15.SecBufferType
  secbuffer_target_host* = 16.SecBufferType
  secbuffer_alert* = 17.SecBufferType
  secbuffer_application_protocols* = 18.SecBufferType ## Lists of application protocol IDs, one per negotiation extension
  secbuffer_srtp_protection_profiles* = 19.SecBufferType ## List of SRTP protection profiles, in descending order of preference
  secbuffer_srtp_master_key_identifier* = 20.SecBufferType ## SRTP master key identifier
  secbuffer_token_binding* = 21.SecBufferType ## Supported Token Binding protocol version and key parameters
  secbuffer_preshared_key* = 22.SecBufferType ## Preshared key
  secbuffer_preshared_key_identity* = 23.SecBufferType ## Preshared key identity
  secbuffer_dtls_mtu* = 24.SecBufferType ## DTLS path MTU setting


  secbuffer_attrmask* = 0xF0000000.SecBufferType
  secbuffer_readonly* = 0x80000000.SecBufferType ## Buffer is read-only, no checksum
  secbuffer_readonly_with_checksum* = 0x10000000.SecBufferType ## Buffer is read-only, and checksummed
  secbuffer_reserved* = 0x60000000.SecBufferType ## Flags reserved to security system

type
  Sec_Negotiation_Info* = object
    size: uint32
      ## Size of this structure
    nameLen: uint32
      ## Length of name hint
    name: AnySizeArrayPtr[SecWChar]
      ## Name hint
    reserved: pointer
      ## Reserved
  PSec_Negotiation_Info* = ptr Sec_Negotiation_Info

type SecurityDrep* = distinct uint32
  ## Data Representation Constant
const
  SECURITY_NATIVE_DREP* = 0x00000010.SecurityDrep
  SECURITY_NETWORK_DREP* = 0x00000000.SecurityDrep

# Credential Use Flags
type SecPkg_Cred_Use* = distinct uint32
const
  secpkg_cred_inbound* = 0x00000001.SecPkg_Cred_Use
  secpkg_cred_outbound* = 0x00000002.SecPkg_Cred_Use
  secpkg_cred_both* = 0x00000003.SecPkg_Cred_Use
  secpkg_cred_default* = 0x00000004.SecPkg_Cred_Use
  secpkg_cred_reserved* = 0xF0000000.SecPkg_Cred_Use
  secpkg_cred_autologon_restricted* = 0x00000010.SecPkg_Cred_Use
    ##[
      SSP SHOULD prompt the user for credentials/consent, independent
      of whether credentials to be used are the 'logged on' credentials
      or retrieved from credman.

      An SSP may choose not to prompt, however, in circumstances determined
      by the SSP.
    ]##
  secpkg_cred_process_policy_only* = 0x00000020
    ## auth will always fail, ISC() is called to process policy data only

type Isc_Req_Flag* = distinct uint32
  ## InitializeSecurityContext Requirement flags
const
  isc_req_delegate* = 0x00000001.Isc_Req_Flag
  isc_req_mutual_auth* = 0x00000002.Isc_Req_Flag
  isc_req_replay_detect* = 0x00000004.Isc_Req_Flag
  isc_req_sequence_detect* = 0x00000008.Isc_Req_Flag
  isc_req_confidentiality* = 0x00000010.Isc_Req_Flag
  isc_req_use_session_key* = 0x00000020.Isc_Req_Flag
  isc_req_prompt_for_creds* = 0x00000040.Isc_Req_Flag
  isc_req_use_supplied_creds* = 0x00000080.Isc_Req_Flag
  isc_req_allocate_memory* = 0x00000100.Isc_Req_Flag
  isc_req_use_dce_style* = 0x00000200.Isc_Req_Flag
  isc_req_datagram* = 0x00000400.Isc_Req_Flag
  isc_req_connection* = 0x00000800.Isc_Req_Flag
  isc_req_call_level* = 0x00001000.Isc_Req_Flag
  isc_req_fragment_supplied* = 0x00002000.Isc_Req_Flag
  isc_req_extended_error* = 0x00004000.Isc_Req_Flag
  isc_req_stream* = 0x00008000.Isc_Req_Flag
  isc_req_integrity* = 0x00010000.Isc_Req_Flag
  isc_req_identify* = 0x00020000.Isc_Req_Flag
  isc_req_null_session* = 0x00040000.Isc_Req_Flag
  isc_req_manual_cred_validation* = 0x00080000.Isc_Req_Flag
  isc_req_reserved1* = 0x00100000.Isc_Req_Flag
  isc_req_fragment_to_fit* = 0x00200000.Isc_Req_Flag
  # This exists only in Windows Vista and greater
  isc_req_forward_credentials* = 0x00400000.Isc_Req_Flag
  isc_req_no_integrity* = 0x00800000.Isc_Req_Flag ## honored only by SPNEGO
  isc_req_use_http_style* = 0x01000000.Isc_Req_Flag
  isc_req_unverified_target_name* = 0x20000000.Isc_Req_Flag
  isc_req_confidentiality_only* = 0x40000000.Isc_Req_Flag ## honored by SPNEGO/Kerberos
type Isc_Ret_Flag* = distinct uint32
  ## InitializeSecurityContext return flags
const
  isc_ret_delegate* = 0x00000001.Isc_Ret_Flag
  isc_ret_mutual_auth* = 0x00000002.Isc_Ret_Flag
  isc_ret_replay_detect* = 0x00000004.Isc_Ret_Flag
  isc_ret_sequence_detect* = 0x00000008.Isc_Ret_Flag
  isc_ret_confidentiality* = 0x00000010.Isc_Ret_Flag
  isc_ret_use_session_key* = 0x00000020.Isc_Ret_Flag
  isc_ret_used_collected_creds* = 0x00000040.Isc_Ret_Flag
  isc_ret_used_supplied_creds* = 0x00000080.Isc_Ret_Flag
  isc_ret_allocated_memory* = 0x00000100.Isc_Ret_Flag
  isc_ret_used_dce_style* = 0x00000200.Isc_Ret_Flag
  isc_ret_datagram* = 0x00000400.Isc_Ret_Flag
  isc_ret_connection* = 0x00000800.Isc_Ret_Flag
  isc_ret_intermediate_return* = 0x00001000.Isc_Ret_Flag
  isc_ret_call_level* = 0x00002000.Isc_Ret_Flag
  isc_ret_extended_error* = 0x00004000.Isc_Ret_Flag
  isc_ret_stream* = 0x00008000.Isc_Ret_Flag
  isc_ret_integrity* = 0x00010000.Isc_Ret_Flag
  isc_ret_identify* = 0x00020000.Isc_Ret_Flag
  isc_ret_null_session* = 0x00040000.Isc_Ret_Flag
  isc_ret_manual_cred_validation* = 0x00080000.Isc_Ret_Flag
  isc_ret_reserved1* = 0x00100000.Isc_Ret_Flag
  isc_ret_fragment_only* = 0x00200000.Isc_Ret_Flag
  # This exists only in Windows Vista and greater
  isc_ret_forward_credentials* = 0x00400000.Isc_Ret_Flag

  isc_ret_used_http_style* = 0x01000000.Isc_Ret_Flag
  isc_ret_no_additional_token = 0x02000000.Isc_Ret_Flag ## *INTERNAL*
  isc_ret_reauthentication = 0x08000000.Isc_Ret_Flag ## *INTERNAL*
  isc_ret_confidentiality_only* = 0x40000000.Isc_Ret_Flag ## honored by SPNEGO/Kerberos

type Asc_Req_Flag* = distinct uint32
const
  asc_req_delegate* = 0x00000001.Asc_Req_Flag
  asc_req_mutual_auth* = 0x00000002.Asc_Req_Flag
  asc_req_replay_detect* = 0x00000004.Asc_Req_Flag
  asc_req_sequence_detect* = 0x00000008.Asc_Req_Flag
  asc_req_confidentiality* = 0x00000010.Asc_Req_Flag
  asc_req_use_session_key* = 0x00000020.Asc_Req_Flag
  asc_req_session_ticket* = 0x00000040.Asc_Req_Flag
  asc_req_allocate_memory* = 0x00000100.Asc_Req_Flag
  asc_req_use_dce_style* = 0x00000200.Asc_Req_Flag
  asc_req_datagram* = 0x00000400.Asc_Req_Flag
  asc_req_connection* = 0x00000800.Asc_Req_Flag
  asc_req_call_level* = 0x00001000.Asc_Req_Flag
  asc_req_fragment_supplied* = 0x00002000.Asc_Req_Flag
  asc_req_extended_error* = 0x00008000.Asc_Req_Flag
  asc_req_stream* = 0x00010000.Asc_Req_Flag
  asc_req_integrity* = 0x00020000.Asc_Req_Flag
  asc_req_licensing* = 0x00040000.Asc_Req_Flag
  asc_req_identify* = 0x00080000.Asc_Req_Flag
  asc_req_allow_null_session* = 0x00100000.Asc_Req_Flag
  asc_req_allow_non_user_logons* = 0x00200000.Asc_Req_Flag
  asc_req_allow_context_replay* = 0x00400000.Asc_Req_Flag
  asc_req_fragment_to_fit* = 0x00800000.Asc_Req_Flag

  asc_req_no_token* = 0x01000000.Asc_Req_Flag
  asc_req_proxy_bindings* = 0x04000000.Asc_Req_Flag
  # ssp_ret_reauthentication = 0x08000000.Asc_Req_Flag ## *INTERNAL*
  asc_req_allow_missing_bindings* = 0x10000000.Asc_Req_Flag
type Asc_Ret_Flag* = distinct uint32
const
  asc_ret_delegate* = 0x00000001.Asc_Ret_Flag
  asc_ret_mutual_auth* = 0x00000002.Asc_Ret_Flag
  asc_ret_replay_detect* = 0x00000004.Asc_Ret_Flag
  asc_ret_sequence_detect* = 0x00000008.Asc_Ret_Flag
  asc_ret_confidentiality* = 0x00000010.Asc_Ret_Flag
  asc_ret_use_session_key* = 0x00000020.Asc_Ret_Flag
  asc_ret_session_ticket* = 0x00000040.Asc_Ret_Flag
  asc_ret_allocated_memory* = 0x00000100.Asc_Ret_Flag
  asc_ret_used_dce_style* = 0x00000200.Asc_Ret_Flag
  asc_ret_datagram* = 0x00000400.Asc_Ret_Flag
  asc_ret_connection* = 0x00000800.Asc_Ret_Flag
  asc_ret_call_level* = 0x00002000.Asc_Ret_Flag ## skipped 0x1000 to be like ISC_
  asc_ret_third_leg_failed* = 0x00004000.Asc_Ret_Flag
  asc_ret_extended_error* = 0x00008000.Asc_Ret_Flag
  asc_ret_stream* = 0x00010000.Asc_Ret_Flag
  asc_ret_integrity* = 0x00020000.Asc_Ret_Flag
  asc_ret_licensing* = 0x00040000.Asc_Ret_Flag
  asc_ret_identify* = 0x00080000.Asc_Ret_Flag
  asc_ret_null_session* = 0x00100000.Asc_Ret_Flag
  asc_ret_allow_non_user_logons* = 0x00200000.Asc_Ret_Flag
  asc_ret_allow_context_replay* {.deprecated.} = 0x00400000.Asc_Ret_Flag ## deprecated - don't use this flag!!!
  asc_ret_fragment_only* = 0x00800000.Asc_Ret_Flag
  asc_ret_no_token* = 0x01000000.Asc_Ret_Flag
  asc_ret_no_additional_token = 0x02000000.Asc_Ret_Flag ## *INTERNAL*
  # ssp_ret_reauthentication = 0x08000000.Asc_Ret_Flag ## *INTERNAL*

type SecPkg_Cred_Attr = distinct uint32
  ## Security Credentials Attributes
const
  secpkg_cred_attr_names* = 1.SecPkg_Cred_Attr
  secpkg_cred_attr_ssi_provider* = 2.SecPkg_Cred_Attr
  secpkg_cred_attr_kdc_proxy_settings* = 3.SecPkg_Cred_Attr
  secpkg_cred_attr_cert* = 4.SecPkg_Cred_Attr

ansiWideAll(SecPkgCredentials_Names, SecPkgCredentials_NamesA, SecPkgCredentials_NamesW,
  LPTStr, LPSTr, LPWStr):
  type SecPkgCredentials_Names* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/aa380100.aspx
    userName: LPTStr
type
  PSecPkgCredentials_NamesA* = ptr SecPkgCredentials_NamesA
  PSecPkgCredentials_NamesW* = ptr SecPkgCredentials_NamesW
  PSecPkgCredentials_Names* = ptr SecPkgCredentials_Names

ansiWideAll(SecPkgCredentials_SSIProvider, SecPkgCredentials_SSIProviderA, SecPkgCredentials_SSIProviderW,
  LPTStr, LPSTr, LPWStr):
  type SecPkgCredentials_SSIProvider* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/hh448510.aspx
    providerName: LPTStr
    providerInfoLen: uint32
    providerInfo: AnySizeArrayPtr[byte]
type
  PSecPkgCredentials_SSIProviderA* = ptr SecPkgCredentials_SSIProviderA
  PSecPkgCredentials_SSIProviderW* = ptr SecPkgCredentials_SSIProviderW
  PSecPkgCredentials_SSIProvider* = ptr SecPkgCredentials_SSIProvider

type Kdc_Proxy_Settings_Version = distinct uint32
const kdc_proxy_settings_v1* = 1.Kdc_Proxy_Settings_Version
type Kdc_Proxy_Settings_Flags* = distinct uint32
const kdc_proxy_settings_flags_forceproxy* = 0x1.Kdc_Proxy_Settings_Flags

ansiWideAll(SecPkgCredentials_KdcProxySettings, SecPkgCredentials_KdcProxySettingsA, SecPkgCredentials_KdcProxySettingsW,
  LPTStr, LPSTr, LPWStr):
  type SecPkgCredentials_KdcProxySettings* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/hh448509.aspx
    version: Kdc_Proxy_Settings_Version
    flags: Kdc_Proxy_Settings_Flags
    proxyServerOffset, proxyServerSize: uint16
    clientTlsCredOffset, clientTlsCredSize: uint16
type
  PSecPkgCredentials_KdcProxySettingsA* = ptr SecPkgCredentials_KdcProxySettingsA
  PSecPkgCredentials_KdcProxySettingsW* = ptr SecPkgCredentials_KdcProxySettingsW
  PSecPkgCredentials_KdcProxySettings* = ptr SecPkgCredentials_KdcProxySettings

type
  SecPkgCredentials_Cert* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/hh448508.aspx
    encodedCertSize: uint32
    encodedCert: AnySizeArrayPtr[byte]
  PSecPkgCredentials_Cert* = ptr SecPkgCredentials_Cert

type SecPkg_Attr* = distinct uint32
  ## Security Context Attributes
const
  secpkg_attr_sizes* = 0.SecPkg_Attr
  secpkg_attr_names* = 1.SecPkg_Attr
  secpkg_attr_lifespan* = 2.SecPkg_Attr
  secpkg_attr_dce_info* = 3.SecPkg_Attr
  secpkg_attr_stream_sizes* = 4.SecPkg_Attr
  secpkg_attr_key_info* = 5.SecPkg_Attr
  secpkg_attr_authority* = 6.SecPkg_Attr
  secpkg_attr_proto_info* = 7.SecPkg_Attr
  secpkg_attr_password_expiry* = 8.SecPkg_Attr
  secpkg_attr_session_key* = 9.SecPkg_Attr
  secpkg_attr_package_info* = 10.SecPkg_Attr
  secpkg_attr_user_flags* = 11.SecPkg_Attr
  secpkg_attr_negotiation_info* = 12.SecPkg_Attr
  secpkg_attr_native_names* = 13.SecPkg_Attr
  secpkg_attr_flags* = 14.SecPkg_Attr
  # These attributes exist only in Win XP and greater
  secpkg_attr_use_validated* = 15.SecPkg_Attr
  secpkg_attr_credential_name* = 16.SecPkg_Attr
  secpkg_attr_target_information* = 17.SecPkg_Attr
  secpkg_attr_access_token* = 18.SecPkg_Attr
  # These attributes exist only in Win2K3 and greater
  secpkg_attr_target* = 19.SecPkg_Attr
  secpkg_attr_authentication_id* = 20.SecPkg_Attr
  # These attributes exist only in Win2K3SP1 and greater
  secpkg_attr_logoff_time* = 21.SecPkg_Attr
  #
  # win7 or greater
  #
  secpkg_attr_nego_keys* = 22.SecPkg_Attr
  secpkg_attr_prompting_needed* = 24.SecPkg_Attr
  secpkg_attr_unique_bindings* = 25.SecPkg_Attr
  secpkg_attr_endpoint_bindings* = 26.SecPkg_Attr
  secpkg_attr_client_specified_target* = 27.SecPkg_Attr

  secpkg_attr_last_client_token_status* = 30.SecPkg_Attr
  secpkg_attr_nego_pkg_info* = 31.SecPkg_Attr ## contains nego info of packages
  secpkg_attr_nego_status* = 32.SecPkg_Attr ## contains the last error
  secpkg_attr_context_deleted* = 33.SecPkg_Attr ## a context has been deleted

  #
  # win8 or greater
  #
  secpkg_attr_dtls_mtu* = 34.SecPkg_Attr
  secpkg_attr_datagram_sizes* = secpkg_attr_stream_sizes

  secpkg_attr_subject_security_attributes* = 128.SecPkg_Attr

  #
  # win8.1 or greater
  #
  secpkg_attr_application_protocol* = 35.SecPkg_Attr

  #
  # win10 or greater
  #
  secpkg_attr_negotiated_tls_extensions* = 36.SecPkg_Attr
  secpkg_attr_is_loopback* = 37.SecPkg_Attr ## indicates authentication to localhost

type SecPkg_Cred_Class* = enum
  ## ref.: https://msdn.microsoft.com/en-us/library/ee351643.aspx
  secPkgCredClass_None = 0 ## no creds
  secPkgCredClass_Ephemeral = 10 ## logon creds
  secPkgCredClass_PersistedGeneric = 20 ## saved creds, not target specific
  secPkgCredClass_PersistedSpecific = 30 ## saved creds, target specific
  secPkgCredClass_Explicit = 40 ## explicitly supplied creds

type
  SecPkgContext_CredInfo* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/ee351641.aspx
    credClass: SecPkg_Cred_Class
    isPromptingNeeded: uint32
  PSecPkgContext_CredInfo* = ptr SecPkgContext_CredInfo

type Sec_Get_Key_Fn* = proc(
  arg: ptr,
  principal: ptr,
  keyVer: uint32,
  key: var ptr,
  status: var SecurityStatus
  ): void {.stdcall.}

ansiWideAllImportC(tIdent = sspiAcquireCredentialsHandle,
  ansiIdent = sspiAcquireCredentialsHandleAnsi, wideIdent = sspiAcquireCredentialsHandleWide,
  innerTIdent = LPTStr, innerAnsiIdent = LPStr, innerWideIdent = LPWStr,
  ansiImportC = "AcquireCredentialsHandleA", wideImportC = "AcquireCredentialsHandleW"):
  proc sspiAcquireCredentialsHandle*(
    principal: LPTStr,
    package: LPTStr,
    credentialUse: SecPkg_Cred_Use,
    logonId: ptr Luid,
    authData: ptr = nil,
    getKeyFn: Sec_Get_Key_Fn = nil,
    getKeyArgument: ptr = nil,
    credential: var CredHandle,
    expiry: var TimeStamp
    ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc.}
    ## ref.: https://msdn.microsoft.com/en-us/library/aa374712.aspx

proc sspiFreeCredentialsHandle*(
  credential: var CredHandle
  ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc: "FreeCredentialsHandle".}
  ## ref.: https://msdn.microsoft.com/en-us/library/aa375417.aspx

#[
########################################################################
###
### Password Change Functions
###
########################################################################
]#
ansiWideAllImportC(tIdent = sspiChangeAccountPassword,
  ansiIdent = sspiChangeAccountPasswordAnsi, wideIdent = sspiChangeAccountPasswordWide,
  innerTIdent = LPTStr, innerAnsiIdent = LPStr, innerWideIdent = LPWStr,
  ansiImportC = "ChangeAccountPasswordA", wideImportC = "ChangeAccountPasswordW"):
  proc sspiChangeAccountPassword*(
    packageName, domainName, accountName, oldPassword, newPassword: LPTStr,
    impersonating: Boolean,
    reserved: uint32,
    output: var SecBufferDesc
    ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc.}
    ## ref.: https://msdn.microsoft.com/en-us/library/aa374755.aspx

#[
########################################################################
###
### Context Management Functions
###
########################################################################
]#
ansiWideAllImportC(tIdent = sspiInitializeSecurityContext,
  ansiIdent = sspiInitializeSecurityContextAnsi, wideIdent = sspiInitializeSecurityContextWide,
  innerTIdent = LPTStr, innerAnsiIdent = LPStr, innerWideIdent = LPWStr,
  ansiImportC = "InitializeSecurityContextA", wideImportC = "InitializeSecurityContextW"):
  proc sspiInitializeSecurityContext*(
    credential: PCredHandle,
    context: PCtxtHandle,
    targetName: LPTStr,
    contextReq: Isc_Req_Flag,
    reserved1: uint32,
    targetDataRep: SecurityDrep,
    input: PSecBufferDesc,
    reserved2: uint32,
    newContext: var CredHandle,
    output: var SecBufferDesc,
    contextAttr: var Isc_Ret_Flag,
    expiry: var TimeStamp
    ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc.}
    ## ref.: https://msdn.microsoft.com/en-us/library/aa375506.aspx


proc sspiAcceptSecurityContext*(
  credential: PCredHandle,
  context: PCtxtHandle,
  input: PSecBufferDesc,
  contextReq: uint32,
  targetDataRep: uint32,
  newContext: var CtxtHandle,
  output: var SecBufferDesc,
  contextAttr: var uint32,
  expiry: var TimeStamp
  ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc: "AcceptSecurityContext".}
  ## ref.: https://msdn.microsoft.com/en-us/library/aa374703.aspx

proc sspiCompleteAuthToken*(
  context: PCtxtHandle,
  token: PSecBufferDesc
  ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc: "CompleteAuthToken".}
  ## ref.: https://msdn.microsoft.com/en-us/library/aa374764.aspx

proc sspiImpersonateSecurityContext*(
  context: PCtxtHandle
  ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc: "ImpersonateSecurityContext".}
  ## ref.: https://msdn.microsoft.com/en-us/library/aa375497.aspx

proc sspiRevertSecurityContext*(
  context: PCtxtHandle
  ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc: "RevertSecurityContext".}
  ## ref.: https://msdn.microsoft.com/en-us/library/aa379446.aspx

proc sspiQuerySecurityContextToken*(
  context: PCtxtHandle,
  token: var pointer
  ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc: "QuerySecurityContextToken".}
  ## ref.: https://msdn.microsoft.com/en-us/library/aa379355.aspx

proc sspiDeleteSecurityContext*(
  context: PCtxtHandle
  ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc: "DeleteSecurityContext".}
  ## ref.: https://msdn.microsoft.com/en-us/library/aa375354.aspx

proc sspiApplyControlToken*(
  context: PCtxtHandle,
  input: PSecBufferDesc
  ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc: "ApplyControlToken".}
  ## ref.: https://msdn.microsoft.com/en-us/library/aa374724.aspx

#[
  Routines for manipulating packages
]#
type
  SecPkg_Options_Type* = distinct uint32
  SecPkg_Options_Flag* = distinct uint32

  Security_Package_Options* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/dd401691.aspx
    size: uint32
    typ: SecPkg_Options_Type
    flags: SecPkg_Options_Flag
    signatureSize: uint32
    signature: pointer
  PSecurity_Package_Options* = ptr Security_Package_Options

const
  secpkg_options_type_unknown* = 0.SecPkg_Options_Type
  secpkg_options_type_lsa* = 1.SecPkg_Options_Type
  secpkg_options_type_sspi* = 2.SecPkg_Options_Type

  secpkg_options_permanent* = 0x00000001.SecPkg_Options_Flag

ansiWideAllImportC(tIdent = sspiAddSecurityPackage,
  ansiIdent = sspiAddSecurityPackageAnsi, wideIdent = sspiAddSecurityPackageWide,
  innerTIdent = LPTStr, innerAnsiIdent = LPStr, innerWideIdent = LPWStr,
  ansiImportC = "AddSecurityPackageA", wideImportC = "AddSecurityPackageW"):
  proc sspiAddSecurityPackage*(
    packageName: LPTStr,
    options: PSecurity_Package_Options
    ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc.}
    ## ref.: https://msdn.microsoft.com/en-us/library/dd401506.aspx

ansiWideAllImportC(tIdent = sspiDeleteSecurityPackage,
  ansiIdent = sspiDeleteSecurityPackageAnsi, wideIdent = sspiDeleteSecurityPackageWide,
  innerTIdent = LPTStr, innerAnsiIdent = LPStr, innerWideIdent = LPWStr,
  ansiImportC = "DeleteSecurityPackageA", wideImportC = "DeleteSecurityPackageW"):
  proc sspiDeleteSecurityPackage*(
    packageName: LPTStr
    ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc.}
    ## ref.: https://msdn.microsoft.com/en-us/library/dd401610.aspx
