##############################################################################
##
##  Microsoft Windows
##  Copyright (C) Microsoft Corporation, 1992-1999.
##
##  File:       wincrypt.h
##
##  Contents:   Cryptographic API Prototypes and Definitions
##
##############################################################################

type 
  Alg_Class* = distinct uint32
    ## Algorithm classes
  Alg_Type* = distinct uint32
    ## Algorithm types
  Alg_SId* = distinct uint32
    ## Algorithm sub-ids
  Alg_Id* = distinct uint32
    ## Algorithm identifier
    ## ref.: https://msdn.microsoft.com/en-us/library/aa375549.aspx

proc class*(x: Alg_Id): Alg_Class = (x.uint32 and (7 shl 13)).Alg_Class
proc type*(x: Alg_Id): Alg_Type = (x.uint32 and (15 shl 9)).Alg_Type
proc sid*(x: Alg_Id): Alg_SId = (x.uint32 and (511)).Alg_SId

const
  alg_class_any* = (0).Alg_Class
  alg_class_signature* = (1 shl 13).Alg_Class
  alg_class_msg_encrypt* = (2 shl 13).Alg_Class
  alg_class_data_encrypt* = (3 shl 13).Alg_Class
  alg_class_hash* = (4 shl 13).Alg_Class
  alg_class_key_exchange* = (5 shl 13).Alg_Class
  alg_class_all* = (7 shl 13).Alg_Class

  alg_type_any* = (0).Alg_Type
  alg_type_dss* = (1 shl 9).Alg_Type
  alg_type_rsa* = (2 shl 9).Alg_Type
  alg_type_block* = (3 shl 9).Alg_Type
  alg_type_stream* = (4 shl 9).Alg_Type
  alg_type_dh* = (5 shl 9).Alg_Type
  alg_type_securechannel* = (6 shl 9).Alg_Type
  alg_type_ecdh* = (7 shl 9).Alg_Type
  alg_type_thirdparty* = (8 shl 9).Alg_Type

  alg_sid_any* = (0).Alg_SId

  alg_sid_thirdparty_any* = (0).Alg_SId

  alg_sid_rsa_any* = 0.Alg_SId
  alg_sid_rsa_pkcs* = 1.Alg_SId
  alg_sid_rsa_msatwork* = 2.Alg_SId
  alg_sid_rsa_entrust* = 3.Alg_SId
  alg_sid_rsa_pgp* = 4.Alg_SId

  alg_sid_dss_any* = 0.Alg_SId
  alg_sid_dss_pkcs* = 1.Alg_SId
  alg_sid_dss_dms* = 2.Alg_SId
  alg_sid_ecdsa* = 3.Alg_SId

  alg_sid_des* = 1.Alg_SId
  alg_sid_3des* = 3.Alg_SId
  alg_sid_desx* = 4.Alg_SId
  alg_sid_idea* = 5.Alg_SId
  alg_sid_cast* = 6.Alg_SId
  alg_sid_safersk64* = 7.Alg_SId
  alg_sid_safersk128* = 8.Alg_SId
  alg_sid_3des_112* = 9.Alg_SId
  alg_sid_cylink_mek* = 12.Alg_SId
  alg_sid_rc5* = 13.Alg_SId
  alg_sid_aes_128* = 14.Alg_SId
  alg_sid_aes_192* = 15.Alg_SId
  alg_sid_aes_256* = 16.Alg_SId
  alg_sid_aes* = 17.Alg_SId

  alg_sid_skipjack* = 10.Alg_SId
  alg_sid_tek* = 11.Alg_SId

  alg_sid_rc2* = 2.Alg_SId

  alg_sid_rc4* = 1.Alg_SId
  alg_sid_seal* = 2.Alg_SId

  alg_sid_dh_sandf* = 1.Alg_SId
  alg_sid_dh_ephem* = 2.Alg_SId
  alg_sid_agreed_key_any* = 3.Alg_SId
  alg_sid_kea* = 4.Alg_SId
  alg_sid_ecdh* = 5.Alg_SId
  alg_sid_ecdh_ephem* = 6.Alg_SId

  alg_sid_md2* = 1.Alg_SId
  alg_sid_md4* = 2.Alg_SId
  alg_sid_md5* = 3.Alg_SId
  alg_sid_sha* = 4.Alg_SId
  alg_sid_sha1* = 4.Alg_SId
  alg_sid_mac* = 5.Alg_SId
  alg_sid_ripemd* = 6.Alg_SId
  alg_sid_ripemd160* = 7.Alg_SId
  alg_sid_ssl3shamd5* = 8.Alg_SId
  alg_sid_hmac* = 9.Alg_SId
  alg_sid_tls1prf* = 10.Alg_SId
  alg_sid_hash_replace_owf* = 11.Alg_SId
  alg_sid_sha_256* = 12.Alg_SId
  alg_sid_sha_384* = 13.Alg_SId
  alg_sid_sha_512* = 14.Alg_SId

  alg_sid_ssl3_master* = 1.Alg_SId
  alg_sid_schannel_master_hash* = 2.Alg_SId
  alg_sid_schannel_mac_key* = 3.Alg_SId
  alg_sid_pct1_master* = 4.Alg_SId
  alg_sid_ssl2_master* = 5.Alg_SId
  alg_sid_tls1_master* = 6.Alg_SId
  alg_sid_schannel_enc_key* = 7.Alg_SId

  alg_sid_ecmqv* = 1.Alg_SId

  alg_sid_example* = 80.Alg_SId

