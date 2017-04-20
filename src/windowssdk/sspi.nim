#+---------------------------------------------------------------------------
#
#  Microsoft Windows
#  Copyright (C) Microsoft Corporation, 1992-1999.
#
#  File:       sspi.h
#
#  Contents:   Security Support Provider Interface
#              Prototypes and structure definitions
#
#  Functions:  Security Support Provider API
#
#
#----------------------------------------------------------------------------

import .. / anysize_array, .. / ansiwide, winnt

type
  SecWChar* = Utf16Char
  SecChar* = char

type SecurityStatus* = int32

ansiWideWhen(SecurityStrChar, SecChar, SecWChar):
  type SecurityPStr* = ptr SecurityStrChar

#
# Okay, security specific types:
#
type SecHandle* = object
  lower*: uint
  upper*: uint
type PSecHandle* = ptr SecHandle

proc secInvalidateHandle*(x: PSecHandle) : void =
  x.lower = uint(-1)
  x.upper = uint(-1)
proc secIsValidHandle*(x: PSecHandle) : bool =
  result = x.lower != uint(-1) and x.upper != uint(-1)

#
# pseudo handle value: the handle has already been deleted
#
const sec_deleted_handle* = uint(-2)

type
  CredHandle* = SecHandle
  PCredHandle* = PSecHandle

  CtxtHandle* = SecHandle
  PCtxtHandle* = PSecHandle

  SecurityInteger* = int64
  PSecurityInteger* = ptr SecurityInteger

  TimeStamp* = SecurityInteger
  PTimeStamp* = PSecurityInteger

##
## If we are in 32 bit mode, define the SECURITY_STRING structure,
## as a clone of the base UNICODE_STRING structure.  This is used
## internally in security components, an as the string interface
## for kernel components (e.g. FSPs)
##
type SecurityString* = object
  len: uint16
  cap: uint16
  buf: WideCString
type PSecurityString* = ptr SecurityString

ansiWide(SecPkgInfo, SecPkgInfoA, SecPkgInfoW, LpTStr, cstring, WideCString):
  ##
  ## SecPkgInfo structure
  ##
  ##  Provides general information about a security provider
  ##
  type SecPkgInfo* = object
    capabilities*: uint32  ## Capability bitmask
    version*     : uint16  ## Version of driver
    rpcId*       : uint16  ## ID for RPC Runtime
    maxToken*    : uint32  ## Size of authentication token (max)
    name*        : LpTStr  ## Text name
    comment*     : LpTStr  ## Comment
ansiWide(PSecPkgInfo, PSecPkgInfoA, PSecPkgInfoW, SecPkgInfo, SecPkgInfoA, SecPkgInfoW):
  type PSecPkgInfo* = ptr SecPkgInfo

ansiWideWhen(SecPkgInfoType, SecPkgInfoA, SecPkgInfoW):
  type
    SecPkgInfo* = SecPkgInfoType
    PSecPkgInfo* = ptr SecPkgInfo

##
## Security Package Capabilities
##
const
  secpkg_flag_integrity* =                0x00000001
  secpkg_flag_privacy* =                  0x00000002
  secpkg_flag_token_only* =               0x00000004
  secpkg_flag_datagram* =                 0x00000008
  secpkg_flag_connection* =               0x00000010
  secpkg_flag_multi_required* =           0x00000020
  secpkg_flag_client_only* =              0x00000040
  secpkg_flag_extended_error* =           0x00000080
  secpkg_flag_impersonation* =            0x00000100
  secpkg_flag_accept_win32_name* =        0x00000200
  secpkg_flag_stream* =                   0x00000400
  secpkg_flag_negotiable* =               0x00000800
  secpkg_flag_gss_compatible* =           0x00001000
  secpkg_flag_logon* =                    0x00002000
  secpkg_flag_ascii_buffers* =            0x00004000
  secpkg_flag_fragment* =                 0x00008000
  secpkg_flag_mutual_auth* =              0x00010000
  secpkg_flag_delegation* =               0x00020000
  secpkg_flag_readonly_with_checksum* =   0x00040000
  secpkg_flag_restricted_tokens* =        0x00080000
  secpkg_flag_nego_extender* =            0x00100000
  secpkg_flag_negotiable2* =              0x00200000
  secpkg_flag_appcontainer_passthrough* = 0x00400000
  secpkg_flag_appcontainer_checks* =      0x00800000
  
const secPkg_Id_None* = 0xFFFF.int16

##
## Extended Call Flags that currently contains
## Appcontainer related information about the caller.
## Packages can query for these
## via an LsaFunction GetExtendedCallFlags
##
const
  secpkg_callflags_appcontainer* =             0x00000001
  secpkg_callflags_appcontainer_authcapable* = 0x00000002
  secpkg_callflags_force_supplied* =           0x00000004

##
## SecBuffer
##
## Generic memory descriptors for buffers passed in to the security
## API
##
type SecBuffer* = object
  size:    uint32 ## Size of the buffer, in bytes
  bufType: uint32 ## Type of the buffer (below)
  buf: ref array[high(uint32), byte]
type PSecBuffer* = ptr SecBuffer

type SecBufferDesc* = object
  version: uint32 ## Version number
  count:   uint32 ## Number of buffers
  buffers: ref array[high(uint32), PSecBuffer] ## Array of buffers
type PSecBufferDesc* = ptr SecBufferDesc

const secBuffer_Version* = 0

const
  secbuffer_empty* =                  0 ## Undefined, replaced by provider
  secbuffer_data* =                   1 ## Packet data
  secbuffer_token* =                  2 ## Security token
  secbuffer_pkg_params* =             3 ## Package specific parameters
  secbuffer_missing* =                4 ## Missing Data indicator
  secbuffer_extra* =                  5 ## Extra data
  secbuffer_stream_trailer* =         6 ## Security Trailer
  secbuffer_stream_header* =          7 ## Security Header
  secbuffer_negotiation_info* =       8 ## Hints from the negotiation pkg
  secbuffer_padding* =                9 ## non-data padding
  secbuffer_stream* =                10 ## whole encrypted message
  secbuffer_mechlist* =              11
  secbuffer_mechlist_signature* =    12
  secbuffer_target* {.deprecated.} = 13 ## obsolete
  secbuffer_channel_bindings* =      14
  secbuffer_change_pass_response* =  15
  secbuffer_target_host* =           16
  secbuffer_alert* =                 17
  secbuffer_application_protocols* = 18 ## Lists of application protocol IDs, one per negotiation extension

  secbuffer_readonly_with_checksum* = 0x10000000 ## Buffer is read-only, and checksummed
  secbuffer_reserved* =               0x60000000 ## Flags reserved to security system
  secbuffer_readonly* =               0x80000000 ## Buffer is read-only, no checksum
  secbuffer_attrmask* =               0xF0000000

type SecNegotiationInfo* = object
  size*:       int32       ## Size of this structure
  nameLength*: int32       ## Length of name hint
  name*:       WideCString ## Name hint
  reserved*:   pointer     ## Reserved
type PSecNegotiationInfo* = ptr SecNegotiationInfo

type
  Sec_Channel_Bindings* = object
    initiatorAddrType, initiatorSize, initiatorOffset: uint32
    acceptorAddrType, acceptorSize, acceptorOffset: uint32
    appDataSize, appDataOffset: uint32
  PSec_Channel_Bindings* = ptr Sec_Channel_Bindings

type SecApplicationProtocolNegotiationExt* = enum
  secApplicationProtocolNegotiationExt_None,
  secApplicationProtocolNegotiationExt_NPN,
  secApplicationProtocolNegotiationExt_ALPN
type PSecApplicationProtocolNegotiationExt* = ptr SecApplicationProtocolNegotiationExt

type SecApplicationProtocolList* = object
  protoNegoExt: SecApplicationProtocolNegotiationExt ## Protocol negotiation extension type to use with this list of protocols
  protocolListSize: uint16                           ## Size in bytes of the protocol ID list
  protocolList: AnySizeArray[byte]                   ## 8-bit length-prefixed application protocol IDs, most preferred first
type PSecApplicationProtocolList* = ptr SecApplicationProtocolList

##
## Data Representation Constant:
##
const
  security_native_drep* = 0x00000010
  security_network_drep* = 0x00000000

##
## Credential Use Flags
##
const
  secpkg_cred_inbound* = 0x00000001
  secpkg_cred_outbound* = 0x00000002
  secpkg_cred_both* = 0x00000003
  secpkg_cred_default* = 0x00000004
  secpkg_cred_reserved* = 0xF0000000

