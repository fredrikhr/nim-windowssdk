##
##
## | Microsoft Windows
## | Copyright (C) Microsoft Corporation, 1992-1999.
##
## :File:       sspi.h
##
## :Contents:   Security Support Provider Interface
##              Prototypes and structure definitions
##
## :Functions:  Security Support Provider API
##
##

import .. / ansiwide
import .. / anysize_array

import .. / shared / guiddef
import .. / shared / minwindef

import .. / um / wincred
import .. / um / wincrypt
import .. / um / winnt

import dynlib

type
  SecWChar* = WChar
  SecChar* = Char

type
  SecurityStatus* = distinct uint32
proc `==`*(a, b: SecurityStatus): bool = (a.uint32 == b.uint32)
proc `!=`*(a, b: SecurityStatus): bool = (a.uint32 != b.uint32)

ansiWideWhen(SecTChar, SecChar, SecWChar):
  type SecurityPStr* = AnySizeArrayPtr[SecTChar]

type
  SecHandle* = object
    lower, upper: int
  CredHandle* = SecHandle
  CtxtHandle* = SecHandle

type
  SecurityInteger* = LargeInteger
    ## ref.: https://msdn.microsoft.com/en-us/library/aa380127.aspx
  TimeStamp* = SecurityInteger

type
  SecPkg_Flag* = distinct uint32
    ## Security Package Capabilities
  SecPkg_Id* = distinct uint16

ansiWideAll(SecPkgInfo, SecPkgInfoA, SecPkgInfoW, LPTStr, LPSTr, LPWStr):
  type SecPkgInfo* = object
    ## Provides general information about a security provider
    ## ref.: https://msdn.microsoft.com/en-us/library/aa380104.aspx
    capabilities*: SecPkg_Flag
      ## Capability bitmask
    version*: uint16
      ## Version of driver
    rpcId*: SecPkg_Id
      ## ID for RPC Runtime
    tokenMaxSize*: uint32
      ## Size of authentication token (max)
    name*: LPTStr
      ## Text name
    comment*: LPTStr
      ## Comment

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

type SecPkg_CallFlag* = distinct uint32
  ## Extended Call Flags that currently contains
  ## Appcontainer related information about the caller.
  ## Packages can query for these
  ## via an LsaFunction GetExtendedCallFlags
const
  secpkg_callflags_appcontainer* = 0x00000001.SecPkg_CallFlag
  secpkg_callflags_appcontainer_authcapable* = 0x00000002.SecPkg_CallFlag
  secpkg_callflags_force_supplied* = 0x00000004.SecPkg_CallFlag
  secpkg_callflags_appcontainer_upncapable* = 0x00000008.SecPkg_CallFlag

type
  SecBufferType* = distinct uint32

  SecBuffer* = object
    ## Generic memory descriptors for buffers passed in to the security
    ## API
    ## ref.: https://msdn.microsoft.com/en-us/library/aa379814.aspx
    size: uint32
      ## Size of the buffer, in bytes
    typ: SecBufferType
      ## Type of the buffer
    buf: pointer
      ## Pointer to the buffer

type 
  SecBufferVersion* = distinct uint32

  SecBufferDesc* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/aa379815.aspx
    version: SecBufferVersion
      ## Version number
    len: uint32
      ## Number of buffers
    buffers: AnySizeArrayPtr[SecBuffer]
      ## Pointer to array of buffers

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
  
  Sec_Channel_Bindings* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/dd919963.aspx
    initiatorAddrType, initiatorLength, initiatorOffset: uint32
    acceptorAddrType, acceptorLength, acceptorOffset: uint32
    applicationDataLength, applicationOffset: uint32

  Sec_Application_Protocol_Negotiation_Ext* = enum
    secApplicationProtocolNegotiationExt_None,
    secApplicationProtocolNegotiationExt_NPN,
    secApplicationProtocolNegotiationExt_ALPN
  
  Sec_Application_Protocol_List* = object
    protoNegoExt: Sec_Application_Protocol_Negotiation_Ext
      ## Protocol negotiation extension type to use with this list of protocols
    protocolListSize: uint16
      ## Size in bytes of the protocol ID list
    protocolList: AnySizeArray[byte]
      ## 8-bit length-prefixed application protocol IDs, most preferred first
  
  Sec_Application_Protocols* = object
    protocolListSize: uint32 ## Size in bytes of the protocol ID lists array
    protocolLists: AnySizeArray[Sec_Application_Protocol_List]
      ## Array of protocol ID lists

  Sec_Srtp_Protection_Profiles* = object
    profilesSize: uint16 ## Size in bytes of the SRTP protection profiles array
    profilesList: AnySizeArray[uint16] ## Array of SRTP protection profiles
  
  Sec_Srtp_Master_Key_Identifier* = object
    masterKeyIdentifierSize: uint8 ## Size in bytes of the SRTP master key identifier
    masterKeyIdentifier: AnySizeArray[byte] ## SRTP master key identifier

  Sec_Token_Binding* = object
    majorVersion: uint8 ## Supported major version of the Token Binding protocol
    minorVersion: uint8 ## Supported minor version of the Token Binding protocol
    keyParameterSize: uint16 ## Size in bytes of the Token Binding key parameter IDs array
    keyParameters: AnySizeArray[byte] ## Token Binding key parameter IDs, most preferred first

  Sec_PreSharedKey* = object
    size: uint16 ## Size in bytes of the PSK
    key: AnySizeArray[byte] ## PSK

  Sec_PreSharedKey_Identity* = object
    size: uint16 ## Size in bytes of the PSK Identity
    keyIdentity: AnySizeArray[byte] ## PSK Identity

  Sec_Dtls_Mtu* = object
    pathMtu: uint16 ## Path MTU for the connection

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
  isc_ret_no_additional_token {.used.} = 0x02000000.Isc_Ret_Flag ## *INTERNAL*
  isc_ret_reauthentication {.used.} = 0x08000000.Isc_Ret_Flag ## *INTERNAL*
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
  asc_ret_no_additional_token {.used.} = 0x02000000.Asc_Ret_Flag ## *INTERNAL*
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
ansiWideAll(SecPkgCredentials_SSIProvider, SecPkgCredentials_SSIProviderA, SecPkgCredentials_SSIProviderW,
  LPTStr, LPSTr, LPWStr):
  type SecPkgCredentials_SSIProvider* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/hh448510.aspx
    providerName: LPTStr
    providerInfoLen: uint32
    providerInfo: AnySizeArrayPtr[byte]

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
  SecPkgCredentials_Cert* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/hh448508.aspx
    encodedCertSize: uint32
    encodedCert: AnySizeArrayPtr[byte]

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

type
  SecPkgContext_SubjectAttributes* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/hh448507.aspx
    when declared(Authz_Security_Attributes_Information):
      attributeInfo: ptr Authz_Security_Attributes_Information
    else:
      attributeInfo: pointer ## contains a PAUTHZ_SECURITY_ATTRIBUTES_INFORMATION structure

type SecPkg_Attr_Nego_Info_Flag* = distinct uint32
const
  secpkg_attr_nego_info_flag_no_kerberos* = 0x1.SecPkg_Attr_Nego_Info_Flag
  secpkg_attr_nego_info_flag_no_ntlm* = 0x2.SecPkg_Attr_Nego_Info_Flag

type
  SecPkg_Cred_Class* = enum
    ## types of credentials, used by SECPKG_ATTR_PROMPTING_NEEDED
    ## ref.: https://msdn.microsoft.com/en-us/library/ee351643.aspx
    secPkgCredClass_None = 0 ## no creds
    secPkgCredClass_Ephemeral = 10 ## logon creds
    secPkgCredClass_PersistedGeneric = 20 ## saved creds, not target specific
    secPkgCredClass_PersistedSpecific = 30 ## saved creds, target specific
    secPkgCredClass_Explicit = 40 ## explicitly supplied creds

  SecPkgContext_CredInfo* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/ee351641.aspx
    credClass: SecPkg_Cred_Class
    isPromptingNeeded: uint32

  SecPkgContext_NegoPackageInfo* = object
    packageMask: uint32
  
  SecPkgContext_NegoStatus* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/ee351642.aspx
    lastStatus: uint32

  SecPkgContext_Sizes* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/aa380097.aspx
    tokenMaxSize, signatureMaxSize, blockSize, securityTrailerSize: uint32
  
  SecPkgContext_StreamSizes* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/aa380098.aspx
    headerSize, trailerSize, msgMaxSize, buffersSize, blockSize: uint32

  SecPkgContext_DatagramSizes* = SecPkgContext_StreamSizes

ansiWideAll(SecPkgContext_Names, SecPkgContext_NamesA, SecPkgContext_NamesW,
  LPTSTr, LPStr, LPWStr):
  type SecPkgContext_Names* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/aa380089.aspx
    userName: LPTStr

type 
  SecPkg_Attr_Lct_Status* = enum
    ## ref.: https://msdn.microsoft.com/en-us/library/dd894404.aspx
    secPkgAttrLastClientTokenYes,
    secPkgAttrLastClientTokenNo,
    secPkgAttrLastClientTokenMaybe
  
  SecPkgContext_LastClientTokenStatus* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/dd894403.aspx
    lastClientTokenStatus: SecPkg_Attr_Lct_Status

  SecPkgContext_Lifespan* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/dd894403.aspx
    start, expiry: TimeStamp

  SecPkgContextDceInfo* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/aa379821.aspx
    authzSvc: uint32
    pac: pointer

ansiWideAll(SecPkgContext_KeyInfo, SecPkgContext_KeyInfoA, SecPkgContext_KeyInfoW,
  LPTStr, LPStr, LPWStr):
  type SecPkgContext_KeyInfo* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/aa380086.aspx
    signatureAlgorithmName, encryptAlgorithmName: LPTStr
    keySize: uint32
    signatureAlgorithm, encryptAlgorithm: wincrypt.Alg_Id
ansiWideAll(SecPkgContext_Authority, SecPkgContext_AuthorityA, SecPkgContext_AuthorityW,
  LPTStr, LPStr, LPWStr):
  type SecPkgContext_Authority* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/aa379818.aspx
    authorityName: LPTStr