proc `|`*(class: Alg_Class, typ: Alg_Type): Alg_Id {.inline.} = 
  (class.uint32 or typ.uint32).Alg_Id
proc `|`*(id: Alg_Id, sid: Alg_SId): Alg_Id {.inline.} = 
  (id.uint32 or sid.uint32).Alg_Id

const
  calg_md2* = (alg_class_hash | alg_type_any | alg_sid_md2)
  calg_md4* = (alg_class_hash | alg_type_any | alg_sid_md4)
  calg_md5* = (alg_class_hash | alg_type_any | alg_sid_md5)
  calg_sha* = (alg_class_hash | alg_type_any | alg_sid_sha)
  calg_sha1* = (alg_class_hash | alg_type_any | alg_sid_sha1)
  calg_mac* {.deprecated.} = (alg_class_hash | alg_type_any | alg_sid_mac) ## Deprecated. Don't use.
  calg_rsa_sign* = (alg_class_signature | alg_type_rsa | alg_sid_rsa_any)
  calg_dss_sign* = (alg_class_signature | alg_type_dss | alg_sid_dss_any)
  calg_no_sign* = (alg_class_signature | alg_type_any | alg_sid_any)
  calg_rsa_keyx* = (alg_class_key_exchange|alg_type_rsa|alg_sid_rsa_any)
  calg_des* = (alg_class_data_encrypt|alg_type_block|alg_sid_des)
  calg_3des_112* = (alg_class_data_encrypt|alg_type_block|alg_sid_3des_112)
  calg_3des* = (alg_class_data_encrypt|alg_type_block|alg_sid_3des)
  calg_desx* = (alg_class_data_encrypt|alg_type_block|alg_sid_desx)
  calg_rc2* = (alg_class_data_encrypt|alg_type_block|alg_sid_rc2)
  calg_rc4* = (alg_class_data_encrypt|alg_type_stream|alg_sid_rc4)
  calg_seal* = (alg_class_data_encrypt|alg_type_stream|alg_sid_seal)
  calg_dh_sf* = (alg_class_key_exchange|alg_type_dh|alg_sid_dh_sandf)
  calg_dh_ephem* = (alg_class_key_exchange|alg_type_dh|alg_sid_dh_ephem)
  calg_agreedkey_any* = (alg_class_key_exchange|alg_type_dh|alg_sid_agreed_key_any)
  calg_kea_keyx* = (alg_class_key_exchange|alg_type_dh|alg_sid_kea)
  calg_hughes_md5* = (alg_class_key_exchange|alg_type_any|alg_sid_md5)
  calg_skipjack* = (alg_class_data_encrypt|alg_type_block|alg_sid_skipjack)
  calg_tek* = (alg_class_data_encrypt|alg_type_block|alg_sid_tek)
  calg_cylink_mek* {.deprecated.} = (alg_class_data_encrypt|alg_type_block|alg_sid_cylink_mek) ## Deprecated. Do not use
  calg_ssl3_shamd5* = (alg_class_hash | alg_type_any | alg_sid_ssl3shamd5)
  calg_ssl3_master* = (alg_class_msg_encrypt|alg_type_securechannel|alg_sid_ssl3_master)
  calg_schannel_master_hash* = (alg_class_msg_encrypt|alg_type_securechannel|alg_sid_schannel_master_hash)
  calg_schannel_mac_key* = (alg_class_msg_encrypt|alg_type_securechannel|alg_sid_schannel_mac_key)
  calg_schannel_enc_key* = (alg_class_msg_encrypt|alg_type_securechannel|alg_sid_schannel_enc_key)
  calg_pct1_master* = (alg_class_msg_encrypt|alg_type_securechannel|alg_sid_pct1_master)
  calg_ssl2_master* = (alg_class_msg_encrypt|alg_type_securechannel|alg_sid_ssl2_master)
  calg_tls1_master* = (alg_class_msg_encrypt|alg_type_securechannel|alg_sid_tls1_master)
  calg_rc5* = (alg_class_data_encrypt|alg_type_block|alg_sid_rc5)
  calg_hmac* = (alg_class_hash | alg_type_any | alg_sid_hmac)
  calg_tls1prf* = (alg_class_hash | alg_type_any | alg_sid_tls1prf)
  calg_hash_replace_owf* = (alg_class_hash | alg_type_any | alg_sid_hash_replace_owf)
  calg_aes_128* = (alg_class_data_encrypt|alg_type_block|alg_sid_aes_128)
  calg_aes_192* = (alg_class_data_encrypt|alg_type_block|alg_sid_aes_192)
  calg_aes_256* = (alg_class_data_encrypt|alg_type_block|alg_sid_aes_256)
  calg_aes* = (alg_class_data_encrypt|alg_type_block|alg_sid_aes)
  calg_sha_256* = (alg_class_hash | alg_type_any | alg_sid_sha_256)
  calg_sha_384* = (alg_class_hash | alg_type_any | alg_sid_sha_384)
  calg_sha_512* = (alg_class_hash | alg_type_any | alg_sid_sha_512)
  calg_ecdh* = (alg_class_key_exchange | alg_type_dh | alg_sid_ecdh)
  calg_ecdh_ephem* = (alg_class_key_exchange | alg_type_ecdh | alg_sid_ecdh_ephem)
  calg_ecmqv* = (alg_class_key_exchange | alg_type_any | alg_sid_ecmqv)
  calg_ecdsa* = (alg_class_signature | alg_type_dss | alg_sid_ecdsa)
  calg_nullcipher* = (alg_class_data_encrypt | alg_type_any | 0.Alg_SId)
  calg_thirdparty_key_exchange* = (alg_class_key_exchange | alg_type_thirdparty | alg_sid_thirdparty_any)
  calg_thirdparty_signature* = (alg_class_signature    | alg_type_thirdparty | alg_sid_thirdparty_any)
  calg_thirdparty_cipher* = (alg_class_data_encrypt | alg_type_thirdparty | alg_sid_thirdparty_any)
  calg_thirdparty_hash* = (alg_class_hash         | alg_type_thirdparty | alg_sid_thirdparty_any)