##
## SSP SHOULD prompt the user for credentials/consent, independent
## of whether credentials to be used are the 'logged on' credentials
## or retrieved from credman.
##
## An SSP may choose not to prompt, however, in circumstances determined
## by the SSP.
##
const secpkg_cred_autologon_restricted* = 0x00000010

##
## auth will always fail, ISC() is called to process policy data only
##
const secpkg_cred_process_policy_only* = 0x00000020

##
## InitializeSecurityContext Requirement and return flags:
##
const
  isc_req_delegate* =                0x00000001
  isc_req_mutual_auth* =             0x00000002
  isc_req_replay_detect* =           0x00000004
  isc_req_sequence_detect* =         0x00000008
  isc_req_confidentiality* =         0x00000010
  isc_req_use_session_key* =         0x00000020
  isc_req_prompt_for_creds* =        0x00000040
  isc_req_use_supplied_creds* =      0x00000080
  isc_req_allocate_memory* =         0x00000100
  isc_req_use_dce_style* =           0x00000200
  isc_req_datagram* =                0x00000400
  isc_req_connection* =              0x00000800
  isc_req_call_level* =              0x00001000
  isc_req_fragment_supplied* =       0x00002000
  isc_req_extended_error* =          0x00004000
  isc_req_stream* =                  0x00008000
  isc_req_integrity* =               0x00010000
  isc_req_identify* =                0x00020000
  isc_req_null_session* =            0x00040000
  isc_req_manual_cred_validation* =  0x00080000
  isc_req_reserved1* =               0x00100000
  isc_req_fragment_to_fit* =         0x00200000
  # This exists only in Windows Vista and greater
  isc_req_forward_credentials* =     0x00400000
  isc_req_no_integrity* =            0x00800000 ## honored only by SPNEGO
  isc_req_use_http_style* =          0x01000000
  isc_req_unverified_target_name* =  0x20000000
  isc_req_confidentiality_only* =    0x40000000 ## honored by SPNEGO/Kerberos

  isc_ret_delegate* =                0x00000001
  isc_ret_mutual_auth* =             0x00000002
  isc_ret_replay_detect* =           0x00000004
  isc_ret_sequence_detect* =         0x00000008
  isc_ret_confidentiality* =         0x00000010
  isc_ret_use_session_key* =         0x00000020
  isc_ret_used_collected_creds* =    0x00000040
  isc_ret_used_supplied_creds* =     0x00000080
  isc_ret_allocated_memory* =        0x00000100
  isc_ret_used_dce_style* =          0x00000200
  isc_ret_datagram* =                0x00000400
  isc_ret_connection* =              0x00000800
  isc_ret_intermediate_return* =     0x00001000
  isc_ret_call_level* =              0x00002000
  isc_ret_extended_error* =          0x00004000
  isc_ret_stream* =                  0x00008000
  isc_ret_integrity* =               0x00010000
  isc_ret_identify* =                0x00020000
  isc_ret_null_session* =            0x00040000
  isc_ret_manual_cred_validation* =  0x00080000
  isc_ret_reserved1* =               0x00100000
  isc_ret_fragment_only* =           0x00200000
  # This exists only in Windows Vista and greater
  isc_ret_forward_credentials* =     0x00400000

  isc_ret_used_http_style* =         0x01000000
  isc_ret_no_additional_token =      0x02000000 ## *INTERNAL*
  isc_ret_reauthentication =         0x08000000 ## *INTERNAL*
  isc_ret_confidentiality_only* =    0x40000000 ## honored by SPNEGO/Kerberos

  asc_req_delegate* =                0x00000001
  asc_req_mutual_auth* =             0x00000002
  asc_req_replay_detect* =           0x00000004
  asc_req_sequence_detect* =         0x00000008
  asc_req_confidentiality* =         0x00000010
  asc_req_use_session_key* =         0x00000020
  asc_req_session_ticket* =          0x00000040
  asc_req_allocate_memory* =         0x00000100
  asc_req_use_dce_style* =           0x00000200
  asc_req_datagram* =                0x00000400
  asc_req_connection* =              0x00000800
  asc_req_call_level* =              0x00001000
  asc_req_extended_error* =          0x00008000
  asc_req_stream* =                  0x00010000
  asc_req_integrity* =               0x00020000
  asc_req_licensing* =               0x00040000
  asc_req_identify* =                0x00080000
  asc_req_allow_null_session* =      0x00100000
  asc_req_allow_non_user_logons* =   0x00200000
  asc_req_allow_context_replay* =    0x00400000
  asc_req_fragment_to_fit* =         0x00800000
  asc_req_fragment_supplied* =       0x00002000
  asc_req_no_token* =                0x01000000
  asc_req_proxy_bindings* =          0x04000000
  #ssp_ret_reauthentication* =        0x08000000 ## *INTERNAL*
  asc_req_allow_missing_bindings* =  0x10000000

  asc_ret_delegate* =                0x00000001
  asc_ret_mutual_auth* =             0x00000002
  asc_ret_replay_detect* =           0x00000004
  asc_ret_sequence_detect* =         0x00000008
  asc_ret_confidentiality* =         0x00000010
  asc_ret_use_session_key* =         0x00000020
  asc_ret_session_ticket* =          0x00000040
  asc_ret_allocated_memory* =        0x00000100
  asc_ret_used_dce_style* =          0x00000200
  asc_ret_datagram* =                0x00000400
  asc_ret_connection* =              0x00000800
  asc_ret_call_level* =              0x00002000 ## skipped 1000 to be like ISC_
  asc_ret_third_leg_failed* =        0x00004000
  asc_ret_extended_error* =          0x00008000
  asc_ret_stream* =                  0x00010000
  asc_ret_integrity* =               0x00020000
  asc_ret_licensing* =               0x00040000
  asc_ret_identify* =                0x00080000
  asc_ret_null_session* =            0x00100000
  asc_ret_allow_non_user_logons* =   0x00200000
  asc_ret_allow_context_replay* {.deprecated.} = 0x00400000 ## deprecated - don't use this flag!!!
  asc_ret_fragment_only* =           0x00800000
  asc_ret_no_token* =                0x01000000
  asc_ret_no_additional_token =      0x02000000 ## *INTERNAL*
  #ssp_ret_reauthentication =         0x08000000 ## *INTERNAL*

#
# Security Credentials Attributes:
#
const
  secpkg_cred_attr_names* =        1
  secpkg_cred_attr_ssi_provider* = 2
  secpkg_cred_attr_kdc_proxy_settings* = 3
  secpkg_cred_attr_cert* =         4

ansiWideAll(
  SecPkgCredentials_Names, SecPkgCredentials_NamesA, SecPkgCredentials_NamesW,
  LpTStr, cstring, WideCString):
  type
    SecPkgCredentials_Names* = object
      userName*: LpTStr
type 
  PSecPkgCredentials_NamesW* = ptr SecPkgCredentials_NamesW
  PSecPkgCredentials_NamesA* = ptr SecPkgCredentials_NamesA
  PSecPkgCredentials_Names* = ptr SecPkgCredentials_Names

ansiWideAll(
  SecPkgCredentials_SSIProvider, SecPkgCredentials_SSIProviderA, SecPkgCredentials_SSIProviderW,
  LpTStr, cstring, WideCString):
  type
    SecPkgCredentials_SSIProvider* = object
      providerName: LpTStr
      providerInfoLength: uint32
      providerInfo: AnySizeArrayRef[byte]
type
  PSecPkgCredentials_SSIProviderW* = ptr SecPkgCredentials_SSIProviderW
  PSecPkgCredentials_SSIProviderA* = ptr SecPkgCredentials_SSIProviderA
  PSecPkgCredentials_SSIProvider* = ptr SecPkgCredentials_SSIProvider

const
 kdc_proxy_settings_v1* =                 1
 kdc_proxy_settings_flags_forceproxy* = 0x1

type SecPkgCredentials_KdcProxySettingsW* = object
  version: uint32 ## kdc_proxy_settings_v1
  flags:   uint32 ## kdc_proxy_settings_flags_*
  proxyServerOffset: uint16 # ProxyServer, optional
  proxyServerLength: uint16
  clientTlsCredOffset: uint16 # ClientTlsCred, optional
  clientTlsCredLength: uint16