ansiWideAll(SecPkgContext_ProtoInfo, SecPkgContext_ProtoInfoA, SecPkgContext_ProtoInfoW,
  LPTStr, LPStr, LPWStr):
  type SecPkgContext_ProtoInfo* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/aa380094.aspx
    protocolName: LPTStr
    majorVersion, minorVersion: uint32
type
  SecPkgContext_PasswordExpiry* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/aa380093.aspx
    passwordExpires: TimeStamp
  
  SecPkgContext_LogoffTime* = object
    logoffTime: TimeStamp

  SecPkgContext_SessionKey* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/aa380096.aspx
    size: uint32
    sessionKey: AnySizeArrayPtr[byte]

  SecPkgContext_NegoKeys* = object
    keyType: uint32
    keySize: uint16
    key: AnySizeArrayPtr[byte]
    verifyKeyType: uint32
    verifyKeySize: uint16
    verifyKey: AnySizeArrayPtr[byte]
ansiWideAll(SecPkgContext_PackageInfo, SecPkgContext_PackageInfoA, SecPkgContext_PackageInfoW,
  SecPkgInfo, SecPkgInfoA, SecPkgInfoW):
  type SecPkgContext_PackageInfo* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/aa380092.aspx
    packageInfo: ptr SecPkgInfo
type
  SecPkgContext_UserFlags* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/aa379957.aspx
    userFlags: uint32
  
  SecPkgContext_Flags* = object
    flags: uint32

  SecPkg_Negotiation_State* = distinct uint32
ansiWideAll(SecPkgContext_NegotiationInfo, SecPkgContext_NegotiationInfoA, SecPkgContext_NegotiationInfoW,
  SecPkgInfo, SecPkgInfoA, SecPkgInfoW):
  type SecPkgContext_NegotiationInfo* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/aa380091.aspx
    packageInfo: ptr SecPkgInfo
    negitiationState: SecPkg_Negotiation_State
const
  secpkg_negotiation_complete* = 0.SecPkg_Negotiation_State
  secpkg_negotiation_optimistic* = 1.SecPkg_Negotiation_State
  secpkg_negotiation_in_progress* = 2.SecPkg_Negotiation_State
  secpkg_negotiation_direct* = 3.SecPkg_Negotiation_State
  secpkg_negotiation_try_multicred* = 4.SecPkg_Negotiation_State
ansiWideAll(SecPkgContext_NativeNames, SecPkgContext_NativeNamesA, SecPkgContext_NativeNamesW,
  LPTStr, LPStr, LPWStr):
  type SecPkgContext_NativeNames* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/aa380090.aspx
    clientName, serverName: LPTStr
ansiWideAll(SecPkgContext_CredentialName, SecPkgContext_CredentialNameA, SecPkgContext_CredentialNameW,
  LPTStr, LPStr, LPWStr):
  type SecPkgContext_CredentialName* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/aa379820.aspx
    credentialType: uint32
    credentialName: LPTStr
type
  SecPkgContext_AccessToken* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/aa379817.aspx
    accessToken: pointer

  SecPkgContext_TargetInformation* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/aa380099.aspx
    marshalledTargetInfoSize: uint32
    marshalledTargetInfo: AnySizeArrayPtr[byte]

  SecPkgContext_AuthzID* = object
    size: uint32
    authzId: AnySizeArrayPtr[byte]

  SecPkgContext_Target* = object
    size: uint32
    target: AnySizeArrayPtr[byte]

  SecPkgContext_ClientSpecifiedTarget* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/dd401690.aspx
    targetName: WideCString

  SecPkgContext_Bindings* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/dd919960.aspx
    len: uint32
    binding: ptr Sec_Channel_Bindings

  Sec_Application_Protocol_Negotiation_Status* = enum
    secApplicationProtocolNegotiationStatus_None,
    secApplicationProtocolNegotiationStatus_Success,
    secApplicationProtocolNegotiationStatus_SelectedClientOnly

const max_protocol_id_size* = 0xff'u8
type
  SecPkgContext_ApplicationProtocol* = object
    protoNegoStatus: Sec_Application_Protocol_Negotiation_Status
      ## Application  protocol negotiation status
    protoNegoExt: Sec_Application_Protocol_Negotiation_Ext
      ## Protocol negotiation extension type corresponding to this protocol ID
    protocolIdSize: uint8 ## Size in bytes of the application protocol ID
    protocolId: array[max_protocol_id_size, byte]
      ## Byte string representing the negotiated application protocol ID

  SecPkgContext_NegotiatedTlsExtensions* = object
    len: uint32 ## Number of negotiated TLS extensions.
    extensions: AnySizeArrayPtr[uint16]
      ## Pointer to array of 2-byte TLS extension IDs (allocated by IANA).

  SecPkg_App_Mode_Info* = object
    userFunction: uint32
    arg1, arg2: uint
    userData: SecBuffer
    returnToLsa: Boolean

type Sec_Get_Key_Fn* = proc(
  arg: pointer,
  principal: pointer,
  keyVer: uint32,
  key: var pointer,
  status: var SecurityStatus
  ): void {.stdcall.}
  ## :arg:        Argument passed in
  ## :principal:  Principal ID
  ## :keyVer:     Key Version
  ## :key:        Returned pointer to key
  ## :status:     returned status
type SecPkg_Context_Export_Flag* = distinct uint32
const
  secpkg_context_export_reset_new* = 0x00000001.SecPkg_Context_Export_Flag ## New context is reset to initial state
  secpkg_context_export_delete_old* = 0x00000002.SecPkg_Context_Export_Flag ## Old context is deleted during export
  # This is only valid in W2K3SP1 and greater
  secpkg_context_export_to_kernel* = 0x00000004.SecPkg_Context_Export_Flag ## Context is to be transferred to the kernel

ansiWideAllImportC(tIdent = sspiAcquireCredentialsHandle,
  ansiIdent = sspiAcquireCredentialsHandleA, wideIdent = sspiAcquireCredentialsHandleW,
  innerTIdent = LPTStr, innerAnsiIdent = LPStr, innerWideIdent = LPWStr,
  ansiImportC = "AcquireCredentialsHandleA", wideImportC = "AcquireCredentialsHandleW"):
  proc sspiAcquireCredentialsHandle*(
    principal: LPTStr,
    package: LPTStr,
    credentialUse: SecPkg_Cred_Use,
    logonId: ptr Luid,
    authData: pointer,
    getKeyFn: Sec_Get_Key_Fn,
    getKeyArgument: pointer,
    credential: var CredHandle,
    expiry: var TimeStamp
    ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc.}
    ## ref.: https://msdn.microsoft.com/en-us/library/aa374712.aspx
    ## :principal: Name of principal
    ## :package: Name of package
    ## :credentialUse: Flags indicating use
    ## :logonId: Pointer to logon ID
    ## :authData:  Package specific data
    ## :getKeyFn:  Pointer to GetKey() func
    ## :getKeyArgument:  Value to pass to GetKey()
    ## :credential:  (out) Cred Handle
    ## :expiry:  (out) Lifetime (optional)
ansiWideAll(Sspi_Acquire_Credentials_Handle_Fn,
  Sspi_Acquire_Credentials_Handle_Fn_A, Sspi_Acquire_Credentials_Handle_Fn_W,
  LPTStr, LPStr, LPWStr):
  type Sspi_Acquire_Credentials_Handle_Fn* = proc(
    principal: LPTStr,
    package: LPTStr,
    credentialUse: SecPkg_Cred_Use,
    logonId: ptr Luid,
    authData: pointer,
    getKeyFn: Sec_Get_Key_Fn,
    getKeyArgument: pointer,
    credential: var CredHandle,
    expiry: var TimeStamp
    ): SecurityStatus {.stdcall.}

proc sspiFreeCredentialsHandle*(
  credential: ptr CredHandle
  ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc: "FreeCredentialsHandle".}
  ## ref.: https://msdn.microsoft.com/en-us/library/aa375417.aspx
type Sspi_Free_Credentials_Handle_Fn* = proc(
  credential: ptr CredHandle
  ): SecurityStatus {.stdcall.}

ansiWideAllImportC(sspiAddCredentials, sspiAddCredentialsA, sspiAddCredentialsW,
  LPTStr, LPStr, LPWStr, "AddCredentialsA", "AddCredentialsW"):
  proc sspiAddCredentials*(
    credentials: ptr CredHandle,
    principal, package: LPTStr,
    credentialUse: SecPkg_Cred_Use,
    authData: pointer,
    getKeyFn: Sec_Get_Key_Fn,
    getKeyArgument: pointer,
    expiry: var TimeStamp
    ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc.}
    ## :principal: Name of principal
    ## :package: Name of package
    ## :credentialUse: Flags indicating use
    ## :authData: Package specific data
    ## :getKeyFn: Pointer to GetKey() func
    ## :getKeyArgument: Value to pass to GetKey()
    ## :expiry: (out) Lifetime (optional)
ansiWideAll(Sspi_Add_Credentials_Fn, Sspi_Add_Credentials_Fn_A, Sspi_Add_Credentials_Fn_W,
  LPTStr, LPStr, LPWStr):
  type Sspi_Add_Credentials_Fn* = proc(
    credentials: ptr CredHandle,
    principal, package: LPTStr,
    credentialUse: SecPkg_Cred_Use,
    authData: pointer,
    getKeyFn: Sec_Get_Key_Fn,
    getKeyArgument: pointer,
    expiry: var TimeStamp
    ): SecurityStatus {.stdcall.}

#[
########################################################################
###
### Password Change Functions
###
########################################################################
]#
ansiWideAllImportC(tIdent = sspiChangeAccountPassword,
  ansiIdent = sspiChangeAccountPasswordA, wideIdent = sspiChangeAccountPasswordW,
  innerTIdent = LPTStr, innerAnsiIdent = LPStr, innerWideIdent = LPWStr,
  ansiImportC = "ChangeAccountPasswordA", wideImportC = "ChangeAccountPasswordW"):
  proc sspiChangeAccountPassword*(
    packageName, domainName, accountName, oldPassword, newPassword: LPTStr,
    impersonating: Boolean,
    reserved: uint32,
    output: var SecBufferDesc
    ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc.}
    ## ref.: https://msdn.microsoft.com/en-us/library/aa374755.aspx