type PSecPkgCredentials_KdcProxySettingsW* = ptr SecPkgCredentials_KdcProxySettingsW

type
  SecPkgCredentials_Cert* = object
    size: uint32
    cert: AnySizeArrayRef[byte]
  PSecPkgCredentials_Cert* = ptr SecPkgCredentials_Cert

#
# Security Context Attributes:
#
const 
  secpkg_attr_sizes* =           0
  secpkg_attr_names* =           1
  secpkg_attr_lifespan* =        2
  secpkg_attr_dce_info* =        3
  secpkg_attr_stream_sizes* =    4
  secpkg_attr_key_info* =        5
  secpkg_attr_authority* =       6
  secpkg_attr_proto_info* =      7
  secpkg_attr_password_expiry* = 8
  secpkg_attr_session_key* =     9
  secpkg_attr_package_info* =    10
  secpkg_attr_user_flags* =      11
  secpkg_attr_negotiation_info* = 12
  secpkg_attr_native_names* =    13
  secpkg_attr_flags* =           14
  # These attributes exist only in Win XP and greater
  secpkg_attr_use_validated* =   15
  secpkg_attr_credential_name* = 16
  secpkg_attr_target_information* = 17
  secpkg_attr_access_token* =    18
  # These attributes exist only in Win2K3 and greater
  secpkg_attr_target* =          19
  secpkg_attr_authentication_id* =  20
  # These attributes exist only in Win2K3SP1 and greater
  secpkg_attr_logoff_time* =     21
  #
  # win7 or greater
  #
  secpkg_attr_nego_keys* =         22
  secpkg_attr_prompting_needed* =  24
  secpkg_attr_unique_bindings* =   25
  secpkg_attr_endpoint_bindings* = 26
  secpkg_attr_client_specified_target* = 27

  secpkg_attr_last_client_token_status* = 30
  secpkg_attr_nego_pkg_info* =        31 ## contains nego info of packages
  secpkg_attr_nego_status* =          32 ## contains the last error
  secpkg_attr_context_deleted* =      33 ## a context has been deleted

  #
  # win8 or greater
  #
  secpkg_attr_dtls_mtu* =        34
  secpkg_attr_datagram_sizes* =  secpkg_attr_stream_sizes

  secpkg_attr_subject_security_attributes* = 128

  #
  # win8.1 or greater
  #
  secpkg_attr_application_protocol* = 35

type
  SecPkgContext_SubjectAttributes* = object
    attributeInfo: pointer ## contains a PAUTHZ_SECURITY_ATTRIBUTES_INFORMATION structure
  PSecPkgContext_SubjectAttributes* = ptr SecPkgContext_SubjectAttributes

const
  secpkg_attr_nego_info_flag_no_kerberos* = 0x1
  secpkg_attr_nego_info_flag_no_ntlm* =     0x2

type
  ## types of credentials, used by SECPKG_ATTR_PROMPTING_NEEDED
  SecPkg_Cred_Class* = enum
    secPkgCredClass_None = 0,  ## no creds
    secPkgCredClass_Ephemeral = 10,  ## logon creds
    secPkgCredClass_PersistedGeneric = 20, ## saved creds, not target specific
    secPkgCredClass_PersistedSpecific = 30, ## saved creds, target specific
    secPkgCredClass_Explicit = 40, ## explicitly supplied creds
  PSecPkg_Cred_Class* = ptr SecPkg_Cred_Class

  SecPkgContext_CredInfo* = object
    credClass: SecPkg_Cred_Class
    isPromptingNeeded: uint32
  PSecPkgContext_CredInfo* = ptr SecPkgContext_CredInfo

  SecPkgContext_NegoPackageInfo* = object
    packageMask: uint32
  PSecPkgContext_NegoPackageInfo* = ptr SecPkgContext_NegoPackageInfo

  SecPkgContext_NegoStatus* = object
    lastStatus: uint32
  PSecPkgContext_NegoStatus* = ptr SecPkgContext_NegoStatus

  SecPkgContext_Sizes* = object
    maxTokenSize*: uint32
    maxSignatureSize*: uint32
    blockSize*: uint32
    securityTrailerSize*: uint32
  PSecPkgContext_Sizes* = ptr SecPkgContext_Sizes

  SecPkgContext_StreamSizes* = object
    headerSize*:  uint32
    trailerSize*: uint32
    maxMsgSize*:  uint32
    buffersSize*: uint32
    blockSize*:   uint32
  PSecPkgContext_StreamSizes* = ptr SecPkgContext_StreamSizes

  SecPkgContext_DatagramSizes* = SecPkgContext_StreamSizes
  PSecPkgContext_DatagramSizes* = ptr SecPkgContext_DatagramSizes

  SecPkg_Attr_Lct_Status* = enum
    secPkgAttrLastClientTokenYes,
    secPkgAttrLastClientTokenNo,
    secPkgAttrLastClientTokenMaybe
  PSecPkg_Attr_Lct_Status* = ptr SecPkg_Attr_Lct_Status

  SecPkgContext_LastClientTokenStatus* = object
    lastClientTokenStatus: SecPkg_Attr_Lct_Status
  PSecPkgContext_LastClientTokenStatus* = ptr SecPkgContext_LastClientTokenStatus

ansiWideAll(SecPkgContext_Names, SecPkgContext_NamesA, SecPkgContext_NamesW,
  LpTStr, cstring, WideCString):
  type SecPkgContext_Names* = object
    userName: LpTStr
type
  PSecPkgContext_Names* = ptr SecPkgContext_Names
  PSecPkgContext_NamesA* = ptr SecPkgContext_NamesA
  PSecPkgContext_NamesW* = ptr SecPkgContext_NamesW

type
  SecPkgContext_Lifespan* = object
    start*, expiry*: TimeStamp
  PSecPkgContext_Lifespan* = ptr SecPkgContext_Lifespan

  SecPkgContext_DceInfo* = object
    authzSvc: uint32
    pPac: pointer
  PSecPkgContext_DceInfo* = ptr SecPkgContext_DceInfo

ansiWideAll(SecPkgContext_KeyInfo, SecPkgContext_KeyInfoA, SecPkgContext_KeyInfoW,
  LpTStr, cstring, WideCString):
  type SecPkgContext_KeyInfo* = object
    signatureAlgorithmName: LpTStr
    encryptAlgorithmName:   LpTStr
    keySize:             uint32
    signatureAlgorithm:  uint32
    encryptAlgorithm:    uint32
type
  PSecPkgContext_KeyInfoA* = ptr SecPkgContext_KeyInfoA
  PSecPkgContext_KeyInfoW* = ptr SecPkgContext_KeyInfoW
  PSecPkgContext_KeyInfo* = ptr SecPkgContext_KeyInfo

ansiWideAll(SecPkgContext_Authority, SecPkgContext_AuthorityA, SecPkgContext_AuthorityW, LpTStr, cstring, WideCString):
  type SecPkgContext_Authority* = object
    authorityName: LpTStr
type
  PSecPkgContext_AuthorityA* = ptr SecPkgContext_AuthorityA
  PSecPkgContext_AuthorityW* = ptr SecPkgContext_AuthorityW
  PSecPkgContext_Authority* = ptr SecPkgContext_Authority

ansiWideAll(SecPkgContext_ProtoInfo, SecPkgContext_ProtoInfoA, SecPkgContext_ProtoInfoW, LpTStr, cstring, WideCString):
  type SecPkgContext_ProtoInfo* = object
    protocolName: LpTStr
    majorVersion, minorVersion: uint32
type
  PSecPkgContext_ProtoInfoA* = ptr SecPkgContext_ProtoInfoA
  PSecPkgContext_ProtoInfoW* = ptr SecPkgContext_ProtoInfoW
  PSecPkgContext_ProtoInfo* = ptr SecPkgContext_ProtoInfo

type
  SecPkgContext_PasswordExpiry* = object
    passwordExpires*: TimeStamp
  PSecPkgContext_PasswordExpiry* = ptr SecPkgContext_PasswordExpiry

  SecPkgContext_LogoffTime* = object
    logoffTime*: TimeStamp
  PSecPkgContext_LogoffTime* = ptr SecPkgContext_LogoffTime

  SecPkgContext_SessionKey* = object
    size: uint32
    sessionKey: AnySizeArrayRef[byte]
  PSecPkgContext_SessionKey* = ptr SecPkgContext_SessionKey

  SecPkgContext_NegoKeys* = object
    keyType, keySize: uint32
    keyValue: AnySizeArrayRef[byte]
    verifyKeyType, verifyKeySize: uint32
    verifyKeyValue: AnySizeArrayRef[byte]
  PSecPkgContext_NegoKeys* = ptr SecPkgContext_NegoKeys

ansiWideAll(SecPkgContext_PackageInfo, SecPkgContext_PackageInfoA, SecPkgContext_PackageInfoW, PSecPkgInfo, PSecPkgInfoA, PSecPkgInfoW):
  type SecPkgContext_PackageInfo* = object
    packageInfo: PSecPkgInfo
type
  PSecPkgContext_PackageInfoW* = ptr SecPkgContext_PackageInfoW
  PSecPkgContext_PackageInfoA* = ptr SecPkgContext_PackageInfoA
  PSecPkgContext_PackageInfo* = ptr SecPkgContext_PackageInfo

type
  SecPkgContext_UserFlags* = object
    userFlags: uint32
  PSecPkgContext_UserFlags* = ptr SecPkgContext_UserFlags

  SecPkgContext_Flags* = object
    flags: uint32
  PSecPkgContext_Flags* = ptr SecPkgContext_Flags
ansiWideAll(SecPkgContext_NegotiationInfo, SecPkgContext_NegotiationInfoA, SecPkgContext_NegotiationInfoW, PSecPkgInfo, PSecPkgInfoA, PSecPkgInfoW):
  type SecPkgContext_NegotiationInfo* = object
    packageInfo: PSecPkgInfo
    negotiationState: uint32
type
  PSecPkgContext_NegotiationInfoA* = ptr SecPkgContext_NegotiationInfoA
  PSecPkgContext_NegotiationInfoW* = ptr SecPkgContext_NegotiationInfoW
  PSecPkgContext_NegotiationInfo* = ptr SecPkgContext_NegotiationInfo

const
  secpkg_negotiation_complete* =      0
  secpkg_negotiation_optimistic* =    1
  secpkg_negotiation_in_progress* =   2
  secpkg_negotiation_direct* =        3
  secpkg_negotiation_try_multicred* = 4

ansiWideAll(SecPkgContext_NativeNames, SecPkgContext_NativeNamesA, SecPkgContext_NativeNamesW, LpTStr, cstring, WideCString):
  type SecPkgContext_NativeNames* = object
    clientName, serverName: LpTStr
type
  PSecPkgContext_NativeNamesW* = ptr SecPkgContext_NativeNamesW
  PSecPkgContext_NativeNamesA* = ptr SecPkgContext_NativeNamesA
  PSecPkgContext_NativeNames* = ptr SecPkgContext_NativeNames

ansiWideAll(SecPkgContext_CredentialName, SecPkgContext_CredentialNameA, SecPkgContext_CredentialNameW, LpTStr, cstring, WideCString):
  type SecPkgContext_CredentialName* = object
    credentialType: uint32
    credentialName: LpTStr
type
  PSecPkgContext_CredentialNameW* = ptr SecPkgContext_CredentialNameW
  PSecPkgContext_CredentialNameA* = ptr SecPkgContext_CredentialNameA
  PSecPkgContext_CredentialName* = ptr SecPkgContext_CredentialName

type
  SecPkgContext_AccessToken* = object
    accessToken: pointer
  PSecPkgContext_AccessToken* = ptr SecPkgContext_AccessToken

  SecPkgContext_TargetInformation* = object
    size: uint32
    val: AnySizeArrayRef[byte]
  PSecPkgContext_TargetInformation* = ptr SecPkgContext_TargetInformation

  SecPkgContext_AuthzID* = object
    len: uint32
    val: cstring
  PSecPkgContext_AuthzID* = ptr SecPkgContext_AuthzID

  SecPkgContext_Target* = object
    len: uint32
    val: cstring
  PSecPkgContext_Target* = ptr SecPkgContext_Target

  SecPkgContext_ClientSpecifiedTarget* = object
    targetName: WideCString
  PSecPkgContext_ClientSpecifiedTarget* = ptr SecPkgContext_ClientSpecifiedTarget

  SecPkgContext_Bindings* = object
    len: uint32
    val: AnySizeArrayRef[Sec_Channel_Bindings]
  PSecPkgContext_Bindings* = ptr SecPkgContext_Bindings

  Sec_Application_Protocol_Negotiation_Status* = enum
    secApplicationProtocolNegotiationStatus_None,
    secApplicationProtocolNegotiationStatus_Success,
    secApplicationProtocolNegotiationStatus_SelectedClientOnly
  PSec_Application_Protocol_Negotiation_Status* = ptr Sec_Application_Protocol_Negotiation_Status

const max_protocol_id_size* = 0xff

type
  SecPkgContext_ApplicationProtocol* = object
    protoNegoStatus: Sec_Application_Protocol_Negotiation_Status
    protoNegoExt: Sec_Application_Protocol_Negotiation_Ext
    protocolIdSize: byte
    protocolId: array[max_protocol_id_size, byte]
  PSecPkgContext_ApplicationProtocol* = ptr SecPkgContext_ApplicationProtocol

type
  ## Parameters:
  ##   arg: Argument passed in
  ##   principal: Principal ID
  ##   keyVer: Key Version
  ##   key: Returned ptr to key
  ##   status: returned status
  Sec_Get_Key_Fn* = proc(
    arg, principal: pointer,
    keyVer: uint32,
    key: var pointer,
    status: var SecurityStatus
    ): void {.stdcall.}

#
# Flags for ExportSecurityContext
#
const
  secpkg_context_export_reset_new* =  0x00000001 ## New context is reset to initial state
  secpkg_context_export_delete_old* = 0x00000002 ## Old context is deleted during export
  # This is only valid in W2K3SP1 and greater
  secpkg_context_export_to_kernel* =  0x00000004 ## Context is to be transferred to the kernel

ansiWideAllImportC(acquireCredentialsHandle,
  acquireCredentialsHandleA, acquireCredentialsHandleW,
  LpTStr, cstring, WideCString,
  "AcquireCredentialsHandleA", "AcquireCredentialsHandleW"):
  ## ref.: https://msdn.microsoft.com/en-us/library/aa374712.aspx
  proc acquireCredentialsHandle*(
    principal: LpTStr,
    package: LpTStr,
    credentialUse: uint32,
    logonId: pointer,
    authData: pointer,
    getKeyFn: Sec_Get_Key_Fn,
    getKeyArgument: pointer,
    credential: var CredHandle,
    expiry: var TimeStamp
    ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importC.}
ansiWideAll(Acquire_Credentials_Handle_Fn, Acquire_Credentials_Handle_Fn_A, Acquire_Credentials_Handle_Fn_W, LpTStr, cstring, WideCString):
  type Acquire_Credentials_Handle_Fn* = proc (
    principal, package: LpTStr,
    credentialUse: uint32,
    logonId, authData: pointer,
    getKeyFn: Sec_Get_Key_Fn,
    getKeyArgument: pointer,
    credential: var CredHandle,
    expiry: var TimeStamp
    ): SecurityStatus {.stdcall.}

## ref.: https://msdn.microsoft.com/en-us/library/aa375417.aspx
proc freeCredentialsHandle*(
  credential: PCredHandle
  ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc: "FreeCredentialsHandle".}
type Free_Credentials_Handle_Fn* = proc(
  credential: PCredHandle
  ): SecurityStatus {.stdcall.}

ansiWideAllImportC(addCredentials,
  addCredentialsA, addCredentialsW,
  LPTStr, cstring, WideCString,
  "AddCredentialsA", "AddCredentialsW"):
  proc addCredentials*(
    credentials: PCredHandle,
    principal, package: LPTStr,
    credentialUse: uint32,
    authData: pointer,
    getKeyFn: Sec_Get_Key_Fn,
    getKeyArg: pointer,
    expiry: var TimeStamp
    ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc.}
ansiWideAll(Add_Credentials_Fn,
  Add_Credentials_Fn_A, Add_Credentials_Fn_W,
  LPTStr, cstring, WideCString):
  type Add_Credentials_Fn* = proc(
    credentials: PCredHandle,
    principal, package: LPTStr,
    credentialUse: uint32,
    authData: pointer,
    getKeyFn: Sec_Get_Key_Fn,
    getKeyArg: pointer,
    expiry: var TimeStamp
    ): SecurityStatus {.stdcall.}