ansiWideAll(Sspi_Change_Password_Fn, Sspi_Change_Password_Fn_A, Sspi_Change_Password_Fn_W,
  LPTStr, LPStr, LPStr):
  type Sspi_Change_Password_Fn* = proc(
    packageName, domainName, accountName, oldPassword, newPassword: LPTStr,
    impersonating: Boolean,
    reserved: uint32,
    output: var SecBufferDesc
    ): SecurityStatus {.stdcall.}
#[
########################################################################
###
### Context Management Functions
###
########################################################################
]#
ansiWideAllImportC(tIdent = sspiInitializeSecurityContext,
  ansiIdent = sspiInitializeSecurityContextA, wideIdent = sspiInitializeSecurityContextW,
  innerTIdent = LPTStr, innerAnsiIdent = LPStr, innerWideIdent = LPWStr,
  ansiImportC = "InitializeSecurityContextA", wideImportC = "InitializeSecurityContextW"):
  proc sspiInitializeSecurityContext*(
    credential: ptr CredHandle,
    context: ptr CtxtHandle,
    targetName: LPTStr,
    contextReq: Isc_Req_Flag,
    reserved1: uint32,
    targetDataRep: SecurityDrep,
    input: ptr SecBufferDesc,
    reserved2: uint32,
    newContext: var CredHandle,
    output: var SecBufferDesc,
    contextAttr: var Isc_Ret_Flag,
    expiry: var TimeStamp
    ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc.}
    ## ref.: https://msdn.microsoft.com/en-us/library/aa375506.aspx
    ## :credential: Cred to base context
    ## :context: Existing context (OPT)
    ## :targetName: Name of target
    ## :contextReq: Context Requirements
    ## :reserved1: Reserved, MBZ
    ## :targetDataRep: Data rep of target
    ## :input: Input Buffers
    ## :reserved2: Reserved, MBZ
    ## :newContext: (out) New Context handle
    ## :output: (inout) Output Buffers
    ## :contextAttr: Context attrs
    ## :expiry: (out) Life span (OPT)
ansiWideAll(Sspi_Initialize_Security_Context_Fn,
  Sspi_Initialize_Security_Context_Fn_A, Sspi_Initialize_Security_Context_Fn_W,
  LPTStr, LPStr, LPWStr):
  type Sspi_Initialize_Security_Context_Fn* = proc(
    credential: ptr CredHandle,
    context: ptr CtxtHandle,
    targetName: LPTStr,
    contextReq: Isc_Req_Flag,
    reserved1: uint32,
    targetDataRep: SecurityDrep,
    input: ptr SecBufferDesc,
    reserved2: uint32,
    newContext: var CredHandle,
    output: var SecBufferDesc,
    contextAttr: var Isc_Ret_Flag,
    expiry: var TimeStamp
    ): SecurityStatus {.stdcall.}

proc sspiAcceptSecurityContext*(
  credential: ptr CredHandle,
  context: ptr CtxtHandle,
  input: ptr SecBufferDesc,
  contextReq: uint32,
  targetDataRep: uint32,
  newContext: var CtxtHandle,
  output: var SecBufferDesc,
  contextAttr: var uint32,
  expiry: var TimeStamp
  ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc: "AcceptSecurityContext".}
  ## ref.: https://msdn.microsoft.com/en-us/library/aa374703.aspx
  ## :credential: Cred to base context
  ## :context: Existing context (OPT)
  ## :input: Input Buffers
  ## :contextReq: Context Requirements
  ## :targetDataRep: Data rep of target
  ## :newContext: (out) New Context handle
  ## :output: (inout) Output Buffers
  ## :contextAttr: Context attrs
  ## :expiry: (out) Life span (OPT)
type Sspi_Accept_Security_Context_Fn* = proc(
  credential: ptr CredHandle,
  context: ptr CtxtHandle,
  input: ptr SecBufferDesc,
  contextReq: uint32,
  targetDataRep: uint32,
  newContext: var CtxtHandle,
  output: var SecBufferDesc,
  contextAttr: var uint32,
  expiry: var TimeStamp
  ): SecurityStatus {.stdcall.}

proc sspiCompleteAuthToken*(
  context: ptr CtxtHandle,
  token: ptr SecBufferDesc
  ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc: "CompleteAuthToken".}
  ## ref.: https://msdn.microsoft.com/en-us/library/aa374764.aspx
  ## :context: Context to complete
  ## :token: Token to complete
type Sspi_Complete_Auth_Token_Fn* = proc(
  context: ptr CtxtHandle,
  token: ptr SecBufferDesc
  ): SecurityStatus {.stdcall.}

proc sspiImpersonateSecurityContext*(
  context: ptr CtxtHandle
  ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc: "ImpersonateSecurityContext".}
  ## ref.: https://msdn.microsoft.com/en-us/library/aa375497.aspx
  ## :context: Context to impersonate
type Sspi_Impersonate_Security_Context_Fn* = proc(
  context: ptr CtxtHandle
  ): SecurityStatus {.stdcall.}

proc sspiRevertSecurityContext*(
  context: ptr CtxtHandle
  ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc: "RevertSecurityContext".}
  ## ref.: https://msdn.microsoft.com/en-us/library/aa379446.aspx
  ## :context: Context from which to re
type Sspi_Revert_Security_Context_Fn* = proc(
  context: ptr CtxtHandle
  ): SecurityStatus {.stdcall.}

proc sspiQuerySecurityContextToken*(
  context: ptr CtxtHandle,
  token: var Handle
  ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc: "QuerySecurityContextToken".}
  ## ref.: https://msdn.microsoft.com/en-us/library/aa379355.aspx
type Sspi_Query_Security_Context_Token_Fn* = proc(
  context: ptr CtxtHandle,
  token: var Handle
  ): SecurityStatus {.stdcall.}

proc sspiDeleteSecurityContext*(
  context: ptr CtxtHandle
  ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc: "DeleteSecurityContext".}
  ## ref.: https://msdn.microsoft.com/en-us/library/aa375354.aspx
  ## :context: Context to delete
type Sspi_Delete_Security_Context_Fn* = proc(
  context: ptr CtxtHandle
  ): SecurityStatus {.stdcall.}

proc sspiApplyControlToken*(
  context: ptr CtxtHandle,
  input: ptr SecBufferDesc
  ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc: "ApplyControlToken".}
  ## ref.: https://msdn.microsoft.com/en-us/library/aa374724.aspx
  ## :context: Context to modify
  ## :input: Input token to apply
type Sspi_Apply_Control_Token_Fn* = proc(
  context: ptr CtxtHandle,
  input: ptr SecBufferDesc
  ): SecurityStatus {.stdcall.}


ansiWideAllImportC(sspiQueryContextAttributes,
  sspiQueryContextAttributesA, sspiQueryContextAttributesW, void, void, void,
  "QueryContextAttributesA", "QueryContextAttributesW"):
  proc sspiQueryContextAttributes*(
    context: ptr CtxtHandle,
    attribute: SecPkg_Attr,
    buffer: pointer
    ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc.}
    ## ref.: https://msdn.microsoft.com/en-us/library/aa379326.aspx
    ## :context: Context to query
    ## :attribute: Attribute to query
    ## :buffer: Buffer for attributes
ansiWideAll(Sspi_Query_Context_Attributes_Fn,
  Sspi_Query_Context_Attributes_Fn_A, Sspi_Query_Context_Attributes_Fn_W, void, void, void):
  type Sspi_Query_Context_Attributes_Fn* = proc(
    context: ptr CtxtHandle,
    attribute: SecPkg_Attr,
    buffer: pointer
    ): SecurityStatus {.stdcall.}
#[
ansiWideAllImportC(sspiQueryContextAttributesEx,
  sspiQueryContextAttributesExA, sspiQueryContextAttributesExW, void, void, void,
  "QueryContextAttributesExA", "QueryContextAttributesExW"):
  proc sspiQueryContextAttributesEx*(
    context: ptr CtxtHandle,
    attribute: SecPkg_Attr,
    buffer: pointer,
    bufferSize: uint32
    ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc.}
    ## :context: Context to query
    ## :attribute: Attribute to query
    ## :buffer: Buffer for attributes
    ## :bufferSize: Size of buffer
]#
ansiWideAll(Sspi_Query_Context_Attributes_Ex_Fn,
  Sspi_Query_Context_Attributes_Ex_Fn_A, Sspi_Query_Context_Attributes_Ex_Fn_W, void, void, void):
  type Sspi_Query_Context_Attributes_Ex_Fn* = proc(
    context: ptr CtxtHandle,
    attribute: SecPkg_Attr,
    buffer: pointer,
    bufferSize: uint32
    ): SecurityStatus {.stdcall.}

ansiWideAllImportC(sspiSetContextAttributes,
  sspiSetContextAttributesA, sspiSetContextAttributesW, void, void, void,
  "SetContextAttributesA", "SetContextAttributesW"):
  proc sspiSetContextAttributes*(
    context: ptr CtxtHandle,
    attribute: SecPkg_Attr,
    buffer: pointer,
    size: uint32
    ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc.}
    ## ref.: https://msdn.microsoft.com/en-us/library/aa380137.aspx
    ## :context: Context to set
    ## :attribute: Attribute to set
    ## :buffer: Buffer for attributes
    ## :size: Size (in bytes) of Buffer
ansiWideAll(Sspi_Set_Context_Attributes_Fn,
  Sspi_Set_Context_Attributes_Fn_A, Sspi_Set_Context_Attributes_Fn_W, void, void, void):
  type Sspi_Set_Context_Attributes_Fn* = proc(
    context: ptr CtxtHandle,
    attribute: SecPkg_Attr,
    buffer: pointer,
    size: uint32
    ): SecurityStatus {.stdcall.}