########################################################################
###
### Password Change Functions
###
########################################################################
ansiWideAllImportC(changeAccountPassword, changeAccountPasswordA, changeAccountPasswordW,
  LpTStr, cstring, WideCString, "ChangeAccountPasswordA", "ChangeAccountPasswordW"):
  ## ref.: https://msdn.microsoft.com/en-us/library/aa374755.aspx
  proc changeAccountPassword*(
    packageName, domainName, accountName, oldPassword, newPassword: LpTStr,
    impersonate: Boolean,
    reserved: uint32 = 0,
    output: var SecBufferDesc
    ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importC.}
ansiWideAll(Change_Password_Fn, Change_Password_Fn_A, Change_Password_Fn_W,
  LpTStr, cstring, WideCString):
  type Change_Password_Fn* = proc(
    packageName, domainName, accountName, oldPassword, newPassword: LpTStr,
    impersonate: Boolean,
    reserved: uint32 = 0,
    output: var SecBufferDesc
    ): SecurityStatus {.stdcall.}

########################################################################
###
### Context Management Functions
###
########################################################################
ansiWideAllImportC(initializeSecurityContext, initializeSecurityContextA, initializeSecurityContextW,
  LpTStr, cstring, WideCString,
  "InitializeSecurityContextA", "InitializeSecurityContextW"):
  ## ref.: https://msdn.microsoft.com/en-us/library/aa375506.aspx
  proc initializeSecurityContext*(
    credential: PCredHandle,
    context: PCtxtHandle,
    targetName: LPTStr,
    contextRequired, 
    reserved1: uint32 = 0,
    targetDataRep: uint32,
    input: PSecBufferDesc,
    reserved2: uint32 = 0,
    newContext: var CtxtHandle,
    output: var SecBufferDesc,
    contextAttrs: var uint32,
    expiry: var TimeStamp
    ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importC.}
ansiWideAll(Initialize_Security_Context_Fn,
  Initialize_Security_Context_Fn_A,
  Initialize_Security_Context_Fn_W,
  LPTStr, cstring, WideCString):
  type Initialize_Security_Context_Fn* = proc(
    credential: PCredHandle,
    context: PCtxtHandle,
    targetName: LPTStr,
    contextRequired, 
    reserved1: uint32,
    targetDataRep: uint32,
    input: PSecBufferDesc,
    reserved2: uint32,
    newContext: var CtxtHandle,
    output: var SecBufferDesc,
    contextAttrs: var uint32,
    expiry: var TimeStamp
    ): SecurityStatus {.stdcall.}

## ref.: https://msdn.microsoft.com/en-us/library/aa374703.aspx
proc acceptSecurityContext*(
  credential: PCredHandle,
  context: PCtxtHandle,
  input: PSecBufferDesc,
  contextReq: uint32,
  targetDataRep: uint32,
  newContext: var CredHandle,
  output: var SecBufferDesc,
  contextAttr: var uint32,
  timeStamp: var TimeStamp
  ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc: "AcceptSecurityContext".}
type Accept_Security_Context_Fn* = proc(
  credential: PCredHandle,
  context: PCtxtHandle,
  input: PSecBufferDesc,
  contextReq: uint32,
  targetDataRep: uint32,
  newContext: var CredHandle,
  output: var SecBufferDesc,
  contextAttr: var uint32,
  timeStamp: var TimeStamp
  ): SecurityStatus {.stdcall.}

## ref.: https://msdn.microsoft.com/en-us/library/aa374764.aspx
proc completeAuthToken*(
  context: PCtxtHandle,
  token: PSecBufferDesc
  ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc: "CompleteAuthToken".}
type Complete_Auth_Token_Fn* = proc(
  context: PCtxtHandle,
  token: PSecBufferDesc
  ): SecurityStatus {.stdcall.}

## ref.: https://msdn.microsoft.com/en-us/library/aa375497.aspx
proc impersonateSecurityContext*(
  context: PCtxtHandle
  ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc: "ImpersonateSecurityContext".}
type Impersonate_Security_Context_Fn* = proc(
  context: PCtxtHandle
  ): SecurityStatus {.stdcall.}

## ref.: https://msdn.microsoft.com/en-us/library/aa379446.aspx
proc revertSecurityContext*(
  context: PCtxtHandle
  ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc: "RevertSecurityContext".}
type Revert_Security_Context_Fn* = proc(
  context: PCtxtHandle
  ): SecurityStatus {.stdcall.}

## ref.: https://msdn.microsoft.com/en-us/library/aa379446.aspx
proc querySecurityContextToken*(
  context: PCtxtHandle,
  token: var pointer
  ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc: "QuerySecurityContextToken".}
type Query_Security_Context_Token_Fn* = proc(
  context: PCtxtHandle,
  token: var pointer
  ): SecurityStatus {.stdcall.}

## ref.: https://msdn.microsoft.com/en-us/library/aa375354.aspx
proc deleteSecurityContext*(
  context: PCtxtHandle,
  ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc: "DeleteSecurityContext".}
type Delete_Security_Context_Fn* = proc(
  context: PCtxtHandle,
  ): SecurityStatus {.stdcall.}

## ref.: https://msdn.microsoft.com/en-us/library/aa374724.aspx
proc applyControlToken*(
  context: PCtxtHandle,
  input: PSecBufferDesc
  ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc: "ApplyControlToken".}
type Apply_Control_Token_Fn* = proc(
  context: PCtxtHandle,
  input: PSecBufferDesc
  ): SecurityStatus {.stdcall.}

ansiWideAllImportC(queryContextAttributes,
  queryContextAttributesA, queryContextAttributesW,
  TNone, char, Utf16Char, "QueryContextAttributesA", "QueryContextAttributesW"):
  ## ref.: https://msdn.microsoft.com/en-us/library/aa379326.aspx
  proc queryContextAttributes*(
    context: PCtxtHandle,
    attribute: uint32,
    buffer: pointer
    ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc.}
ansiWideAll(Query_Context_Attributes_Fn,
  Query_Context_Attributes_Fn_A, Query_Context_Attributes_Fn_W,
  TNone, char, Utf16Char):
  type Query_Context_Attributes_Fn* = proc(
    context: PCtxtHandle,
    attribute: uint32,
    buffer: pointer
    ): SecurityStatus {.stdcall.}

ansiWideAllImportC(setContextAttributes,
  setContextAttributesA, setContextAttributesW,
  TNone, char, Utf16Char, "SetContextAttributesA", "SetContextAttributesW"):
  ## ref.: https://msdn.microsoft.com/en-us/library/aa380137.aspx
  proc setContextAttributes*(
    context: PCtxtHandle,
    attribute: uint32,
    buffer: pointer,
    bufferSize: uint32
    ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc.}
ansiWideAll(Set_Context_Attributes_Fn,
  Set_Context_Attributes_Fn_A, Set_Context_Attributes_Fn_W,
  TNone, char, Utf16Char):
  type Set_Context_Attributes_Fn* = proc(
    context: PCtxtHandle,
    attribute: uint32,
    buffer: pointer,
    bufferSize: uint32
    ): SecurityStatus {.stdcall.}

ansiWideAllImportC(queryCredentialsAttributes,
  queryCredentialsAttributesA, queryCredentialsAttributesW,
  TNone, char, Utf16Char, "QueryCredentialsAttributesA", "QueryCredentialsAttributesW"):
  ## ref.: https://msdn.microsoft.com/en-us/library/aa379342.aspx
  proc queryCredentialsAttributes*(
    context: PCredHandle,
    attribute: uint32,
    buffer: pointer
    ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc.}
ansiWideAll(Query_Credentials_Attributes_Fn,
  Query_Credentials_Attributes_Fn_A, Query_Credentials_Attributes_Fn_W,
  TNone, char, Utf16Char):
  type Query_Credentials_Attributes_Fn* = proc(
    context: PCredHandle,
    attribute: uint32,
    buffer: pointer
    ): SecurityStatus {.stdcall.}

ansiWideAllImportC(setCredentialsAttributes,
  setCredentialsAttributesA, setCredentialsAttributesW,
  TNone, char, Utf16Char, "SetCredentialsAttributesA", "SetCredentialsAttributesW"):
  ## ref.: https://msdn.microsoft.com/en-us/library/ff621492.aspx
  proc setCredentialsAttributes*(
    context: PCredHandle,
    attribute: uint32,
    buffer: pointer,
    bufferSize: uint32
    ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc.}
ansiWideAll(Set_Credentials_Attributes_Fn,
  Set_Credentials_Attributes_Fn_A, Set_Credentials_Attributes_Fn_W,
  TNone, char, Utf16Char):
  type Set_Credentials_Attributes_Fn* = proc(
    context: PCredHandle,
    attribute: uint32,
    buffer: pointer,
    bufferSize: uint32
    ): SecurityStatus {.stdcall.}

## ref.: https://msdn.microsoft.com/en-us/library/aa375416.aspx
proc freeContextBuffer*(
  contextBuffer: pointer
  ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc: "FreeContextBuffer".}
type Free_Context_Buffer_Fn* = proc(
  contextBuffer: pointer
  ): SecurityStatus {.stdcall.}

###################################################################
####
####    Message Support API
####
##################################################################
## ref.: https://msdn.microsoft.com/en-us/library/aa378736.aspx
proc makeSignature*(
  context: PCtxtHandle,
  qop: uint32,
  msg: var SecBufferDesc,
  msgSeqNo: uint32
  ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc: "MakeSignature".}
type Make_Signature_Fn* = proc(
  context: PCtxtHandle,
  qop: uint32,
  msg: var SecBufferDesc,
  msgSeqNo: uint32
  ): SecurityStatus {.stdcall.}

## ref.: https://msdn.microsoft.com/en-us/library/aa380540.aspx
proc verifySignature*(
  context: PCtxtHandle,
  msg: PSecBufferDesc,
  msgSeqNo: uint32,
  qop: var uint32
  ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc: "VerifySignature".}
type Verify_Signature_Fn* = proc(
  context: PCtxtHandle,
  msg: PSecBufferDesc,
  msgSeqNo: uint32,
  qop: var uint32
  ): SecurityStatus {.stdcall.}

# This only exists win Win2k3 and Greater
const
  secqop_wrap_no_encrypt* =    0x80000001
  secqop_wrap_oob_data* =      0x40000000

## ref.: https://msdn.microsoft.com/en-us/library/aa375378.aspx
proc encryptMessage*(
  context: PCtxtHandle,
  qop: uint32,
  msg: var SecBufferDesc,
  msgSeqNo: uint32
  ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc: "EncryptMessage".}
type Encrypt_Message_Fn* = proc(
  context: PCtxtHandle,
  qop: uint32,
  msg: var SecBufferDesc,
  msgSeqNo: uint32
  ): SecurityStatus {.stdcall.}

## ref.: https://msdn.microsoft.com/en-us/library/aa375211.aspx
proc decryptMessage*(
  context: PCtxtHandle,
  msg: var SecBufferDesc,
  msgSeqNo: uint32,
  qop: var uint32
  ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc: "DecryptMessage".}
type Decrypt_Message_Fn* = proc(
  context: PCtxtHandle,
  msg: var SecBufferDesc,
  msgSeqNo: uint32,
  qop: var uint32
  ): SecurityStatus {.stdcall.}

###########################################################################
####
####    Misc.
####
###########################################################################
ansiWideAllImportC(enumerateSecurityPackages,
  enumerateSecurityPackagesA, enumerateSecurityPackagesW,
  SecPkgInfo, SecPkgInfoA, SecPkgInfoW,
  "EnumerateSecurityPackagesA", "EnumerateSecurityPackagesW"):
  ## ref.: https://msdn.microsoft.com/en-us/library/aa375397.aspx
  proc enumerateSecurityPackages*(
    len: var uint32,
    buf: var AnySizeArrayRef[SecPkgInfo]
    ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc.}
ansiWideAll(Enumerate_Security_Packages_Fn,
  Enumerate_Security_Packages_Fn_A, Enumerate_Security_Packages_Fn_W,
  SecPkgInfo, SecPkgInfoA, SecPkgInfoW):
  type Enumerate_Security_Packages_Fn* = proc(
    len: var uint32,
    buf: var AnySizeArrayRef[SecPkgInfo]
    ): SecurityStatus {.stdcall.}

ansiWideAllMulti(
  (src: "querySecurityPackageInfo", ansi: "querySecurityPackageInfoA", wide: "querySecurityPackageInfoW"),
  [(src: "LpTStr", ansi: "cstring", wide: "WideCString"),
  (src: "SecPkgInfo", ansi: "SecPkgInfoA", wide: "SecPkgInfoW")],
  (ansi: "QuerySecurityPackageInfoA", wide: "QuerySecurityPackageInfoW")
  ):
  ## ref.: https://msdn.microsoft.com/en-us/library/aa379359.aspx
  proc querySecurityPackageInfo*(
    packageName: LpTStr,
    buf: var SecPkgInfo
    ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc.}
ansiWideAllMulti(
  ("Query_Security_Package_Info_Fn", "Query_Security_Package_Info_Fn_A", "Query_Security_Package_Info_Fn_W"),
  [("LpTStr", "cstring", "WideCString"),
  ("SecPkgInfo", "SecPkgInfoA", "SecPkgInfoW")],
  (nil, nil)):
  type Query_Security_Package_Info_Fn* = proc(
    packageName: LpTStr,
    buf: var SecPkgInfo
    ): SecurityStatus {.stdcall.}

#[
type 
  SecDelegationType* = enum
    secFull,
    secService,
    secTree,
    secDirectory,
    secObject
  PSecDelegationType* = ptr SecDelegationType

proc delegateSecurityContext*(
  context: PCtxtHandle,
  target: PSecurityString,
  delegationType: SecDelegationType,
  expiry: PTimeStamp,
  packageParam: PSecBuffer,
  output: var SecBufferDesc
  ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc: "DelegateSecurityContext".}
]#

###########################################################################
####
####    Proxies
####
###########################################################################


##
## Proxies are only available on NT platforms
##

###########################################################################
####
####    Context export#import
####
###########################################################################
## ref.: https://msdn.microsoft.com/en-us/library/aa375409.aspx
proc exportSecurityContext*(
  context: PCtxtHandle,
  flags: uint32,
  packagedContext: var SecBuffer,
  token: var pointer
  ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc: "ExportSecurityContext".}
type Export_Security_Context_Fn* = proc(
  context: PCtxtHandle,
  flags: uint32,
  packagedContext: var SecBuffer,
  token: var pointer
  ): SecurityStatus {.stdcall.}

ansiWideAllImportC(importSecurityContext,
  importSecurityContextA, importSecurityContextW,
  LPTStr, cstring, WideCString,
  "ImportSecurityContextA", "ImportSecurityContextW"):
  ## ref.: https://msdn.microsoft.com/en-us/library/aa375502.aspx
  proc importSecurityContext*(
    package: LPTStr,
    packedContext: PSecBuffer,
    token: pointer,
    context: var CtxtHandle
    ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc.}
ansiWideAll(Import_Security_Context_Fn,
  Import_Security_Context_Fn_A, Import_Security_Context_Fn_W,
  LPTStr, cstring, WideCString):
  type Import_Security_Context_Fn* = proc(
    package: LPTStr,
    packedContext: PSecBuffer,
    token: pointer,
    context: var CtxtHandle
    ): SecurityStatus {.stdcall.}