ansiWideAllImportC(sspiQueryCredentialsAttributes,
  sspiQueryCredentialsAttributesA, sspiQueryCredentialsAttributesW,
  void, void, void, "QueryCredentialsAttributesA", "QueryCredentialsAttributesW"):
  proc sspiQueryCredentialsAttributes*(
    credential: ptr CredHandle,
    attribute: SecPkg_Cred_Attr,
    buffer: pointer
    ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc.}
    ## ref.: https://msdn.microsoft.com/en-us/library/aa379326.aspx
    ## :credential: Credential to query
    ## :attribute: Attribute to query
    ## :buffer: Buffer for attributes
ansiWideAll(Sspi_Query_Credentials_Attributes_Fn,
  Sspi_Query_Credentials_Attributes_Fn_A, Sspi_Query_Credentials_Attributes_Fn_W,
  void, void, void):
  type Sspi_Query_Credentials_Attributes_Fn* = proc(
    credential: ptr CredHandle,
    attribute: SecPkg_Cred_Attr,
    buffer: pointer
    ): SecurityStatus {.stdcall.}
#[
ansiWideAllImportC(sspiQueryCredentialsAttributesEx,
  sspiQueryCredentialsAttributesExA, sspiQueryCredentialsAttributesExW,
  void, void, void, "QueryCredentialsAttributesExA", "QueryCredentialsAttributesExW"):
  proc sspiQueryCredentialsAttributesEx*(
    credential: ptr CredHandle,
    attribute: SecPkg_Cred_Attr,
    buffer: pointer,
    size: uint32
    ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc.}
    ## :credential: Credential to query
    ## :attribute: Attribute to query
    ## :buffer: Buffer for attributes
    ## :size: Size of buffer
]#
ansiWideAll(Sspi_Query_Credentials_Attributes_Ex_Fn,
  Sspi_Query_Credentials_Attributes_Ex_Fn_A, Sspi_Query_Credentials_Attributes_Ex_Fn_W,
  void, void, void):
  type Sspi_Query_Credentials_Attributes_Ex_Fn* = proc(
    credential: ptr CredHandle,
    attribute: SecPkg_Cred_Attr,
    buffer: pointer,
    size: uint32
    ): SecurityStatus {.stdcall.}

ansiWideAllImportC(sspiSetCredentialsAttributes,
  sspiSetCredentialsAttributesA, sspiSetCredentialsAttributesW,
  void, void, void, "SetCredentialsAttributesA", "SetCredentialsAttributesW"):
  proc sspiSetCredentialsAttributes*(
    credential: ptr CredHandle,
    attribute: SecPkg_Cred_Attr,
    buffer: pointer,
    size: uint32
    ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc.}
    ## ref.: https://msdn.microsoft.com/en-us/library/ff621492.aspx
    ## :credential: Credential to set
    ## :attribute: Attribute to set
    ## :buffer: Buffer for attributes
    ## :size: Size (in bytes) of buffer
ansiWideAll(Sspi_Set_Credentials_Attributes_Fn,
  Sspi_Set_Credentials_Attributes_Fn_A, Sspi_Set_Credentials_Attributes_Fn_W,
  void, void, void):
  type Sspi_Set_Credentials_Attributes_Fn* = proc(
    credential: ptr CredHandle,
    attribute: SecPkg_Cred_Attr,
    buffer: pointer,
    size: uint32
    ): SecurityStatus {.stdcall.}

proc sspiFreeContextBuffer*(
  contextBuffer: pointer
  ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc: "FreeContextBuffer".}
  ## ref.: https://msdn.microsoft.com/en-us/library/aa375416.aspx
  ## :contextBuffer: buffer to free
type Sspi_Free_Context_Buffer_Fn* = proc(contextBuffer: pointer): SecurityStatus {.stdcall.}

#[
###################################################################
####
####    Message Support API
####
##################################################################
]#
type SecQoP* = distinct uint32

proc sspiMakeSignature*(
  context: ptr CtxtHandle,
  qop: SecQoP,
  msg: ptr SecBufferDesc,
  msgSeqNo: uint32
  ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc: "MakeSignature".}
  ## ref.: https://msdn.microsoft.com/en-us/library/aa378736.aspx
  ## :context: Context to use
  ## :qop: Quality of Protection
  ## :msg: Message to sign
  ## :msgSeqNo: Message Sequence Num.
type Sspi_Make_Signature_Fn* = proc(
  context: ptr CtxtHandle,
  qop: SecQoP,
  msg: ptr SecBufferDesc,
  msgSeqNo: uint32
  ): SecurityStatus {.stdcall.}

proc sspiVerifySignature*(
  context: ptr CtxtHandle,
  msg: ptr SecBufferDesc,
  msgSeqNo: uint32,
  qop: var SecQoP
  ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc: "VerifySignature".}
  ## ref.: https://msdn.microsoft.com/en-us/library/aa380540.aspx
  ## :context: Context to use
  ## :msg: Message to verify
  ## :msgSeqNo: Message Sequence Num.
  ## :qop: QOP used
type Sspi_Verify_Signature_Fn* = proc(
  context: ptr CtxtHandle,
  msg: ptr SecBufferDesc,
  msgSeqNo: uint32,
  qop: var SecQoP
  ): SecurityStatus {.stdcall.}

# This only exists win Win2k3 and Greater
const
  secqop_wrap_no_encrypt* = 0x80000001.SecQoP
  secqop_wrap_oob_data* = 0x40000000.SecQoP

proc sspiEncryptMessage*(
  context: ptr CtxtHandle,
  qop: SecQoP,
  msg: ptr SecBufferDesc,
  msgSeqNo: uint32
  ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc: "EncryptMessage".}
  ## ref.: https://msdn.microsoft.com/en-us/library/aa375378.aspx
type Sspi_Encrypt_Message_Fn* = proc(
  context: ptr CtxtHandle,
  qop: SecQoP,
  msg: ptr SecBufferDesc,
  msgSeqNo: uint32
  ): SecurityStatus {.stdcall.}

proc sspiDecryptMessage*(
  context: ptr CtxtHandle,
  msg: ptr SecBufferDesc,
  msgSeqNo: uint32,
  qop: var SecQoP
  ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc: "DecryptMessage".}
  ## ref.: https://msdn.microsoft.com/en-us/library/aa375211.aspx
type Sspi_Decrypt_Message_Fn* = proc(
  context: ptr CtxtHandle,
  msg: ptr SecBufferDesc,
  msgSeqNo: uint32,
  qop: var SecQoP
  ): SecurityStatus {.stdcall.}

#[
###########################################################################
####
####    Misc.
####
###########################################################################
]#
ansiWideAllImportC(sspiEnumerateSecurityPackages,
  sspiEnumerateSecurityPackagesA, sspiEnumerateSecurityPackagesW,
  SecPkgInfo, SecPkgInfoA, SecPkgInfoW,
  "EnumerateSecurityPackagesA", "EnumerateSecurityPackagesW"):
  proc sspiEnumerateSecurityPackages*(
    len: var uint32,
    packageInfos: var AnySizeArrayPtr[SecPkgInfo]
    ): SecurityStatus {.stdcall, dynlib: "SspiCli.dll", importc.}
    ## ref.: https://msdn.microsoft.com/en-us/library/aa375397.aspx
    ## :len: Receives num. packages
    ## :packageInfos: Receives array of info
ansiWideAll(Sspi_Enumerate_Security_Packages_Fn,
  Sspi_Enumerate_Security_Packages_Fn_A, Sspi_Enumerate_Security_Packages_Fn_W,
  SecPkgInfo, SecPkgInfoA, SecPkgInfoW):
  type Sspi_Enumerate_Security_Packages_Fn* = proc(
    len: var uint32,
    packageInfos: var AnySizeArrayPtr[SecPkgInfo]
    ): SecurityStatus {.stdcall.}

ansiWideAllMultiImportC(sspiQuerySecurityPackageInfo,
  sspiQuerySecurityPackageInfoA, sspiQuerySecurityPackageInfoW,
  [("SecPkgInfo", "SecPkgInfoA", "SecPkgInfoW"), ("LPTStr", "LPStr", "LPWStr")],
  "QuerySecurityPackageInfoA", "QuerySecurityPackageInfoW"):
  proc sspiQuerySecurityPackageInfo*(
    packageName: LPTStr,
    packageInfo: var ptr SecPkgInfo
    ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc.}
    ## ref.: https://msdn.microsoft.com/en-us/library/aa379359.aspx
    ## :packageName: Name of package
    ## :packageInfo: Receives package info
ansiWideAllMulti(Sspi_Query_Security_Package_Info_Fn,
  Sspi_Query_Security_Package_Info_Fn_A, Sspi_Query_Security_Package_Info_Fn_W,
  [("SecPkgInfo", "SecPkgInfoA", "SecPkgInfoW"), ("LPTStr", "LPStr", "LPWStr")]):
  type Sspi_Query_Security_Package_Info_Fn* = proc(
    packageName: LPTStr,
    packageInfo: var ptr SecPkgInfo
    ): SecurityStatus {.stdcall.}

type SecDelegationType* = enum
  secFull, secService, secTree, secDirectory, secObject

#[
proc sspiDelegateSecurityContext*(
  context: ptr CtxtHandle,
  target: LPStr,
  delegationType: SecDelegationType,
  timestamp: ptr TimeStamp = nil,
  packageParameters: ptr SecBuffer = nil,
  output: var SecBufferDesc
  ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc: "DelegateSecurityContext".}
  ## :context: Active context to delegate
  ## :target: Target path
  ## :delegationType: Type of delegation
  ## :timestamp: OPTIONAL time limit
  ## :packageParameters: OPTIONAL package specific
  ## :output: Token for :sspiApplyControlToken:.
]#

#[
###########################################################################
####
####    Proxies
####
###########################################################################
]#

#[
Proxies are only available on NT platforms
]#

#[
###########################################################################
####
####    Context export/import
####
###########################################################################
]#
proc sspiExportSecurityContext*(
  context: ptr CtxtHandle,
  flags: SecPkg_Context_Export_Flag,
  packedContext: var SecBuffer,
  token: var Handle
  ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc: "ExportSecurityContext".}
  ## ref.: https://msdn.microsoft.com/en-us/library/aa375409.aspx
  ## :context: context to export
  ## :flags: option flags
  ## :packedContext: marshalled context
  ## :token: token handle for impersonation
type Sspi_Export_Security_Context_Fn* = proc(
  context: ptr CtxtHandle,
  flags: SecPkg_Context_Export_Flag,
  packedContext: var SecBuffer,
  token: var Handle
  ): SecurityStatus {.stdcall.}

ansiWideAllImportC(sspiImportSecurityContext,
  sspiImportSecurityContextA, sspiImportSecurityContextW,
  LPTStr, LPStr, LPWStr, "ImportSecurityContextA", "ImportSecurityContextW"):
  proc sspiImportSecurityContext*(
    package: LPTStr,
    packedContext: ptr SecBuffer,
    token: Handle,
    context: var CtxtHandle
    ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc.}
    ## ref.: https://msdn.microsoft.com/en-us/library/aa375502.aspx
    ## :packedContext: marshalled context
    ## :token: handle to token for context
    ## :context: new context handle
ansiWideAll(Sspi_Import_Security_Context_Fn,
  Sspi_Import_Security_Context_Fn_A, Sspi_Import_Security_Context_Fn_W,
  LPTStr, LPStr, LPWStr):
  type Sspi_Import_Security_Context_Fn* = proc(
    package: LPTStr,
    packedContext: ptr SecBuffer,
    token: Handle,
    context: var CtxtHandle
    ): SecurityStatus {.stdcall.}

#[
###############################################################################
####
####  Fast access for RPC:
####
###############################################################################
]#
type Security_Support_Provider_Interface_Version* = distinct uint32
ansiWideAllMulti(SecurityFunctionTable, SecurityFunctionTableA, SecurityFunctionTableW,
  [
    ("Sspi_Enumerate_Security_Packages_Fn", "Sspi_Enumerate_Security_Packages_Fn_A", "Sspi_Enumerate_Security_Packages_Fn_W"),
    ("Sspi_Query_Credentials_Attributes_Fn", "Sspi_Query_Credentials_Attributes_Fn_A", "Sspi_Query_Credentials_Attributes_Fn_W"),
    ("Sspi_Acquire_Credentials_Handle_Fn", "Sspi_Acquire_Credentials_Handle_Fn_A", "Sspi_Acquire_Credentials_Handle_Fn_W"),
    ("Sspi_Initialize_Security_Context_Fn", "Sspi_Initialize_Security_Context_Fn_A", "Sspi_Initialize_Security_Context_Fn_W"),
    ("Sspi_Query_Context_Attributes_Fn", "Sspi_Query_Context_Attributes_Fn_A", "Sspi_Query_Context_Attributes_Fn_W"),
    ("Sspi_Query_Security_Package_Info_Fn", "Sspi_Query_Security_Package_Info_Fn_A", "Sspi_Query_Security_Package_Info_Fn_W"),
    ("Sspi_Import_Security_Context_Fn", "Sspi_Import_Security_Context_Fn_A", "Sspi_Import_Security_Context_Fn_W"),
    ("Sspi_Add_Credentials_Fn", "Sspi_Add_Credentials_Fn_A", "Sspi_Add_Credentials_Fn_W"),
    ("Sspi_Set_Context_Attributes_Fn", "Sspi_Set_Context_Attributes_Fn_A", "Sspi_Set_Context_Attributes_Fn_W"),
    ("Sspi_Set_Credentials_Attributes_Fn", "Sspi_Set_Credentials_Attributes_Fn_A", "Sspi_Set_Credentials_Attributes_Fn_W"),
    ("Sspi_Change_Password_Fn", "Sspi_Change_Password_Fn_A", "Sspi_Change_Password_Fn_W"),
    ("Sspi_Query_Context_Attributes_Ex_Fn", "Sspi_Query_Context_Attributes_Ex_Fn_A", "Sspi_Query_Context_Attributes_Ex_Fn_W"),
    ("Sspi_Query_Credentials_Attributes_Ex_Fn", "Sspi_Query_Credentials_Attributes_Ex_Fn_A", "Sspi_Query_Credentials_Attributes_Ex_Fn_W"),
  ]):
  type SecurityFunctionTable* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/aa380125.aspx
    version*: Security_Support_Provider_Interface_Version
    enumerateSecurityPackages: Sspi_Enumerate_Security_Packages_Fn
    queryCredentialsAttributes: Sspi_Query_Credentials_Attributes_Fn
    acquireCredentialsHandle: Sspi_Acquire_Credentials_Handle_Fn
    freeCredentialsHandle: Sspi_Free_Credentials_Handle_Fn
    reserved2: pointer
    initializeSecurityContext: Sspi_Initialize_Security_Context_Fn
    acceptSecurityContext: Sspi_Accept_Security_Context_Fn
    completeAuthToken: Sspi_Complete_Auth_Token_Fn
    deleteSecurityContext: Sspi_Delete_Security_Context_Fn
    applyControlToken: Sspi_Apply_Control_Token_Fn
    queryContextAttributes: Sspi_Query_Context_Attributes_Fn
    impersonateSecurityContext: Sspi_Impersonate_Security_Context_Fn
    revertSecurityContext: Sspi_Revert_Security_Context_Fn
    makeSignature: Sspi_Make_Signature_Fn
    verifySignature: Sspi_Verify_Signature_Fn
    freeContextBuffer: Sspi_Free_Context_Buffer_Fn
    querySecurityPackageInfo: Sspi_Query_Security_Package_Info_Fn
    reserved3: pointer
    reserved4: pointer
    exportSecurityContext: Sspi_Export_Security_Context_Fn
    importSecurityContext: Sspi_Import_Security_Context_Fn
    addCredentials: Sspi_Add_Credentials_Fn
    reserved8: pointer
    querySecurityContextToken: Sspi_Query_Security_Context_Token_Fn
    encryptMessage: Sspi_Encrypt_Message_Fn
    decryptMessage: Sspi_Decrypt_Message_Fn
    setContextAttributes: Sspi_Set_Context_Attributes_Fn
    setCredentialsAttributes: Sspi_Set_Credentials_Attributes_Fn
    changeAccountPassword: Sspi_Change_Password_Fn
    queryContextAttributesEx: Sspi_Query_Context_Attributes_Ex_Fn
    queryCredentialsAttributesEx: Sspi_Query_Credentials_Attributes_Ex_Fn
const
  security_support_provider_interface_version* = 1.Security_Support_Provider_Interface_Version
    ## Function table has all routines through DecryptMessage
  security_support_provider_interface_version_2* = 2.Security_Support_Provider_Interface_Version
    ## Function table has all routines through SetContextAttributes
  security_support_provider_interface_version_3* = 3.Security_Support_Provider_Interface_Version
    ## Function table has all routines through SetCredentialsAttributes
  security_support_provider_interface_version_4* = 4.Security_Support_Provider_Interface_Version
    ## Function table has all routines through ChangeAccountPassword
  security_support_provider_interface_version_5* = 5.Security_Support_Provider_Interface_Version
    ## Function table has all routines through QueryCredentialsAttributesEx
ansiWideAllImportC(sspiInitSecurityInterface,
  sspiInitSecurityInterfaceA, sspiInitSecurityInterfaceW,
  SecurityFunctionTable, SecurityFunctionTableA, SecurityFunctionTableW,
  "InitSecurityInterfaceA", "InitSecurityInterfaceW"):
  proc sspiInitSecurityInterface*(): SecurityFunctionTable {.stdcall, dynlib: "Secur32.dll", importc.}
    ## ref.: https://msdn.microsoft.com/en-us/library/aa376103.aspx
ansiWideAll(Sspi_Init_Security_Interface_Fn,
  Sspi_Init_Security_Interface_Fn_A, Sspi_Init_Security_Interface_Fn_W,
  SecurityFunctionTable, SecurityFunctionTableA, SecurityFunctionTableW):
  type Sspi_Init_Security_Interface_Fn* = proc(): SecurityFunctionTable {.stdcall.}

#[
  SASL Profile Support
]#
ansiWideAllImportC(saslEnumerateProfiles,
  saslEnumerateProfilesA, saslEnumerateProfilesW,
  LPTStr, LPStr, LPWStr, "SaslEnumerateProfilesA", "SaslEnumerateProfilesW"):
  proc saslEnumerateProfiles*(
    profileList: var LPTStr,
    len: var uint32
    ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc.}
    ## ref.: https://msdn.microsoft.com/en-us/library/aa379455.aspx
ansiWideAllMultiImportC(saslGetProfilePackage,
  saslGetProfilePackageA, saslGetProfilePackageW,
  [("LPTStr", "LPStr", "LPWStr"), ("SecPkgInfo", "SecPkgInfoA", "SecPkgInfoW")],
  "SaslGetProfilePackageA", "SaslGetProfilePackageW"):
  proc saslGetProfilePackage*(
    profileName: LPTStr,
    packageInfo: var SecPkgInfo
    ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc.}
    ## ref.: https://msdn.microsoft.com/en-us/library/aa379459.aspx
ansiWideAllImportC(saslIdentifyPackage,
  saslIdentifyPackageA, saslIdentifyPackageW,
  SecPkgInfo, SecPkgInfoA, SecPkgInfoW,
  "SaslIdentifyPackageA", "SaslIdentifyPackageW"):
  proc saslIdentifyPackage*(
    input: ptr SecPkgInfo,
    packageInfo: var SecPkgInfo
    ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc.}
    ## ref.: https://msdn.microsoft.com/en-us/library/aa379461.aspx
ansiWideAllImportC(saslInitializeSecurityContext,
  saslInitializeSecurityContextA, saslInitializeSecurityContextW,
  LPTStr, LPStr, LPWStr, "SaslInitializeSecurityContextA", "SaslInitializeSecurityContextW"):
  proc saslInitializeSecurityContext*(
    credential: ptr CredHandle,
    context: ptr CtxtHandle,
    targetName: LPTStr,
    contextReq: Isc_Req_Flag,
    reserved1: uint32,
    targetDataRep: SecurityDrep,
    input: ptr SecBufferDesc,
    reserved2: uint32,
    newContext: var CtxtHandle,
    output: var SecBufferDesc,
    contextAttr: var Isc_Ret_Flag,
    expiry: var TimeStamp
    ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc.}
    ## ref.: https://msdn.microsoft.com/en-us/library/aa379463.aspx
    ## :credential: Cred to base context
    ## :context: Existing context (OPT)
    ## :targetName: Name of target
    ## :contextReq: Context Requirements
    ## :reserved1: Reserved, MBZ
    ## :targetDataRep: Data rep of target
    ## :input: Input Buffers
    ## :reserved2: Reserved, MBZ
    ## :newContext: (out) New Context handle
    ## :output: (inout) Output Buffers
    ## :contextAttr: (out) Context attrs
    ## :expiry: (out) Life span (OPT)