###############################################################################
####
####  Fast access for RPC:
####
###############################################################################
ansiWideAllMulti(
  ("SecurityFunctionTable", "SecurityFunctionTableA", "SecurityFunctionTableW"),
  [
    ("Enumerate_Security_Packages_Fn", "Enumerate_Security_Packages_Fn_A", "Enumerate_Security_Packages_Fn_W"),
    ("Query_Context_Attributes_Fn", "Query_Context_Attributes_Fn_A", "Query_Context_Attributes_Fn_W"),
    ("Acquire_Credentials_Handle_Fn", "Acquire_Credentials_Handle_Fn_A", "Acquire_Credentials_Handle_Fn_W"),
    ("Initialize_Security_Context_Fn", "Initialize_Security_Context_Fn_A", "Initialize_Security_Context_Fn_W"),
    ("Query_Context_Attributes_Fn", "Query_Context_Attributes_Fn_A", "Query_Context_Attributes_Fn_W"),
    ("Query_Security_Package_Info_Fn", "Query_Security_Package_Info_Fn_A", "Query_Security_Package_Info_Fn_W"),
    ("Import_Security_Context_Fn", "Import_Security_Context_Fn_A", "Import_Security_Context_Fn_W"),
    ("Add_Credentials_Fn", "Add_Credentials_Fn_A", "Add_Credentials_Fn_W"),
    ("Set_Context_Attributes_Fn", "Set_Context_Attributes_Fn_A", "Set_Context_Attributes_Fn_W"),
    ("Set_Credentials_Attributes_Fn", "Set_Credentials_Attributes_Fn_A", "Set_Credentials_Attributes_Fn_W"),
    ("Change_Password_Fn", "Change_Password_Fn_A", "Change_Password_Fn_W")
  ], (nil, nil)):
  type SecurityFunctionTable* = object
    version: uint32
    enumerateSecurityPackages: Enumerate_Security_Packages_Fn
    queryCredentialsAttributes: Query_Context_Attributes_Fn
    acquireCredentialsHandle: Acquire_Credentials_Handle_Fn
    freeCredentialsHandle: Free_Credentials_Handle_Fn
    reserved2: pointer
    initializeSecurityContext: Initialize_Security_Context_Fn
    acceptSecurityContext: Accept_Security_Context_Fn
    completeAuthToken: Complete_Auth_Token_Fn
    deleteSecurityContext: Delete_Security_Context_Fn
    applyControlToken: Apply_Control_Token_Fn
    queryContextAttributes: Query_Context_Attributes_Fn
    impersonateSecurityContext: Impersonate_Security_Context_Fn
    revertSecurityContext: Revert_Security_Context_Fn
    makeSignature: Make_Signature_Fn
    verifySignature: Verify_Signature_Fn
    freeContextBuffer: Free_Context_Buffer_Fn
    querySecurityPackageInfo: Query_Security_Package_Info_Fn
    reserved3, reserved4: pointer
    exportSecurityContext: Export_Security_Context_Fn
    importSecurityContext: Import_Security_Context_Fn
    addCredentials: Add_Credentials_Fn
    reserved8: pointer
    querySecurityContextToken: Query_Security_Context_Token_Fn
    encryptMessage: Encrypt_Message_Fn
    decryptMessage: Decrypt_Message_Fn
    setContextAttributes: Set_Context_Attributes_Fn
    setCredentialsAttributes: Set_Credentials_Attributes_Fn
    changeAccountPassword: Change_Password_Fn
type
  PSecurityFunctionTableW* = ptr SecurityFunctionTableW
  PSecurityFunctionTableA* = ptr SecurityFunctionTableA
  PSecurityFunctionTable* = ptr SecurityFunctionTable

const
  ## Function table has all routines through DecryptMessage
  security_support_provider_interface_version* =   1

  ## Function table has all routines through SetContextAttributes
  security_support_provider_interface_version_2* = 2

  ## Function table has all routines through SetCredentialsAttributes
  security_support_provider_interface_version_3* = 3

  ## Function table has all routines through ChangeAccountPassword
  security_support_provider_interface_version_4* = 4

ansiWideAllImportC(initSecurityInterface,
  initSecurityInterfaceA, initSecurityInterfaceW,
  PSecurityFunctionTable, PSecurityFunctionTableA, PSecurityFunctionTableW,
  "InitSecurityInterfaceA", "InitSecurityInterfaceW"):
  proc initSecurityInterface*(): PSecurityFunctionTable {.stdcall, dynlib: "Secur32.dll", importc.}
ansiWideAll(Init_Security_Interface_Fn,
  Init_Security_Interface_Fn_A, Init_Security_Interface_Fn_W,
  PSecurityFunctionTable, PSecurityFunctionTableA, PSecurityFunctionTableW):
  type Init_Security_Interface_Fn* = proc(): PSecurityFunctionTable {.stdcall.}

##
## SASL Profile Support
##

ansiWideAllImportC(saslEnumerateProfiles,
  saslEnumerateProfilesA, saslEnumerateProfilesW,
  LPTStr, cstring, WideCString,
  "SaslEnumerateProfilesA", "SaslEnumerateProfilesW"):
  ## ref.: https://msdn.microsoft.com/en-us/library/aa379455.aspx
  proc saslEnumerateProfiles*(
    profileList: var AnySizeArrayRef[LPTStr],
    profileLen: var uint32
    ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc.}

ansiWideAllMulti(("saslGetProfilePackage",
  "saslGetProfilePackageA", "saslGetProfilePackageW"),
  [
    ("LPTStr", "cstring", "WideCString"),
    ("SecPkgInfo", "SecPkgInfoA", "SecPkgInfoW")
  ],
  ("SaslGetProfilePackageA", "SaslGetProfilePackageW")):
  ## ref.: https://msdn.microsoft.com/en-us/library/aa379459.aspx
  proc saslGetProfilePackage*(
    profileName: LPTStr,
    packageInfo: var SecPkgInfo
    ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc.}

ansiWideAllImportC(saslIdentifyPackage,
  saslIdentifyPackageA, saslIdentifyPackageW,
  SecPkgInfo, SecPkgInfoA, SecPkgInfoW,
  "SaslIdentifyPackageA", "SaslIdentifyPackageW"):
  ## ref.: https://msdn.microsoft.com/en-us/library/aa379461.aspx
  proc saslIdentifyPackage*(
    input: PSecBufferDesc,
    packageInfo: var SecPkgInfo
    ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc.}

ansiWideAllImportC(saslInitializeSecurityContext,
  saslInitializeSecurityContextA, saslInitializeSecurityContextW,
  LPTStr, cstring, WideCString,
  "SaslInitializeSecurityContextA", "SaslInitializeSecurityContextW"):
  ## ref.: https://msdn.microsoft.com/en-us/library/aa379463.aspx
  proc saslInitializeSecurityContext*(
    credential: PCredHandle,
    context: PCtxtHandle,
    targetName: LPTStr,
    contextReq: uint32,
    reserved1: uint32,
    targetDataRep: uint32,
    input: PSecBufferDesc,
    reserved2: uint32,
    newContext: var CredHandle,
    output: var SecBufferDesc,
    contextAttr: var uint32,
    expiry: var TimeStamp
    ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc.}

## ref.: https://msdn.microsoft.com/en-us/library/aa379453.aspx
proc saslAcceptSecurityContext*(
  credential: PCredHandle,
  context: PCtxtHandle,
  input: PSecBufferDesc,
  contextReq: uint32,
  targetDataRep: uint32,
  newContext: var CredHandle,
  output: var SecBufferDesc,
  contextAttr: var uint32,
  expiry: var TimeStamp
  ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc: "SaslAcceptSecurityContext".}

const
  sasl_option_send_size* =     1       ## Maximum size to send to peer
  sasl_option_recv_size* =     2       ## Maximum size willing to receive
  sasl_option_authz_string* =  3       ## Authorization string
  sasl_option_authz_processing* =  4       ## Authorization string processing

type 
  Sasl_Authzid_State* = enum
    sasl_AuthZIDForbidden, ## allow no AuthZID strings to be specified - error out (default)
    sasl_AuthZIDProcessed ## AuthZID Strings processed by Application or SSP

## ref.: https://msdn.microsoft.com/en-us/library/aa379464.aspx
proc saslSetContextOption*(
  context: PCtxtHandle,
  option: uint32,
  value: pointer,
  size: uint32
  ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc: "SaslSetContextOption".}

## ref.: https://msdn.microsoft.com/en-us/library/aa379456.aspx
proc saslGetContextOption*[T](
  context: PCtxtHandle,
  option: uint32,
  value: pointer,
  size: uint32,
  needed: var uint32
  ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc: "SaslGetContextOption".}


#
# This is the legacy credentials structure.
# The EX version below is preferred.

const sec_winnt_auth_identity_version_2* = 0x201

type
  Sec_WinNT_Auth_Identity_Ex2* = object
    version: uint32 ## contains sec_winnt_auth_identity_version_2
    headerSize: uint16
    structureSize: uint32
    userOffset: uint32               ## Non-NULL terminated string, unicode only
    userSize: uint16                 ## # of bytes (NOT WCHARs), not including NULL.
    domainOffset: uint32             ## Non-NULL terminated string, unicode only
    domainSize: uint16               ## # of bytes (NOT WCHARs), not including NULL.
    packedCredentialsOffset: uint32  ## Non-NULL terminated string, unicode only
    packedCredentialsSize: uint16    ## # of bytes (NOT WCHARs), not including NULL.
    flags: uint32
    packageListOffset: uint32        ## Non-NULL terminated string, unicode only
    packageListSize: uint32
  PSec_WinNT_Auth_Identity_Ex2* = ptr Sec_WinNT_Auth_Identity_Ex2

ansiWideAll(Sec_WinNT_Auth_Identity,
  Sec_WinNT_Auth_Identity_A, Sec_WinNT_Auth_Identity_W,
  TAnsiWide, byte, uint16):
  type Sec_WinNT_Auth_Identity* = object
    user: AnySizeArrayRef[TAnsiWide]     ## Non-NULL terminated string.
    userLen: uint32                      ## # of characters (NOT bytes), not including NULL.
    domain: AnySizeArrayRef[TAnsiWide]   ## Non-NULL terminated string.
    domainLen: uint32                    ## # of characters (NOT bytes), not including NULL.
    password: AnySizeArrayRef[TAnsiWide] ## Non-NULL terminated string.
    passwordLen: uint32                  ## # of characters (NOT bytes), not including NULL.
    flags: uint32
type
  PSec_WinNT_Auth_Identity_W* = ptr Sec_WinNT_Auth_Identity_W
  PSec_WinNT_Auth_Identity_A* = ptr Sec_WinNT_Auth_Identity_A
  PSec_WinNT_Auth_Identity* = ptr Sec_WinNT_Auth_Identity

ansiWideAll(Sec_WinNT_Auth_Identity_Ex,
  Sec_WinNT_Auth_Identity_ExA, Sec_WinNT_Auth_Identity_ExW,
  TAnsiWide, byte, uint16):
  ##
  ## This is the combined authentication identity structure that may be
  ## used with the negotiate package, NTLM, Kerberos, or SCHANNEL
  ##
  type Sec_WinNT_Auth_Identity_Ex* = object
    version: uint32
    len: uint32
    user: AnySizeArrayRef[TAnsiWide]     ## Non-NULL terminated string.
    userLen: uint32                      ## # of characters (NOT bytes), not including NULL.
    domain: AnySizeArrayRef[TAnsiWide]   ## Non-NULL terminated string.
    domainLen: uint32                    ## # of characters (NOT bytes), not including NULL.
    password: AnySizeArrayRef[TAnsiWide] ## Non-NULL terminated string.
    passwordLen: uint32                  ## # of characters (NOT bytes), not including NULL.
    flags: uint32
    packageList: AnySizeArrayRef[TAnsiWide]
    packageListLen: uint32
type
  PSec_WinNT_Auth_Identity_ExW* = ptr Sec_WinNT_Auth_Identity_ExW
  PSec_WinNT_Auth_Identity_ExA* = ptr Sec_WinNT_Auth_Identity_ExA
  PSec_WinNT_Auth_Identity_Ex* = ptr Sec_WinNT_Auth_Identity_Ex

const
  ## the credential structure is encrypted via
  ## RtlEncryptMemory(OptionFlags = 0)
  sec_winnt_auth_identity_flags_process_encrypted* = 0x10

  ## the credential structure is protected by local system via
  ## RtlEncryptMemory(OptionFlags=IOCTL_KSEC_ENCRYPT_MEMORY_SAME_LOGON)
  sec_winnt_auth_identity_flags_system_protected* =  0x20

  ## the credential structure is encrypted by a non-system context
  ## RtlEncryptMemory(OptionFlags=IOCTL_KSEC_ENCRYPT_MEMORY_SAME_LOGON)
  sec_winnt_auth_identity_flags_user_protected* =    0x40

  sec_winnt_auth_identity_flags_reserved* =       0x10000
  sec_winnt_auth_identity_flags_null_user* =      0x20000
  sec_winnt_auth_identity_flags_null_domain* =    0x40000
  sec_winnt_auth_identity_flags_id_provider* =    0x80000


  ##
  ## These bits are for communication between SspiPromptForCredentials()
  ## and the credential providers. Do not use these bits for any other
  ## purpose.
  ##
  sec_winnt_auth_identity_flags_sspipfc_use_mask* =  0xFF000000

  ##
  ## Instructs the credential provider to not save credentials itself
  ## when caller selects the "Remember my credential" checkbox.
  ##
  sec_winnt_auth_identity_flags_sspipfc_credprov_do_not_save* =  0x80000000

  ##
  ## Support the old name for this flag for callers that were built for earlier
  ## versions of the SDK.
  ##
  sec_winnt_auth_identity_flags_sspipfc_save_cred_by_caller* =   sec_winnt_auth_identity_flags_sspipfc_credprov_do_not_save

  ##
  ## State of the "Remember my credentials" checkbox.
  ## When set, indicates checked; when cleared, indicates unchecked.
  ##
  sec_winnt_auth_identity_flags_sspipfc_save_cred_checked* =     0x40000000

  ##
  ## The "Save" checkbox is not displayed on the credential provider tiles
  ##
  sec_winnt_auth_identity_flags_sspipfc_no_checkbox* =           0x20000000

  ##
  ## Credential providers will not attempt to prepopulate the CredUI dialog
  ## box with credentials retrieved from Cred Man.
  ##
  sec_winnt_auth_identity_flags_sspipfc_credprov_do_not_load* =  0x10000000

  sec_winnt_auth_identity_flags_valid_sspipfc_flags* =   (sec_winnt_auth_identity_flags_sspipfc_credprov_do_not_save or sec_winnt_auth_identity_flags_sspipfc_save_cred_checked or sec_winnt_auth_identity_flags_sspipfc_no_checkbox or sec_winnt_auth_identity_flags_sspipfc_credprov_do_not_load)

type
  ## the credential structure is opaque
  PSec_WinNT_Auth_Identity_Opaque* = distinct pointer

#
# flags parameter of sspiPromptForCredentials():
#
const
  ##
  ## Indicates that the credentials should not be saved if
  ## the user selects the 'save' (or 'remember my password')
  ## checkbox in the credential dialog box. The location pointed
  ## to by the pfSave parameter indicates whether or not the user
  ## selected the checkbox.
  ##
  ## Note that some credential providers won't honour this flag and
  ## may save the credentials in a persistent manner anyway if the
  ## user selects the 'save' checbox.
  ##
  sspipfc_credprov_do_not_save* =    0x00000001

  ##
  ## Support the old name for this flag for callers that were built for earlier
  ## versions of the SDK.
  ##
  sspipfc_save_cred_by_caller* =     sspipfc_credprov_do_not_save

  ##
  ## The password and smart card credential providers will not display the 
  ## "Remember my credentials" check box in the provider tiles. 
  ##
  sspipfc_no_checkbox* =             0x00000002

  ##
  ## Credential providers will not attempt to prepopulate the CredUI dialog
  ## box with credentials retrieved from Cred Man.
  ##
  sspipfc_credprov_do_not_load* =    0x00000004

  ##
  ## Credential providers along with UI Dialog will be hosted in a separate
  ## broker process.
  ##
  sspipfc_use_creduibroker* = 0x00000008

  sspipfc_valid_flags* = (sspipfc_credprov_do_not_save or sspipfc_no_checkbox or sspipfc_credprov_do_not_load or sspipfc_use_creduibroker)



#
# Common types used by negotiable security packages
#
# These are defined after W2K
#
const
  sec_winnt_auth_identity_marshalled* =   0x4     ## all data is in one buffer
  sec_winnt_auth_identity_only* =         0x8     ## these credentials are for identity only - no PAC needed

#
# Routines for manipulating packages
#
type
  Security_Package_Options* = object
    size: uint32
    typ: uint32
    flags: uint32
    signatureSize: uint32
    signature: AnySizeArrayRef[byte]
  PSecurity_Package_Options* = ptr Security_Package_Options

const
  secpkg_options_type_unknown* = 0
  secpkg_options_type_lsa* =     1
  secpkg_options_type_sspi* =    2

  secpkg_options_permanent* =    0x00000001

ansiWideAllImportC(addSecurityPackage,
  addSecurityPackageA, addSecurityPackageW,
  LPTStr, cstring, WideCString,
  "AddSecurityPackageA", "AddSecurityPackageW"):
  ## ref.: https://msdn.microsoft.com/en-us/library/dd401506.aspx
  proc addSecurityPackage*(
    packageName: LPTStr,
    options: PSecurityPackageOptions
    ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc.}

ansiWideAllImportC(deleteSecurityPackage,
  deleteSecurityPackageA, deleteSecurityPackageW,
  LPTStr, cstring, WideCString,
  "DeleteSecurityPackageA", "DeleteSecurityPackageW"):
  ## ref.: https://msdn.microsoft.com/en-us/library/dd401610.aspx
  proc deleteSecurityPackage*(
    packageName: LPTStr
    ): SecurityStatus {.stdcall, dynlib: "Secur32.dll", importc.}