proc saslAcceptSecurityContext*(
    credential: ptr CredHandle,
    context: ptr CtxtHandle,
    input: ptr SecBufferDesc,
    contextReq: Isc_Req_Flag,
    targetDataRep: SecurityDrep,
    newContext: var CtxtHandle,
    output: var SecBufferDesc,
    contextAttr: var Isc_Ret_Flag,
    expiry: var TimeStamp
  ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc: "SaslAcceptSecurityContext".}
  ## ref.: https://msdn.microsoft.com/en-us/library/aa379453.aspx
  ## :credential: Cred to base context
  ## :context: Existing context (OPT)
  ## :input: Input buffer
  ## :contextReq: Context Requirements
  ## :targetDataRep: Target Data Rep
  ## :newContext: (out) New context handle
  ## :output: (inout) Output buffers
  ## :contextAttr: (out) Context attributes
  ## :expiry: (out) Life span (OPT)
type Sasl_Context_Option = distinct uint32
const
  sasl_option_send_size* = 1.Sasl_Context_Option ## Maximum size to send to peer
  sasl_option_recv_size* = 2.Sasl_Context_Option ## Maximum size willing to receive
  sasl_option_authz_string* = 3.Sasl_Context_Option ## Authorization string
  sasl_option_authz_processing* = 4.Sasl_Context_Option ## Authorization string processing
type Sasl_Authzid_State* = enum
    sasl_AuthZIDForbidden
      ## allow no AuthZID strings to be specified - error out (default)
    sasl_AuthZIDProcessed
      ## AuthZID Strings processed by Application or SSP
proc saslSetContextOption*(
  context: ptr CtxtHandle,
  option: Sasl_Context_Option,
  value: pointer,
  size: uint32
  ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc: "SaslSetContextOption".}
  ## ref.: https://msdn.microsoft.com/en-us/library/aa379464.aspx
proc saslGetContextOption*(
  context: ptr CtxtHandle,
  option: Sasl_Context_Option,
  value: pointer,
  size: uint32,
  needed: var uint32
  ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc: "SaslGetContextOption".}
  ## ref.: https://msdn.microsoft.com/en-us/library/aa379456.aspx

type 
  Sec_Winnt_Auth_Identity_Version* = distinct uint32
  Sec_WinNt_Auth_Identity_Flag* = distinct uint32
const
  sec_winnt_auth_identity_version_2* = 0x201.Sec_Winnt_Auth_Identity_Version

type Sec_Winnt_Auth_Identity_Ex2* = object
  ## This is the legacy credentials structure.
  ## ref.: https://msdn.microsoft.com/en-us/library/dd759400.aspx
  version: Sec_Winnt_Auth_Identity_Version ## contains SEC_WINNT_AUTH_IDENTITY_VERSION_2
  headerSize: uint16
  structSize: uint32
  userOffset: uint32 ## Non-NULL terminated string, unicode only
  userSize: uint16 ## # of bytes (NOT WCHARs), not including NULL.
  domainOffset: uint32 ## Non-NULL terminated string, unicode only
  domainSize: uint16 ## # of bytes (NOT WCHARs), not including NULL.
  packedCredentialsOffset: uint32 ## Non-NULL terminated string, unicode only
  packedCredentialsSize: uint16 ## # of bytes (NOT WCHARs), not including NULL.
  flags: Sec_WinNt_Auth_Identity_Flag
  packageListOffset: uint32 ## Non-NULL terminated string, unicode only
  packageListSize: uint16

const
  sec_winnt_auth_identity_ansi* = 0x1.Sec_WinNt_Auth_Identity_Flag
  sec_winnt_auth_identity_unicode* = 0x2.Sec_WinNt_Auth_Identity_Flag

ansiWideAll(Sec_Winnt_Auth_Identity,
  Sec_Winnt_Auth_Identity_A, Sec_Winnt_Auth_Identity_W,
  LPTStr, LPStr, LPWStr):
  type Sec_Winnt_Auth_Identity* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/aa380131.aspx
    user: LPTStr ## Non-NULL terminated string.
    userLen: uint32 ## # of characters (NOT bytes), not including NULL.
    domain: LPTStr ## Non-NULL terminated string.
    domainLen: uint32 ## # of characters (NOT bytes), not including NULL.
    password: LPTStr ## Non-NULL terminated string.
    passwordLen: uint32 ## # of characters (NOT bytes), not including NULL.
    flags: Sec_WinNt_Auth_Identity_Flag

const sec_winnt_auth_identity_version* = 0x200.Sec_Winnt_Auth_Identity_Version

ansiWideAll(Sec_Winnt_Auth_Identity_Ex,
  Sec_Winnt_Auth_Identity_ExA, Sec_Winnt_Auth_Identity_ExW,
  LPTStr, LPStr, LPWStr):
  type Sec_Winnt_Auth_Identity_Ex* = object
    ## This is the combined authentication identity structure that may be
    ## used with the negotiate package, NTLM, Kerberos, or SCHANNEL
    ## ref.: https://msdn.microsoft.com/en-us/library/aa380132.aspx
    version: Sec_WinNt_Auth_Identity_Version
    size: uint32
    user: LPTStr ## Non-NULL terminated string.
    userLen: uint32 ## # of characters (NOT bytes), not including NULL.
    domain: LPTStr ## Non-NULL terminated string.
    domainLen: uint32 ## # of characters (NOT bytes), not including NULL.
    password: LPTStr ## Non-NULL terminated string.
    passwordLen: uint32 ## # of characters (NOT bytes), not including NULL.
    flags: Sec_WinNt_Auth_Identity_Flag
    packageList: LPTStr
    packageListLen: uint32

type Sec_WinNt_Auth_Identity_Info* {.union.} = object
  ## the procedure for how to parse a Sec_WinNt_Auth_Identity_Info structure:
  ## 1) First check the first DWORD of SEC_WINNT_AUTH_IDENTITY_INFO, if the first
  ##    DWORD is 0x200, it is either an AuthIdExw or AuthIdExA, otherwise if the first
  ##    DWORD is 0x201, the structure is an AuthIdEx2 structure. Otherwise the structure
  ##    is either an AuthId_a or an AuthId_w.
  ## 2) Secondly check the flags for SEC_WINNT_AUTH_IDENTITY_ANSI or
  ##    SEC_WINNT_AUTH_IDENTITY_UNICODE, the presence of the former means the structure
  ##    is an ANSI structure. Otherwise, the structure is the wide version.  Note that
  ##    AuthIdEx2 does not have an ANSI version so this check does not apply to it.
  authIdExW: Sec_Winnt_Auth_Identity_ExW
  authIdExA: Sec_Winnt_Auth_Identity_ExA
  authIdA: Sec_Winnt_Auth_Identity_A
  authIdW: Sec_Winnt_Auth_Identity_W
  authIdEx2: Sec_Winnt_Auth_Identity_Ex2

const
  sec_winnt_auth_identity_flags_process_encrypted* = 0x10.Sec_WinNt_Auth_Identity_Flag
    ## the credential structure is encrypted via
    ## RtlEncryptMemory(OptionFlags = 0)

  sec_winnt_auth_identity_flags_system_protected* = 0x20.Sec_WinNt_Auth_Identity_Flag
    ## the credential structure is protected by local system via
    ## RtlEncryptMemory(OptionFlags=IOCTL_KSEC_ENCRYPT_MEMORY_SAME_LOGON)

  sec_winnt_auth_identity_flags_user_protected* = 0x40.Sec_WinNt_Auth_Identity_Flag
    ## the credential structure is encrypted by a non-system context
    ## RtlEncryptMemory(OptionFlags=IOCTL_KSEC_ENCRYPT_MEMORY_SAME_LOGON)

  sec_winnt_auth_identity_flags_reserved* = 0x10000.Sec_WinNt_Auth_Identity_Flag
  sec_winnt_auth_identity_flags_null_user* = 0x20000.Sec_WinNt_Auth_Identity_Flag
  sec_winnt_auth_identity_flags_null_domain* = 0x40000.Sec_WinNt_Auth_Identity_Flag
  sec_winnt_auth_identity_flags_id_provider* = 0x80000.Sec_WinNt_Auth_Identity_Flag

  sec_winnt_auth_identity_flags_sspipfc_use_mask* = 0xFF000000.Sec_WinNt_Auth_Identity_Flag
    ## These bits are for communication between SspiPromptForCredentials()
    ## and the credential providers. Do not use these bits for any other
    ## purpose.

  sec_winnt_auth_identity_flags_sspipfc_credprov_do_not_save* = 0x80000000.Sec_WinNt_Auth_Identity_Flag
    ## Instructs the credential provider to not save credentials itself
    ## when caller selects the "Remember my credential" checkbox.

  sec_winnt_auth_identity_flags_sspipfc_save_cred_by_caller* = sec_winnt_auth_identity_flags_sspipfc_credprov_do_not_save
    ## Support the old name for this flag for callers that were built for earlier
    ## versions of the SDK.

  sec_winnt_auth_identity_flags_sspipfc_save_cred_checked* = 0x40000000.Sec_WinNt_Auth_Identity_Flag
    ## State of the "Remember my credentials" checkbox.
    ## When set, indicates checked; when cleared, indicates unchecked.

  sec_winnt_auth_identity_flags_sspipfc_no_checkbox* = 0x20000000.Sec_WinNt_Auth_Identity_Flag
    ## The "Save" checkbox is not displayed on the credential provider tiles

  sec_winnt_auth_identity_flags_sspipfc_credprov_do_not_load* = 0x10000000.Sec_WinNt_Auth_Identity_Flag
    ## Credential providers will not attempt to prepopulate the CredUI dialog
    ## box with credentials retrieved from Cred Man.

  sec_winnt_auth_identity_flags_valid_sspipfc_flags* = (
    sec_winnt_auth_identity_flags_sspipfc_credprov_do_not_save.uint32 or
    sec_winnt_auth_identity_flags_sspipfc_save_cred_checked.uint32 or
    sec_winnt_auth_identity_flags_sspipfc_no_checkbox.uint32 or
    sec_winnt_auth_identity_flags_sspipfc_credprov_do_not_load.uint32
    ).Sec_WinNt_Auth_Identity_Flag

type SspiPfc_Flag* = distinct uint32
  ## flags parameter of SspiPromptForCredentials()
const
  sspipfc_credprov_do_not_save* = 0x00000001.SspiPfc_Flag
    ## Indicates that the credentials should not be saved if
    ## the user selects the 'save' (or 'remember my password')
    ## checkbox in the credential dialog box. The location pointed
    ## to by the pfSave parameter indicates whether or not the user
    ## selected the checkbox.
    ## Note that some credential providers won't honour this flag and
    ## may save the credentials in a persistent manner anyway if the
    ## user selects the 'save' checbox.

  sspipfc_save_cred_by_caller* = sspipfc_credprov_do_not_save
    ## Support the old name for this flag for callers that were built for earlier
    ## versions of the SDK.

  sspipfc_no_checkbox* = 0x00000002.SspiPfc_Flag
    ## The password and smart card credential providers will not display the 
    ## "Remember my credentials" check box in the provider tiles. 

  sspipfc_credprov_do_not_load* = 0x00000004.SspiPfc_Flag
    ## Credential providers will not attempt to prepopulate the CredUI dialog
    ## box with credentials retrieved from Cred Man.

  sspipfc_use_creduibroker* = 0x00000008.SspiPfc_Flag
    ## Credential providers along with UI Dialog will be hosted in a separate
    ## broker process.

  sspipfc_valid_flags* = (sspipfc_credprov_do_not_save.uint32 or sspipfc_no_checkbox.uint32 or sspipfc_credprov_do_not_load.uint32 or sspipfc_use_creduibroker.uint32).SspiPfc_Flag

ansiWideAllMultiImportC(sspiPromptForCredentials,
  sspiPromptForCredentialsA, sspiPromptForCredentialsW,
  [("LPTStr", "LPStr", "LPWStr"), ("CredUi_Info", "CredUi_InfoA", "CredUi_InfoW")],
  "SspiPromptForCredentialsA", "SspiPromptForCredentialsW"):
  proc sspiPromptForCredentials*(
    targetName: LPTStr,
    uiInfo: CredUi_Info,
    authError: uint32,
    package: LPTStr,
    inputAuthIdentity: ptr Sec_WinNt_Auth_Identity_Info,
    authIdentity: var Sec_WinNt_Auth_Identity_Info,
    save: var Bool,
    flags: SspiPfc_Flag
    ): SecurityStatus {.stdcall, dynlib: "CredUi.dll", importc.}
    ## ref.: https://msdn.microsoft.com/en-us/library/dd401714.aspx

type
  Sec_WinNt_Auth_Byte_Vector* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/dd401692.aspx
    byteArrayOffset: uint32 ## each element is a byte
    byteArrayLen: uint16
  
  Sec_WinNt_Auth_Data* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/dd759399.aspx
    credType: Guid
    credData: Sec_WinNt_Auth_Byte_Vector

  Sec_WinNt_Auth_Packed_Credentials* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/dd401695.aspx
    headerSize: uint16 ## the length of the header
    structureSize: uint16 ## pay load length including the header
    authData: Sec_WinNt_Auth_Data

const
  sec_winnt_auth_data_type_password* = Guid(data1: 0x28bfc32f, data2: 0x10f6, data3: 0x4738, data4: [0x98'u8, 0xd1'u8, 0x1a'u8, 0xc0'u8, 0x61'u8, 0xdf'u8, 0x71'u8, 0x6a'u8])
  sec_winnt_auth_data_type_cert* = Guid(data1: 0x235f69ad, data2: 0x73fb, data3: 0x4dbc, data4: [0x82'u8, 0x3'u8, 0x6'u8, 0x29'u8, 0xe7'u8, 0x39'u8, 0x33'u8, 0x9b'u8])
  sec_winnt_auth_data_type_ngc* = Guid(data1: 0x10a47879, data2: 0x5ebf, data3: 0x4b85, data4: [0xbd'u8, 0x8d'u8, 0xc2'u8, 0x1b'u8, 0xb4'u8, 0xf4'u8, 0x9c'u8, 0x8a'u8])

type Sec_WinNt_Auth_Data_Password* = object
  ## ref.: https://msdn.microsoft.com/en-us/library/dd401694.aspx
  unicodePassword: Sec_WinNt_Auth_Byte_Vector

const sec_winnt_auth_data_type_csp_data* = Guid(data1: 0x68fd9879, data2: 0x79c, data3: 0x4dfe, data4: [0x82'u8, 0x81'u8, 0x57'u8, 0x8a'u8, 0xad'u8, 0xc1'u8, 0xc1'u8, 0x0'u8])

type
  Sec_WinNt_Auth_Certificate_Data* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/dd401693.aspx
    headerSize: uint16
    structureSize: uint16
    certificate: Sec_WinNt_Auth_Byte_Vector

  Sec_WinNt_Auth_Ngc_Data* = object
    logonId: Luid
    flags: uint32
    cspInfo: Sec_WinNt_Auth_Byte_Vector
    userIdKeyAuthTicket: Sec_WinNt_Auth_Byte_Vector
    decryptionKeyName: Sec_WinNt_Auth_Byte_Vector
    decryptionKeyAuthTicket: Sec_WinNt_Auth_Byte_Vector

  Sec_WinNt_CredUi_Context_Vector* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/dd401697.aspx
    credUiContextArrayOffset: uint32
      ## offset starts at the beginning of
      ## this structure, and each element is a SEC_WINNT_AUTH_BYTE_VECTOR that
      ## describes the flat CredUI context returned by SpGetCredUIContext()
    credUiContextLen: uint16

  Sec_WinNt_Auth_Short_Vector* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/dd894408.aspx
    shortArrayOffset: uint32 ## each element is a short
    shortArrayLen: uint16

  Sec_WinNt_CredUi_Context* = object
    ## ref.: https://msdn.microsoft.com/en-us/library/dd433793.aspx
    headerSize: uint16
    credUiContextHandle: Handle ## the handle to call SspiGetCredUIContext()
    uiInfo: CredUi_InfoW ## input from SspiPromptForCredentials()
    authError: uint32 ## the authentication error
    inputAuthIdentity: ptr Sec_WinNt_Auth_Identity_Info

# free the returned memory using SspiLocalFree

proc sspiGetCredUiContext*(
  context: ptr Sec_WinNt_CredUi_Context,
  credType: ptr Guid,
  logonId: ptr Luid,
  credUiContexts: var ptr Sec_WinNt_CredUi_Context_Vector,
  tokenHandle: var Handle
  ): SecurityStatus {.stdcall, dynlib: "CredUi.dll", importc: "SspiGetCredUIContext".}
  ## ref.: https://msdn.microsoft.com/en-us/library/dd401706.aspx
  ## :logonId: use this LogonId, the caller must be localsystem to supply a logon id

proc sspiUpdateCredentials*(
  context: ptr Sec_WinNt_CredUi_Context,
  credType: ptr Guid,
  flatCredUiContextSize: uint32,
  flatCredUiContext: AnySizeArrayPtr[byte]
  ): SecurityStatus {.stdcall, dynlib: "CredUi.dll", importc: "SspiUpdateCredentials".}
  ## ref.: https://msdn.microsoft.com/en-us/library/dd401717.aspx

type CredUiWin_Marshaled_Context* = object
  ## ref.: https://msdn.microsoft.com/en-us/library/dd401609.aspx
  structureType: Guid
  headerSize: uint16
  logonId: Luid ## user's logon id
  marshaledDataType: Guid
  marshaledDataOffset: uint32
  marshaledDataSize: uint16

const
  creduiwin_structure_type_sspipfc* = Guid(data1: 0x3c3e93d9, data2: 0xd96b, data3: 0x49b5, data4: [0x94'u8, 0xa7'u8, 0x45'u8, 0x85'u8, 0x92'u8, 0x8'u8, 0x83'u8, 0x37'u8])
  sspipfc_structure_type_credui_context* = Guid(data1: 0xc2fffe6f'u32, data2: 0x503d, data3: 0x4c3d, data4: [0xa9'u8, 0x5e'u8, 0xbc'u8, 0xe8'u8, 0x21'u8, 0x21'u8, 0x3d'u8, 0x44'u8])

type Sec_WinNt_Auth_Packed_Credentials_Ex* = object
  ## ref.: https://msdn.microsoft.com/en-us/library/dd401696.aspx
  headerSize: uint16
  flags: uint32 
    ## contains the Flags field in
    ## SEC_WINNT_AUTH_IDENTITY_EX
  packedCredentials: Sec_WinNt_Auth_Byte_Vector
  packageList: Sec_WinNt_Auth_Short_Vector

# free the returned memory using SspiLocalFree

proc sspiUnmarshalCredUIContext*(
  marshaledCredUiContext: AnySizeArrayPtr[byte],
  marshaledCredUiContextLen: uint32,
  credUiContext: var ptr Sec_WinNt_CredUi_Context
  ): SecurityStatus {.stdcall, dynlib: "CredUi.dll", importc: "SspiUnmarshalCredUIContext".}
  ## ref.: https://msdn.microsoft.com/en-us/library/dd401716.aspx

proc sspiPrepareForCredRead*(
  authIdentity: ptr Sec_WinNt_Auth_Identity_Info,
  targetName: LPWStr,
  credManCredentialType: var uint32,
  credmanTargetName: var LPWStr
  ): SecurityStatus {.stdcall, dynlib: "SspiCli.dll", importc: "SspiPrepareForCredRead".}
  ## ref.: https://msdn.microsoft.com/en-us/library/dd401712.aspx

proc sspiPrepareForCredWrite*(
  authIdentity: ptr Sec_WinNt_Auth_Identity_Info,
  targetName: LPWStr,
  credManCredentialType: var uint32,
  credmanTargetName: var LPWStr,
  credmanUserName: var LPWStr,
  credentialBlob: var AnySizeArrayPtr[byte],
  credentialBlobSize: var uint32
  ): SecurityStatus {.stdcall, dynlib: "SspiCli.dll", importc: "SspiPrepareForCredWrite".}
  ## ref.: https://msdn.microsoft.com/en-us/library/dd401713.aspx
  ## :targetName: supply NULL for username-target credentials

type Sec_WinNt_Auth_Identity_Encrypt_Flag* = distinct uint32
  ## Input flags for SspiEncryptAuthIdentityEx and
  ## SspiDecryptAuthIdentityEx functions
const
  sec_winnt_auth_identity_encrypt_same_logon* = 0x1.Sec_WinNt_Auth_Identity_Encrypt_Flag
  sec_winnt_auth_identity_encrypt_same_process* = 0x2.Sec_WinNt_Auth_Identity_Encrypt_Flag

proc sspiEncryptAuthIdentity*(
  authData: var Sec_WinNt_Auth_Identity_Info
  ): SecurityStatus {.stdcall, dynlib: "SspiCli.dll", importc: "SspiEncryptAuthIdentity".}
  ## ref.: https://msdn.microsoft.com/en-us/library/dd401703.aspx

proc sspiEncryptAuthIdentityEx*(
  options: Sec_WinNt_Auth_Identity_Encrypt_Flag,
  authData: var Sec_WinNt_Auth_Identity_Info
  ): SecurityStatus {.stdcall, dynlib: "SspiCli.dll", importc: "SspiEncryptAuthIdentityEx".}
  ## ref.: https://msdn.microsoft.com/en-us/library/hh448519.aspx

proc sspiDecryptAuthIdentity*(
  encryptedAuthData: var Sec_WinNt_Auth_Identity_Info
  ): SecurityStatus {.stdcall, dynlib: "SspiCli.dll", importc: "SspiDecryptAuthIdentity".}
  ## ref.: https://msdn.microsoft.com/en-us/library/dd401700.aspx

proc sspiDecryptAuthIdentityEx*(
  options: Sec_WinNt_Auth_Identity_Encrypt_Flag,
  encryptedAuthData: var Sec_WinNt_Auth_Identity_Info
  ): SecurityStatus {.stdcall, dynlib: "SspiCli.dll", importc: "SspiDecryptAuthIdentityEx".}
  ## ref.: https://msdn.microsoft.com/en-us/library/hh448518.aspx

proc sspiIsAuthIdentityEncrypted*(
  encryptedAuthData: var Sec_WinNt_Auth_Identity_Info
  ): Boolean {.stdcall, dynlib: "SspiCli.dll", importc: "SspiIsAuthIdentityEncrypted".}
  ## ref.: https://msdn.microsoft.com/en-us/library/dd401708.aspx

proc sspiEncodeAuthIdentityAsStrings*(
  authIdentity: ptr Sec_WinNt_Auth_Identity_Info,
  userName, domainName, packedCredentials: var LPWStr
  ): SecurityStatus {.stdcall, dynlib: "SspiCli.dll", importc: "SspiEncodeAuthIdentityAsStrings".}
  ## Convert the opaque identity info structure passed in to the
  ## 3 tuple <username, domainname, 'password'>.
  ## 
  ## Note: The 'strings' returned need not necessarily be
  ## in user recognisable form. The purpose of this API
  ## is to 'flatten' the opaque structure into the 3 tuple.
  ## 
  ## zero out the packedCredentials then
  ## free the returned memory using `sspiLocalFree`
  ## ref.: https://msdn.microsoft.com/en-us/library/dd401701.aspx

proc sspiValidateAuthIdentity*(
  authData: ptr Sec_WinNt_Auth_Identity_Info
  ): SecurityStatus {.stdcall, dynlib: "SspiCli.dll", importc: "SspiValidateAuthIdentity".}
  ## ref.: https://msdn.microsoft.com/en-us/library/dd401718.aspx

proc sspiCopyAuthIdentity*(
  authData: ptr Sec_WinNt_Auth_Identity_Info,
  authDataCopy: var ptr Sec_WinNt_Auth_Identity_Info
  ): SecurityStatus {.stdcall, dynlib: "SspiCli.dll", importc: "SspiCopyAuthIdentity".}
  ## free the returned memory using `sspiFreeAuthIdentity`
  ## ref.: https://msdn.microsoft.com/en-us/library/dd401699.aspx

proc sspiFreeAuthIdentity*(
  authData: ptr Sec_WinNt_Auth_Identity_Info
  ): SecurityStatus {.stdcall, dynlib: "SspiCli.dll", importc: "SspiFreeAuthIdentity".}
  ## ref.: https://msdn.microsoft.com/en-us/library/dd401705.aspx

proc sspiZeroAuthIdentity*(
  authData: ptr Sec_WinNt_Auth_Identity_Info
  ): SecurityStatus {.stdcall, dynlib: "SspiCli.dll", importc: "SspiZeroAuthIdentity".}
  ## ref.: https://msdn.microsoft.com/en-us/library/dd401719.aspx

proc sspiLocalFree*(
  dataBuffer: pointer
  ): void {.stdcall, dynlib: "SspiCli.dll", importc: "SspiLocalFree".}
  ## ref.: https://msdn.microsoft.com/en-us/library/dd401710.aspx

proc sspiEncodeStringsAsAuthIdentity*(
  userName, domainName, packedCredentialsString: LPWStr,
  authIdentity: var ptr Sec_WinNt_Auth_Identity_Info
  ): SecurityStatus {.stdcall, dynlib: "SspiCli.dll", importc: "SspiEncodeStringsAsAuthIdentity".}
  ## call ``sspiFreeAuthIdentity`` to free the returned `authIdentity`
  ## which zeroes out the credentials blob before freeing it
  ##
  ## ref.: https://msdn.microsoft.com/en-us/library/dd401702.aspx

proc sspiCompareAuthIdentities*(
  authIdentity1, authIdentity2: ptr Sec_WinNt_Auth_Identity_Info,
  sameSuppliedUser, sameSuppliedIdentity: var Boolean
  ): SecurityStatus {.stdcall, dynlib: "SspiCli.dll", importc: "SspiCompareAuthIdentities".}
  ## ref.: https://msdn.microsoft.com/en-us/library/dd401698.aspx

proc sspiMarshalAuthIdentity*(
  authIdentity: ptr Sec_WinNt_Auth_Identity_Info,
  size: var uint32,
  byteArray: var AnySizeArrayPtr[byte]
  ): SecurityStatus {.stdcall, dynlib: "SspiCli.dll", importc: "SspiMarshalAuthIdentity".}
  ## zero out the returned `byteArray` then
  ## free the returned memory using ``sspiLocalFree``
  ##
  ## ref.: https://msdn.microsoft.com/en-us/library/dd401711.aspx

proc sspiUnmarshalAuthIdentity*(
  size: uint32,
  byteArray: AnySizeArrayPtr[byte],
  authIdentity: var ptr Sec_WinNt_Auth_Identity_Info
  ): SecurityStatus {.stdcall, dynlib: "SspiCli.dll", importc: "SspiUnmarshalAuthIdentity".}
  ## free the returned auth identity using ``sspiFreeAuthIdentity()``
  ##
  ## ref.: https://msdn.microsoft.com/en-us/library/dd401715.aspx

proc sspiIsPromptingNeeded*(errorOrNtStatus: uint32
  ): Boolean {.stdcall, dynlib: "CredUi.dll", importc: "SspiIsPromptingNeeded".}
  ## ref.: https://msdn.microsoft.com/en-us/library/dd401709.aspx

proc sspiGetTargetHostName*(
  targetName: LPWStr,
  hostName: var LPWStr
  ): SecurityStatus {.stdcall, dynlib: "SspiCli.dll", importc: "SspiGetTargetHostName".}
  ## ref.: https://msdn.microsoft.com/en-us/library/dd401707.aspx

proc sspiExcludePackage*(
  authIdentity: ptr Sec_WinNt_Auth_Identity_Info,
  packageName: LPWStr,
  newAuthIdentity: var ptr Sec_WinNt_Auth_Identity_Info
  ): SecurityStatus {.stdcall, dynlib: "SspiCli.dll", importc: "SspiExcludePackage".}
  ## ref.: https://msdn.microsoft.com/en-us/library/dd401704.aspx

const
  sec_winnt_auth_identity_marshalled* = 0x4.Sec_WinNt_Auth_Identity_Flag ## all data is in one buffer
  sec_winnt_auth_identity_only* = 0x8.Sec_WinNt_Auth_Identity_Flag ## these credentials are for identity only - no PAC needed

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
  ansiIdent = sspiAddSecurityPackageA, wideIdent = sspiAddSecurityPackageW,
  innerTIdent = LPTStr, innerAnsiIdent = LPStr, innerWideIdent = LPWStr,
  ansiImportC = "AddSecurityPackageA", wideImportC = "AddSecurityPackageW"):
  proc sspiAddSecurityPackage*(
    packageName: LPTStr,
    options: PSecurity_Package_Options
    ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc.}
    ## ref.: https://msdn.microsoft.com/en-us/library/dd401506.aspx

ansiWideAllImportC(tIdent = sspiDeleteSecurityPackage,
  ansiIdent = sspiDeleteSecurityPackageA, wideIdent = sspiDeleteSecurityPackageW,
  innerTIdent = LPTStr, innerAnsiIdent = LPStr, innerWideIdent = LPWStr,
  ansiImportC = "DeleteSecurityPackageA", wideImportC = "DeleteSecurityPackageW"):
  proc sspiDeleteSecurityPackage*(
    packageName: LPTStr
    ): SecurityStatus {.dynlib: "Secur32.dll", stdcall, importc.}
    ## ref.: https://msdn.microsoft.com/en-us/library/dd401610.aspx
