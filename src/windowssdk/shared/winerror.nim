###########################################################################
##                                                                       ##
##   winerror.h --  error code definitions for the Win32 API functions   ##
##                                                                       ##
##   Copyright (c) Microsoft Corp. All rights reserved.                  ##
##                                                                       ##
###########################################################################

##
## Note: There is a slightly modified layout for HRESULT values below,
##        after the heading "COM Error Codes".
##
## Search for "**** Available SYSTEM error codes ****" to find where to
## insert new error codes
##
##  Values are 32 bit values laid out as follows:
##
##   3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
##   1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
##  +-+-+-+-+-+---------------------+-------------------------------+
##  |S|R|C|N|r|    Facility         |               Code            |
##  +-+-+-+-+-+---------------------+-------------------------------+
##
##  where
##
##      S - Severity - indicates success/fail
##
##          0 - Success
##          1 - Fail (COERROR)
##
##      R - reserved portion of the facility code, corresponds to NT's
##              second severity bit.
##
##      C - reserved portion of the facility code, corresponds to NT's
##              C field.
##
##      N - reserved portion of the facility code. Used to indicate a
##              mapped NT status value.
##
##      r - reserved portion of the facility code. Reserved for internal
##              use. Used to indicate HRESULT values that are not status
##              values, but are instead message ids for display strings.
##
##      Facility - is the facility code
##
##      Code - is the facility's status code
##

import importc_helpers, macros, strutils

proc getDistinctAndBaseSym(t: typedesc): tuple[`distinct`, base: NimNode] {.compileTime.} =
  var beD = t.getType()
  beD.expectKind(nnkBracketExpr)
  beD.expectMinLen(2)
  let dSym = beD[1]
  dSym.expectKind(nnkSym)
  let beB = dSym.getType()
  beB.expectKind(nnkBracketExpr)
  beB.expectMinLen(2)
  let bSym = beB[1]
  result = (dSym, bSym)

proc createBorrowInfixOperator(`distinct`, base: NimNode, op: string, returnType: NimNode = ident("bool"), exportable: bool = true, docString: string = nil): NimNode =
  let
    leftArgIdent = ident("a")
    rightArgIdent = ident("b")
    leftBaseValue = newDotExpr(leftArgIdent, base) # a.base
    rightBaseValue = newDotExpr(rightArgIdent, base) # b.base
    argsIdentDefs = newNimNode(nnkIdentDefs).add(leftArgIdent, rightArgIdent, `distinct`, newEmptyNode())
  var procBody = infix(leftBaseValue, op, rightBaseValue)
  if docString.len > 0:
    var docComment = newNimNode(nnkCommentStmt)
    # docComment.strVal = docComment
    procBody = newStmtList(docComment, procBody)
  var procName = newNimNode(nnkAccQuoted).add(ident(op))
  if exportable: procName = postfix(procName, "*")
  result = newProc(
    name = procName, params = [returnType, argsIdentDefs],
    body = procBody)

macro implementDistinctEnumEqual(typ: typedesc): typed =
  let
    typedescTuple = getDistinctAndBaseSym(typ)
    distinctSym = typedescTuple.`distinct`
    baseSym = typedescTuple.base
  result = newStmtList()
  result.add(createBorrowInfixOperator(distinctSym, baseSym, "==", docString = "Equality (``==``) " &
    "operator for the $1 type. Comparison is done by converting both the left and right argument to " &
    "the $2 type and calling the ``==`` operator for the $2 type.".format(distinctSym, baseSym)))

template conditionalStringify(typ: typedesc, knownValueDecl: untyped): typed =
  when defined(useWinErrorStringify):
    implementDistinctEnum(typ, knownValueDecl)
  else:
    knownValueDecl
    implementDistinctEnumEqual(typ)

type HResult* = distinct uint32
  ## ref.: https://msdn.microsoft.com/en-us/library/aa383751.aspx#HRESULT

converter toOSErrorCode*(x: HResult): OSErrorCode = cast[OSErrorCode](x)

#
# Define the facility codes
#
type FacilityCode* = distinct int16
conditionalStringify(FacilityCode):
  const
    facility_xps* =                     82.FacilityCode
    facility_xbox* =                    2339.FacilityCode
    facility_xaml* =                    43.FacilityCode
    facility_usn* =                     129.FacilityCode
    facility_blbui* =                   128.FacilityCode
    facility_spp* =                     256.FacilityCode
    facility_wsb_online* =              133.FacilityCode
    facility_dls* =                     153.FacilityCode
    facility_blb_cli* =                 121.FacilityCode
    facility_blb* =                     120.FacilityCode
    facility_wsbapp* =                  122.FacilityCode
    facility_wpn* =                     62.FacilityCode
    facility_wmaaecma* =                1996.FacilityCode
    facility_winrm* =                   51.FacilityCode
    facility_winpe* =                   61.FacilityCode
    facility_windowsupdate* =           36.FacilityCode
    facility_windows_store* =           63.FacilityCode
    facility_windows_setup* =           48.FacilityCode
    facility_windows_defender* =        80.FacilityCode
    facility_windows_ce* =              24.FacilityCode
    facility_windows* =                 8.FacilityCode
    facility_wincodec_dwrite_dwm* =     2200.FacilityCode
    facility_wia* =                     33.FacilityCode
    facility_wer* =                     27.FacilityCode
    facility_wep* =                     2049.FacilityCode
    facility_web_socket* =              886.FacilityCode
    facility_web* =                     885.FacilityCode
    facility_usermode_volsnap* =        130.FacilityCode
    facility_usermode_volmgr* =         56.FacilityCode
    facility_visualcpp* =               109.FacilityCode
    facility_usermode_virtualization* = 55.FacilityCode
    facility_usermode_vhd* =            58.FacilityCode
    facility_utc* =                     1989.FacilityCode
    facility_urt* =                     19.FacilityCode
    facility_umi* =                     22.FacilityCode
    facility_ui* =                      42.FacilityCode
    facility_tpm_software* =            41.FacilityCode
    facility_tpm_services* =            40.FacilityCode
    facility_tiering* =                 131.FacilityCode
    facility_syncengine* =              2050.FacilityCode
    facility_sxs* =                     23.FacilityCode
    facility_storage* =                 3.FacilityCode
    facility_staterepository* =         103.FacilityCode
    facility_state_management* =        34.FacilityCode
    facility_sspi* =                    9.FacilityCode
    facility_sqlite* =                  1967.FacilityCode
    facility_usermode_spaces* =         231.FacilityCode
    facility_sos* =                     160.FacilityCode
    facility_scard* =                   16.FacilityCode
    facility_shell* =                   39.FacilityCode
    facility_setupapi* =                15.FacilityCode
    facility_security* =                9.FacilityCode
    facility_user_mode_security_core* = 232.FacilityCode
    facility_sdiag* =                   60.FacilityCode
    facility_usermode_sdbus* =          2305.FacilityCode
    facility_rpc* =                     1.FacilityCode
    facility_restore* =                 256.FacilityCode
    facility_script* =                  112.FacilityCode
    facility_parse* =                   113.FacilityCode
    facility_ras* =                     83.FacilityCode
    facility_powershell* =              84.FacilityCode
    facility_pla* =                     48.FacilityCode
    facility_pidgenx* =                 2561.FacilityCode
    facility_p2p_int* =                 98.FacilityCode
    facility_p2p* =                     99.FacilityCode
    facility_opc* =                     81.FacilityCode
    facility_online_id* =               134.FacilityCode
    facility_win32* =                   7.FacilityCode
    facility_control* =                 10.FacilityCode
    facility_webservices* =             61.FacilityCode
    facility_null* =                    0.FacilityCode
    facility_ndis* =                    52.FacilityCode
    facility_nap* =                     39.FacilityCode
    facility_mobile* =                  1793.FacilityCode
    facility_metadirectory* =           35.FacilityCode
    facility_msmq* =                    14.FacilityCode
    facility_mediaserver* =             13.FacilityCode
    facility_mbn* =                     84.FacilityCode
    facility_linguistic_services* =     305.FacilityCode
    facility_usermode_licensing* =      234.FacilityCode
    facility_leap* =                    2184.FacilityCode
    facility_jscript* =                 2306.FacilityCode
    facility_internet* =                12.FacilityCode
    facility_itf* =                     4.FacilityCode
    facility_input* =                   64.FacilityCode
    facility_usermode_hypervisor* =     53.FacilityCode
    facility_accelerator* =             1536.FacilityCode
    facility_http* =                    25.FacilityCode
    facility_usermode_hns* =            59.FacilityCode
    facility_graphics* =                38.FacilityCode
    facility_fwp* =                     50.FacilityCode
    facility_fve* =                     49.FacilityCode
    facility_usermode_filter_manager* = 31.FacilityCode
    facility_eas* =                     85.FacilityCode
    facility_eap* =                     66.FacilityCode
    facility_dxgi_ddi* =                2171.FacilityCode
    facility_dxgi* =                    2170.FacilityCode
    facility_dplay* =                   21.FacilityCode
    facility_dmserver* =                256.FacilityCode
    facility_dispatch* =                2.FacilityCode
    facility_directoryservice* =        37.FacilityCode
    facility_directmusic* =             2168.FacilityCode
    facility_direct3d12_debug* =        2175.FacilityCode
    facility_direct3d12* =              2174.FacilityCode
    facility_direct3d11_debug* =        2173.FacilityCode
    facility_direct3d11* =              2172.FacilityCode
    facility_direct3d10* =              2169.FacilityCode
    facility_direct2d* =                2201.FacilityCode
    facility_daf* =                     100.FacilityCode
    facility_deployment_services_util* = 260.FacilityCode
    facility_deployment_services_transport_management* = 272.FacilityCode
    facility_deployment_services_tftp* = 264.FacilityCode
    facility_deployment_services_pxe* = 263.FacilityCode
    facility_deployment_services_multicast_server* = 289.FacilityCode
    facility_deployment_services_multicast_client* = 290.FacilityCode
    facility_deployment_services_management* = 259.FacilityCode
    facility_deployment_services_imaging* = 258.FacilityCode
    facility_deployment_services_driver_provisioning* = 278.FacilityCode
    facility_deployment_services_server* = 257.FacilityCode
    facility_deployment_services_content_provider* = 293.FacilityCode
    facility_deployment_services_binlsvc* = 261.FacilityCode
    facility_delivery_optimization* =   208.FacilityCode
    facility_defrag* =                  2304.FacilityCode
    facility_debuggers* =               176.FacilityCode
    facility_configuration* =           33.FacilityCode
    facility_complus* =                 17.FacilityCode
    facility_usermode_commonlog* =      26.FacilityCode
    facility_cmi* =                     54.FacilityCode
    facility_cert* =                    11.FacilityCode
    facility_bluetooth_att* =           101.FacilityCode
    facility_bcd* =                     57.FacilityCode
    facility_backgroundcopy* =          32.FacilityCode
    facility_audiostreaming* =          1094.FacilityCode
    facility_audclnt* =                 2185.FacilityCode
    facility_audio* =                   102.FacilityCode
    facility_action_queue* =            44.FacilityCode
    facility_acs* =                     20.FacilityCode
    facility_aaf* =                     18.FacilityCode

#
# Define the severity codes
#
type WinError* = distinct uint32
conditionalStringify(WinError):
  const
    error_success* =                     0.WinError
      ## The operation completed successfully.

    no_error* = 0.WinError

    error_invalid_function* =            1.WinError
      ## Incorrect function.

    error_file_not_found* =              2.WinError
      ## The system cannot find the file specified.

    error_path_not_found* =              3.WinError
      ## The system cannot find the path specified.

    error_too_many_open_files* =         4.WinError
      ## The system cannot open the file.

    error_access_denied* =               5.WinError
      ## Access is denied.

    error_invalid_handle* =              6.WinError
      ## The handle is invalid.

    error_arena_trashed* =               7.WinError
      ## The storage control blocks were destroyed.

    error_not_enough_memory* =           8.WinError
      ## Not enough storage is available to process this command.

    error_invalid_block* =               9.WinError
      ## The storage control block address is invalid.

    error_bad_environment* =             10.WinError
      ## The environment is incorrect.

    error_bad_format* =                  11.WinError
      ## An attempt was made to load a program with an incorrect format.

    error_invalid_access* =              12.WinError
      ## The access code is invalid.

    error_invalid_data* =                13.WinError
      ## The data is invalid.

    error_outofmemory* =                 14.WinError
      ## Not enough storage is available to complete this operation.

    error_invalid_drive* =               15.WinError
      ## The system cannot find the drive specified.

    error_current_directory* =           16.WinError
      ## The directory cannot be removed.

    error_not_same_device* =             17.WinError
      ## The system cannot move the file to a different disk drive.

    error_no_more_files* =               18.WinError
      ## There are no more files.

    error_write_protect* =               19.WinError
      ## The media is write protected.

    error_bad_unit* =                    20.WinError
      ## The system cannot find the device specified.

    error_not_ready* =                   21.WinError
      ## The device is not ready.

    error_bad_command* =                 22.WinError
      ## The device does not recognize the command.

    error_crc* =                         23.WinError
      ## Data error (cyclic redundancy check).

    error_bad_length* =                  24.WinError
      ## The program issued a command but the command length is incorrect.

    error_seek* =                        25.WinError
      ## The drive cannot locate a specific area or track on the disk.

    error_not_dos_disk* =                26.WinError
      ## The specified disk or diskette cannot be accessed.

    error_sector_not_found* =            27.WinError
      ## The drive cannot find the sector requested.

    error_out_of_paper* =                28.WinError
      ## The printer is out of paper.

    error_write_fault* =                 29.WinError
      ## The system cannot write to the specified device.

    error_read_fault* =                  30.WinError
      ## The system cannot read from the specified device.

    error_gen_failure* =                 31.WinError
      ## A device attached to the system is not functioning.

    error_sharing_violation* =           32.WinError
      ## The process cannot access the file because it is being used by another process.

    error_lock_violation* =              33.WinError
      ## The process cannot access the file because another process has locked a portion of the file.

    error_wrong_disk* =                  34.WinError
      ## The wrong diskette is in the drive.
      ## Insert %2 (Volume Serial Number: %3) into drive %1.

    error_sharing_buffer_exceeded* =     36.WinError
      ## Too many files opened for sharing.

    error_handle_eof* =                  38.WinError
      ## Reached the end of the file.

    error_handle_disk_full* =            39.WinError
      ## The disk is full.

    error_not_supported* =               50.WinError
      ## The request is not supported.

    error_rem_not_list* =                51.WinError
      ## Windows cannot find the network path. Verify that the network path is correct and the destination computer is not busy or turned off. If Windows still cannot find the network path, contact your network administrator.

    error_dup_name* =                    52.WinError
      ## You were not connected because a duplicate name exists on the network. If joining a domain, go to System in Control Panel to change the computer name and try again. If joining a workgroup, choose another workgroup name.

    error_bad_netpath* =                 53.WinError
      ## The network path was not found.

    error_network_busy* =                54.WinError
      ## The network is busy.

    error_dev_not_exist* =               55.WinError
      ## The specified network resource or device is no longer available.

    error_too_many_cmds* =               56.WinError
      ## The network BIOS command limit has been reached.

    error_adap_hdw_err* =                57.WinError
      ## A network adapter hardware error occurred.

    error_bad_net_resp* =                58.WinError
      ## The specified server cannot perform the requested operation.

    error_unexp_net_err* =               59.WinError
      ## An unexpected network error occurred.

    error_bad_rem_adap* =                60.WinError
      ## The remote adapter is not compatible.

    error_printq_full* =                 61.WinError
      ## The printer queue is full.

    error_no_spool_space* =              62.WinError
      ## Space to store the file waiting to be printed is not available on the server.

    error_print_cancelled* =             63.WinError
      ## Your file waiting to be printed was deleted.

    error_netname_deleted* =             64.WinError
      ## The specified network name is no longer available.

    error_network_access_denied* =       65.WinError
      ## Network access is denied.

    error_bad_dev_type* =                66.WinError
      ## The network resource type is not correct.

    error_bad_net_name* =                67.WinError
      ## The network name cannot be found.

    error_too_many_names* =              68.WinError
      ## The name limit for the local computer network adapter card was exceeded.

    error_too_many_sess* =               69.WinError
      ## The network BIOS session limit was exceeded.

    error_sharing_paused* =              70.WinError
      ## The remote server has been paused or is in the process of being started.

    error_req_not_accep* =               71.WinError
      ## No more connections can be made to this remote computer at this time because there are already as many connections as the computer can accept.

    error_redir_paused* =                72.WinError
      ## The specified printer or disk device has been paused.

    error_file_exists* =                 80.WinError
      ## The file exists.

    error_cannot_make* =                 82.WinError
      ## The directory or file cannot be created.

    error_fail_i24* =                    83.WinError
      ## Fail on INT 24.

    error_out_of_structures* =           84.WinError
      ## Storage to process this request is not available.

    error_already_assigned* =            85.WinError
      ## The local device name is already in use.

    error_invalid_password* =            86.WinError
      ## The specified network password is not correct.

    error_invalid_parameter* =           87.WinError
      ## The parameter is incorrect.

    error_net_write_fault* =             88.WinError
      ## A write fault occurred on the network.

    error_no_proc_slots* =               89.WinError
      ## The system cannot start another process at this time.

    error_too_many_semaphores* =         100.WinError
      ## Cannot create another system semaphore.

    error_excl_sem_already_owned* =      101.WinError
      ## The exclusive semaphore is owned by another process.

    error_sem_is_set* =                  102.WinError
      ## The semaphore is set and cannot be closed.

    error_too_many_sem_requests* =       103.WinError
      ## The semaphore cannot be set again.

    error_invalid_at_interrupt_time* =   104.WinError
      ## Cannot request exclusive semaphores at interrupt time.

    error_sem_owner_died* =              105.WinError
      ## The previous ownership of this semaphore has ended.

    error_sem_user_limit* =              106.WinError
      ## Insert the diskette for drive %1.

    error_disk_change* =                 107.WinError
      ## The program stopped because an alternate diskette was not inserted.

    error_drive_locked* =                108.WinError
      ## The disk is in use or locked by another process.

    error_broken_pipe* =                 109.WinError
      ## The pipe has been ended.

    error_open_failed* =                 110.WinError
      ## The system cannot open the device or file specified.

    error_buffer_overflow* =             111.WinError
      ## The file name is too long.

    error_disk_full* =                   112.WinError
      ## There is not enough space on the disk.

    error_no_more_search_handles* =      113.WinError
      ## No more internal file identifiers available.

    error_invalid_target_handle* =       114.WinError
      ## The target internal file identifier is incorrect.

    error_invalid_category* =            117.WinError
      ## The IOCTL call made by the application program is not correct.

    error_invalid_verify_switch* =       118.WinError
      ## The verify-on-write switch parameter value is not correct.

    error_bad_driver_level* =            119.WinError
      ## The system does not support the command requested.

    error_call_not_implemented* =        120.WinError
      ## This function is not supported on this system.

    error_sem_timeout* =                 121.WinError
      ## The semaphore timeout period has expired.

    error_insufficient_buffer* =         122.WinError
      ## The data area passed to a system call is too small.

    error_invalid_name* =                123.WinError
      ## The filename, directory name, or volume label syntax is incorrect.

    error_invalid_level* =               124.WinError
      ## The system call level is not correct.

    error_no_volume_label* =             125.WinError
      ## The disk has no volume label.

    error_mod_not_found* =               126.WinError
      ## The specified module could not be found.

    error_proc_not_found* =              127.WinError
      ## The specified procedure could not be found.

    error_wait_no_children* =            128.WinError
      ## There are no child processes to wait for.

    error_child_not_complete* =          129.WinError
      ## The %1 application cannot be run in Win32 mode.

    error_direct_access_handle* =        130.WinError
      ## Attempt to use a file handle to an open disk partition for an operation other than raw disk I/O.

    error_negative_seek* =               131.WinError
      ## An attempt was made to move the file pointer before the beginning of the file.

    error_seek_on_device* =              132.WinError
      ## The file pointer cannot be set on the specified device or file.

    error_is_join_target* =              133.WinError
      ## A JOIN or SUBST command cannot be used for a drive that contains previously joined drives.

    error_is_joined* =                   134.WinError
      ## An attempt was made to use a JOIN or SUBST command on a drive that has already been joined.

    error_is_substed* =                  135.WinError
      ## An attempt was made to use a JOIN or SUBST command on a drive that has already been substituted.

    error_not_joined* =                  136.WinError
      ## The system tried to delete the JOIN of a drive that is not joined.

    error_not_substed* =                 137.WinError
      ## The system tried to delete the substitution of a drive that is not substituted.

    error_join_to_join* =                138.WinError
      ## The system tried to join a drive to a directory on a joined drive.

    error_subst_to_subst* =              139.WinError
      ## The system tried to substitute a drive to a directory on a substituted drive.

    error_join_to_subst* =               140.WinError
      ## The system tried to join a drive to a directory on a substituted drive.

    error_subst_to_join* =               141.WinError
      ## The system tried to SUBST a drive to a directory on a joined drive.

    error_busy_drive* =                  142.WinError
      ## The system cannot perform a JOIN or SUBST at this time.

    error_same_drive* =                  143.WinError
      ## The system cannot join or substitute a drive to or for a directory on the same drive.

    error_dir_not_root* =                144.WinError
      ## The directory is not a subdirectory of the root directory.

    error_dir_not_empty* =               145.WinError
      ## The directory is not empty.

    error_is_subst_path* =               146.WinError
      ## The path specified is being used in a substitute.

    error_is_join_path* =                147.WinError
      ## Not enough resources are available to process this command.

    error_path_busy* =                   148.WinError
      ## The path specified cannot be used at this time.

    error_is_subst_target* =             149.WinError
      ## An attempt was made to join or substitute a drive for which a directory on the drive is the target of a previous substitute.

    error_system_trace* =                150.WinError
      ## System trace information was not specified in your CONFIG.SYS file, or tracing is disallowed.

    error_invalid_event_count* =         151.WinError
      ## The number of specified semaphore events for DosMuxSemWait is not correct.

    error_too_many_muxwaiters* =         152.WinError
      ## DosMuxSemWait did not execute; too many semaphores are already set.

    error_invalid_list_format* =         153.WinError
      ## The DosMuxSemWait list is not correct.

    error_label_too_long* =              154.WinError
      ## The volume label you entered exceeds the label character limit of the target file system.

    error_too_many_tcbs* =               155.WinError
      ## Cannot create another thread.

    error_signal_refused* =              156.WinError
      ## The recipient process has refused the signal.

    error_discarded* =                   157.WinError
      ## The segment is already discarded and cannot be locked.

    error_not_locked* =                  158.WinError
      ## The segment is already unlocked.

    error_bad_threadid_addr* =           159.WinError
      ## The address for the thread ID is not correct.

    error_bad_arguments* =               160.WinError
      ## One or more arguments are not correct.

    error_bad_pathname* =                161.WinError
      ## The specified path is invalid.

    error_signal_pending* =              162.WinError
      ## A signal is already pending.

    error_max_thrds_reached* =           164.WinError
      ## No more threads can be created in the system.

    error_lock_failed* =                 167.WinError
      ## Unable to lock a region of a file.

    error_busy* =                        170.WinError
      ## The requested resource is in use.

    error_device_support_in_progress* =  171.WinError
      ## Device's command support detection is in progress.

    error_cancel_violation* =            173.WinError
      ## A lock request was not outstanding for the supplied cancel region.

    error_atomic_locks_not_supported* =  174.WinError
      ## The file system does not support atomic changes to the lock type.

    error_invalid_segment_number* =      180.WinError
      ## The system detected a segment number that was not correct.

    error_invalid_ordinal* =             182.WinError
      ## The operating system cannot run %1.

    error_already_exists* =              183.WinError
      ## Cannot create a file when that file already exists.

    error_invalid_flag_number* =         186.WinError
      ## The flag passed is not correct.

    error_sem_not_found* =               187.WinError
      ## The specified system semaphore name was not found.

    error_invalid_starting_codeseg* =    188.WinError
      ## The operating system cannot run %1.

    error_invalid_stackseg* =            189.WinError
      ## The operating system cannot run %1.

    error_invalid_moduletype* =          190.WinError
      ## The operating system cannot run %1.

    error_invalid_exe_signature* =       191.WinError
      ## Cannot run %1 in Win32 mode.

    error_exe_marked_invalid* =          192.WinError
      ## The operating system cannot run %1.

    error_bad_exe_format* =              193.WinError
      ## %1 is not a valid Win32 application.

    error_iterated_data_exceeds_64k* =   194.WinError
      ## The operating system cannot run %1.

    error_invalid_minallocsize* =        195.WinError
      ## The operating system cannot run %1.

    error_dynlink_from_invalid_ring* =   196.WinError
      ## The operating system cannot run this application program.

    error_iopl_not_enabled* =            197.WinError
      ## The operating system is not presently configured to run this application.

    error_invalid_segdpl* =              198.WinError
      ## The operating system cannot run %1.

    error_autodataseg_exceeds_64k* =     199.WinError
      ## The operating system cannot run this application program.

    error_ring2seg_must_be_movable* =    200.WinError
      ## The code segment cannot be greater than or equal to 64K.

    error_reloc_chain_xeeds_seglim* =    201.WinError
      ## The operating system cannot run %1.

    error_infloop_in_reloc_chain* =      202.WinError
      ## The operating system cannot run %1.

    error_envvar_not_found* =            203.WinError
      ## The system could not find the environment option that was entered.

    error_no_signal_sent* =              205.WinError
      ## No process in the command subtree has a signal handler.

    error_filename_exced_range* =        206.WinError
      ## The filename or extension is too long.

    error_ring2_stack_in_use* =          207.WinError
      ## The ring 2 stack is in use.

    error_meta_expansion_too_long* =     208.WinError
      ## The global filename characters, * or ?, are entered incorrectly or too many global filename characters are specified.

    error_invalid_signal_number* =       209.WinError
      ## The signal being posted is not correct.

    error_thread_1_inactive* =           210.WinError
      ## The signal handler cannot be set.

    error_locked* =                      212.WinError
      ## The segment is locked and cannot be reallocated.

    error_too_many_modules* =            214.WinError
      ## Too many dynamic-link modules are attached to this program or dynamic-link module.

    error_nesting_not_allowed* =         215.WinError
      ## Cannot nest calls to LoadModule.

    error_exe_machine_type_mismatch* =   216.WinError
      ## This version of %1 is not compatible with the version of Windows you're running. Check your computer's system information and then contact the software publisher.

    error_exe_cannot_modify_signed_binary* =  217.WinError
      ## The image file %1 is signed, unable to modify.

    error_exe_cannot_modify_strong_signed_binary* =  218.WinError
      ## The image file %1 is strong signed, unable to modify.

    error_file_checked_out* =            220.WinError
      ## This file is checked out or locked for editing by another user.

    error_checkout_required* =           221.WinError
      ## The file must be checked out before saving changes.

    error_bad_file_type* =               222.WinError
      ## The file type being saved or retrieved has been blocked.

    error_file_too_large* =              223.WinError
      ## The file size exceeds the limit allowed and cannot be saved.

    error_forms_auth_required* =         224.WinError
      ## Access Denied. Before opening files in this location, you must first add the web site to your trusted sites list, browse to the web site, and select the option to login automatically.

    error_virus_infected* =              225.WinError
      ## Operation did not complete successfully because the file contains a virus or potentially unwanted software.

    error_virus_deleted* =               226.WinError
      ## This file contains a virus or potentially unwanted software and cannot be opened. Due to the nature of this virus or potentially unwanted software, the file has been removed from this location.

    error_pipe_local* =                  229.WinError
      ## The pipe is local.

    error_bad_pipe* =                    230.WinError
      ## The pipe state is invalid.

    error_pipe_busy* =                   231.WinError
      ## All pipe instances are busy.

    error_no_data* =                     232.WinError
      ## The pipe is being closed.

    error_pipe_not_connected* =          233.WinError
      ## No process is on the other end of the pipe.

    error_more_data* =                   234.WinError
      ## More data is available.

    error_no_work_done* =                235.WinError
      ## The action requested resulted in no work being done. Error-style clean-up has been performed.

    error_vc_disconnected* =             240.WinError
      ## The session was canceled.

    error_invalid_ea_name* =             254.WinError
      ## The specified extended attribute name was invalid.

    error_ea_list_inconsistent* =        255.WinError
      ## The extended attributes are inconsistent.

    wait_timeout* =                      258.WinError
      ## The wait operation timed out.

    error_no_more_items* =               259.WinError
      ## No more data is available.

    error_cannot_copy* =                 266.WinError
      ## The copy functions cannot be used.

    error_directory* =                   267.WinError
      ## The directory name is invalid.

    error_eas_didnt_fit* =               275.WinError
      ## The extended attributes did not fit in the buffer.

    error_ea_file_corrupt* =             276.WinError
      ## The extended attribute file on the mounted file system is corrupt.

    error_ea_table_full* =               277.WinError
      ## The extended attribute table file is full.

    error_invalid_ea_handle* =           278.WinError
      ## The specified extended attribute handle is invalid.

    error_eas_not_supported* =           282.WinError
      ## The mounted file system does not support extended attributes.

    error_not_owner* =                   288.WinError
      ## Attempt to release mutex not owned by caller.

    error_too_many_posts* =              298.WinError
      ## Too many posts were made to a semaphore.

    error_partial_copy* =                299.WinError
      ## Only part of a ReadProcessMemory or WriteProcessMemory request was completed.

    error_oplock_not_granted* =          300.WinError
      ## The oplock request is denied.

    error_invalid_oplock_protocol* =     301.WinError
      ## An invalid oplock acknowledgment was received by the system.

    error_disk_too_fragmented* =         302.WinError
      ## The volume is too fragmented to complete this operation.

    error_delete_pending* =              303.WinError
      ## The file cannot be opened because it is in the process of being deleted.

    error_incompatible_with_global_short_name_registry_setting* =  304.WinError
      ## Short name settings may not be changed on this volume due to the global registry setting.

    error_short_names_not_enabled_on_volume* =  305.WinError
      ## Short names are not enabled on this volume.

    error_security_stream_is_inconsistent* =  306.WinError
      ## The security stream for the given volume is in an inconsistent state.
      ## Please run CHKDSK on the volume.

    error_invalid_lock_range* =          307.WinError
      ## A requested file lock operation cannot be processed due to an invalid byte range.

    error_image_subsystem_not_present* =  308.WinError
      ## The subsystem needed to support the image type is not present.

    error_notification_guid_already_defined* =  309.WinError
      ## The specified file already has a notification GUID associated with it.

    error_invalid_exception_handler* =   310.WinError
      ## An invalid exception handler routine has been detected.

    error_duplicate_privileges* =        311.WinError
      ## Duplicate privileges were specified for the token.

    error_no_ranges_processed* =         312.WinError
      ## No ranges for the specified operation were able to be processed.

    error_not_allowed_on_system_file* =  313.WinError
      ## Operation is not allowed on a file system internal file.

    error_disk_resources_exhausted* =    314.WinError
      ## The physical resources of this disk have been exhausted.

    error_invalid_token* =               315.WinError
      ## The token representing the data is invalid.

    error_device_feature_not_supported* =  316.WinError
      ## The device does not support the command feature.

    error_mr_mid_not_found* =            317.WinError
      ## The system cannot find message text for message number 0x%1 in the message file for %2.

    error_scope_not_found* =             318.WinError
      ## The scope specified was not found.

    error_undefined_scope* =             319.WinError
      ## The Central Access Policy specified is not defined on the target machine.

    error_invalid_cap* =                 320.WinError
      ## The Central Access Policy obtained from Active Directory is invalid.

    error_device_unreachable* =          321.WinError
      ## The device is unreachable.

    error_device_no_resources* =         322.WinError
      ## The target device has insufficient resources to complete the operation.

    error_data_checksum_error* =         323.WinError
      ## A data integrity checksum error occurred. Data in the file stream is corrupt.

    error_intermixed_kernel_ea_operation* =  324.WinError
      ## An attempt was made to modify both a KERNEL and normal Extended Attribute (EA) in the same operation.

    error_file_level_trim_not_supported* =  326.WinError
      ## Device does not support file-level TRIM.

    error_offset_alignment_violation* =  327.WinError
      ## The command specified a data offset that does not align to the device's granularity/alignment.

    error_invalid_field_in_parameter_list* =  328.WinError
      ## The command specified an invalid field in its parameter list.

    error_operation_in_progress* =       329.WinError
      ## An operation is currently in progress with the device.

    error_bad_device_path* =             330.WinError
      ## An attempt was made to send down the command via an invalid path to the target device.

    error_too_many_descriptors* =        331.WinError
      ## The command specified a number of descriptors that exceeded the maximum supported by the device.

    error_scrub_data_disabled* =         332.WinError
      ## Scrub is disabled on the specified file.

    error_not_redundant_storage* =       333.WinError
      ## The storage device does not provide redundancy.

    error_resident_file_not_supported* =  334.WinError
      ## An operation is not supported on a resident file.

    error_compressed_file_not_supported* =  335.WinError
      ## An operation is not supported on a compressed file.

    error_directory_not_supported* =     336.WinError
      ## An operation is not supported on a directory.

    error_not_read_from_copy* =          337.WinError
      ## The specified copy of the requested data could not be read.

    error_ft_write_failure* =            338.WinError
      ## The specified data could not be written to any of the copies.

    error_ft_di_scan_required* =         339.WinError
      ## One or more copies of data on this device may be out of sync. No writes may be performed until a data integrity scan is completed.

    error_invalid_kernel_info_version* =  340.WinError
      ## The supplied kernel information version is invalid.

    error_invalid_pep_info_version* =    341.WinError
      ## The supplied PEP information version is invalid.

    error_object_not_externally_backed* =  342.WinError
      ## This object is not externally backed by any provider.

    error_external_backing_provider_unknown* =  343.WinError
      ## The external backing provider is not recognized.

    error_compression_not_beneficial* =  344.WinError
      ## Compressing this object would not save space.

    error_storage_topology_id_mismatch* =  345.WinError
      ## The request failed due to a storage topology ID mismatch.

    error_blocked_by_parental_controls* =  346.WinError
      ## The operation was blocked by parental controls.

    error_block_too_many_references* =   347.WinError
      ## A file system block being referenced has already reached the maximum reference count and can't be referenced any further.

    error_marked_to_disallow_writes* =   348.WinError
      ## The requested operation failed because the file stream is marked to disallow writes.

    error_enclave_failure* =             349.WinError
      ## The requested operation failed with an architecture-specific failure code.

    error_fail_noaction_reboot* =        350.WinError
      ## No action was taken as a system reboot is required.

    error_fail_shutdown* =               351.WinError
      ## The shutdown operation failed.

    error_fail_restart* =                352.WinError
      ## The restart operation failed.

    error_max_sessions_reached* =        353.WinError
      ## The maximum number of sessions has been reached.

    error_network_access_denied_edp* =   354.WinError
      ## Enterprise Data Protection policy does not allow access to this network resource.

    error_device_hint_name_buffer_too_small* =  355.WinError
      ## The device hint name buffer is too small to receive the remaining name.

    error_edp_policy_denies_operation* =  356.WinError
      ## The requested operation was blocked by Enterprise Data Protection policy. For more information, contact your system administrator.

    error_edp_dpl_policy_cant_be_satisfied* =  357.WinError
      ## The requested operation cannot be performed because hardware or software configuration of the device does not comply with Enterprise Data Protection under Lock policy. Please, verify that user PIN has been created. For more information, contact your system administrator.

    error_cloud_file_provider_unknown* =  358.WinError
      ## The Cloud File provider is unknown.

    error_device_in_maintenance* =       359.WinError
      ## The device is in maintenance mode.

    error_not_supported_on_dax* =        360.WinError
      ## This operation is not supported on a DAX volume.

    error_dax_mapping_exists* =          361.WinError
      ## The volume has active DAX mappings.

    error_cloud_file_provider_not_running* =  362.WinError
      ## The Cloud File provider is not running.

    error_cloud_file_metadata_corrupt* =  363.WinError
      ## The Cloud File metadata is corrupt and unreadable.

    error_cloud_file_metadata_too_large* =  364.WinError
      ## The operation could not be completed because the Cloud File metadata has is too large.

    error_cloud_file_property_blob_too_large* =  365.WinError
      ## The operation could not be completed because the Cloud File property blob is too large.

    error_cloud_file_property_blob_checksum_mismatch* =  366.WinError
      ## The Cloud File property blob is possibly corrupt. The on-disk checksum does not match the computed checksum.

    error_child_process_blocked* =       367.WinError
      ## The process creation has been blocked.

    error_storage_lost_data_persistence* =  368.WinError
      ## The storage device has lost data or persistence.

    #
    # **** Available SYSTEM error codes ****
    #
    error_thread_mode_already_background* =  400.WinError
      ## The thread is already in background processing mode.

    error_thread_mode_not_background* =  401.WinError
      ## The thread is not in background processing mode.

    error_process_mode_already_background* =  402.WinError
      ## The process is already in background processing mode.

    error_process_mode_not_background* =  403.WinError
      ## The process is not in background processing mode.

    #
    # **** Available SYSTEM error codes ****
    #

    ##################################################
    #                                               ##
    #    Capability Authorization Error codes       ##
    #                                               ##
    #                 0450 to 0460                  ##
    ##################################################

    error_capauthz_not_devunlocked* =    450.WinError
      ## Neither developer unlocked mode nor side loading mode is enabled on the device.

    error_capauthz_change_type* =        451.WinError
      ## Can not change application type during upgrade or re-provision.

    error_capauthz_not_provisioned* =    452.WinError
      ## The application has not been provisioned.

    error_capauthz_not_authorized* =     453.WinError
      ## The requested capability can not be authorized for this application.

    error_capauthz_no_policy* =          454.WinError
      ## There is no capability authorization policy on the device.

    error_capauthz_db_corrupted* =       455.WinError
      ## The capability authorization database has been corrupted.

    #
    # **** Available SYSTEM error codes ****
    #
    error_device_hardware_error* =       483.WinError
      ## The request failed due to a fatal device hardware error.

    error_invalid_address* =             487.WinError
      ## Attempt to access invalid address.

    #
    # **** Available SYSTEM error codes ****
    #
    error_user_profile_load* =           500.WinError
      ## User profile cannot be loaded.

    #
    # **** Available SYSTEM error codes ****
    #
    error_arithmetic_overflow* =         534.WinError
      ## Arithmetic result exceeded 32 bits.

    error_pipe_connected* =              535.WinError
      ## There is a process on other end of the pipe.

    error_pipe_listening* =              536.WinError
      ## Waiting for a process to open the other end of the pipe.

    error_verifier_stop* =               537.WinError
      ## Application verifier has found an error in the current process.

    error_abios_error* =                 538.WinError
      ## An error occurred in the ABIOS subsystem.

    error_wx86_warning* =                539.WinError
      ## A warning occurred in the WX86 subsystem.

    error_wx86_error* =                  540.WinError
      ## An error occurred in the WX86 subsystem.

    error_timer_not_canceled* =          541.WinError
      ## An attempt was made to cancel or set a timer that has an associated APC and the subject thread is not the thread that originally set the timer with an associated APC routine.

    error_unwind* =                      542.WinError
      ## Unwind exception code.

    error_bad_stack* =                   543.WinError
      ## An invalid or unaligned stack was encountered during an unwind operation.

    error_invalid_unwind_target* =       544.WinError
      ## An invalid unwind target was encountered during an unwind operation.

    error_invalid_port_attributes* =     545.WinError
      ## Invalid Object Attributes specified to NtCreatePort or invalid Port Attributes specified to NtConnectPort

    error_port_message_too_long* =       546.WinError
      ## Length of message passed to NtRequestPort or NtRequestWaitReplyPort was longer than the maximum message allowed by the port.

    error_invalid_quota_lower* =         547.WinError
      ## An attempt was made to lower a quota limit below the current usage.

    error_device_already_attached* =     548.WinError
      ## An attempt was made to attach to a device that was already attached to another device.

    error_instruction_misalignment* =    549.WinError
      ## An attempt was made to execute an instruction at an unaligned address and the host system does not support unaligned instruction references.

    error_profiling_not_started* =       550.WinError
      ## Profiling not started.

    error_profiling_not_stopped* =       551.WinError
      ## Profiling not stopped.

    error_could_not_interpret* =         552.WinError
      ## The passed ACL did not contain the minimum required information.

    error_profiling_at_limit* =          553.WinError
      ## The number of active profiling objects is at the maximum and no more may be started.

    error_cant_wait* =                   554.WinError
      ## Used to indicate that an operation cannot continue without blocking for I/O.

    error_cant_terminate_self* =         555.WinError
      ## Indicates that a thread attempted to terminate itself by default (called NtTerminateThread with NULL) and it was the last thread in the current process.

    error_unexpected_mm_create_err* =    556.WinError
      ## If an MM error is returned which is not defined in the standard FsRtl filter, it is converted to one of the following errors which is guaranteed to be in the filter.
      ## In this case information is lost, however, the filter correctly handles the exception.

    error_unexpected_mm_map_error* =     557.WinError
      ## If an MM error is returned which is not defined in the standard FsRtl filter, it is converted to one of the following errors which is guaranteed to be in the filter.
      ## In this case information is lost, however, the filter correctly handles the exception.

    error_unexpected_mm_extend_err* =    558.WinError
      ## If an MM error is returned which is not defined in the standard FsRtl filter, it is converted to one of the following errors which is guaranteed to be in the filter.
      ## In this case information is lost, however, the filter correctly handles the exception.

    error_bad_function_table* =          559.WinError
      ## A malformed function table was encountered during an unwind operation.

    error_no_guid_translation* =         560.WinError
      ## Indicates that an attempt was made to assign protection to a file system file or directory and one of the SIDs in the security descriptor could not be translated into a GUID that could be stored by the file system.
      ## This causes the protection attempt to fail, which may cause a file creation attempt to fail.

    error_invalid_ldt_size* =            561.WinError
      ## Indicates that an attempt was made to grow an LDT by setting its size, or that the size was not an even number of selectors.

    error_invalid_ldt_offset* =          563.WinError
      ## Indicates that the starting value for the LDT information was not an integral multiple of the selector size.

    error_invalid_ldt_descriptor* =      564.WinError
      ## Indicates that the user supplied an invalid descriptor when trying to set up Ldt descriptors.

    error_too_many_threads* =            565.WinError
      ## Indicates a process has too many threads to perform the requested action. For example, assignment of a primary token may only be performed when a process has zero or one threads.

    error_thread_not_in_process* =       566.WinError
      ## An attempt was made to operate on a thread within a specific process, but the thread specified is not in the process specified.

    error_pagefile_quota_exceeded* =     567.WinError
      ## Page file quota was exceeded.

    error_logon_server_conflict* =       568.WinError
      ## The Netlogon service cannot start because another Netlogon service running in the domain conflicts with the specified role.

    error_synchronization_required* =    569.WinError
      ## The SAM database on a Windows Server is significantly out of synchronization with the copy on the Domain Controller. A complete synchronization is required.

    error_net_open_failed* =             570.WinError
      ## The NtCreateFile API failed. This error should never be returned to an application, it is a place holder for the Windows Lan Manager Redirector to use in its internal error mapping routines.

    error_io_privilege_failed* =         571.WinError
      ## {Privilege Failed}
      ## The I/O permissions for the process could not be changed.

    error_control_c_exit* =              572.WinError
      ## {Application Exit by CTRL+C}
      ## The application terminated as a result of a CTRL+C.    ## winnt

    error_missing_systemfile* =          573.WinError
      ## {Missing System File}
      ## The required system file %hs is bad or missing.

    error_unhandled_exception* =         574.WinError
      ## {Application Error}
      ## The exception %s (0x%08lx) occurred in the application at location 0x%08lx.

    error_app_init_failure* =            575.WinError
      ## {Application Error}
      ## The application was unable to start correctly (0x%lx). Click OK to close the application.

    error_pagefile_create_failed* =      576.WinError
      ## {Unable to Create Paging File}
      ## The creation of the paging file %hs failed (%lx). The requested size was %ld.

    error_invalid_image_hash* =          577.WinError
      ## Windows cannot verify the digital signature for this file. A recent hardware or software change might have installed a file that is signed incorrectly or damaged, or that might be malicious software from an unknown source.

    error_no_pagefile* =                 578.WinError
      ## {No Paging File Specified}
      ## No paging file was specified in the system configuration.

    error_illegal_float_context* =       579.WinError
      ## {EXCEPTION}
      ## A real-mode application issued a floating-point instruction and floating-point hardware is not present.

    error_no_event_pair* =               580.WinError
      ## An event pair synchronization operation was performed using the thread specific client/server event pair object, but no event pair object was associated with the thread.

    error_domain_ctrlr_config_error* =   581.WinError
      ## A Windows Server has an incorrect configuration.

    error_illegal_character* =           582.WinError
      ## An illegal character was encountered. For a multi-byte character set this includes a lead byte without a succeeding trail byte. For the Unicode character set this includes the characters 0xFFFF and 0xFFFE.

    error_undefined_character* =         583.WinError
      ## The Unicode character is not defined in the Unicode character set installed on the system.

    error_floppy_volume* =               584.WinError
      ## The paging file cannot be created on a floppy diskette.

    error_bios_failed_to_connect_interrupt* =  585.WinError
      ## The system BIOS failed to connect a system interrupt to the device or bus for which the device is connected.

    error_backup_controller* =           586.WinError
      ## This operation is only allowed for the Primary Domain Controller of the domain.

    error_mutant_limit_exceeded* =       587.WinError
      ## An attempt was made to acquire a mutant such that its maximum count would have been exceeded.

    error_fs_driver_required* =          588.WinError
      ## A volume has been accessed for which a file system driver is required that has not yet been loaded.

    error_cannot_load_registry_file* =   589.WinError
      ## {Registry File Failure}
      ## The registry cannot load the hive (file):
      ## %hs
      ## or its log or alternate.
      ## It is corrupt, absent, or not writable.

    error_debug_attach_failed* =         590.WinError
      ## {Unexpected Failure in DebugActiveProcess}
      ## An unexpected failure occurred while processing a DebugActiveProcess API request. You may choose OK to terminate the process, or Cancel to ignore the error.

    error_system_process_terminated* =   591.WinError
      ## {Fatal System Error}
      ## The %hs system process terminated unexpectedly with a status of 0x%08x (0x%08x 0x%08x).
      ## The system has been shut down.

    error_data_not_accepted* =           592.WinError
      ## {Data Not Accepted}
      ## The TDI client could not handle the data received during an indication.

    error_vdm_hard_error* =              593.WinError
      ## NTVDM encountered a hard error.

    error_driver_cancel_timeout* =       594.WinError
      ## {Cancel Timeout}
      ## The driver %hs failed to complete a cancelled I/O request in the allotted time.

    error_reply_message_mismatch* =      595.WinError
      ## {Reply Message Mismatch}
      ## An attempt was made to reply to an LPC message, but the thread specified by the client ID in the message was not waiting on that message.

    error_lost_writebehind_data* =       596.WinError
      ## {Delayed Write Failed}
      ## Windows was unable to save all the data for the file %hs. The data has been lost.
      ## This error may be caused by a failure of your computer hardware or network connection. Please try to save this file elsewhere.

    error_client_server_parameters_invalid* =  597.WinError
      ## The parameter(s) passed to the server in the client/server shared memory window were invalid. Too much data may have been put in the shared memory window.

    error_not_tiny_stream* =             598.WinError
      ## The stream is not a tiny stream.

    error_stack_overflow_read* =         599.WinError
      ## The request must be handled by the stack overflow code.

    error_convert_to_large* =            600.WinError
      ## Internal OFS status codes indicating how an allocation operation is handled. Either it is retried after the containing onode is moved or the extent stream is converted to a large stream.

    error_found_out_of_scope* =          601.WinError
      ## The attempt to find the object found an object matching by ID on the volume but it is out of the scope of the handle used for the operation.

    error_allocate_bucket* =             602.WinError
      ## The bucket array must be grown. Retry transaction after doing so.

    error_marshall_overflow* =           603.WinError
      ## The user/kernel marshalling buffer has overflowed.

    error_invalid_variant* =             604.WinError
      ## The supplied variant structure contains invalid data.

    error_bad_compression_buffer* =      605.WinError
      ## The specified buffer contains ill-formed data.

    error_audit_failed* =                606.WinError
      ## {Audit Failed}
      ## An attempt to generate a security audit failed.

    error_timer_resolution_not_set* =    607.WinError
      ## The timer resolution was not previously set by the current process.

    error_insufficient_logon_info* =     608.WinError
      ## There is insufficient account information to log you on.

    error_bad_dll_entrypoint* =          609.WinError
      ## {Invalid DLL Entrypoint}
      ## The dynamic link library %hs is not written correctly. The stack pointer has been left in an inconsistent state.
      ## The entrypoint should be declared as WINAPI or STDCALL. Select YES to fail the DLL load. Select NO to continue execution. Selecting NO may cause the application to operate incorrectly.

    error_bad_service_entrypoint* =      610.WinError
      ## {Invalid Service Callback Entrypoint}
      ## The %hs service is not written correctly. The stack pointer has been left in an inconsistent state.
      ## The callback entrypoint should be declared as WINAPI or STDCALL. Selecting OK will cause the service to continue operation. However, the service process may operate incorrectly.

    error_ip_address_conflict1* =        611.WinError
      ## There is an IP address conflict with another system on the network

    error_ip_address_conflict2* =        612.WinError
      ## There is an IP address conflict with another system on the network

    error_registry_quota_limit* =        613.WinError
      ## {Low On Registry Space}
      ## The system has reached the maximum size allowed for the system part of the registry. Additional storage requests will be ignored.

    error_no_callback_active* =          614.WinError
      ## A callback return system service cannot be executed when no callback is active.

    error_pwd_too_short* =               615.WinError
      ## The password provided is too short to meet the policy of your user account.
      ## Please choose a longer password.

    error_pwd_too_recent* =              616.WinError
      ## The policy of your user account does not allow you to change passwords too frequently.
      ## This is done to prevent users from changing back to a familiar, but potentially discovered, password.
      ## If you feel your password has been compromised then please contact your administrator immediately to have a new one assigned.

    error_pwd_history_conflict* =        617.WinError
      ## You have attempted to change your password to one that you have used in the past.
      ## The policy of your user account does not allow this. Please select a password that you have not previously used.

    error_unsupported_compression* =     618.WinError
      ## The specified compression format is unsupported.

    error_invalid_hw_profile* =          619.WinError
      ## The specified hardware profile configuration is invalid.

    error_invalid_plugplay_device_path* =  620.WinError
      ## The specified Plug and Play registry device path is invalid.

    error_quota_list_inconsistent* =     621.WinError
      ## The specified quota list is internally inconsistent with its descriptor.

    error_evaluation_expiration* =       622.WinError
      ## {Windows Evaluation Notification}
      ## The evaluation period for this installation of Windows has expired. This system will shutdown in 1 hour. To restore access to this installation of Windows, please upgrade this installation using a licensed distribution of this product.

    error_illegal_dll_relocation* =      623.WinError
      ## {Illegal System DLL Relocation}
      ## The system DLL %hs was relocated in memory. The application will not run properly.
      ## The relocation occurred because the DLL %hs occupied an address range reserved for Windows system DLLs. The vendor supplying the DLL should be contacted for a new DLL.

    error_dll_init_failed_logoff* =      624.WinError
      ## {DLL Initialization Failed}
      ## The application failed to initialize because the window station is shutting down.

    error_validate_continue* =           625.WinError
      ## The validation process needs to continue on to the next step.

    error_no_more_matches* =             626.WinError
      ## There are no more matches for the current index enumeration.

    error_range_list_conflict* =         627.WinError
      ## The range could not be added to the range list because of a conflict.

    error_server_sid_mismatch* =         628.WinError
      ## The server process is running under a SID different than that required by client.

    error_cant_enable_deny_only* =       629.WinError
      ## A group marked use for deny only cannot be enabled.

    error_float_multiple_faults* =       630.WinError
      ## {EXCEPTION}
      ## Multiple floating point faults.    ## winnt

    error_float_multiple_traps* =        631.WinError
      ## {EXCEPTION}
      ## Multiple floating point traps.    ## winnt

    error_nointerface* =                 632.WinError
      ## The requested interface is not supported.

    error_driver_failed_sleep* =         633.WinError
      ## {System Standby Failed}
      ## The driver %hs does not support standby mode. Updating this driver may allow the system to go to standby mode.

    error_corrupt_system_file* =         634.WinError
      ## The system file %1 has become corrupt and has been replaced.

    error_commitment_minimum* =          635.WinError
      ## {Virtual Memory Minimum Too Low}
      ## Your system is low on virtual memory. Windows is increasing the size of your virtual memory paging file.
      ## During this process, memory requests for some applications may be denied. For more information, see Help.

    error_pnp_restart_enumeration* =     636.WinError
      ## A device was removed so enumeration must be restarted.

    error_system_image_bad_signature* =  637.WinError
      ## {Fatal System Error}
      ## The system image %s is not properly signed.
      ## The file has been replaced with the signed file.
      ## The system has been shut down.

    error_pnp_reboot_required* =         638.WinError
      ## Device will not start without a reboot.

    error_insufficient_power* =          639.WinError
      ## There is not enough power to complete the requested operation.

    error_multiple_fault_violation* =    640.WinError
      ##  ERROR_MULTIPLE_FAULT_VIOLATION

    error_system_shutdown* =             641.WinError
      ## The system is in the process of shutting down.

    error_port_not_set* =                642.WinError
      ## An attempt to remove a processes DebugPort was made, but a port was not already associated with the process.

    error_ds_version_check_failure* =    643.WinError
      ## This version of Windows is not compatible with the behavior version of directory forest, domain or domain controller.

    error_range_not_found* =             644.WinError
      ## The specified range could not be found in the range list.

    error_not_safe_mode_driver* =        646.WinError
      ## The driver was not loaded because the system is booting into safe mode.

    error_failed_driver_entry* =         647.WinError
      ## The driver was not loaded because it failed its initialization call.

    error_device_enumeration_error* =    648.WinError
      ## The "%hs" encountered an error while applying power or reading the device configuration.
      ## This may be caused by a failure of your hardware or by a poor connection.

    error_mount_point_not_resolved* =    649.WinError
      ## The create operation failed because the name contained at least one mount point which resolves to a volume to which the specified device object is not attached.

    error_invalid_device_object_parameter* =  650.WinError
      ## The device object parameter is either not a valid device object or is not attached to the volume specified by the file name.

    error_mca_occured* =                 651.WinError
      ## A Machine Check Error has occurred. Please check the system eventlog for additional information.

    error_driver_database_error* =       652.WinError
      ## There was error [%2] processing the driver database.

    error_system_hive_too_large* =       653.WinError
      ## System hive size has exceeded its limit.

    error_driver_failed_prior_unload* =  654.WinError
      ## The driver could not be loaded because a previous version of the driver is still in memory.

    error_volsnap_prepare_hibernate* =   655.WinError
      ## {Volume Shadow Copy Service}
      ## Please wait while the Volume Shadow Copy Service prepares volume %hs for hibernation.

    error_hibernation_failure* =         656.WinError
      ## The system has failed to hibernate (The error code is %hs). Hibernation will be disabled until the system is restarted.

    error_pwd_too_long* =                657.WinError
      ## The password provided is too long to meet the policy of your user account.
      ## Please choose a shorter password.

    error_file_system_limitation* =      665.WinError
      ## The requested operation could not be completed due to a file system limitation

    error_assertion_failure* =           668.WinError
      ## An assertion failure has occurred.

    error_acpi_error* =                  669.WinError
      ## An error occurred in the ACPI subsystem.

    error_wow_assertion* =               670.WinError
      ## WOW Assertion Error.

    error_pnp_bad_mps_table* =           671.WinError
      ## A device is missing in the system BIOS MPS table. This device will not be used.
      ## Please contact your system vendor for system BIOS update.

    error_pnp_translation_failed* =      672.WinError
      ## A translator failed to translate resources.

    error_pnp_irq_translation_failed* =  673.WinError
      ## A IRQ translator failed to translate resources.

    error_pnp_invalid_id* =              674.WinError
      ## Driver %2 returned invalid ID for a child device (%3).

    error_wake_system_debugger* =        675.WinError
      ## {Kernel Debugger Awakened}
      ## the system debugger was awakened by an interrupt.

    error_handles_closed* =              676.WinError
      ## {Handles Closed}
      ## Handles to objects have been automatically closed as a result of the requested operation.

    error_extraneous_information* =      677.WinError
      ## {Too Much Information}
      ## The specified access control list (ACL) contained more information than was expected.

    error_rxact_commit_necessary* =      678.WinError
      ## This warning level status indicates that the transaction state already exists for the registry sub-tree, but that a transaction commit was previously aborted.
      ## The commit has NOT been completed, but has not been rolled back either (so it may still be committed if desired).

    error_media_check* =                 679.WinError
      ## {Media Changed}
      ## The media may have changed.

    error_guid_substitution_made* =      680.WinError
      ## {GUID Substitution}
      ## During the translation of a global identifier (GUID) to a Windows security ID (SID), no administratively-defined GUID prefix was found.
      ## A substitute prefix was used, which will not compromise system security. However, this may provide a more restrictive access than intended.

    error_stopped_on_symlink* =          681.WinError
      ## The create operation stopped after reaching a symbolic link

    error_longjump* =                    682.WinError
      ## A long jump has been executed.

    error_plugplay_query_vetoed* =       683.WinError
      ## The Plug and Play query operation was not successful.

    error_unwind_consolidate* =          684.WinError
      ## A frame consolidation has been executed.

    error_registry_hive_recovered* =     685.WinError
      ## {Registry Hive Recovered}
      ## Registry hive (file):
      ## %hs
      ## was corrupted and it has been recovered. Some data might have been lost.

    error_dll_might_be_insecure* =       686.WinError
      ## The application is attempting to run executable code from the module %hs. This may be insecure. An alternative, %hs, is available. Should the application use the secure module %hs?

    error_dll_might_be_incompatible* =   687.WinError
      ## The application is loading executable code from the module %hs. This is secure, but may be incompatible with previous releases of the operating system. An alternative, %hs, is available. Should the application use the secure module %hs?

    error_dbg_exception_not_handled* =   688.WinError
      ## Debugger did not handle the exception.    ## winnt

    error_dbg_reply_later* =             689.WinError
      ## Debugger will reply later.

    error_dbg_unable_to_provide_handle* =  690.WinError
      ## Debugger cannot provide handle.

    error_dbg_terminate_thread* =        691.WinError
      ## Debugger terminated thread.    ## winnt

    error_dbg_terminate_process* =       692.WinError
      ## Debugger terminated process.    ## winnt

    error_dbg_control_c* =               693.WinError
      ## Debugger got control C.    ## winnt

    error_dbg_printexception_c* =        694.WinError
      ## Debugger printed exception on control C.

    error_dbg_ripexception* =            695.WinError
      ## Debugger received RIP exception.

    error_dbg_control_break* =           696.WinError
      ## Debugger received control break.    ## winnt

    error_dbg_command_exception* =       697.WinError
      ## Debugger command communication exception.    ## winnt

    error_object_name_exists* =          698.WinError
      ## {Object Exists}
      ## An attempt was made to create an object and the object name already existed.

    error_thread_was_suspended* =        699.WinError
      ## {Thread Suspended}
      ## A thread termination occurred while the thread was suspended. The thread was resumed, and termination proceeded.

    error_image_not_at_base* =           700.WinError
      ## {Image Relocated}
      ## An image file could not be mapped at the address specified in the image file. Local fixups must be performed on this image.

    error_rxact_state_created* =         701.WinError
      ## This informational level status indicates that a specified registry sub-tree transaction state did not yet exist and had to be created.

    error_segment_notification* =        702.WinError
      ## {Segment Load}
      ## A virtual DOS machine (VDM) is loading, unloading, or moving an MS-DOS or Win16 program segment image.
      ## An exception is raised so a debugger can load, unload or track symbols and breakpoints within these 16-bit segments.    ## winnt

    error_bad_current_directory* =       703.WinError
      ## {Invalid Current Directory}
      ## The process cannot switch to the startup current directory %hs.
      ## Select OK to set current directory to %hs, or select CANCEL to exit.

    error_ft_read_recovery_from_backup* =  704.WinError
      ## {Redundant Read}
      ## To satisfy a read request, the NT fault-tolerant file system successfully read the requested data from a redundant copy.
      ## This was done because the file system encountered a failure on a member of the fault-tolerant volume, but was unable to reassign the failing area of the device.

    error_ft_write_recovery* =           705.WinError
      ## {Redundant Write}
      ## To satisfy a write request, the NT fault-tolerant file system successfully wrote a redundant copy of the information.
      ## This was done because the file system encountered a failure on a member of the fault-tolerant volume, but was not able to reassign the failing area of the device.

    error_image_machine_type_mismatch* =  706.WinError
      ## {Machine Type Mismatch}
      ## The image file %hs is valid, but is for a machine type other than the current machine. Select OK to continue, or CANCEL to fail the DLL load.

    error_receive_partial* =             707.WinError
      ## {Partial Data Received}
      ## The network transport returned partial data to its client. The remaining data will be sent later.

    error_receive_expedited* =           708.WinError
      ## {Expedited Data Received}
      ## The network transport returned data to its client that was marked as expedited by the remote system.

    error_receive_partial_expedited* =   709.WinError
      ## {Partial Expedited Data Received}
      ## The network transport returned partial data to its client and this data was marked as expedited by the remote system. The remaining data will be sent later.

    error_event_done* =                  710.WinError
      ## {TDI Event Done}
      ## The TDI indication has completed successfully.

    error_event_pending* =               711.WinError
      ## {TDI Event Pending}
      ## The TDI indication has entered the pending state.

    error_checking_file_system* =        712.WinError
      ## Checking file system on %wZ

    error_fatal_app_exit* =              713.WinError
      ## {Fatal Application Exit}
      ## %hs

    error_predefined_handle* =           714.WinError
      ## The specified registry key is referenced by a predefined handle.

    error_was_unlocked* =                715.WinError
      ## {Page Unlocked}
      ## The page protection of a locked page was changed to 'No Access' and the page was unlocked from memory and from the process.

    error_service_notification* =        716.WinError
      ## %hs

    error_was_locked* =                  717.WinError
      ## {Page Locked}
      ## One of the pages to lock was already locked.

    error_log_hard_error* =              718.WinError
      ## Application popup: %1 : %2

    error_already_win32* =               719.WinError
      ##  ERROR_ALREADY_WIN32

    error_image_machine_type_mismatch_exe* =  720.WinError
      ## {Machine Type Mismatch}
      ## The image file %hs is valid, but is for a machine type other than the current machine.

    error_no_yield_performed* =          721.WinError
      ## A yield execution was performed and no thread was available to run.

    error_timer_resume_ignored* =        722.WinError
      ## The resumable flag to a timer API was ignored.

    error_arbitration_unhandled* =       723.WinError
      ## The arbiter has deferred arbitration of these resources to its parent

    error_cardbus_not_supported* =       724.WinError
      ## The inserted CardBus device cannot be started because of a configuration error on "%hs".

    error_mp_processor_mismatch* =       725.WinError
      ## The CPUs in this multiprocessor system are not all the same revision level. To use all processors the operating system restricts itself to the features of the least capable processor in the system. Should problems occur with this system, contact the CPU manufacturer to see if this mix of processors is supported.

    error_hibernated* =                  726.WinError
      ## The system was put into hibernation.    

    error_resume_hibernation* =          727.WinError
      ## The system was resumed from hibernation.    

    error_firmware_updated* =            728.WinError
      ## Windows has detected that the system firmware (BIOS) was updated [previous firmware date = %2, current firmware date %3].

    error_drivers_leaking_locked_pages* =  729.WinError
      ## A device driver is leaking locked I/O pages causing system degradation. The system has automatically enabled tracking code in order to try and catch the culprit.

    error_wake_system* =                 730.WinError
      ## The system has awoken

    error_wait_1* =                      731.WinError
      ##  ERROR_WAIT_1

    error_wait_2* =                      732.WinError
      ##  ERROR_WAIT_2

    error_wait_3* =                      733.WinError
      ##  ERROR_WAIT_3

    error_wait_63* =                     734.WinError
      ##  ERROR_WAIT_63

    error_abandoned_wait_0* =            735.WinError
      ##  ERROR_ABANDONED_WAIT_0    ## winnt

    error_abandoned_wait_63* =           736.WinError
      ##  ERROR_ABANDONED_WAIT_63

    error_user_apc* =                    737.WinError
      ##  ERROR_USER_APC    ## winnt

    error_kernel_apc* =                  738.WinError
      ##  ERROR_KERNEL_APC

    error_alerted* =                     739.WinError
      ##  ERROR_ALERTED

    error_elevation_required* =          740.WinError
      ## The requested operation requires elevation.

    error_reparse* =                     741.WinError
      ## A reparse should be performed by the Object Manager since the name of the file resulted in a symbolic link.

    error_oplock_break_in_progress* =    742.WinError
      ## An open/create operation completed while an oplock break is underway.

    error_volume_mounted* =              743.WinError
      ## A new volume has been mounted by a file system.

    error_rxact_committed* =             744.WinError
      ## This success level status indicates that the transaction state already exists for the registry sub-tree, but that a transaction commit was previously aborted.
      ## The commit has now been completed.

    error_notify_cleanup* =              745.WinError
      ## This indicates that a notify change request has been completed due to closing the handle which made the notify change request.

    error_primary_transport_connect_failed* =  746.WinError
      ## {Connect Failure on Primary Transport}
      ## An attempt was made to connect to the remote server %hs on the primary transport, but the connection failed.
      ## The computer WAS able to connect on a secondary transport.

    error_page_fault_transition* =       747.WinError
      ## Page fault was a transition fault.

    error_page_fault_demand_zero* =      748.WinError
      ## Page fault was a demand zero fault.

    error_page_fault_copy_on_write* =    749.WinError
      ## Page fault was a demand zero fault.

    error_page_fault_guard_page* =       750.WinError
      ## Page fault was a demand zero fault.

    error_page_fault_paging_file* =      751.WinError
      ## Page fault was satisfied by reading from a secondary storage device.

    error_cache_page_locked* =           752.WinError
      ## Cached page was locked during operation.

    error_crash_dump* =                  753.WinError
      ## Crash dump exists in paging file.

    error_buffer_all_zeros* =            754.WinError
      ## Specified buffer contains all zeros.

    error_reparse_object* =              755.WinError
      ## A reparse should be performed by the Object Manager since the name of the file resulted in a symbolic link.

    error_resource_requirements_changed* =  756.WinError
      ## The device has succeeded a query-stop and its resource requirements have changed.

    error_translation_complete* =        757.WinError
      ## The translator has translated these resources into the global space and no further translations should be performed.

    error_nothing_to_terminate* =        758.WinError
      ## A process being terminated has no threads to terminate.

    error_process_not_in_job* =          759.WinError
      ## The specified process is not part of a job.

    error_process_in_job* =              760.WinError
      ## The specified process is part of a job.

    error_volsnap_hibernate_ready* =     761.WinError
      ## {Volume Shadow Copy Service}
      ## The system is now ready for hibernation.

    error_fsfilter_op_completed_successfully* =  762.WinError
      ## A file system or file system filter driver has successfully completed an FsFilter operation.

    error_interrupt_vector_already_connected* =  763.WinError
      ## The specified interrupt vector was already connected.

    error_interrupt_still_connected* =   764.WinError
      ## The specified interrupt vector is still connected.

    error_wait_for_oplock* =             765.WinError
      ## An operation is blocked waiting for an oplock.

    error_dbg_exception_handled* =       766.WinError
      ## Debugger handled exception    ## winnt

    error_dbg_continue* =                767.WinError
      ## Debugger continued    ## winnt

    error_callback_pop_stack* =          768.WinError
      ## An exception occurred in a user mode callback and the kernel callback frame should be removed.

    error_compression_disabled* =        769.WinError
      ## Compression is disabled for this volume.

    error_cantfetchbackwards* =          770.WinError
      ## The data provider cannot fetch backwards through a result set.

    error_cantscrollbackwards* =         771.WinError
      ## The data provider cannot scroll backwards through a result set.

    error_rowsnotreleased* =             772.WinError
      ## The data provider requires that previously fetched data is released before asking for more data.

    error_bad_accessor_flags* =          773.WinError
      ## The data provider was not able to interpret the flags set for a column binding in an accessor.

    error_errors_encountered* =          774.WinError
      ## One or more errors occurred while processing the request.

    error_not_capable* =                 775.WinError
      ## The implementation is not capable of performing the request.

    error_request_out_of_sequence* =     776.WinError
      ## The client of a component requested an operation which is not valid given the state of the component instance.

    error_version_parse_error* =         777.WinError
      ## A version number could not be parsed.

    error_badstartposition* =            778.WinError
      ## The iterator's start position is invalid.

    error_memory_hardware* =             779.WinError
      ## The hardware has reported an uncorrectable memory error.

    error_disk_repair_disabled* =        780.WinError
      ## The attempted operation required self healing to be enabled.

    error_insufficient_resource_for_specified_shared_section_size* =  781.WinError
      ## The Desktop heap encountered an error while allocating session memory. There is more information in the system event log.

    error_system_powerstate_transition* =  782.WinError
      ## The system power state is transitioning from %2 to %3.

    error_system_powerstate_complex_transition* =  783.WinError
      ## The system power state is transitioning from %2 to %3 but could enter %4.

    error_mca_exception* =               784.WinError
      ## A thread is getting dispatched with MCA EXCEPTION because of MCA.

    error_access_audit_by_policy* =      785.WinError
      ## Access to %1 is monitored by policy rule %2.

    error_access_disabled_no_safer_ui_by_policy* =  786.WinError
      ## Access to %1 has been restricted by your Administrator by policy rule %2.

    error_abandon_hiberfile* =           787.WinError
      ## A valid hibernation file has been invalidated and should be abandoned.

    error_lost_writebehind_data_network_disconnected* =  788.WinError
      ## {Delayed Write Failed}
      ## Windows was unable to save all the data for the file %hs; the data has been lost.
      ## This error may be caused by network connectivity issues. Please try to save this file elsewhere.

    error_lost_writebehind_data_network_server_error* =  789.WinError
      ## {Delayed Write Failed}
      ## Windows was unable to save all the data for the file %hs; the data has been lost.
      ## This error was returned by the server on which the file exists. Please try to save this file elsewhere.

    error_lost_writebehind_data_local_disk_error* =  790.WinError
      ## {Delayed Write Failed}
      ## Windows was unable to save all the data for the file %hs; the data has been lost.
      ## This error may be caused if the device has been removed or the media is write-protected.

    error_bad_mcfg_table* =              791.WinError
      ## The resources required for this device conflict with the MCFG table.

    error_disk_repair_redirected* =      792.WinError
      ## The volume repair could not be performed while it is online.
      ## Please schedule to take the volume offline so that it can be repaired.

    error_disk_repair_unsuccessful* =    793.WinError
      ## The volume repair was not successful.

    error_corrupt_log_overfull* =        794.WinError
      ## One of the volume corruption logs is full. Further corruptions that may be detected won't be logged.

    error_corrupt_log_corrupted* =       795.WinError
      ## One of the volume corruption logs is internally corrupted and needs to be recreated. The volume may contain undetected corruptions and must be scanned.

    error_corrupt_log_unavailable* =     796.WinError
      ## One of the volume corruption logs is unavailable for being operated on.

    error_corrupt_log_deleted_full* =    797.WinError
      ## One of the volume corruption logs was deleted while still having corruption records in them. The volume contains detected corruptions and must be scanned.

    error_corrupt_log_cleared* =         798.WinError
      ## One of the volume corruption logs was cleared by chkdsk and no longer contains real corruptions.

    error_orphan_name_exhausted* =       799.WinError
      ## Orphaned files exist on the volume but could not be recovered because no more new names could be created in the recovery directory. Files must be moved from the recovery directory.

    error_oplock_switched_to_new_handle* =  800.WinError
      ## The oplock that was associated with this handle is now associated with a different handle.

    error_cannot_grant_requested_oplock* =  801.WinError
      ## An oplock of the requested level cannot be granted.  An oplock of a lower level may be available.

    error_cannot_break_oplock* =         802.WinError
      ## The operation did not complete successfully because it would cause an oplock to be broken. The caller has requested that existing oplocks not be broken.

    error_oplock_handle_closed* =        803.WinError
      ## The handle with which this oplock was associated has been closed.  The oplock is now broken.

    error_no_ace_condition* =            804.WinError
      ## The specified access control entry (ACE) does not contain a condition.

    error_invalid_ace_condition* =       805.WinError
      ## The specified access control entry (ACE) contains an invalid condition.

    error_file_handle_revoked* =         806.WinError
      ## Access to the specified file handle has been revoked.

    error_image_at_different_base* =     807.WinError
      ## {Image Relocated}
      ## An image file was mapped at a different address from the one specified in the image file but fixups will still be automatically performed on the image.

    error_encrypted_io_not_possible* =   808.WinError
      ## The read or write operation to an encrypted file could not be completed because the file has not been opened for data access.

    error_file_metadata_optimization_in_progress* =  809.WinError
      ## File metadata optimization is already in progress.

    error_quota_activity* =              810.WinError
      ## The requested operation failed due to quota operation is still in progress.

    error_handle_revoked* =              811.WinError
      ## Access to the specified handle has been revoked.

    error_callback_invoke_inline* =      812.WinError
      ## The callback function must be invoked inline.

    error_cpu_set_invalid* =             813.WinError
      ## The specified CPU Set IDs are invalid.

    #
    # **** Available SYSTEM error codes ****
    #
    error_ea_access_denied* =            994.WinError
      ## Access to the extended attribute was denied.

    error_operation_aborted* =           995.WinError
      ## The I/O operation has been aborted because of either a thread exit or an application request.

    error_io_incomplete* =               996.WinError
      ## Overlapped I/O event is not in a signaled state.

    error_io_pending* =                  997.WinError
      ## Overlapped I/O operation is in progress.

    error_noaccess* =                    998.WinError
      ## Invalid access to memory location.

    error_swaperror* =                   999.WinError
      ## Error performing inpage operation.

    error_stack_overflow* =              1001.WinError
      ## Recursion too deep; the stack overflowed.

    error_invalid_message* =             1002.WinError
      ## The window cannot act on the sent message.

    error_can_not_complete* =            1003.WinError
      ## Cannot complete this function.

    error_invalid_flags* =               1004.WinError
      ## Invalid flags.

    error_unrecognized_volume* =         1005.WinError
      ## The volume does not contain a recognized file system.
      ## Please make sure that all required file system drivers are loaded and that the volume is not corrupted.

    error_file_invalid* =                1006.WinError
      ## The volume for a file has been externally altered so that the opened file is no longer valid.

    error_fullscreen_mode* =             1007.WinError
      ## The requested operation cannot be performed in full-screen mode.

    error_no_token* =                    1008.WinError
      ## An attempt was made to reference a token that does not exist.

    error_baddb* =                       1009.WinError
      ## The configuration registry database is corrupt.

    error_badkey* =                      1010.WinError
      ## The configuration registry key is invalid.

    error_cantopen* =                    1011.WinError
      ## The configuration registry key could not be opened.

    error_cantread* =                    1012.WinError
      ## The configuration registry key could not be read.

    error_cantwrite* =                   1013.WinError
      ## The configuration registry key could not be written.

    error_registry_recovered* =          1014.WinError
      ## One of the files in the registry database had to be recovered by use of a log or alternate copy. The recovery was successful.

    error_registry_corrupt* =            1015.WinError
      ## The registry is corrupted. The structure of one of the files containing registry data is corrupted, or the system's memory image of the file is corrupted, or the file could not be recovered because the alternate copy or log was absent or corrupted.

    error_registry_io_failed* =          1016.WinError
      ## An I/O operation initiated by the registry failed unrecoverably. The registry could not read in, or write out, or flush, one of the files that contain the system's image of the registry.

    error_not_registry_file* =           1017.WinError
      ## The system has attempted to load or restore a file into the registry, but the specified file is not in a registry file format.

    error_key_deleted* =                 1018.WinError
      ## Illegal operation attempted on a registry key that has been marked for deletion.

    error_no_log_space* =                1019.WinError
      ## System could not allocate the required space in a registry log.

    error_key_has_children* =            1020.WinError
      ## Cannot create a symbolic link in a registry key that already has subkeys or values.

    error_child_must_be_volatile* =      1021.WinError
      ## Cannot create a stable subkey under a volatile parent key.

    error_notify_enum_dir* =             1022.WinError
      ## A notify change request is being completed and the information is not being returned in the caller's buffer. The caller now needs to enumerate the files to find the changes.

    error_dependent_services_running* =  1051.WinError
      ## A stop control has been sent to a service that other running services are dependent on.

    error_invalid_service_control* =     1052.WinError
      ## The requested control is not valid for this service.

    error_service_request_timeout* =     1053.WinError
      ## The service did not respond to the start or control request in a timely fashion.

    error_service_no_thread* =           1054.WinError
      ## A thread could not be created for the service.

    error_service_database_locked* =     1055.WinError
      ## The service database is locked.

    error_service_already_running* =     1056.WinError
      ## An instance of the service is already running.

    error_invalid_service_account* =     1057.WinError
      ## The account name is invalid or does not exist, or the password is invalid for the account name specified.

    error_service_disabled* =            1058.WinError
      ## The service cannot be started, either because it is disabled or because it has no enabled devices associated with it.

    error_circular_dependency* =         1059.WinError
      ## Circular service dependency was specified.

    error_service_does_not_exist* =      1060.WinError
      ## The specified service does not exist as an installed service.

    error_service_cannot_accept_ctrl* =  1061.WinError
      ## The service cannot accept control messages at this time.

    error_service_not_active* =          1062.WinError
      ## The service has not been started.

    error_failed_service_controller_connect* =  1063.WinError
      ## The service process could not connect to the service controller.

    error_exception_in_service* =        1064.WinError
      ## An exception occurred in the service when handling the control request.

    error_database_does_not_exist* =     1065.WinError
      ## The database specified does not exist.

    error_service_specific_error* =      1066.WinError
      ## The service has returned a service-specific error code.

    error_process_aborted* =             1067.WinError
      ## The process terminated unexpectedly.

    error_service_dependency_fail* =     1068.WinError
      ## The dependency service or group failed to start.

    error_service_logon_failed* =        1069.WinError
      ## The service did not start due to a logon failure.

    error_service_start_hang* =          1070.WinError
      ## After starting, the service hung in a start-pending state.

    error_invalid_service_lock* =        1071.WinError
      ## The specified service database lock is invalid.

    error_service_marked_for_delete* =   1072.WinError
      ## The specified service has been marked for deletion.

    error_service_exists* =              1073.WinError
      ## The specified service already exists.

    error_already_running_lkg* =         1074.WinError
      ## The system is currently running with the last-known-good configuration.

    error_service_dependency_deleted* =  1075.WinError
      ## The dependency service does not exist or has been marked for deletion.

    error_boot_already_accepted* =       1076.WinError
      ## The current boot has already been accepted for use as the last-known-good control set.

    error_service_never_started* =       1077.WinError
      ## No attempts to start the service have been made since the last boot.

    error_duplicate_service_name* =      1078.WinError
      ## The name is already in use as either a service name or a service display name.

    error_different_service_account* =   1079.WinError
      ## The account specified for this service is different from the account specified for other services running in the same process.

    error_cannot_detect_driver_failure* =  1080.WinError
      ## Failure actions can only be set for Win32 services, not for drivers.

    error_cannot_detect_process_abort* =  1081.WinError
      ## This service runs in the same process as the service control manager.
      ## Therefore, the service control manager cannot take action if this service's process terminates unexpectedly.

    error_no_recovery_program* =         1082.WinError
      ## No recovery program has been configured for this service.

    error_service_not_in_exe* =          1083.WinError
      ## The executable program that this service is configured to run in does not implement the service.

    error_not_safeboot_service* =        1084.WinError
      ## This service cannot be started in Safe Mode

    error_end_of_media* =                1100.WinError
      ## The physical end of the tape has been reached.

    error_filemark_detected* =           1101.WinError
      ## A tape access reached a filemark.

    error_beginning_of_media* =          1102.WinError
      ## The beginning of the tape or a partition was encountered.

    error_setmark_detected* =            1103.WinError
      ## A tape access reached the end of a set of files.

    error_no_data_detected* =            1104.WinError
      ## No more data is on the tape.

    error_partition_failure* =           1105.WinError
      ## Tape could not be partitioned.

    error_invalid_block_length* =        1106.WinError
      ## When accessing a new tape of a multivolume partition, the current block size is incorrect.

    error_device_not_partitioned* =      1107.WinError
      ## Tape partition information could not be found when loading a tape.

    error_unable_to_lock_media* =        1108.WinError
      ## Unable to lock the media eject mechanism.

    error_unable_to_unload_media* =      1109.WinError
      ## Unable to unload the media.

    error_media_changed* =               1110.WinError
      ## The media in the drive may have changed.

    error_bus_reset* =                   1111.WinError
      ## The I/O bus was reset.

    error_no_media_in_drive* =           1112.WinError
      ## No media in drive.

    error_no_unicode_translation* =      1113.WinError
      ## No mapping for the Unicode character exists in the target multi-byte code page.

    error_dll_init_failed* =             1114.WinError
      ## A dynamic link library (DLL) initialization routine failed.

    error_shutdown_in_progress* =        1115.WinError
      ## A system shutdown is in progress.

    error_no_shutdown_in_progress* =     1116.WinError
      ## Unable to abort the system shutdown because no shutdown was in progress.

    error_io_device* =                   1117.WinError
      ## The request could not be performed because of an I/O device error.

    error_serial_no_device* =            1118.WinError
      ## No serial device was successfully initialized. The serial driver will unload.

    error_irq_busy* =                    1119.WinError
      ## Unable to open a device that was sharing an interrupt request (IRQ) with other devices. At least one other device that uses that IRQ was already opened.

    error_more_writes* =                 1120.WinError
      ## A serial I/O operation was completed by another write to the serial port.
      ## (The IOCTL_SERIAL_XOFF_COUNTER reached zero.)

    error_counter_timeout* =             1121.WinError
      ## A serial I/O operation completed because the timeout period expired.
      ## (The IOCTL_SERIAL_XOFF_COUNTER did not reach zero.)

    error_floppy_id_mark_not_found* =    1122.WinError
      ## No ID address mark was found on the floppy disk.

    error_floppy_wrong_cylinder* =       1123.WinError
      ## Mismatch between the floppy disk sector ID field and the floppy disk controller track address.

    error_floppy_unknown_error* =        1124.WinError
      ## The floppy disk controller reported an error that is not recognized by the floppy disk driver.

    error_floppy_bad_registers* =        1125.WinError
      ## The floppy disk controller returned inconsistent results in its registers.

    error_disk_recalibrate_failed* =     1126.WinError
      ## While accessing the hard disk, a recalibrate operation failed, even after retries.

    error_disk_operation_failed* =       1127.WinError
      ## While accessing the hard disk, a disk operation failed even after retries.

    error_disk_reset_failed* =           1128.WinError
      ## While accessing the hard disk, a disk controller reset was needed, but even that failed.

    error_eom_overflow* =                1129.WinError
      ## Physical end of tape encountered.

    error_not_enough_server_memory* =    1130.WinError
      ## Not enough server storage is available to process this command.

    error_possible_deadlock* =           1131.WinError
      ## A potential deadlock condition has been detected.

    error_mapped_alignment* =            1132.WinError
      ## The base address or the file offset specified does not have the proper alignment.

    error_set_power_state_vetoed* =      1140.WinError
      ## An attempt to change the system power state was vetoed by another application or driver.

    error_set_power_state_failed* =      1141.WinError
      ## The system BIOS failed an attempt to change the system power state.

    error_too_many_links* =              1142.WinError
      ## An attempt was made to create more links on a file than the file system supports.

    error_old_win_version* =             1150.WinError
      ## The specified program requires a newer version of Windows.

    error_app_wrong_os* =                1151.WinError
      ## The specified program is not a Windows or MS-DOS program.

    error_single_instance_app* =         1152.WinError
      ## Cannot start more than one instance of the specified program.

    error_rmode_app* =                   1153.WinError
      ## The specified program was written for an earlier version of Windows.

    error_invalid_dll* =                 1154.WinError
      ## One of the library files needed to run this application is damaged.

    error_no_association* =              1155.WinError
      ## No application is associated with the specified file for this operation.

    error_dde_fail* =                    1156.WinError
      ## An error occurred in sending the command to the application.

    error_dll_not_found* =               1157.WinError
      ## One of the library files needed to run this application cannot be found.

    error_no_more_user_handles* =        1158.WinError
      ## The current process has used all of its system allowance of handles for Window Manager objects.

    error_message_sync_only* =           1159.WinError
      ## The message can be used only with synchronous operations.

    error_source_element_empty* =        1160.WinError
      ## The indicated source element has no media.

    error_destination_element_full* =    1161.WinError
      ## The indicated destination element already contains media.

    error_illegal_element_address* =     1162.WinError
      ## The indicated element does not exist.

    error_magazine_not_present* =        1163.WinError
      ## The indicated element is part of a magazine that is not present.

    error_device_reinitialization_needed* =  1164.WinError
      ## The indicated device requires reinitialization due to hardware errors.

    error_device_requires_cleaning* =    1165.WinError
      ## The device has indicated that cleaning is required before further operations are attempted.

    error_device_door_open* =            1166.WinError
      ## The device has indicated that its door is open.

    error_device_not_connected* =        1167.WinError
      ## The device is not connected.

    error_not_found* =                   1168.WinError
      ## Element not found.

    error_no_match* =                    1169.WinError
      ## There was no match for the specified key in the index.

    error_set_not_found* =               1170.WinError
      ## The property set specified does not exist on the object.

    error_point_not_found* =             1171.WinError
      ## The point passed to GetMouseMovePoints is not in the buffer.

    error_no_tracking_service* =         1172.WinError
      ## The tracking (workstation) service is not running.

    error_no_volume_id* =                1173.WinError
      ## The Volume ID could not be found.

    error_unable_to_remove_replaced* =   1175.WinError
      ## Unable to remove the file to be replaced.

    error_unable_to_move_replacement* =  1176.WinError
      ## Unable to move the replacement file to the file to be replaced. The file to be replaced has retained its original name.

    error_unable_to_move_replacement_2* =  1177.WinError
      ## Unable to move the replacement file to the file to be replaced. The file to be replaced has been renamed using the backup name.

    error_journal_delete_in_progress* =  1178.WinError
      ## The volume change journal is being deleted.

    error_journal_not_active* =          1179.WinError
      ## The volume change journal is not active.

    error_potential_file_found* =        1180.WinError
      ## A file was found, but it may not be the correct file.

    error_journal_entry_deleted* =       1181.WinError
      ## The journal entry has been deleted from the journal.

    error_shutdown_is_scheduled* =       1190.WinError
      ## A system shutdown has already been scheduled.

    error_shutdown_users_logged_on* =    1191.WinError
      ## The system shutdown cannot be initiated because there are other users logged on to the computer.

    error_bad_device* =                  1200.WinError
      ## The specified device name is invalid.

    error_connection_unavail* =          1201.WinError
      ## The device is not currently connected but it is a remembered connection.

    error_device_already_remembered* =   1202.WinError
      ## The local device name has a remembered connection to another network resource.

    error_no_net_or_bad_path* =          1203.WinError
      ## The network path was either typed incorrectly, does not exist, or the network provider is not currently available. Please try retyping the path or contact your network administrator.

    error_bad_provider* =                1204.WinError
      ## The specified network provider name is invalid.

    error_cannot_open_profile* =         1205.WinError
      ## Unable to open the network connection profile.

    error_bad_profile* =                 1206.WinError
      ## The network connection profile is corrupted.

    error_not_container* =               1207.WinError
      ## Cannot enumerate a noncontainer.

    error_extended_error* =              1208.WinError
      ## An extended error has occurred.

    error_invalid_groupname* =           1209.WinError
      ## The format of the specified group name is invalid.

    error_invalid_computername* =        1210.WinError
      ## The format of the specified computer name is invalid.

    error_invalid_eventname* =           1211.WinError
      ## The format of the specified event name is invalid.

    error_invalid_domainname* =          1212.WinError
      ## The format of the specified domain name is invalid.

    error_invalid_servicename* =         1213.WinError
      ## The format of the specified service name is invalid.

    error_invalid_netname* =             1214.WinError
      ## The format of the specified network name is invalid.

    error_invalid_sharename* =           1215.WinError
      ## The format of the specified share name is invalid.

    error_invalid_passwordname* =        1216.WinError
      ## The format of the specified password is invalid.

    error_invalid_messagename* =         1217.WinError
      ## The format of the specified message name is invalid.

    error_invalid_messagedest* =         1218.WinError
      ## The format of the specified message destination is invalid.

    error_session_credential_conflict* =  1219.WinError
      ## Multiple connections to a server or shared resource by the same user, using more than one user name, are not allowed. Disconnect all previous connections to the server or shared resource and try again.

    error_remote_session_limit_exceeded* =  1220.WinError
      ## An attempt was made to establish a session to a network server, but there are already too many sessions established to that server.

    error_dup_domainname* =              1221.WinError
      ## The workgroup or domain name is already in use by another computer on the network.

    error_no_network* =                  1222.WinError
      ## The network is not present or not started.

    error_cancelled* =                   1223.WinError
      ## The operation was canceled by the user.

    error_user_mapped_file* =            1224.WinError
      ## The requested operation cannot be performed on a file with a user-mapped section open.

    error_connection_refused* =          1225.WinError
      ## The remote computer refused the network connection.

    error_graceful_disconnect* =         1226.WinError
      ## The network connection was gracefully closed.

    error_address_already_associated* =  1227.WinError
      ## The network transport endpoint already has an address associated with it.

    error_address_not_associated* =      1228.WinError
      ## An address has not yet been associated with the network endpoint.

    error_connection_invalid* =          1229.WinError
      ## An operation was attempted on a nonexistent network connection.

    error_connection_active* =           1230.WinError
      ## An invalid operation was attempted on an active network connection.

    error_network_unreachable* =         1231.WinError
      ## The network location cannot be reached. For information about network troubleshooting, see Windows Help.

    error_host_unreachable* =            1232.WinError
      ## The network location cannot be reached. For information about network troubleshooting, see Windows Help.

    error_protocol_unreachable* =        1233.WinError
      ## The network location cannot be reached. For information about network troubleshooting, see Windows Help.

    error_port_unreachable* =            1234.WinError
      ## No service is operating at the destination network endpoint on the remote system.

    error_request_aborted* =             1235.WinError
      ## The request was aborted.

    error_connection_aborted* =          1236.WinError
      ## The network connection was aborted by the local system.

    error_retry* =                       1237.WinError
      ## The operation could not be completed. A retry should be performed.

    error_connection_count_limit* =      1238.WinError
      ## A connection to the server could not be made because the limit on the number of concurrent connections for this account has been reached.

    error_login_time_restriction* =      1239.WinError
      ## Attempting to log in during an unauthorized time of day for this account.

    error_login_wksta_restriction* =     1240.WinError
      ## The account is not authorized to log in from this station.

    error_incorrect_address* =           1241.WinError
      ## The network address could not be used for the operation requested.

    error_already_registered* =          1242.WinError
      ## The service is already registered.

    error_service_not_found* =           1243.WinError
      ## The specified service does not exist.

    error_not_authenticated* =           1244.WinError
      ## The operation being requested was not performed because the user has not been authenticated.

    error_not_logged_on* =               1245.WinError
      ## The operation being requested was not performed because the user has not logged on to the network. The specified service does not exist.

    error_continue* =                    1246.WinError
      ## Continue with work in progress.

    error_already_initialized* =         1247.WinError
      ## An attempt was made to perform an initialization operation when initialization has already been completed.

    error_no_more_devices* =             1248.WinError
      ## No more local devices.

    error_no_such_site* =                1249.WinError
      ## The specified site does not exist.

    error_domain_controller_exists* =    1250.WinError
      ## A domain controller with the specified name already exists.

    error_only_if_connected* =           1251.WinError
      ## This operation is supported only when you are connected to the server.

    error_override_nochanges* =          1252.WinError
      ## The group policy framework should call the extension even if there are no changes.

    error_bad_user_profile* =            1253.WinError
      ## The specified user does not have a valid profile.

    error_not_supported_on_sbs* =        1254.WinError
      ## This operation is not supported on a computer running Windows Server 2003 for Small Business Server

    error_server_shutdown_in_progress* =  1255.WinError
      ## The server machine is shutting down.

    error_host_down* =                   1256.WinError
      ## The remote system is not available. For information about network troubleshooting, see Windows Help.

    error_non_account_sid* =             1257.WinError
      ## The security identifier provided is not from an account domain.

    error_non_domain_sid* =              1258.WinError
      ## The security identifier provided does not have a domain component.

    error_apphelp_block* =               1259.WinError
      ## AppHelp dialog canceled thus preventing the application from starting.

    error_access_disabled_by_policy* =   1260.WinError
      ## This program is blocked by group policy. For more information, contact your system administrator.

    error_reg_nat_consumption* =         1261.WinError
      ## A program attempt to use an invalid register value. Normally caused by an uninitialized register. This error is Itanium specific.

    error_cscshare_offline* =            1262.WinError
      ## The share is currently offline or does not exist.

    error_pkinit_failure* =              1263.WinError
      ## The Kerberos protocol encountered an error while validating the KDC certificate during smartcard logon. There is more information in the system event log.

    error_smartcard_subsystem_failure* =  1264.WinError
      ## The Kerberos protocol encountered an error while attempting to utilize the smartcard subsystem.

    error_downgrade_detected* =          1265.WinError
      ## The system cannot contact a domain controller to service the authentication request. Please try again later.

    #
    # Do not use ID's 1266 - 1270 as the symbolicNames have been moved to SEC_E_*
    #
    error_machine_locked* =              1271.WinError
      ## The machine is locked and cannot be shut down without the force option.

    error_smb_guest_logon_blocked* =     1272.WinError
      ## You can't access this shared folder because your organization's security policies block unauthenticated guest access. These policies help protect your PC from unsafe or malicious devices on the network.

    error_callback_supplied_invalid_data* =  1273.WinError
      ## An application-defined callback gave invalid data when called.

    error_sync_foreground_refresh_required* =  1274.WinError
      ## The group policy framework should call the extension in the synchronous foreground policy refresh.

    error_driver_blocked* =              1275.WinError
      ## This driver has been blocked from loading

    error_invalid_import_of_non_dll* =   1276.WinError
      ## A dynamic link library (DLL) referenced a module that was neither a DLL nor the process's executable image.

    error_access_disabled_webblade* =    1277.WinError
      ## Windows cannot open this program since it has been disabled.

    error_access_disabled_webblade_tamper* =  1278.WinError
      ## Windows cannot open this program because the license enforcement system has been tampered with or become corrupted.

    error_recovery_failure* =            1279.WinError
      ## A transaction recover failed.

    error_already_fiber* =               1280.WinError
      ## The current thread has already been converted to a fiber.

    error_already_thread* =              1281.WinError
      ## The current thread has already been converted from a fiber.

    error_stack_buffer_overrun* =        1282.WinError
      ## The system detected an overrun of a stack-based buffer in this application. This overrun could potentially allow a malicious user to gain control of this application.

    error_parameter_quota_exceeded* =    1283.WinError
      ## Data present in one of the parameters is more than the function can operate on.

    error_debugger_inactive* =           1284.WinError
      ## An attempt to do an operation on a debug object failed because the object is in the process of being deleted.

    error_delay_load_failed* =           1285.WinError
      ## An attempt to delay-load a .dll or get a function address in a delay-loaded .dll failed.

    error_vdm_disallowed* =              1286.WinError
      ## %1 is a 16-bit application. You do not have permissions to execute 16-bit applications. Check your permissions with your system administrator.

    error_unidentified_error* =          1287.WinError
      ## Insufficient information exists to identify the cause of failure.

    error_invalid_cruntime_parameter* =  1288.WinError
      ## The parameter passed to a C runtime function is incorrect.

    error_beyond_vdl* =                  1289.WinError
      ## The operation occurred beyond the valid data length of the file.

    error_incompatible_service_sid_type* =  1290.WinError
      ## The service start failed since one or more services in the same process have an incompatible service SID type setting. A service with restricted service SID type can only coexist in the same process with other services with a restricted SID type. If the service SID type for this service was just configured, the hosting process must be restarted in order to start this service.

    error_driver_process_terminated* =   1291.WinError
      ## The process hosting the driver for this device has been terminated.

    error_implementation_limit* =        1292.WinError
      ## An operation attempted to exceed an implementation-defined limit.

    error_process_is_protected* =        1293.WinError
      ## Either the target process, or the target thread's containing process, is a protected process.

    error_service_notify_client_lagging* =  1294.WinError
      ## The service notification client is lagging too far behind the current state of services in the machine.

    error_disk_quota_exceeded* =         1295.WinError
      ## The requested file operation failed because the storage quota was exceeded.
      ## To free up disk space, move files to a different location or delete unnecessary files. For more information, contact your system administrator.

    error_content_blocked* =             1296.WinError
      ## The requested file operation failed because the storage policy blocks that type of file. For more information, contact your system administrator.

    error_incompatible_service_privilege* =  1297.WinError
      ## A privilege that the service requires to function properly does not exist in the service account configuration.
      ## You may use the Services Microsoft Management Console (MMC) snap-in (services.msc) and the Local Security Settings MMC snap-in (secpol.msc) to view the service configuration and the account configuration.

    error_app_hang* =                    1298.WinError
      ## A thread involved in this operation appears to be unresponsive.


    ##################################################
    #                                               ##
    #             SECURITY Error codes              ##
    #                                               ##
    #                 1299 to 1399                  ##
    ##################################################

    error_invalid_label* =               1299.WinError
      ## Indicates a particular Security ID may not be assigned as the label of an object.

    error_not_all_assigned* =            1300.WinError
      ## Not all privileges or groups referenced are assigned to the caller.

    error_some_not_mapped* =             1301.WinError
      ## Some mapping between account names and security IDs was not done.

    error_no_quotas_for_account* =       1302.WinError
      ## No system quota limits are specifically set for this account.

    error_local_user_session_key* =      1303.WinError
      ## No encryption key is available. A well-known encryption key was returned.

    error_null_lm_password* =            1304.WinError
      ## The password is too complex to be converted to a LAN Manager password. The LAN Manager password returned is a NULL string.

    error_unknown_revision* =            1305.WinError
      ## The revision level is unknown.

    error_revision_mismatch* =           1306.WinError
      ## Indicates two revision levels are incompatible.

    error_invalid_owner* =               1307.WinError
      ## This security ID may not be assigned as the owner of this object.

    error_invalid_primary_group* =       1308.WinError
      ## This security ID may not be assigned as the primary group of an object.

    error_no_impersonation_token* =      1309.WinError
      ## An attempt has been made to operate on an impersonation token by a thread that is not currently impersonating a client.

    error_cant_disable_mandatory* =      1310.WinError
      ## The group may not be disabled.

    error_no_logon_servers* =            1311.WinError
      ## There are currently no logon servers available to service the logon request.

    error_no_such_logon_session* =       1312.WinError
      ## A specified logon session does not exist. It may already have been terminated.

    error_no_such_privilege* =           1313.WinError
      ## A specified privilege does not exist.

    error_privilege_not_held* =          1314.WinError
      ## A required privilege is not held by the client.

    error_invalid_account_name* =        1315.WinError
      ## The name provided is not a properly formed account name.

    error_user_exists* =                 1316.WinError
      ## The specified account already exists.

    error_no_such_user* =                1317.WinError
      ## The specified account does not exist.

    error_group_exists* =                1318.WinError
      ## The specified group already exists.

    error_no_such_group* =               1319.WinError
      ## The specified group does not exist.

    error_member_in_group* =             1320.WinError
      ## Either the specified user account is already a member of the specified group, or the specified group cannot be deleted because it contains a member.

    error_member_not_in_group* =         1321.WinError
      ## The specified user account is not a member of the specified group account.

    error_last_admin* =                  1322.WinError
      ## This operation is disallowed as it could result in an administration account being disabled, deleted or unable to logon.

    error_wrong_password* =              1323.WinError
      ## Unable to update the password. The value provided as the current password is incorrect.

    error_ill_formed_password* =         1324.WinError
      ## Unable to update the password. The value provided for the new password contains values that are not allowed in passwords.

    error_password_restriction* =        1325.WinError
      ## Unable to update the password. The value provided for the new password does not meet the length, complexity, or history requirements of the domain.

    error_logon_failure* =               1326.WinError
      ## The user name or password is incorrect.

    error_account_restriction* =         1327.WinError
      ## Account restrictions are preventing this user from signing in. For example: blank passwords aren't allowed, sign-in times are limited, or a policy restriction has been enforced.

    error_invalid_logon_hours* =         1328.WinError
      ## Your account has time restrictions that keep you from signing in right now.

    error_invalid_workstation* =         1329.WinError
      ## This user isn't allowed to sign in to this computer.

    error_password_expired* =            1330.WinError
      ## The password for this account has expired.

    error_account_disabled* =            1331.WinError
      ## This user can't sign in because this account is currently disabled.

    error_none_mapped* =                 1332.WinError
      ## No mapping between account names and security IDs was done.

    error_too_many_luids_requested* =    1333.WinError
      ## Too many local user identifiers (LUIDs) were requested at one time.

    error_luids_exhausted* =             1334.WinError
      ## No more local user identifiers (LUIDs) are available.

    error_invalid_sub_authority* =       1335.WinError
      ## The subauthority part of a security ID is invalid for this particular use.

    error_invalid_acl* =                 1336.WinError
      ## The access control list (ACL) structure is invalid.

    error_invalid_sid* =                 1337.WinError
      ## The security ID structure is invalid.

    error_invalid_security_descr* =      1338.WinError
      ## The security descriptor structure is invalid.

    error_bad_inheritance_acl* =         1340.WinError
      ## The inherited access control list (ACL) or access control entry (ACE) could not be built.

    error_server_disabled* =             1341.WinError
      ## The server is currently disabled.

    error_server_not_disabled* =         1342.WinError
      ## The server is currently enabled.

    error_invalid_id_authority* =        1343.WinError
      ## The value provided was an invalid value for an identifier authority.

    error_allotted_space_exceeded* =     1344.WinError
      ## No more memory is available for security information updates.

    error_invalid_group_attributes* =    1345.WinError
      ## The specified attributes are invalid, or incompatible with the attributes for the group as a whole.

    error_bad_impersonation_level* =     1346.WinError
      ## Either a required impersonation level was not provided, or the provided impersonation level is invalid.

    error_cant_open_anonymous* =         1347.WinError
      ## Cannot open an anonymous level security token.

    error_bad_validation_class* =        1348.WinError
      ## The validation information class requested was invalid.

    error_bad_token_type* =              1349.WinError
      ## The type of the token is inappropriate for its attempted use.

    error_no_security_on_object* =       1350.WinError
      ## Unable to perform a security operation on an object that has no associated security.

    error_cant_access_domain_info* =     1351.WinError
      ## Configuration information could not be read from the domain controller, either because the machine is unavailable, or access has been denied.

    error_invalid_server_state* =        1352.WinError
      ## The security account manager (SAM) or local security authority (LSA) server was in the wrong state to perform the security operation.

    error_invalid_domain_state* =        1353.WinError
      ## The domain was in the wrong state to perform the security operation.

    error_invalid_domain_role* =         1354.WinError
      ## This operation is only allowed for the Primary Domain Controller of the domain.

    error_no_such_domain* =              1355.WinError
      ## The specified domain either does not exist or could not be contacted.

    error_domain_exists* =               1356.WinError
      ## The specified domain already exists.

    error_domain_limit_exceeded* =       1357.WinError
      ## An attempt was made to exceed the limit on the number of domains per server.

    error_internal_db_corruption* =      1358.WinError
      ## Unable to complete the requested operation because of either a catastrophic media failure or a data structure corruption on the disk.

    error_internal_error* =              1359.WinError
      ## An internal error occurred.

    error_generic_not_mapped* =          1360.WinError
      ## Generic access types were contained in an access mask which should already be mapped to nongeneric types.

    error_bad_descriptor_format* =       1361.WinError
      ## A security descriptor is not in the right format (absolute or self-relative).

    error_not_logon_process* =           1362.WinError
      ## The requested action is restricted for use by logon processes only. The calling process has not registered as a logon process.

    error_logon_session_exists* =        1363.WinError
      ## Cannot start a new logon session with an ID that is already in use.

    error_no_such_package* =             1364.WinError
      ## A specified authentication package is unknown.

    error_bad_logon_session_state* =     1365.WinError
      ## The logon session is not in a state that is consistent with the requested operation.

    error_logon_session_collision* =     1366.WinError
      ## The logon session ID is already in use.

    error_invalid_logon_type* =          1367.WinError
      ## A logon request contained an invalid logon type value.

    error_cannot_impersonate* =          1368.WinError
      ## Unable to impersonate using a named pipe until data has been read from that pipe.

    error_rxact_invalid_state* =         1369.WinError
      ## The transaction state of a registry subtree is incompatible with the requested operation.

    error_rxact_commit_failure* =        1370.WinError
      ## An internal security database corruption has been encountered.

    error_special_account* =             1371.WinError
      ## Cannot perform this operation on built-in accounts.

    error_special_group* =               1372.WinError
      ## Cannot perform this operation on this built-in special group.

    error_special_user* =                1373.WinError
      ## Cannot perform this operation on this built-in special user.

    error_members_primary_group* =       1374.WinError
      ## The user cannot be removed from a group because the group is currently the user's primary group.

    error_token_already_in_use* =        1375.WinError
      ## The token is already in use as a primary token.

    error_no_such_alias* =               1376.WinError
      ## The specified local group does not exist.

    error_member_not_in_alias* =         1377.WinError
      ## The specified account name is not a member of the group.

    error_member_in_alias* =             1378.WinError
      ## The specified account name is already a member of the group.

    error_alias_exists* =                1379.WinError
      ## The specified local group already exists.

    error_logon_not_granted* =           1380.WinError
      ## Logon failure: the user has not been granted the requested logon type at this computer.

    error_too_many_secrets* =            1381.WinError
      ## The maximum number of secrets that may be stored in a single system has been exceeded.

    error_secret_too_long* =             1382.WinError
      ## The length of a secret exceeds the maximum length allowed.

    error_internal_db_error* =           1383.WinError
      ## The local security authority database contains an internal inconsistency.

    error_too_many_context_ids* =        1384.WinError
      ## During a logon attempt, the user's security context accumulated too many security IDs.

    error_logon_type_not_granted* =      1385.WinError
      ## Logon failure: the user has not been granted the requested logon type at this computer.

    error_nt_cross_encryption_required* =  1386.WinError
      ## A cross-encrypted password is necessary to change a user password.

    error_no_such_member* =              1387.WinError
      ## A member could not be added to or removed from the local group because the member does not exist.

    error_invalid_member* =              1388.WinError
      ## A new member could not be added to a local group because the member has the wrong account type.

    error_too_many_sids* =               1389.WinError
      ## Too many security IDs have been specified.

    error_lm_cross_encryption_required* =  1390.WinError
      ## A cross-encrypted password is necessary to change this user password.

    error_no_inheritance* =              1391.WinError
      ## Indicates an ACL contains no inheritable components.

    error_file_corrupt* =                1392.WinError
      ## The file or directory is corrupted and unreadable.

    error_disk_corrupt* =                1393.WinError
      ## The disk structure is corrupted and unreadable.

    error_no_user_session_key* =         1394.WinError
      ## There is no user session key for the specified logon session.

    error_license_quota_exceeded* =      1395.WinError
      ## The service being accessed is licensed for a particular number of connections. No more connections can be made to the service at this time because there are already as many connections as the service can accept.

    error_wrong_target_name* =           1396.WinError
      ## The target account name is incorrect.

    error_mutual_auth_failed* =          1397.WinError
      ## Mutual Authentication failed. The server's password is out of date at the domain controller.

    error_time_skew* =                   1398.WinError
      ## There is a time and/or date difference between the client and server.

    error_current_domain_not_allowed* =  1399.WinError
      ## This operation cannot be performed on the current domain.


    ##################################################
    #                                               ##
    #              WinUser Error codes              ##
    #                                               ##
    #                 1400 to 1499                  ##
    ##################################################

    error_invalid_window_handle* =       1400.WinError
      ## Invalid window handle.

    error_invalid_menu_handle* =         1401.WinError
      ## Invalid menu handle.

    error_invalid_cursor_handle* =       1402.WinError
      ## Invalid cursor handle.

    error_invalid_accel_handle* =        1403.WinError
      ## Invalid accelerator table handle.

    error_invalid_hook_handle* =         1404.WinError
      ## Invalid hook handle.

    error_invalid_dwp_handle* =          1405.WinError
      ## Invalid handle to a multiple-window position structure.

    error_tlw_with_wschild* =            1406.WinError
      ## Cannot create a top-level child window.

    error_cannot_find_wnd_class* =       1407.WinError
      ## Cannot find window class.

    error_window_of_other_thread* =      1408.WinError
      ## Invalid window; it belongs to other thread.

    error_hotkey_already_registered* =   1409.WinError
      ## Hot key is already registered.

    error_class_already_exists* =        1410.WinError
      ## Class already exists.

    error_class_does_not_exist* =        1411.WinError
      ## Class does not exist.

    error_class_has_windows* =           1412.WinError
      ## Class still has open windows.

    error_invalid_index* =               1413.WinError
      ## Invalid index.

    error_invalid_icon_handle* =         1414.WinError
      ## Invalid icon handle.

    error_private_dialog_index* =        1415.WinError
      ## Using private DIALOG window words.

    error_listbox_id_not_found* =        1416.WinError
      ## The list box identifier was not found.

    error_no_wildcard_characters* =      1417.WinError
      ## No wildcards were found.

    error_clipboard_not_open* =          1418.WinError
      ## Thread does not have a clipboard open.

    error_hotkey_not_registered* =       1419.WinError
      ## Hot key is not registered.

    error_window_not_dialog* =           1420.WinError
      ## The window is not a valid dialog window.

    error_control_id_not_found* =        1421.WinError
      ## Control ID not found.

    error_invalid_combobox_message* =    1422.WinError
      ## Invalid message for a combo box because it does not have an edit control.

    error_window_not_combobox* =         1423.WinError
      ## The window is not a combo box.

    error_invalid_edit_height* =         1424.WinError
      ## Height must be less than 256.

    error_dc_not_found* =                1425.WinError
      ## Invalid device context (DC) handle.

    error_invalid_hook_filter* =         1426.WinError
      ## Invalid hook procedure type.

    error_invalid_filter_proc* =         1427.WinError
      ## Invalid hook procedure.

    error_hook_needs_hmod* =             1428.WinError
      ## Cannot set nonlocal hook without a module handle.

    error_global_only_hook* =            1429.WinError
      ## This hook procedure can only be set globally.

    error_journal_hook_set* =            1430.WinError
      ## The journal hook procedure is already installed.

    error_hook_not_installed* =          1431.WinError
      ## The hook procedure is not installed.

    error_invalid_lb_message* =          1432.WinError
      ## Invalid message for single-selection list box.

    error_setcount_on_bad_lb* =          1433.WinError
      ## LB_SETCOUNT sent to non-lazy list box.

    error_lb_without_tabstops* =         1434.WinError
      ## This list box does not support tab stops.

    error_destroy_object_of_other_thread* =  1435.WinError
      ## Cannot destroy object created by another thread.

    error_child_window_menu* =           1436.WinError
      ## Child windows cannot have menus.

    error_no_system_menu* =              1437.WinError
      ## The window does not have a system menu.

    error_invalid_msgbox_style* =        1438.WinError
      ## Invalid message box style.

    error_invalid_spi_value* =           1439.WinError
      ## Invalid system-wide (SPI_*) parameter.

    error_screen_already_locked* =       1440.WinError
      ## Screen already locked.

    error_hwnds_have_diff_parent* =      1441.WinError
      ## All handles to windows in a multiple-window position structure must have the same parent.

    error_not_child_window* =            1442.WinError
      ## The window is not a child window.

    error_invalid_gw_command* =          1443.WinError
      ## Invalid GW_* command.

    error_invalid_thread_id* =           1444.WinError
      ## Invalid thread identifier.

    error_non_mdichild_window* =         1445.WinError
      ## Cannot process a message from a window that is not a multiple document interface (MDI) window.

    error_popup_already_active* =        1446.WinError
      ## Popup menu already active.

    error_no_scrollbars* =               1447.WinError
      ## The window does not have scroll bars.

    error_invalid_scrollbar_range* =     1448.WinError
      ## Scroll bar range cannot be greater than MAXLONG.

    error_invalid_showwin_command* =     1449.WinError
      ## Cannot show or remove the window in the way specified.

    error_no_system_resources* =         1450.WinError
      ## Insufficient system resources exist to complete the requested service.

    error_nonpaged_system_resources* =   1451.WinError
      ## Insufficient system resources exist to complete the requested service.

    error_paged_system_resources* =      1452.WinError
      ## Insufficient system resources exist to complete the requested service.

    error_working_set_quota* =           1453.WinError
      ## Insufficient quota to complete the requested service.

    error_pagefile_quota* =              1454.WinError
      ## Insufficient quota to complete the requested service.

    error_commitment_limit* =            1455.WinError
      ## The paging file is too small for this operation to complete.

    error_menu_item_not_found* =         1456.WinError
      ## A menu item was not found.

    error_invalid_keyboard_handle* =     1457.WinError
      ## Invalid keyboard layout handle.

    error_hook_type_not_allowed* =       1458.WinError
      ## Hook type not allowed.

    error_requires_interactive_windowstation* =  1459.WinError
      ## This operation requires an interactive window station.

    error_timeout* =                     1460.WinError
      ## This operation returned because the timeout period expired.

    error_invalid_monitor_handle* =      1461.WinError
      ## Invalid monitor handle.

    error_incorrect_size* =              1462.WinError
      ## Incorrect size argument.

    error_symlink_class_disabled* =      1463.WinError
      ## The symbolic link cannot be followed because its type is disabled.

    error_symlink_not_supported* =       1464.WinError
      ## This application does not support the current operation on symbolic links.

    error_xml_parse_error* =             1465.WinError
      ## Windows was unable to parse the requested XML data.

    error_xmldsig_error* =               1466.WinError
      ## An error was encountered while processing an XML digital signature.

    error_restart_application* =         1467.WinError
      ## This application must be restarted.

    error_wrong_compartment* =           1468.WinError
      ## The caller made the connection request in the wrong routing compartment.

    error_authip_failure* =              1469.WinError
      ## There was an AuthIP failure when attempting to connect to the remote host.

    error_no_nvram_resources* =          1470.WinError
      ## Insufficient NVRAM resources exist to complete the requested service. A reboot might be required.

    error_not_gui_process* =             1471.WinError
      ## Unable to finish the requested operation because the specified process is not a GUI process.


    ##################################################
    #                                               ##
    #             EventLog Error codes              ##
    #                                               ##
    #                 1500 to 1549                  ##
    ##################################################

    error_eventlog_file_corrupt* =       1500.WinError
      ## The event log file is corrupted.

    error_eventlog_cant_start* =         1501.WinError
      ## No event log file could be opened, so the event logging service did not start.

    error_log_file_full* =               1502.WinError
      ## The event log file is full.

    error_eventlog_file_changed* =       1503.WinError
      ## The event log file has changed between read operations.

    error_container_assigned* =          1504.WinError
      ## The specified Job already has a container assigned to it.

    error_job_no_container* =            1505.WinError
      ## The specified Job does not have a container assigned to it.


    ##################################################
    #                                               ##
    #            Class Scheduler Error codes        ##
    #                                               ##
    #                 1550 to 1599                  ##
    ##################################################

    error_invalid_task_name* =           1550.WinError
      ## The specified task name is invalid.

    error_invalid_task_index* =          1551.WinError
      ## The specified task index is invalid.

    error_thread_already_in_task* =      1552.WinError
      ## The specified thread is already joining a task.


    ##################################################
    #                                               ##
    #                MSI Error codes                ##
    #                                               ##
    #                 1600 to 1699                  ##
    ##################################################

    error_install_service_failure* =     1601.WinError
      ## The Windows Installer Service could not be accessed. This can occur if the Windows Installer is not correctly installed. Contact your support personnel for assistance.

    error_install_userexit* =            1602.WinError
      ## User cancelled installation.

    error_install_failure* =             1603.WinError
      ## Fatal error during installation.

    error_install_suspend* =             1604.WinError
      ## Installation suspended, incomplete.

    error_unknown_product* =             1605.WinError
      ## This action is only valid for products that are currently installed.

    error_unknown_feature* =             1606.WinError
      ## Feature ID not registered.

    error_unknown_component* =           1607.WinError
      ## Component ID not registered.

    error_unknown_property* =            1608.WinError
      ## Unknown property.

    error_invalid_handle_state* =        1609.WinError
      ## Handle is in an invalid state.

    error_bad_configuration* =           1610.WinError
      ## The configuration data for this product is corrupt. Contact your support personnel.

    error_index_absent* =                1611.WinError
      ## Component qualifier not present.

    error_install_source_absent* =       1612.WinError
      ## The installation source for this product is not available. Verify that the source exists and that you can access it.

    error_install_package_version* =     1613.WinError
      ## This installation package cannot be installed by the Windows Installer service. You must install a Windows service pack that contains a newer version of the Windows Installer service.

    error_product_uninstalled* =         1614.WinError
      ## Product is uninstalled.

    error_bad_query_syntax* =            1615.WinError
      ## SQL query syntax invalid or unsupported.

    error_invalid_field* =               1616.WinError
      ## Record field does not exist.

    error_device_removed* =              1617.WinError
      ## The device has been removed.

    error_install_already_running* =     1618.WinError
      ## Another installation is already in progress. Complete that installation before proceeding with this install.

    error_install_package_open_failed* =  1619.WinError
      ## This installation package could not be opened. Verify that the package exists and that you can access it, or contact the application vendor to verify that this is a valid Windows Installer package.

    error_install_package_invalid* =     1620.WinError
      ## This installation package could not be opened. Contact the application vendor to verify that this is a valid Windows Installer package.

    error_install_ui_failure* =          1621.WinError
      ## There was an error starting the Windows Installer service user interface. Contact your support personnel.

    error_install_log_failure* =         1622.WinError
      ## Error opening installation log file. Verify that the specified log file location exists and that you can write to it.

    error_install_language_unsupported* =  1623.WinError
      ## The language of this installation package is not supported by your system.

    error_install_transform_failure* =   1624.WinError
      ## Error applying transforms. Verify that the specified transform paths are valid.

    error_install_package_rejected* =    1625.WinError
      ## This installation is forbidden by system policy. Contact your system administrator.

    error_function_not_called* =         1626.WinError
      ## Function could not be executed.

    error_function_failed* =             1627.WinError
      ## Function failed during execution.

    error_invalid_table* =               1628.WinError
      ## Invalid or unknown table specified.

    error_datatype_mismatch* =           1629.WinError
      ## Data supplied is of wrong type.

    error_unsupported_type* =            1630.WinError
      ## Data of this type is not supported.

    error_create_failed* =               1631.WinError
      ## The Windows Installer service failed to start. Contact your support personnel.

    error_install_temp_unwritable* =     1632.WinError
      ## The Temp folder is on a drive that is full or is inaccessible. Free up space on the drive or verify that you have write permission on the Temp folder.

    error_install_platform_unsupported* =  1633.WinError
      ## This installation package is not supported by this processor type. Contact your product vendor.

    error_install_notused* =             1634.WinError
      ## Component not used on this computer.

    error_patch_package_open_failed* =   1635.WinError
      ## This update package could not be opened. Verify that the update package exists and that you can access it, or contact the application vendor to verify that this is a valid Windows Installer update package.

    error_patch_package_invalid* =       1636.WinError
      ## This update package could not be opened. Contact the application vendor to verify that this is a valid Windows Installer update package.

    error_patch_package_unsupported* =   1637.WinError
      ## This update package cannot be processed by the Windows Installer service. You must install a Windows service pack that contains a newer version of the Windows Installer service.

    error_product_version* =             1638.WinError
      ## Another version of this product is already installed. Installation of this version cannot continue. To configure or remove the existing version of this product, use Add/Remove Programs on the Control Panel.

    error_invalid_command_line* =        1639.WinError
      ## Invalid command line argument. Consult the Windows Installer SDK for detailed command line help.

    error_install_remote_disallowed* =   1640.WinError
      ## Only administrators have permission to add, remove, or configure server software during a Terminal services remote session. If you want to install or configure software on the server, contact your network administrator.

    error_success_reboot_initiated* =    1641.WinError
      ## The requested operation completed successfully. The system will be restarted so the changes can take effect.

    error_patch_target_not_found* =      1642.WinError
      ## The upgrade cannot be installed by the Windows Installer service because the program to be upgraded may be missing, or the upgrade may update a different version of the program. Verify that the program to be upgraded exists on your computer and that you have the correct upgrade.

    error_patch_package_rejected* =      1643.WinError
      ## The update package is not permitted by software restriction policy.

    error_install_transform_rejected* =  1644.WinError
      ## One or more customizations are not permitted by software restriction policy.

    error_install_remote_prohibited* =   1645.WinError
      ## The Windows Installer does not permit installation from a Remote Desktop Connection.

    error_patch_removal_unsupported* =   1646.WinError
      ## Uninstallation of the update package is not supported.

    error_unknown_patch* =               1647.WinError
      ## The update is not applied to this product.

    error_patch_no_sequence* =           1648.WinError
      ## No valid sequence could be found for the set of updates.

    error_patch_removal_disallowed* =    1649.WinError
      ## Update removal was disallowed by policy.

    error_invalid_patch_xml* =           1650.WinError
      ## The XML update data is invalid.

    error_patch_managed_advertised_product* =  1651.WinError
      ## Windows Installer does not permit updating of managed advertised products. At least one feature of the product must be installed before applying the update.

    error_install_service_safeboot* =    1652.WinError
      ## The Windows Installer service is not accessible in Safe Mode. Please try again when your computer is not in Safe Mode or you can use System Restore to return your machine to a previous good state.

    error_fail_fast_exception* =         1653.WinError
      ## A fail fast exception occurred. Exception handlers will not be invoked and the process will be terminated immediately.

    error_install_rejected* =            1654.WinError
      ## The app that you are trying to run is not supported on this version of Windows.

    error_dynamic_code_blocked* =        1655.WinError
      ## The operation was blocked as the process prohibits dynamic code generation.

    error_not_same_object* =             1656.WinError
      ## The objects are not identical.


    ##################################################
    #                                               ##
    #               RPC Error codes                 ##
    #                                               ##
    #                 1700 to 1999                  ##
    ##################################################

    rpc_s_invalid_string_binding* =      1700.WinError
      ## The string binding is invalid.

    rpc_s_wrong_kind_of_binding* =       1701.WinError
      ## The binding handle is not the correct type.

    rpc_s_invalid_binding* =             1702.WinError
      ## The binding handle is invalid.

    rpc_s_protseq_not_supported* =       1703.WinError
      ## The RPC protocol sequence is not supported.

    rpc_s_invalid_rpc_protseq* =         1704.WinError
      ## The RPC protocol sequence is invalid.

    rpc_s_invalid_string_uuid* =         1705.WinError
      ## The string universal unique identifier (UUID) is invalid.

    rpc_s_invalid_endpoint_format* =     1706.WinError
      ## The endpoint format is invalid.

    rpc_s_invalid_net_addr* =            1707.WinError
      ## The network address is invalid.

    rpc_s_no_endpoint_found* =           1708.WinError
      ## No endpoint was found.

    rpc_s_invalid_timeout* =             1709.WinError
      ## The timeout value is invalid.

    rpc_s_object_not_found* =            1710.WinError
      ## The object universal unique identifier (UUID) was not found.

    rpc_s_already_registered* =          1711.WinError
      ## The object universal unique identifier (UUID) has already been registered.

    rpc_s_type_already_registered* =     1712.WinError
      ## The type universal unique identifier (UUID) has already been registered.

    rpc_s_already_listening* =           1713.WinError
      ## The RPC server is already listening.

    rpc_s_no_protseqs_registered* =      1714.WinError
      ## No protocol sequences have been registered.

    rpc_s_not_listening* =               1715.WinError
      ## The RPC server is not listening.

    rpc_s_unknown_mgr_type* =            1716.WinError
      ## The manager type is unknown.

    rpc_s_unknown_if* =                  1717.WinError
      ## The interface is unknown.

    rpc_s_no_bindings* =                 1718.WinError
      ## There are no bindings.

    rpc_s_no_protseqs* =                 1719.WinError
      ## There are no protocol sequences.

    rpc_s_cant_create_endpoint* =        1720.WinError
      ## The endpoint cannot be created.

    rpc_s_out_of_resources* =            1721.WinError
      ## Not enough resources are available to complete this operation.

    rpc_s_server_unavailable* =          1722.WinError
      ## The RPC server is unavailable.

    rpc_s_server_too_busy* =             1723.WinError
      ## The RPC server is too busy to complete this operation.

    rpc_s_invalid_network_options* =     1724.WinError
      ## The network options are invalid.

    rpc_s_no_call_active* =              1725.WinError
      ## There are no remote procedure calls active on this thread.

    rpc_s_call_failed* =                 1726.WinError
      ## The remote procedure call failed.

    rpc_s_call_failed_dne* =             1727.WinError
      ## The remote procedure call failed and did not execute.

    rpc_s_protocol_error* =              1728.WinError
      ## A remote procedure call (RPC) protocol error occurred.

    rpc_s_proxy_access_denied* =         1729.WinError
      ## Access to the HTTP proxy is denied.

    rpc_s_unsupported_trans_syn* =       1730.WinError
      ## The transfer syntax is not supported by the RPC server.

    rpc_s_unsupported_type* =            1732.WinError
      ## The universal unique identifier (UUID) type is not supported.

    rpc_s_invalid_tag* =                 1733.WinError
      ## The tag is invalid.

    rpc_s_invalid_bound* =               1734.WinError
      ## The array bounds are invalid.

    rpc_s_no_entry_name* =               1735.WinError
      ## The binding does not contain an entry name.

    rpc_s_invalid_name_syntax* =         1736.WinError
      ## The name syntax is invalid.

    rpc_s_unsupported_name_syntax* =     1737.WinError
      ## The name syntax is not supported.

    rpc_s_uuid_no_address* =             1739.WinError
      ## No network address is available to use to construct a universal unique identifier (UUID).

    rpc_s_duplicate_endpoint* =          1740.WinError
      ## The endpoint is a duplicate.

    rpc_s_unknown_authn_type* =          1741.WinError
      ## The authentication type is unknown.

    rpc_s_max_calls_too_small* =         1742.WinError
      ## The maximum number of calls is too small.

    rpc_s_string_too_long* =             1743.WinError
      ## The string is too long.

    rpc_s_protseq_not_found* =           1744.WinError
      ## The RPC protocol sequence was not found.

    rpc_s_procnum_out_of_range* =        1745.WinError
      ## The procedure number is out of range.

    rpc_s_binding_has_no_auth* =         1746.WinError
      ## The binding does not contain any authentication information.

    rpc_s_unknown_authn_service* =       1747.WinError
      ## The authentication service is unknown.

    rpc_s_unknown_authn_level* =         1748.WinError
      ## The authentication level is unknown.

    rpc_s_invalid_auth_identity* =       1749.WinError
      ## The security context is invalid.

    rpc_s_unknown_authz_service* =       1750.WinError
      ## The authorization service is unknown.

    ept_s_invalid_entry* =               1751.WinError
      ## The entry is invalid.

    ept_s_cant_perform_op* =             1752.WinError
      ## The server endpoint cannot perform the operation.

    ept_s_not_registered* =              1753.WinError
      ## There are no more endpoints available from the endpoint mapper.

    rpc_s_nothing_to_export* =           1754.WinError
      ## No interfaces have been exported.

    rpc_s_incomplete_name* =             1755.WinError
      ## The entry name is incomplete.

    rpc_s_invalid_vers_option* =         1756.WinError
      ## The version option is invalid.

    rpc_s_no_more_members* =             1757.WinError
      ## There are no more members.

    rpc_s_not_all_objs_unexported* =     1758.WinError
      ## There is nothing to unexport.

    rpc_s_interface_not_found* =         1759.WinError
      ## The interface was not found.

    rpc_s_entry_already_exists* =        1760.WinError
      ## The entry already exists.

    rpc_s_entry_not_found* =             1761.WinError
      ## The entry is not found.

    rpc_s_name_service_unavailable* =    1762.WinError
      ## The name service is unavailable.

    rpc_s_invalid_naf_id* =              1763.WinError
      ## The network address family is invalid.

    rpc_s_cannot_support* =              1764.WinError
      ## The requested operation is not supported.

    rpc_s_no_context_available* =        1765.WinError
      ## No security context is available to allow impersonation.

    rpc_s_internal_error* =              1766.WinError
      ## An internal error occurred in a remote procedure call (RPC).

    rpc_s_zero_divide* =                 1767.WinError
      ## The RPC server attempted an integer division by zero.

    rpc_s_address_error* =               1768.WinError
      ## An addressing error occurred in the RPC server.

    rpc_s_fp_div_zero* =                 1769.WinError
      ## A floating-point operation at the RPC server caused a division by zero.

    rpc_s_fp_underflow* =                1770.WinError
      ## A floating-point underflow occurred at the RPC server.

    rpc_s_fp_overflow* =                 1771.WinError
      ## A floating-point overflow occurred at the RPC server.

    rpc_x_no_more_entries* =             1772.WinError
      ## The list of RPC servers available for the binding of auto handles has been exhausted.

    rpc_x_ss_char_trans_open_fail* =     1773.WinError
      ## Unable to open the character translation table file.

    rpc_x_ss_char_trans_short_file* =    1774.WinError
      ## The file containing the character translation table has fewer than 512 bytes.

    rpc_x_ss_in_null_context* =          1775.WinError
      ## A null context handle was passed from the client to the host during a remote procedure call.

    rpc_x_ss_context_damaged* =          1777.WinError
      ## The context handle changed during a remote procedure call.

    rpc_x_ss_handles_mismatch* =         1778.WinError
      ## The binding handles passed to a remote procedure call do not match.

    rpc_x_ss_cannot_get_call_handle* =   1779.WinError
      ## The stub is unable to get the remote procedure call handle.

    rpc_x_null_ref_pointer* =            1780.WinError
      ## A null reference pointer was passed to the stub.

    rpc_x_enum_value_out_of_range* =     1781.WinError
      ## The enumeration value is out of range.

    rpc_x_byte_count_too_small* =        1782.WinError
      ## The byte count is too small.

    rpc_x_bad_stub_data* =               1783.WinError
      ## The stub received bad data.

    error_invalid_user_buffer* =         1784.WinError
      ## The supplied user buffer is not valid for the requested operation.

    error_unrecognized_media* =          1785.WinError
      ## The disk media is not recognized. It may not be formatted.

    error_no_trust_lsa_secret* =         1786.WinError
      ## The workstation does not have a trust secret.

    error_no_trust_sam_account* =        1787.WinError
      ## The security database on the server does not have a computer account for this workstation trust relationship.

    error_trusted_domain_failure* =      1788.WinError
      ## The trust relationship between the primary domain and the trusted domain failed.

    error_trusted_relationship_failure* =  1789.WinError
      ## The trust relationship between this workstation and the primary domain failed.

    error_trust_failure* =               1790.WinError
      ## The network logon failed.

    rpc_s_call_in_progress* =            1791.WinError
      ## A remote procedure call is already in progress for this thread.

    error_netlogon_not_started* =        1792.WinError
      ## An attempt was made to logon, but the network logon service was not started.

    error_account_expired* =             1793.WinError
      ## The user's account has expired.

    error_redirector_has_open_handles* =  1794.WinError
      ## The redirector is in use and cannot be unloaded.

    error_printer_driver_already_installed* =  1795.WinError
      ## The specified printer driver is already installed.

    error_unknown_port* =                1796.WinError
      ## The specified port is unknown.

    error_unknown_printer_driver* =      1797.WinError
      ## The printer driver is unknown.

    error_unknown_printprocessor* =      1798.WinError
      ## The print processor is unknown.

    error_invalid_separator_file* =      1799.WinError
      ## The specified separator file is invalid.

    error_invalid_priority* =            1800.WinError
      ## The specified priority is invalid.

    error_invalid_printer_name* =        1801.WinError
      ## The printer name is invalid.

    error_printer_already_exists* =      1802.WinError
      ## The printer already exists.

    error_invalid_printer_command* =     1803.WinError
      ## The printer command is invalid.

    error_invalid_datatype* =            1804.WinError
      ## The specified datatype is invalid.

    error_invalid_environment* =         1805.WinError
      ## The environment specified is invalid.

    rpc_s_no_more_bindings* =            1806.WinError
      ## There are no more bindings.

    error_nologon_interdomain_trust_account* =  1807.WinError
      ## The account used is an interdomain trust account. Use your global user account or local user account to access this server.

    error_nologon_workstation_trust_account* =  1808.WinError
      ## The account used is a computer account. Use your global user account or local user account to access this server.

    error_nologon_server_trust_account* =  1809.WinError
      ## The account used is a server trust account. Use your global user account or local user account to access this server.

    error_domain_trust_inconsistent* =   1810.WinError
      ## The name or security ID (SID) of the domain specified is inconsistent with the trust information for that domain.

    error_server_has_open_handles* =     1811.WinError
      ## The server is in use and cannot be unloaded.

    error_resource_data_not_found* =     1812.WinError
      ## The specified image file did not contain a resource section.

    error_resource_type_not_found* =     1813.WinError
      ## The specified resource type cannot be found in the image file.

    error_resource_name_not_found* =     1814.WinError
      ## The specified resource name cannot be found in the image file.

    error_resource_lang_not_found* =     1815.WinError
      ## The specified resource language ID cannot be found in the image file.

    error_not_enough_quota* =            1816.WinError
      ## Not enough quota is available to process this command.

    rpc_s_no_interfaces* =               1817.WinError
      ## No interfaces have been registered.

    rpc_s_call_cancelled* =              1818.WinError
      ## The remote procedure call was cancelled.

    rpc_s_binding_incomplete* =          1819.WinError
      ## The binding handle does not contain all required information.

    rpc_s_comm_failure* =                1820.WinError
      ## A communications failure occurred during a remote procedure call.

    rpc_s_unsupported_authn_level* =     1821.WinError
      ## The requested authentication level is not supported.

    rpc_s_no_princ_name* =               1822.WinError
      ## No principal name registered.

    rpc_s_not_rpc_error* =               1823.WinError
      ## The error specified is not a valid Windows RPC error code.

    rpc_s_uuid_local_only* =             1824.WinError
      ## A UUID that is valid only on this computer has been allocated.

    rpc_s_sec_pkg_error* =               1825.WinError
      ## A security package specific error occurred.

    rpc_s_not_cancelled* =               1826.WinError
      ## Thread is not canceled.

    rpc_x_invalid_es_action* =           1827.WinError
      ## Invalid operation on the encoding/decoding handle.

    rpc_x_wrong_es_version* =            1828.WinError
      ## Incompatible version of the serializing package.

    rpc_x_wrong_stub_version* =          1829.WinError
      ## Incompatible version of the RPC stub.

    rpc_x_invalid_pipe_object* =         1830.WinError
      ## The RPC pipe object is invalid or corrupted.

    rpc_x_wrong_pipe_order* =            1831.WinError
      ## An invalid operation was attempted on an RPC pipe object.

    rpc_x_wrong_pipe_version* =          1832.WinError
      ## Unsupported RPC pipe version.

    rpc_s_cookie_auth_failed* =          1833.WinError
      ## HTTP proxy server rejected the connection because the cookie authentication failed.

    rpc_s_do_not_disturb* =              1834.WinError
      ## The RPC server is suspended, and could not be resumed for this request. The call did not execute.

    rpc_s_system_handle_count_exceeded* =  1835.WinError
      ## The RPC call contains too many handles to be transmitted in a single request.

    rpc_s_system_handle_type_mismatch* =  1836.WinError
      ## The RPC call contains a handle that differs from the declared handle type.

    rpc_s_group_member_not_found* =      1898.WinError
      ## The group member was not found.

    ept_s_cant_create* =                 1899.WinError
      ## The endpoint mapper database entry could not be created.

    rpc_s_invalid_object* =              1900.WinError
      ## The object universal unique identifier (UUID) is the nil UUID.

    error_invalid_time* =                1901.WinError
      ## The specified time is invalid.

    error_invalid_form_name* =           1902.WinError
      ## The specified form name is invalid.

    error_invalid_form_size* =           1903.WinError
      ## The specified form size is invalid.

    error_already_waiting* =             1904.WinError
      ## The specified printer handle is already being waited on

    error_printer_deleted* =             1905.WinError
      ## The specified printer has been deleted.

    error_invalid_printer_state* =       1906.WinError
      ## The state of the printer is invalid.

    error_password_must_change* =        1907.WinError
      ## The user's password must be changed before signing in.

    error_domain_controller_not_found* =  1908.WinError
      ## Could not find the domain controller for this domain.

    error_account_locked_out* =          1909.WinError
      ## The referenced account is currently locked out and may not be logged on to.

    or_invalid_oxid* =                   1910.WinError
      ## The object exporter specified was not found.

    or_invalid_oid* =                    1911.WinError
      ## The object specified was not found.

    or_invalid_set* =                    1912.WinError
      ## The object resolver set specified was not found.

    rpc_s_send_incomplete* =             1913.WinError
      ## Some data remains to be sent in the request buffer.

    rpc_s_invalid_async_handle* =        1914.WinError
      ## Invalid asynchronous remote procedure call handle.

    rpc_s_invalid_async_call* =          1915.WinError
      ## Invalid asynchronous RPC call handle for this operation.

    rpc_x_pipe_closed* =                 1916.WinError
      ## The RPC pipe object has already been closed.

    rpc_x_pipe_discipline_error* =       1917.WinError
      ## The RPC call completed before all pipes were processed.

    rpc_x_pipe_empty* =                  1918.WinError
      ## No more data is available from the RPC pipe.

    error_no_sitename* =                 1919.WinError
      ## No site name is available for this machine.

    error_cant_access_file* =            1920.WinError
      ## The file cannot be accessed by the system.

    error_cant_resolve_filename* =       1921.WinError
      ## The name of the file cannot be resolved by the system.

    rpc_s_entry_type_mismatch* =         1922.WinError
      ## The entry is not of the expected type.

    rpc_s_not_all_objs_exported* =       1923.WinError
      ## Not all object UUIDs could be exported to the specified entry.

    rpc_s_interface_not_exported* =      1924.WinError
      ## Interface could not be exported to the specified entry.

    rpc_s_profile_not_added* =           1925.WinError
      ## The specified profile entry could not be added.

    rpc_s_prf_elt_not_added* =           1926.WinError
      ## The specified profile element could not be added.

    rpc_s_prf_elt_not_removed* =         1927.WinError
      ## The specified profile element could not be removed.

    rpc_s_grp_elt_not_added* =           1928.WinError
      ## The group element could not be added.

    rpc_s_grp_elt_not_removed* =         1929.WinError
      ## The group element could not be removed.

    error_km_driver_blocked* =           1930.WinError
      ## The printer driver is not compatible with a policy enabled on your computer that blocks NT 4.0 drivers.

    error_context_expired* =             1931.WinError
      ## The context has expired and can no longer be used.

    error_per_user_trust_quota_exceeded* =  1932.WinError
      ## The current user's delegated trust creation quota has been exceeded.

    error_all_user_trust_quota_exceeded* =  1933.WinError
      ## The total delegated trust creation quota has been exceeded.

    error_user_delete_trust_quota_exceeded* =  1934.WinError
      ## The current user's delegated trust deletion quota has been exceeded.

    error_authentication_firewall_failed* =  1935.WinError
      ## The computer you are signing into is protected by an authentication firewall. The specified account is not allowed to authenticate to the computer.

    error_remote_print_connections_blocked* =  1936.WinError
      ## Remote connections to the Print Spooler are blocked by a policy set on your machine.

    error_ntlm_blocked* =                1937.WinError
      ## Authentication failed because NTLM authentication has been disabled.

    error_password_change_required* =    1938.WinError
      ## Logon Failure: EAS policy requires that the user change their password before this operation can be performed.


    ##################################################
    #                                               ##
    #              OpenGL Error codes               ##
    #                                               ##
    #                 2000 to 2009                  ##
    ##################################################

    error_invalid_pixel_format* =        2000.WinError
      ## The pixel format is invalid.

    error_bad_driver* =                  2001.WinError
      ## The specified driver is invalid.

    error_invalid_window_style* =        2002.WinError
      ## The window style or class attribute is invalid for this operation.

    error_metafile_not_supported* =      2003.WinError
      ## The requested metafile operation is not supported.

    error_transform_not_supported* =     2004.WinError
      ## The requested transformation operation is not supported.

    error_clipping_not_supported* =      2005.WinError
      ## The requested clipping operation is not supported.


    ##################################################
    #                                               ##
    #       Image Color Management Error codes      ##
    #                                               ##
    #                 2010 to 2049                  ##
    ##################################################

    error_invalid_cmm* =                 2010.WinError
      ## The specified color management module is invalid.

    error_invalid_profile* =             2011.WinError
      ## The specified color profile is invalid.

    error_tag_not_found* =               2012.WinError
      ## The specified tag was not found.

    error_tag_not_present* =             2013.WinError
      ## A required tag is not present.

    error_duplicate_tag* =               2014.WinError
      ## The specified tag is already present.

    error_profile_not_associated_with_device* =  2015.WinError
      ## The specified color profile is not associated with the specified device.

    error_profile_not_found* =           2016.WinError
      ## The specified color profile was not found.

    error_invalid_colorspace* =          2017.WinError
      ## The specified color space is invalid.

    error_icm_not_enabled* =             2018.WinError
      ## Image Color Management is not enabled.

    error_deleting_icm_xform* =          2019.WinError
      ## There was an error while deleting the color transform.

    error_invalid_transform* =           2020.WinError
      ## The specified color transform is invalid.

    error_colorspace_mismatch* =         2021.WinError
      ## The specified transform does not match the bitmap's color space.

    error_invalid_colorindex* =          2022.WinError
      ## The specified named color index is not present in the profile.

    error_profile_does_not_match_device* =  2023.WinError
      ## The specified profile is intended for a device of a different type than the specified device.


    ##################################################
    #                                               ##
    #             Winnet32 Error codes              ##
    #                                               ##
    #                 2100 to 2999                  ##
    #                                               ##
    # The range 2100 through 2999 is reserved for   ##
    # network status codes. See lmerr.h for a       ##
    # complete listing                              ##
    ##################################################

    error_connected_other_password* =    2108.WinError
      ## The network connection was made successfully, but the user had to be prompted for a password other than the one originally specified.

    error_connected_other_password_default* =  2109.WinError
      ## The network connection was made successfully using default credentials.

    error_bad_username* =                2202.WinError
      ## The specified username is invalid.

    error_not_connected* =               2250.WinError
      ## This network connection does not exist.

    error_open_files* =                  2401.WinError
      ## This network connection has files open or requests pending.

    error_active_connections* =          2402.WinError
      ## Active connections still exist.

    error_device_in_use* =               2404.WinError
      ## The device is in use by an active process and cannot be disconnected.


    ##################################################
    #                                               ##
    #           Win32 Spooler Error codes           ##
    #                                               ##
    #                 3000 to 3049                  ##
    ##################################################

    error_unknown_print_monitor* =       3000.WinError
      ## The specified print monitor is unknown.

    error_printer_driver_in_use* =       3001.WinError
      ## The specified printer driver is currently in use.

    error_spool_file_not_found* =        3002.WinError
      ## The spool file was not found.

    error_spl_no_startdoc* =             3003.WinError
      ## A StartDocPrinter call was not issued.

    error_spl_no_addjob* =               3004.WinError
      ## An AddJob call was not issued.

    error_print_processor_already_installed* =  3005.WinError
      ## The specified print processor has already been installed.

    error_print_monitor_already_installed* =  3006.WinError
      ## The specified print monitor has already been installed.

    error_invalid_print_monitor* =       3007.WinError
      ## The specified print monitor does not have the required functions.

    error_print_monitor_in_use* =        3008.WinError
      ## The specified print monitor is currently in use.

    error_printer_has_jobs_queued* =     3009.WinError
      ## The requested operation is not allowed when there are jobs queued to the printer.

    error_success_reboot_required* =     3010.WinError
      ## The requested operation is successful. Changes will not be effective until the system is rebooted.

    error_success_restart_required* =    3011.WinError
      ## The requested operation is successful. Changes will not be effective until the service is restarted.

    error_printer_not_found* =           3012.WinError
      ## No printers were found.

    error_printer_driver_warned* =       3013.WinError
      ## The printer driver is known to be unreliable.

    error_printer_driver_blocked* =      3014.WinError
      ## The printer driver is known to harm the system.

    error_printer_driver_package_in_use* =  3015.WinError
      ## The specified printer driver package is currently in use.

    error_core_driver_package_not_found* =  3016.WinError
      ## Unable to find a core driver package that is required by the printer driver package.

    error_fail_reboot_required* =        3017.WinError
      ## The requested operation failed. A system reboot is required to roll back changes made.

    error_fail_reboot_initiated* =       3018.WinError
      ## The requested operation failed. A system reboot has been initiated to roll back changes made.

    error_printer_driver_download_needed* =  3019.WinError
      ## The specified printer driver was not found on the system and needs to be downloaded.

    error_print_job_restart_required* =  3020.WinError
      ## The requested print job has failed to print. A print system update requires the job to be resubmitted.

    error_invalid_printer_driver_manifest* =  3021.WinError
      ## The printer driver does not contain a valid manifest, or contains too many manifests.

    error_printer_not_shareable* =       3022.WinError
      ## The specified printer cannot be shared.


    ##################################################
    #                                               ##
    #           CopyFile ext. Error codes           ##
    #                                               ##
    #                 3050 to 3059                  ##
    ##################################################

    error_request_paused* =              3050.WinError
      ## The operation was paused.


    ##################################################
    #                                               ##
    #                  Available                    ##
    #                                               ##
    #                 3060 to 3199                  ##
    ##################################################


    #
    #               the message range
    #                 3200 to 3299
    #      is reserved and used in isolation lib
    #

    ##################################################
    #                                               ##
    #                  Available                    ##
    #                                               ##
    #                 3300 to 3899                  ##
    ##################################################


    ##################################################
    #                                               ##
    #                IO Error Codes                 ##
    #                                               ##
    #                 3900 to 3999                  ##
    ##################################################

    error_io_reissue_as_cached* =        3950.WinError
      ## Reissue the given operation as a cached IO operation



    ##################################################
    #                                               ##
    #                Wins Error codes               ##
    #                                               ##
    #                 4000 to 4049                  ##
    ##################################################

    error_wins_internal* =               4000.WinError
      ## WINS encountered an error while processing the command.

    error_can_not_del_local_wins* =      4001.WinError
      ## The local WINS cannot be deleted.

    error_static_init* =                 4002.WinError
      ## The importation from the file failed.

    error_inc_backup* =                  4003.WinError
      ## The backup failed. Was a full backup done before?

    error_full_backup* =                 4004.WinError
      ## The backup failed. Check the directory to which you are backing the database.

    error_rec_non_existent* =            4005.WinError
      ## The name does not exist in the WINS database.

    error_rpl_not_allowed* =             4006.WinError
      ## Replication with a nonconfigured partner is not allowed.


    ##################################################
    #                                               ##
    #              PeerDist Error codes             ##
    #                                               ##
    #                 4050 to 4099                  ##
    ##################################################

    peerdist_error_contentinfo_version_unsupported* =  4050.WinError
      ## The version of the supplied content information is not supported.

    peerdist_error_cannot_parse_contentinfo* =  4051.WinError
      ## The supplied content information is malformed.

    peerdist_error_missing_data* =       4052.WinError
      ## The requested data cannot be found in local or peer caches.

    peerdist_error_no_more* =            4053.WinError
      ## No more data is available or required.

    peerdist_error_not_initialized* =    4054.WinError
      ## The supplied object has not been initialized.

    peerdist_error_already_initialized* =  4055.WinError
      ## The supplied object has already been initialized.

    peerdist_error_shutdown_in_progress* =  4056.WinError
      ## A shutdown operation is already in progress.

    peerdist_error_invalidated* =        4057.WinError
      ## The supplied object has already been invalidated.

    peerdist_error_already_exists* =     4058.WinError
      ## An element already exists and was not replaced.

    peerdist_error_operation_notfound* =  4059.WinError
      ## Can not cancel the requested operation as it has already been completed.

    peerdist_error_already_completed* =  4060.WinError
      ## Can not perform the reqested operation because it has already been carried out.

    peerdist_error_out_of_bounds* =      4061.WinError
      ## An operation accessed data beyond the bounds of valid data.

    peerdist_error_version_unsupported* =  4062.WinError
      ## The requested version is not supported.

    peerdist_error_invalid_configuration* =  4063.WinError
      ## A configuration value is invalid.

    peerdist_error_not_licensed* =       4064.WinError
      ## The SKU is not licensed.

    peerdist_error_service_unavailable* =  4065.WinError
      ## PeerDist Service is still initializing and will be available shortly.

    peerdist_error_trust_failure* =      4066.WinError
      ## Communication with one or more computers will be temporarily blocked due to recent errors.


    ##################################################
    #                                               ##
    #               DHCP Error codes                ##
    #                                               ##
    #                 4100 to 4149                  ##
    ##################################################

    error_dhcp_address_conflict* =       4100.WinError
      ## The DHCP client has obtained an IP address that is already in use on the network. The local interface will be disabled until the DHCP client can obtain a new address.


    ##################################################
    #                                               ##
    #                  Available                    ##
    #                                               ##
    #                 4150 to 4199                  ##
    ##################################################


    ##################################################
    #                                               ##
    #               WMI Error codes                 ##
    #                                               ##
    #                 4200 to 4249                  ##
    ##################################################

    error_wmi_guid_not_found* =          4200.WinError
      ## The GUID passed was not recognized as valid by a WMI data provider.

    error_wmi_instance_not_found* =      4201.WinError
      ## The instance name passed was not recognized as valid by a WMI data provider.

    error_wmi_itemid_not_found* =        4202.WinError
      ## The data item ID passed was not recognized as valid by a WMI data provider.

    error_wmi_try_again* =               4203.WinError
      ## The WMI request could not be completed and should be retried.

    error_wmi_dp_not_found* =            4204.WinError
      ## The WMI data provider could not be located.

    error_wmi_unresolved_instance_ref* =  4205.WinError
      ## The WMI data provider references an instance set that has not been registered.

    error_wmi_already_enabled* =         4206.WinError
      ## The WMI data block or event notification has already been enabled.

    error_wmi_guid_disconnected* =       4207.WinError
      ## The WMI data block is no longer available.

    error_wmi_server_unavailable* =      4208.WinError
      ## The WMI data service is not available.

    error_wmi_dp_failed* =               4209.WinError
      ## The WMI data provider failed to carry out the request.

    error_wmi_invalid_mof* =             4210.WinError
      ## The WMI MOF information is not valid.

    error_wmi_invalid_reginfo* =         4211.WinError
      ## The WMI registration information is not valid.

    error_wmi_already_disabled* =        4212.WinError
      ## The WMI data block or event notification has already been disabled.

    error_wmi_read_only* =               4213.WinError
      ## The WMI data item or data block is read only.

    error_wmi_set_failure* =             4214.WinError
      ## The WMI data item or data block could not be changed.


    ##################################################
    #                                               ##
    #      app container Specific Error Codes        ##
    #                                               ##
    #                 4250 to 4299                  ##
    ##################################################

    error_not_appcontainer* =            4250.WinError
      ## This operation is only valid in the context of an app container.

    error_appcontainer_required* =       4251.WinError
      ## This application can only run in the context of an app container.

    error_not_supported_in_appcontainer* =  4252.WinError
      ## This functionality is not supported in the context of an app container.

    error_invalid_package_sid_length* =  4253.WinError
      ## The length of the SID supplied is not a valid length for app container SIDs.

    ##################################################
    #                                               ##
    #        RSM (Media Services) Error codes       ##
    #                                               ##
    #                 4300 to 4349                  ##
    ##################################################

    error_invalid_media* =               4300.WinError
      ## The media identifier does not represent a valid medium.

    error_invalid_library* =             4301.WinError
      ## The library identifier does not represent a valid library.

    error_invalid_media_pool* =          4302.WinError
      ## The media pool identifier does not represent a valid media pool.

    error_drive_media_mismatch* =        4303.WinError
      ## The drive and medium are not compatible or exist in different libraries.

    error_media_offline* =               4304.WinError
      ## The medium currently exists in an offline library and must be online to perform this operation.

    error_library_offline* =             4305.WinError
      ## The operation cannot be performed on an offline library.

    error_empty* =                       4306.WinError
      ## The library, drive, or media pool is empty.

    error_not_empty* =                   4307.WinError
      ## The library, drive, or media pool must be empty to perform this operation.

    error_media_unavailable* =           4308.WinError
      ## No media is currently available in this media pool or library.

    error_resource_disabled* =           4309.WinError
      ## A resource required for this operation is disabled.

    error_invalid_cleaner* =             4310.WinError
      ## The media identifier does not represent a valid cleaner.

    error_unable_to_clean* =             4311.WinError
      ## The drive cannot be cleaned or does not support cleaning.

    error_object_not_found* =            4312.WinError
      ## The object identifier does not represent a valid object.

    error_database_failure* =            4313.WinError
      ## Unable to read from or write to the database.

    error_database_full* =               4314.WinError
      ## The database is full.

    error_media_incompatible* =          4315.WinError
      ## The medium is not compatible with the device or media pool.

    error_resource_not_present* =        4316.WinError
      ## The resource required for this operation does not exist.

    error_invalid_operation* =           4317.WinError
      ## The operation identifier is not valid.

    error_media_not_available* =         4318.WinError
      ## The media is not mounted or ready for use.

    error_device_not_available* =        4319.WinError
      ## The device is not ready for use.

    error_request_refused* =             4320.WinError
      ## The operator or administrator has refused the request.

    error_invalid_drive_object* =        4321.WinError
      ## The drive identifier does not represent a valid drive.

    error_library_full* =                4322.WinError
      ## Library is full. No slot is available for use.

    error_medium_not_accessible* =       4323.WinError
      ## The transport cannot access the medium.

    error_unable_to_load_medium* =       4324.WinError
      ## Unable to load the medium into the drive.

    error_unable_to_inventory_drive* =   4325.WinError
      ## Unable to retrieve the drive status.

    error_unable_to_inventory_slot* =    4326.WinError
      ## Unable to retrieve the slot status.

    error_unable_to_inventory_transport* =  4327.WinError
      ## Unable to retrieve status about the transport.

    error_transport_full* =              4328.WinError
      ## Cannot use the transport because it is already in use.

    error_controlling_ieport* =          4329.WinError
      ## Unable to open or close the inject/eject port.

    error_unable_to_eject_mounted_media* =  4330.WinError
      ## Unable to eject the medium because it is in a drive.

    error_cleaner_slot_set* =            4331.WinError
      ## A cleaner slot is already reserved.

    error_cleaner_slot_not_set* =        4332.WinError
      ## A cleaner slot is not reserved.

    error_cleaner_cartridge_spent* =     4333.WinError
      ## The cleaner cartridge has performed the maximum number of drive cleanings.

    error_unexpected_omid* =             4334.WinError
      ## Unexpected on-medium identifier.

    error_cant_delete_last_item* =       4335.WinError
      ## The last remaining item in this group or resource cannot be deleted.

    error_message_exceeds_max_size* =    4336.WinError
      ## The message provided exceeds the maximum size allowed for this parameter.

    error_volume_contains_sys_files* =   4337.WinError
      ## The volume contains system or paging files.

    error_indigenous_type* =             4338.WinError
      ## The media type cannot be removed from this library since at least one drive in the library reports it can support this media type.

    error_no_supporting_drives* =        4339.WinError
      ## This offline media cannot be mounted on this system since no enabled drives are present which can be used.

    error_cleaner_cartridge_installed* =  4340.WinError
      ## A cleaner cartridge is present in the tape library.

    error_ieport_full* =                 4341.WinError
      ## Cannot use the inject/eject port because it is not empty.


    ##################################################
    #                                               ##
    #       Remote Storage Service Error codes      ##
    #                                               ##
    #                 4350 to 4389                  ##
    ##################################################

    error_file_offline* =                4350.WinError
      ## This file is currently not available for use on this computer.

    error_remote_storage_not_active* =   4351.WinError
      ## The remote storage service is not operational at this time.

    error_remote_storage_media_error* =  4352.WinError
      ## The remote storage service encountered a media error.


    ##################################################
    #                                               ##
    #           Reparse Point Error codes           ##
    #                                               ##
    #                 4390 to 4399                  ##
    ##################################################

    error_not_a_reparse_point* =         4390.WinError
      ## The file or directory is not a reparse point.

    error_reparse_attribute_conflict* =  4391.WinError
      ## The reparse point attribute cannot be set because it conflicts with an existing attribute.

    error_invalid_reparse_data* =        4392.WinError
      ## The data present in the reparse point buffer is invalid.

    error_reparse_tag_invalid* =         4393.WinError
      ## The tag present in the reparse point buffer is invalid.

    error_reparse_tag_mismatch* =        4394.WinError
      ## There is a mismatch between the tag specified in the request and the tag present in the reparse point.

    error_reparse_point_encountered* =   4395.WinError
      ## The object manager encountered a reparse point while retrieving an object.


    ##################################################
    #                                               ##
    #         Fast Cache Specific Error Codes       ##
    #                                               ##
    #                 4400 to 4419                  ##
    ##################################################

    error_app_data_not_found* =          4400.WinError
      ## Fast Cache data not found.

    error_app_data_expired* =            4401.WinError
      ## Fast Cache data expired.

    error_app_data_corrupt* =            4402.WinError
      ## Fast Cache data corrupt.

    error_app_data_limit_exceeded* =     4403.WinError
      ## Fast Cache data has exceeded its max size and cannot be updated.

    error_app_data_reboot_required* =    4404.WinError
      ## Fast Cache has been ReArmed and requires a reboot until it can be updated.


    ##################################################
    #                                               ##
    #             SecureBoot Error codes            ##
    #                                               ##
    #                 4420 to 4439                  ##
    ##################################################

    error_secureboot_rollback_detected* =  4420.WinError
      ## Secure Boot detected that rollback of protected data has been attempted.

    error_secureboot_policy_violation* =  4421.WinError
      ## The value is protected by Secure Boot policy and cannot be modified or deleted.

    error_secureboot_invalid_policy* =   4422.WinError
      ## The Secure Boot policy is invalid.

    error_secureboot_policy_publisher_not_found* =  4423.WinError
      ## A new Secure Boot policy did not contain the current publisher on its update list.

    error_secureboot_policy_not_signed* =  4424.WinError
      ## The Secure Boot policy is either not signed or is signed by a non-trusted signer.

    error_secureboot_not_enabled* =      4425.WinError
      ## Secure Boot is not enabled on this machine.

    error_secureboot_file_replaced* =    4426.WinError
      ## Secure Boot requires that certain files and drivers are not replaced by other files or drivers.

    error_secureboot_policy_not_authorized* =  4427.WinError
      ## The Secure Boot Supplemental Policy file was not authorized on this machine.

    error_secureboot_policy_unknown* =   4428.WinError
      ## The Supplemntal Policy is not recognized on this device.

    error_secureboot_policy_missing_antirollbackversion* =  4429.WinError
      ## The Antirollback version was not found in the Secure Boot Policy.

    error_secureboot_platform_id_mismatch* =  4430.WinError
      ## The Platform ID specified in the Secure Boot policy does not match the Platform ID on this device.

    error_secureboot_policy_rollback_detected* =  4431.WinError
      ## The Secure Boot policy file has an older Antirollback Version than this device.

    error_secureboot_policy_upgrade_mismatch* =  4432.WinError
      ## The Secure Boot policy file does not match the upgraded legacy policy.

    error_secureboot_required_policy_file_missing* =  4433.WinError
      ## The Secure Boot policy file is required but could not be found.

    error_secureboot_not_base_policy* =  4434.WinError
      ## Supplemental Secure Boot policy file can not be loaded as a base Secure Boot policy.

    error_secureboot_not_supplemental_policy* =  4435.WinError
      ## Base Secure Boot policy file can not be loaded as a Supplemental Secure Boot policy.


    ##################################################
    #                                               ##
    #   File System Supported Features Error Codes  ##
    #                                               ##
    #                 4440 to 4499                  ##
    ##################################################

    error_offload_read_flt_not_supported* =  4440.WinError
      ## The copy offload read operation is not supported by a filter.

    error_offload_write_flt_not_supported* =  4441.WinError
      ## The copy offload write operation is not supported by a filter.

    error_offload_read_file_not_supported* =  4442.WinError
      ## The copy offload read operation is not supported for the file.

    error_offload_write_file_not_supported* =  4443.WinError
      ## The copy offload write operation is not supported for the file.


    ##################################################
    #                                               ##
    #    Single Instance Store (SIS) Error codes    ##
    #                                               ##
    #                 4500 to 4549                  ##
    ##################################################

    error_volume_not_sis_enabled* =      4500.WinError
      ## Single Instance Storage is not available on this volume.


    ##################################################
    #                                               ##
    #             System Integrity Error codes      ##
    #                                               ##
    #                 4550 to 4559                  ##
    ##################################################

    error_system_integrity_rollback_detected* =  4550.WinError
      ## System Integrity detected that policy rollback has been attempted.

    error_system_integrity_policy_violation* =  4551.WinError
      ## Your organization used Device Guard to block this app. Contact your support person for more info.

    error_system_integrity_invalid_policy* =  4552.WinError
      ## The System Integrity policy is invalid.

    error_system_integrity_policy_not_signed* =  4553.WinError
      ## The System Integrity policy is either not signed or is signed by a non-trusted signer.


    ##################################################
    #                                               ##
    #             VSM Error codes                   ##
    #                                               ##
    #                 4560 to 4569                  ##
    ##################################################

    error_vsm_not_initialized* =         4560.WinError
      ## Virtual Secure Mode (VSM) is not initialized. The hypervisor or VSM may not be present or enabled.

    error_vsm_dma_protection_not_in_use* =  4561.WinError
      ## The hypervisor is not protecting DMA because an IOMMU is not present or not enabled in the BIOS.

    ##################################################
    #                                               ##
    #         Platform Manifest Error Codes         ##
    #                                               ##
    #                 4570 to 4579                  ##
    ##################################################

    error_platform_manifest_not_authorized* =  4570.WinError
      ## The Platform Manifest file was not authorized on this machine.

    error_platform_manifest_invalid* =   4571.WinError
      ## The Platform Manifest file was not valid.

    error_platform_manifest_file_not_authorized* =  4572.WinError
      ## The file is not authorized on this platform because an entry was not found in the Platform Manifest.

    error_platform_manifest_catalog_not_authorized* =  4573.WinError
      ## The catalog is not authorized on this platform because an entry was not found in the Platform Manifest.

    error_platform_manifest_binary_id_not_found* =  4574.WinError
      ## The file is not authorized on this platform because a Binary ID was not found in the embedded signature.

    error_platform_manifest_not_active* =  4575.WinError
      ## No active Platform Manifest exists on this system.

    error_platform_manifest_not_signed* =  4576.WinError
      ## The Platform Manifest file was not properly signed.

    ##################################################
    #                                               ##
    #                  Available                    ##
    #                                               ##
    #                 4580 to 4599                  ##
    ##################################################

    ##################################################
    #                                               ##
    #             Cluster Error codes               ##
    #                                               ##
    #                 5000 to 5999                  ##
    ##################################################

    error_dependent_resource_exists* =   5001.WinError
      ## The operation cannot be completed because other resources are dependent on this resource.

    error_dependency_not_found* =        5002.WinError
      ## The cluster resource dependency cannot be found.

    error_dependency_already_exists* =   5003.WinError
      ## The cluster resource cannot be made dependent on the specified resource because it is already dependent.

    error_resource_not_online* =         5004.WinError
      ## The cluster resource is not online.

    error_host_node_not_available* =     5005.WinError
      ## A cluster node is not available for this operation.

    error_resource_not_available* =      5006.WinError
      ## The cluster resource is not available.

    error_resource_not_found* =          5007.WinError
      ## The cluster resource could not be found.

    error_shutdown_cluster* =            5008.WinError
      ## The cluster is being shut down.

    error_cant_evict_active_node* =      5009.WinError
      ## A cluster node cannot be evicted from the cluster unless the node is down or it is the last node.

    error_object_already_exists* =       5010.WinError
      ## The object already exists.

    error_object_in_list* =              5011.WinError
      ## The object is already in the list.

    error_group_not_available* =         5012.WinError
      ## The cluster group is not available for any new requests.

    error_group_not_found* =             5013.WinError
      ## The cluster group could not be found.

    error_group_not_online* =            5014.WinError
      ## The operation could not be completed because the cluster group is not online.

    error_host_node_not_resource_owner* =  5015.WinError
      ## The operation failed because either the specified cluster node is not the owner of the resource, or the node is not a possible owner of the resource.

    error_host_node_not_group_owner* =   5016.WinError
      ## The operation failed because either the specified cluster node is not the owner of the group, or the node is not a possible owner of the group.

    error_resmon_create_failed* =        5017.WinError
      ## The cluster resource could not be created in the specified resource monitor.

    error_resmon_online_failed* =        5018.WinError
      ## The cluster resource could not be brought online by the resource monitor.

    error_resource_online* =             5019.WinError
      ## The operation could not be completed because the cluster resource is online.

    error_quorum_resource* =             5020.WinError
      ## The cluster resource could not be deleted or brought offline because it is the quorum resource.

    error_not_quorum_capable* =          5021.WinError
      ## The cluster could not make the specified resource a quorum resource because it is not capable of being a quorum resource.

    error_cluster_shutting_down* =       5022.WinError
      ## The cluster software is shutting down.

    error_invalid_state* =               5023.WinError
      ## The group or resource is not in the correct state to perform the requested operation.

    error_resource_properties_stored* =  5024.WinError
      ## The properties were stored but not all changes will take effect until the next time the resource is brought online.

    error_not_quorum_class* =            5025.WinError
      ## The cluster could not make the specified resource a quorum resource because it does not belong to a shared storage class.

    error_core_resource* =               5026.WinError
      ## The cluster resource could not be deleted since it is a core resource.

    error_quorum_resource_online_failed* =  5027.WinError
      ## The quorum resource failed to come online.

    error_quorumlog_open_failed* =       5028.WinError
      ## The quorum log could not be created or mounted successfully.

    error_clusterlog_corrupt* =          5029.WinError
      ## The cluster log is corrupt.

    error_clusterlog_record_exceeds_maxsize* =  5030.WinError
      ## The record could not be written to the cluster log since it exceeds the maximum size.

    error_clusterlog_exceeds_maxsize* =  5031.WinError
      ## The cluster log exceeds its maximum size.

    error_clusterlog_chkpoint_not_found* =  5032.WinError
      ## No checkpoint record was found in the cluster log.

    error_clusterlog_not_enough_space* =  5033.WinError
      ## The minimum required disk space needed for logging is not available.

    error_quorum_owner_alive* =          5034.WinError
      ## The cluster node failed to take control of the quorum resource because the resource is owned by another active node.

    error_network_not_available* =       5035.WinError
      ## A cluster network is not available for this operation.

    error_node_not_available* =          5036.WinError
      ## A cluster node is not available for this operation.

    error_all_nodes_not_available* =     5037.WinError
      ## All cluster nodes must be running to perform this operation.

    error_resource_failed* =             5038.WinError
      ## A cluster resource failed.

    error_cluster_invalid_node* =        5039.WinError
      ## The cluster node is not valid.

    error_cluster_node_exists* =         5040.WinError
      ## The cluster node already exists.

    error_cluster_join_in_progress* =    5041.WinError
      ## A node is in the process of joining the cluster.

    error_cluster_node_not_found* =      5042.WinError
      ## The cluster node was not found.

    error_cluster_local_node_not_found* =  5043.WinError
      ## The cluster local node information was not found.

    error_cluster_network_exists* =      5044.WinError
      ## The cluster network already exists.

    error_cluster_network_not_found* =   5045.WinError
      ## The cluster network was not found.

    error_cluster_netinterface_exists* =  5046.WinError
      ## The cluster network interface already exists.

    error_cluster_netinterface_not_found* =  5047.WinError
      ## The cluster network interface was not found.

    error_cluster_invalid_request* =     5048.WinError
      ## The cluster request is not valid for this object.

    error_cluster_invalid_network_provider* =  5049.WinError
      ## The cluster network provider is not valid.

    error_cluster_node_down* =           5050.WinError
      ## The cluster node is down.

    error_cluster_node_unreachable* =    5051.WinError
      ## The cluster node is not reachable.

    error_cluster_node_not_member* =     5052.WinError
      ## The cluster node is not a member of the cluster.

    error_cluster_join_not_in_progress* =  5053.WinError
      ## A cluster join operation is not in progress.

    error_cluster_invalid_network* =     5054.WinError
      ## The cluster network is not valid.

    error_cluster_node_up* =             5056.WinError
      ## The cluster node is up.

    error_cluster_ipaddr_in_use* =       5057.WinError
      ## The cluster IP address is already in use.

    error_cluster_node_not_paused* =     5058.WinError
      ## The cluster node is not paused.

    error_cluster_no_security_context* =  5059.WinError
      ## No cluster security context is available.

    error_cluster_network_not_internal* =  5060.WinError
      ## The cluster network is not configured for internal cluster communication.

    error_cluster_node_already_up* =     5061.WinError
      ## The cluster node is already up.

    error_cluster_node_already_down* =   5062.WinError
      ## The cluster node is already down.

    error_cluster_network_already_online* =  5063.WinError
      ## The cluster network is already online.

    error_cluster_network_already_offline* =  5064.WinError
      ## The cluster network is already offline.

    error_cluster_node_already_member* =  5065.WinError
      ## The cluster node is already a member of the cluster.

    error_cluster_last_internal_network* =  5066.WinError
      ## The cluster network is the only one configured for internal cluster communication between two or more active cluster nodes. The internal communication capability cannot be removed from the network.

    error_cluster_network_has_dependents* =  5067.WinError
      ## One or more cluster resources depend on the network to provide service to clients. The client access capability cannot be removed from the network.

    error_invalid_operation_on_quorum* =  5068.WinError
      ## This operation cannot currently be performed on the cluster group containing the quorum resource.

    error_dependency_not_allowed* =      5069.WinError
      ## The cluster quorum resource is not allowed to have any dependencies.

    error_cluster_node_paused* =         5070.WinError
      ## The cluster node is paused.

    error_node_cant_host_resource* =     5071.WinError
      ## The cluster resource cannot be brought online. The owner node cannot run this resource.

    error_cluster_node_not_ready* =      5072.WinError
      ## The cluster node is not ready to perform the requested operation.

    error_cluster_node_shutting_down* =  5073.WinError
      ## The cluster node is shutting down.

    error_cluster_join_aborted* =        5074.WinError
      ## The cluster join operation was aborted.

    error_cluster_incompatible_versions* =  5075.WinError
      ## The node failed to join the cluster because the joining node and other nodes in the cluster have incompatible operating system versions. To get more information about operating system versions of the cluster, run the Validate a Configuration Wizard or the Test-Cluster Windows PowerShell cmdlet.

    error_cluster_maxnum_of_resources_exceeded* =  5076.WinError
      ## This resource cannot be created because the cluster has reached the limit on the number of resources it can monitor.

    error_cluster_system_config_changed* =  5077.WinError
      ## The system configuration changed during the cluster join or form operation. The join or form operation was aborted.

    error_cluster_resource_type_not_found* =  5078.WinError
      ## The specified resource type was not found.

    error_cluster_restype_not_supported* =  5079.WinError
      ## The specified node does not support a resource of this type. This may be due to version inconsistencies or due to the absence of the resource DLL on this node.

    error_cluster_resname_not_found* =   5080.WinError
      ## The specified resource name is not supported by this resource DLL. This may be due to a bad (or changed) name supplied to the resource DLL.

    error_cluster_no_rpc_packages_registered* =  5081.WinError
      ## No authentication package could be registered with the RPC server.

    error_cluster_owner_not_in_preflist* =  5082.WinError
      ## You cannot bring the group online because the owner of the group is not in the preferred list for the group. To change the owner node for the group, move the group.

    error_cluster_database_seqmismatch* =  5083.WinError
      ## The join operation failed because the cluster database sequence number has changed or is incompatible with the locker node. This may happen during a join operation if the cluster database was changing during the join.

    error_resmon_invalid_state* =        5084.WinError
      ## The resource monitor will not allow the fail operation to be performed while the resource is in its current state. This may happen if the resource is in a pending state.

    error_cluster_gum_not_locker* =      5085.WinError
      ## A non locker code got a request to reserve the lock for making global updates.

    error_quorum_disk_not_found* =       5086.WinError
      ## The quorum disk could not be located by the cluster service.

    error_database_backup_corrupt* =     5087.WinError
      ## The backed up cluster database is possibly corrupt.

    error_cluster_node_already_has_dfs_root* =  5088.WinError
      ## A DFS root already exists in this cluster node.

    error_resource_property_unchangeable* =  5089.WinError
      ## An attempt to modify a resource property failed because it conflicts with another existing property.

    error_no_admin_access_point* =       5090.WinError
      ## This operation is not supported on a cluster without an Administrator Access Point.

    #[
  Codes from 4300 through 5889 overlap with codes in ds\published\inc\apperr2.w.
  Do not add any more error codes in that range.
    ]#
    error_cluster_membership_invalid_state* =  5890.WinError
      ## An operation was attempted that is incompatible with the current membership state of the node.

    error_cluster_quorumlog_not_found* =  5891.WinError
      ## The quorum resource does not contain the quorum log.

    error_cluster_membership_halt* =     5892.WinError
      ## The membership engine requested shutdown of the cluster service on this node.

    error_cluster_instance_id_mismatch* =  5893.WinError
      ## The join operation failed because the cluster instance ID of the joining node does not match the cluster instance ID of the sponsor node.

    error_cluster_network_not_found_for_ip* =  5894.WinError
      ## A matching cluster network for the specified IP address could not be found.

    error_cluster_property_data_type_mismatch* =  5895.WinError
      ## The actual data type of the property did not match the expected data type of the property.

    error_cluster_evict_without_cleanup* =  5896.WinError
      ## The cluster node was evicted from the cluster successfully, but the node was not cleaned up. To determine what cleanup steps failed and how to recover, see the Failover Clustering application event log using Event Viewer.

    error_cluster_parameter_mismatch* =  5897.WinError
      ## Two or more parameter values specified for a resource's properties are in conflict.

    error_node_cannot_be_clustered* =    5898.WinError
      ## This computer cannot be made a member of a cluster.

    error_cluster_wrong_os_version* =    5899.WinError
      ## This computer cannot be made a member of a cluster because it does not have the correct version of Windows installed.

    error_cluster_cant_create_dup_cluster_name* =  5900.WinError
      ## A cluster cannot be created with the specified cluster name because that cluster name is already in use. Specify a different name for the cluster.

    error_cluscfg_already_committed* =   5901.WinError
      ## The cluster configuration action has already been committed.

    error_cluscfg_rollback_failed* =     5902.WinError
      ## The cluster configuration action could not be rolled back.

    error_cluscfg_system_disk_drive_letter_conflict* =  5903.WinError
      ## The drive letter assigned to a system disk on one node conflicted with the drive letter assigned to a disk on another node.

    error_cluster_old_version* =         5904.WinError
      ## One or more nodes in the cluster are running a version of Windows that does not support this operation.

    error_cluster_mismatched_computer_acct_name* =  5905.WinError
      ## The name of the corresponding computer account doesn't match the Network Name for this resource.

    error_cluster_no_net_adapters* =     5906.WinError
      ## No network adapters are available.

    error_cluster_poisoned* =            5907.WinError
      ## The cluster node has been poisoned.

    error_cluster_group_moving* =        5908.WinError
      ## The group is unable to accept the request since it is moving to another node.

    error_cluster_resource_type_busy* =  5909.WinError
      ## The resource type cannot accept the request since is too busy performing another operation.

    error_resource_call_timed_out* =     5910.WinError
      ## The call to the cluster resource DLL timed out.

    error_invalid_cluster_ipv6_address* =  5911.WinError
      ## The address is not valid for an IPv6 Address resource. A global IPv6 address is required, and it must match a cluster network. Compatibility addresses are not permitted.

    error_cluster_internal_invalid_function* =  5912.WinError
      ## An internal cluster error occurred. A call to an invalid function was attempted.

    error_cluster_parameter_out_of_bounds* =  5913.WinError
      ## A parameter value is out of acceptable range.

    error_cluster_partial_send* =        5914.WinError
      ## A network error occurred while sending data to another node in the cluster. The number of bytes transmitted was less than required.

    error_cluster_registry_invalid_function* =  5915.WinError
      ## An invalid cluster registry operation was attempted.

    error_cluster_invalid_string_termination* =  5916.WinError
      ## An input string of characters is not properly terminated.

    error_cluster_invalid_string_format* =  5917.WinError
      ## An input string of characters is not in a valid format for the data it represents.

    error_cluster_database_transaction_in_progress* =  5918.WinError
      ## An internal cluster error occurred. A cluster database transaction was attempted while a transaction was already in progress.

    error_cluster_database_transaction_not_in_progress* =  5919.WinError
      ## An internal cluster error occurred. There was an attempt to commit a cluster database transaction while no transaction was in progress.

    error_cluster_null_data* =           5920.WinError
      ## An internal cluster error occurred. Data was not properly initialized.

    error_cluster_partial_read* =        5921.WinError
      ## An error occurred while reading from a stream of data. An unexpected number of bytes was returned.

    error_cluster_partial_write* =       5922.WinError
      ## An error occurred while writing to a stream of data. The required number of bytes could not be written.

    error_cluster_cant_deserialize_data* =  5923.WinError
      ## An error occurred while deserializing a stream of cluster data.

    error_dependent_resource_property_conflict* =  5924.WinError
      ## One or more property values for this resource are in conflict with one or more property values associated with its dependent resource(s).

    error_cluster_no_quorum* =           5925.WinError
      ## A quorum of cluster nodes was not present to form a cluster.

    error_cluster_invalid_ipv6_network* =  5926.WinError
      ## The cluster network is not valid for an IPv6 Address resource, or it does not match the configured address.

    error_cluster_invalid_ipv6_tunnel_network* =  5927.WinError
      ## The cluster network is not valid for an IPv6 Tunnel resource. Check the configuration of the IP Address resource on which the IPv6 Tunnel resource depends.

    error_quorum_not_allowed_in_this_group* =  5928.WinError
      ## Quorum resource cannot reside in the Available Storage group.

    error_dependency_tree_too_complex* =  5929.WinError
      ## The dependencies for this resource are nested too deeply.

    error_exception_in_resource_call* =  5930.WinError
      ## The call into the resource DLL raised an unhandled exception.

    error_cluster_rhs_failed_initialization* =  5931.WinError
      ## The RHS process failed to initialize.

    error_cluster_not_installed* =       5932.WinError
      ## The Failover Clustering feature is not installed on this node.

    error_cluster_resources_must_be_online_on_the_same_node* =  5933.WinError
      ## The resources must be online on the same node for this operation

    error_cluster_max_nodes_in_cluster* =  5934.WinError
      ## A new node can not be added since this cluster is already at its maximum number of nodes.

    error_cluster_too_many_nodes* =      5935.WinError
      ## This cluster can not be created since the specified number of nodes exceeds the maximum allowed limit.

    error_cluster_object_already_used* =  5936.WinError
      ## An attempt to use the specified cluster name failed because an enabled computer object with the given name already exists in the domain.

    error_noncore_groups_found* =        5937.WinError
      ## This cluster cannot be destroyed. It has non-core application groups which must be deleted before the cluster can be destroyed.

    error_file_share_resource_conflict* =  5938.WinError
      ## File share associated with file share witness resource cannot be hosted by this cluster or any of its nodes.

    error_cluster_evict_invalid_request* =  5939.WinError
      ## Eviction of this node is invalid at this time. Due to quorum requirements node eviction will result in cluster shutdown.
      ## If it is the last node in the cluster, destroy cluster command should be used.

    error_cluster_singleton_resource* =  5940.WinError
      ## Only one instance of this resource type is allowed in the cluster.

    error_cluster_group_singleton_resource* =  5941.WinError
      ## Only one instance of this resource type is allowed per resource group.

    error_cluster_resource_provider_failed* =  5942.WinError
      ## The resource failed to come online due to the failure of one or more provider resources.

    error_cluster_resource_configuration_error* =  5943.WinError
      ## The resource has indicated that it cannot come online on any node.

    error_cluster_group_busy* =          5944.WinError
      ## The current operation cannot be performed on this group at this time.

    error_cluster_not_shared_volume* =   5945.WinError
      ## The directory or file is not located on a cluster shared volume.

    error_cluster_invalid_security_descriptor* =  5946.WinError
      ## The Security Descriptor does not meet the requirements for a cluster.

    error_cluster_shared_volumes_in_use* =  5947.WinError
      ## There is one or more shared volumes resources configured in the cluster.
      ## Those resources must be moved to available storage in order for operation to succeed.

    error_cluster_use_shared_volumes_api* =  5948.WinError
      ## This group or resource cannot be directly manipulated.
      ## Use shared volume APIs to perform desired operation.

    error_cluster_backup_in_progress* =  5949.WinError
      ## Back up is in progress. Please wait for backup completion before trying this operation again.

    error_non_csv_path* =                5950.WinError
      ## The path does not belong to a cluster shared volume.

    error_csv_volume_not_local* =        5951.WinError
      ## The cluster shared volume is not locally mounted on this node.

    error_cluster_watchdog_terminating* =  5952.WinError
      ## The cluster watchdog is terminating.

    error_cluster_resource_vetoed_move_incompatible_nodes* =  5953.WinError
      ## A resource vetoed a move between two nodes because they are incompatible.

    error_cluster_invalid_node_weight* =  5954.WinError
      ## The request is invalid either because node weight cannot be changed while the cluster is in disk-only quorum mode, or because changing the node weight would violate the minimum cluster quorum requirements.

    error_cluster_resource_vetoed_call* =  5955.WinError
      ## The resource vetoed the call.

    error_resmon_system_resources_lacking* =  5956.WinError
      ## Resource could not start or run because it could not reserve sufficient system resources.

    error_cluster_resource_vetoed_move_not_enough_resources_on_destination* =  5957.WinError
      ## A resource vetoed a move between two nodes because the destination currently does not have enough resources to complete the operation.

    error_cluster_resource_vetoed_move_not_enough_resources_on_source* = 5958.WinError
      ## A resource vetoed a move between two nodes because the source currently does not have enough resources to complete the operation.

    error_cluster_group_queued* =       5959.WinError
      ## The requested operation can not be completed because the group is queued for an operation.

    error_cluster_resource_locked_status* = 5960.WinError
      ## The requested operation can not be completed because a resource has locked status.

    error_cluster_shared_volume_failover_not_allowed* = 5961.WinError
      ## The resource cannot move to another node because a cluster shared volume vetoed the operation.

    error_cluster_node_drain_in_progress* = 5962.WinError
      ## A node drain is already in progress.

    error_cluster_disk_not_connected* = 5963.WinError
      ## Clustered storage is not connected to the node.

    error_disk_not_csv_capable* =       5964.WinError
      ## The disk is not configured in a way to be used with CSV. CSV disks must have at least one partition that is formatted with NTFS or REFS.

    error_resource_not_in_available_storage* = 5965.WinError
      ## The resource must be part of the Available Storage group to complete this action.

    error_cluster_shared_volume_redirected* = 5966.WinError
      ## CSVFS failed operation as volume is in redirected mode.

    error_cluster_shared_volume_not_redirected* = 5967.WinError
      ## CSVFS failed operation as volume is not in redirected mode.

    error_cluster_cannot_return_properties* = 5968.WinError
      ## Cluster properties cannot be returned at this time.

    error_cluster_resource_contains_unsupported_diff_area_for_shared_volumes* = 5969.WinError
      ## The clustered disk resource contains software snapshot diff area that are not supported for Cluster Shared Volumes.

    error_cluster_resource_is_in_maintenance_mode* = 5970.WinError
      ## The operation cannot be completed because the resource is in maintenance mode.

    error_cluster_affinity_conflict* =  5971.WinError
      ## The operation cannot be completed because of cluster affinity conflicts

    error_cluster_resource_is_replica_virtual_machine* = 5972.WinError
      ## The operation cannot be completed because the resource is a replica virtual machine.

    error_cluster_upgrade_incompatible_versions* = 5973.WinError
      ## The Cluster Functional Level could not be increased because not all nodes in the cluster support the updated version.

    error_cluster_upgrade_fix_quorum_not_supported* = 5974.WinError
      ## Updating the cluster functional level failed because the cluster is running in fix quorum mode.
      ## Start additional nodes which are members of the cluster until the cluster reaches quorum and the cluster will automatically
      ## switch out of fix quorum mode, or stop and restart the cluster without the FixQuorum switch. Once the cluster is out
      ## of fix quorum mode retry the Update-ClusterFunctionalLevel PowerShell cmdlet to update the cluster functional level.

    error_cluster_upgrade_restart_required* = 5975.WinError
      ## The cluster functional level has been successfully updated but not all features are available yet. Restart the cluster by
      ## using the Stop-Cluster PowerShell cmdlet followed by the Start-Cluster PowerShell cmdlet and all cluster features will
      ## be available.

    error_cluster_upgrade_in_progress* = 5976.WinError
      ## The cluster is currently performing a version upgrade.

    error_cluster_upgrade_incomplete* = 5977.WinError
      ## The cluster did not successfully complete the version upgrade.

    error_cluster_node_in_grace_period* = 5978.WinError
      ## The cluster node is in grace period.

    error_cluster_csv_io_pause_timeout* = 5979.WinError
      ## The operation has failed because CSV volume was not able to recover in time specified on this file object.

    error_node_not_active_cluster_member* = 5980.WinError
      ## The operation failed because the requested node is not currently part of active cluster membership.

    error_cluster_resource_not_monitored* = 5981.WinError
      ## The operation failed because the requested cluster resource is currently unmonitored.

    error_cluster_resource_does_not_support_unmonitored* = 5982.WinError
      ## The operation failed because a resource does not support running in an unmonitored state.

    error_cluster_resource_is_replicated* = 5983.WinError
      ## The operation cannot be completed because a resource participates in replication.

    error_cluster_node_isolated* =      5984.WinError
      ## The operation failed because the requested cluster node has been isolated

    error_cluster_node_quarantined* =   5985.WinError
      ## The operation failed because the requested cluster node has been quarantined

    error_cluster_database_update_condition_failed* = 5986.WinError
      ## The operation failed because the specified database update condition was not met

    error_cluster_space_degraded* =     5987.WinError
      ## A clustered space is in a degraded condition and the requested action cannot be completed at this time.

    error_cluster_token_delegation_not_supported* = 5988.WinError
      ## The operation failed because token delegation for this control is not supported.

    error_cluster_csv_invalid_handle* = 5989.WinError
      ## The operation has failed because CSV has invalidated this file object.

    error_cluster_csv_supported_only_on_coordinator* = 5990.WinError
      ## This operation is supported only on the CSV coordinator node.

    error_groupset_not_available* =     5991.WinError
      ## The cluster group set is not available for any further requests.

    error_groupset_not_found* =         5992.WinError
      ## The cluster group set could not be found.

    error_groupset_cant_provide* =      5993.WinError
      ## The action cannot be completed at this time because the cluster group set would fall below quorum and not be able to act as a provider.

    error_cluster_fault_domain_parent_not_found* = 5994.WinError
      ## The specified parent fault domain is not found.

    error_cluster_fault_domain_invalid_hierarchy* = 5995.WinError
      ## The fault domain cannot be a child of the parent specified.

    error_cluster_fault_domain_failed_s2d_validation* = 5996.WinError
      ## Storage Spaces Direct has rejected the proposed fault domain changes because it impacts the fault tolerance of the storage.

    error_cluster_fault_domain_s2d_connectivity_loss* = 5997.WinError
      ## Storage Spaces Direct has rejected the proposed fault domain changes because it reduces the storage connected to the system.


    ##################################################
    #                                               ##
    #               EFS Error codes                 ##
    #                                               ##
    #                 6000 to 6099                  ##
    ##################################################

    error_encryption_failed* =           6000.WinError
      ## The specified file could not be encrypted.

    error_decryption_failed* =           6001.WinError
      ## The specified file could not be decrypted.

    error_file_encrypted* =              6002.WinError
      ## The specified file is encrypted and the user does not have the ability to decrypt it.

    error_no_recovery_policy* =          6003.WinError
      ## There is no valid encryption recovery policy configured for this system.

    error_no_efs* =                      6004.WinError
      ## The required encryption driver is not loaded for this system.

    error_wrong_efs* =                   6005.WinError
      ## The file was encrypted with a different encryption driver than is currently loaded.

    error_no_user_keys* =                6006.WinError
      ## There are no EFS keys defined for the user.

    error_file_not_encrypted* =          6007.WinError
      ## The specified file is not encrypted.

    error_not_export_format* =           6008.WinError
      ## The specified file is not in the defined EFS export format.

    error_file_read_only* =              6009.WinError
      ## The specified file is read only.

    error_dir_efs_disallowed* =          6010.WinError
      ## The directory has been disabled for encryption.

    error_efs_server_not_trusted* =      6011.WinError
      ## The server is not trusted for remote encryption operation.

    error_bad_recovery_policy* =         6012.WinError
      ## Recovery policy configured for this system contains invalid recovery certificate.

    error_efs_alg_blob_too_big* =        6013.WinError
      ## The encryption algorithm used on the source file needs a bigger key buffer than the one on the destination file.

    error_volume_not_support_efs* =      6014.WinError
      ## The disk partition does not support file encryption.

    error_efs_disabled* =                6015.WinError
      ## This machine is disabled for file encryption.

    error_efs_version_not_support* =     6016.WinError
      ## A newer system is required to decrypt this encrypted file.

    error_cs_encryption_invalid_server_response* =  6017.WinError
      ## The remote server sent an invalid response for a file being opened with Client Side Encryption.

    error_cs_encryption_unsupported_server* =  6018.WinError
      ## Client Side Encryption is not supported by the remote server even though it claims to support it.

    error_cs_encryption_existing_encrypted_file* =  6019.WinError
      ## File is encrypted and should be opened in Client Side Encryption mode.

    error_cs_encryption_new_encrypted_file* =  6020.WinError
      ## A new encrypted file is being created and a $EFS needs to be provided.

    error_cs_encryption_file_not_cse* =  6021.WinError
      ## The SMB client requested a CSE FSCTL on a non-CSE file.

    error_encryption_policy_denies_operation* =  6022.WinError
      ## The requested operation was blocked by policy. For more information, contact your system administrator.


    ##################################################
    #                                               ##
    #              BROWSER Error codes              ##
    #                                               ##
    #                 6100 to 6199                  ##
    ##################################################

    # This message number is for historical purposes and cannot be changed or re-used.
    error_no_browser_servers_found* =    6118.WinError
      ## The list of servers for this workgroup is not currently available


    ##################################################
    #                                               ##
    #            Task Scheduler Error codes         ##
    #            NET START must understand          ##
    #                                               ##
    #                 6200 to 6249                  ##
    ##################################################

    sched_e_service_not_localsystem* =   6200.WinError
      ## The Task Scheduler service must be configured to run in the System account to function properly. Individual tasks may be configured to run in other accounts.


    ##################################################
    #                                               ##
    #                  Available                    ##
    #                                               ##
    #                 6250 to 6599                  ##
    ##################################################

    ##################################################
    #                                               ##
    #         Common Log (CLFS) Error codes         ##
    #                                               ##
    #                 6600 to 6699                  ##
    ##################################################

    error_log_sector_invalid* =          6600.WinError
      ## Log service encountered an invalid log sector.

    error_log_sector_parity_invalid* =   6601.WinError
      ## Log service encountered a log sector with invalid block parity.

    error_log_sector_remapped* =         6602.WinError
      ## Log service encountered a remapped log sector.

    error_log_block_incomplete* =        6603.WinError
      ## Log service encountered a partial or incomplete log block.

    error_log_invalid_range* =           6604.WinError
      ## Log service encountered an attempt access data outside the active log range.

    error_log_blocks_exhausted* =        6605.WinError
      ## Log service user marshalling buffers are exhausted.

    error_log_read_context_invalid* =    6606.WinError
      ## Log service encountered an attempt read from a marshalling area with an invalid read context.

    error_log_restart_invalid* =         6607.WinError
      ## Log service encountered an invalid log restart area.

    error_log_block_version* =           6608.WinError
      ## Log service encountered an invalid log block version.

    error_log_block_invalid* =           6609.WinError
      ## Log service encountered an invalid log block.

    error_log_read_mode_invalid* =       6610.WinError
      ## Log service encountered an attempt to read the log with an invalid read mode.

    error_log_no_restart* =              6611.WinError
      ## Log service encountered a log stream with no restart area.

    error_log_metadata_corrupt* =        6612.WinError
      ## Log service encountered a corrupted metadata file.

    error_log_metadata_invalid* =        6613.WinError
      ## Log service encountered a metadata file that could not be created by the log file system.

    error_log_metadata_inconsistent* =   6614.WinError
      ## Log service encountered a metadata file with inconsistent data.

    error_log_reservation_invalid* =     6615.WinError
      ## Log service encountered an attempt to erroneous allocate or dispose reservation space.

    error_log_cant_delete* =             6616.WinError
      ## Log service cannot delete log file or file system container.

    error_log_container_limit_exceeded* =  6617.WinError
      ## Log service has reached the maximum allowable containers allocated to a log file.

    error_log_start_of_log* =            6618.WinError
      ## Log service has attempted to read or write backward past the start of the log.

    error_log_policy_already_installed* =  6619.WinError
      ## Log policy could not be installed because a policy of the same type is already present.

    error_log_policy_not_installed* =    6620.WinError
      ## Log policy in question was not installed at the time of the request.

    error_log_policy_invalid* =          6621.WinError
      ## The installed set of policies on the log is invalid.

    error_log_policy_conflict* =         6622.WinError
      ## A policy on the log in question prevented the operation from completing.

    error_log_pinned_archive_tail* =     6623.WinError
      ## Log space cannot be reclaimed because the log is pinned by the archive tail.

    error_log_record_nonexistent* =      6624.WinError
      ## Log record is not a record in the log file.

    error_log_records_reserved_invalid* =  6625.WinError
      ## Number of reserved log records or the adjustment of the number of reserved log records is invalid.

    error_log_space_reserved_invalid* =  6626.WinError
      ## Reserved log space or the adjustment of the log space is invalid.

    error_log_tail_invalid* =            6627.WinError
      ## An new or existing archive tail or base of the active log is invalid.

    error_log_full* =                    6628.WinError
      ## Log space is exhausted.

    error_could_not_resize_log* =        6629.WinError
      ## The log could not be set to the requested size.

    error_log_multiplexed* =             6630.WinError
      ## Log is multiplexed, no direct writes to the physical log is allowed.

    error_log_dedicated* =               6631.WinError
      ## The operation failed because the log is a dedicated log.

    error_log_archive_not_in_progress* =  6632.WinError
      ## The operation requires an archive context.

    error_log_archive_in_progress* =     6633.WinError
      ## Log archival is in progress.

    error_log_ephemeral* =               6634.WinError
      ## The operation requires a non-ephemeral log, but the log is ephemeral.

    error_log_not_enough_containers* =   6635.WinError
      ## The log must have at least two containers before it can be read from or written to.

    error_log_client_already_registered* =  6636.WinError
      ## A log client has already registered on the stream.

    error_log_client_not_registered* =   6637.WinError
      ## A log client has not been registered on the stream.

    error_log_full_handler_in_progress* =  6638.WinError
      ## A request has already been made to handle the log full condition.

    error_log_container_read_failed* =   6639.WinError
      ## Log service encountered an error when attempting to read from a log container.

    error_log_container_write_failed* =  6640.WinError
      ## Log service encountered an error when attempting to write to a log container.

    error_log_container_open_failed* =   6641.WinError
      ## Log service encountered an error when attempting open a log container.

    error_log_container_state_invalid* =  6642.WinError
      ## Log service encountered an invalid container state when attempting a requested action.

    error_log_state_invalid* =           6643.WinError
      ## Log service is not in the correct state to perform a requested action.

    error_log_pinned* =                  6644.WinError
      ## Log space cannot be reclaimed because the log is pinned.

    error_log_metadata_flush_failed* =   6645.WinError
      ## Log metadata flush failed.

    error_log_inconsistent_security* =   6646.WinError
      ## Security on the log and its containers is inconsistent.

    error_log_appended_flush_failed* =   6647.WinError
      ## Records were appended to the log or reservation changes were made, but the log could not be flushed.

    error_log_pinned_reservation* =      6648.WinError
      ## The log is pinned due to reservation consuming most of the log space. Free some reserved records to make space available.


    ##################################################
    #                                               ##
    #           Transaction (KTM) Error codes       ##
    #                                               ##
    #                 6700 to 6799                  ##
    ##################################################

    error_invalid_transaction* =         6700.WinError
      ## The transaction handle associated with this operation is not valid.

    error_transaction_not_active* =      6701.WinError
      ## The requested operation was made in the context of a transaction that is no longer active.

    error_transaction_request_not_valid* =  6702.WinError
      ## The requested operation is not valid on the Transaction object in its current state.

    error_transaction_not_requested* =   6703.WinError
      ## The caller has called a response API, but the response is not expected because the TM did not issue the corresponding request to the caller.

    error_transaction_already_aborted* =  6704.WinError
      ## It is too late to perform the requested operation, since the Transaction has already been aborted.

    error_transaction_already_committed* =  6705.WinError
      ## It is too late to perform the requested operation, since the Transaction has already been committed.

    error_tm_initialization_failed* =    6706.WinError
      ## The Transaction Manager was unable to be successfully initialized. Transacted operations are not supported.

    error_resourcemanager_read_only* =   6707.WinError
      ## The specified ResourceManager made no changes or updates to the resource under this transaction.

    error_transaction_not_joined* =      6708.WinError
      ## The resource manager has attempted to prepare a transaction that it has not successfully joined.

    error_transaction_superior_exists* =  6709.WinError
      ## The Transaction object already has a superior enlistment, and the caller attempted an operation that would have created a new superior. Only a single superior enlistment is allow.

    error_crm_protocol_already_exists* =  6710.WinError
      ## The RM tried to register a protocol that already exists.

    error_transaction_propagation_failed* =  6711.WinError
      ## The attempt to propagate the Transaction failed.

    error_crm_protocol_not_found* =      6712.WinError
      ## The requested propagation protocol was not registered as a CRM.

    error_transaction_invalid_marshall_buffer* =  6713.WinError
      ## The buffer passed in to PushTransaction or PullTransaction is not in a valid format.

    error_current_transaction_not_valid* =  6714.WinError
      ## The current transaction context associated with the thread is not a valid handle to a transaction object.

    error_transaction_not_found* =       6715.WinError
      ## The specified Transaction object could not be opened, because it was not found.

    error_resourcemanager_not_found* =   6716.WinError
      ## The specified ResourceManager object could not be opened, because it was not found.

    error_enlistment_not_found* =        6717.WinError
      ## The specified Enlistment object could not be opened, because it was not found.

    error_transactionmanager_not_found* =  6718.WinError
      ## The specified TransactionManager object could not be opened, because it was not found.

    error_transactionmanager_not_online* =  6719.WinError
      ## The object specified could not be created or opened, because its associated TransactionManager is not online.  The TransactionManager must be brought fully Online by calling RecoverTransactionManager to recover to the end of its LogFile before objects in its Transaction or ResourceManager namespaces can be opened.  In addition, errors in writing records to its LogFile can cause a TransactionManager to go offline.

    error_transactionmanager_recovery_name_collision* =  6720.WinError
      ## The specified TransactionManager was unable to create the objects contained in its logfile in the Ob namespace. Therefore, the TransactionManager was unable to recover.

    error_transaction_not_root* =        6721.WinError
      ## The call to create a superior Enlistment on this Transaction object could not be completed, because the Transaction object specified for the enlistment is a subordinate branch of the Transaction. Only the root of the Transaction can be enlisted on as a superior.

    error_transaction_object_expired* =  6722.WinError
      ## Because the associated transaction manager or resource manager has been closed, the handle is no longer valid.

    error_transaction_response_not_enlisted* =  6723.WinError
      ## The specified operation could not be performed on this Superior enlistment, because the enlistment was not created with the corresponding completion response in the NotificationMask.

    error_transaction_record_too_long* =  6724.WinError
      ## The specified operation could not be performed, because the record that would be logged was too long. This can occur because of two conditions: either there are too many Enlistments on this Transaction, or the combined RecoveryInformation being logged on behalf of those Enlistments is too long.

    error_implicit_transaction_not_supported* =  6725.WinError
      ## Implicit transaction are not supported.

    error_transaction_integrity_violated* =  6726.WinError
      ## The kernel transaction manager had to abort or forget the transaction because it blocked forward progress.

    error_transactionmanager_identity_mismatch* =  6727.WinError
      ## The TransactionManager identity that was supplied did not match the one recorded in the TransactionManager's log file.

    error_rm_cannot_be_frozen_for_snapshot* =  6728.WinError
      ## This snapshot operation cannot continue because a transactional resource manager cannot be frozen in its current state.  Please try again.

    error_transaction_must_writethrough* =  6729.WinError
      ## The transaction cannot be enlisted on with the specified EnlistmentMask, because the transaction has already completed the PrePrepare phase.  In order to ensure correctness, the ResourceManager must switch to a write-through mode and cease caching data within this transaction.  Enlisting for only subsequent transaction phases may still succeed.

    error_transaction_no_superior* =     6730.WinError
      ## The transaction does not have a superior enlistment.

    error_heuristic_damage_possible* =   6731.WinError
      ## The attempt to commit the Transaction completed, but it is possible that some portion of the transaction tree did not commit successfully due to heuristics.  Therefore it is possible that some data modified in the transaction may not have committed, resulting in transactional inconsistency.  If possible, check the consistency of the associated data.


    ##################################################
    #                                               ##
    #        Transactional File Services (TxF)      ##
    #                  Error codes                  ##
    #                                               ##
    #                 6800 to 6899                  ##
    ##################################################

    error_transactional_conflict* =      6800.WinError
      ## The function attempted to use a name that is reserved for use by another transaction.

    error_rm_not_active* =               6801.WinError
      ## Transaction support within the specified resource manager is not started or was shut down due to an error.

    error_rm_metadata_corrupt* =         6802.WinError
      ## The metadata of the RM has been corrupted. The RM will not function.

    error_directory_not_rm* =            6803.WinError
      ## The specified directory does not contain a resource manager.

    error_transactions_unsupported_remote* =  6805.WinError
      ## The remote server or share does not support transacted file operations.

    error_log_resize_invalid_size* =     6806.WinError
      ## The requested log size is invalid.

    error_object_no_longer_exists* =     6807.WinError
      ## The object (file, stream, link) corresponding to the handle has been deleted by a Transaction Savepoint Rollback.

    error_stream_miniversion_not_found* =  6808.WinError
      ## The specified file miniversion was not found for this transacted file open.

    error_stream_miniversion_not_valid* =  6809.WinError
      ## The specified file miniversion was found but has been invalidated. Most likely cause is a transaction savepoint rollback.

    error_miniversion_inaccessible_from_specified_transaction* =  6810.WinError
      ## A miniversion may only be opened in the context of the transaction that created it.

    error_cant_open_miniversion_with_modify_intent* =  6811.WinError
      ## It is not possible to open a miniversion with modify access.

    error_cant_create_more_stream_miniversions* =  6812.WinError
      ## It is not possible to create any more miniversions for this stream.

    error_remote_file_version_mismatch* =  6814.WinError
      ## The remote server sent mismatching version number or Fid for a file opened with transactions.

    error_handle_no_longer_valid* =      6815.WinError
      ## The handle has been invalidated by a transaction. The most likely cause is the presence of memory mapping on a file or an open handle when the transaction ended or rolled back to savepoint.

    error_no_txf_metadata* =             6816.WinError
      ## There is no transaction metadata on the file.

    error_log_corruption_detected* =     6817.WinError
      ## The log data is corrupt.

    error_cant_recover_with_handle_open* =  6818.WinError
      ## The file can't be recovered because there is a handle still open on it.

    error_rm_disconnected* =             6819.WinError
      ## The transaction outcome is unavailable because the resource manager responsible for it has disconnected.

    error_enlistment_not_superior* =     6820.WinError
      ## The request was rejected because the enlistment in question is not a superior enlistment.

    error_recovery_not_needed* =         6821.WinError
      ## The transactional resource manager is already consistent. Recovery is not needed.

    error_rm_already_started* =          6822.WinError
      ## The transactional resource manager has already been started.

    error_file_identity_not_persistent* =  6823.WinError
      ## The file cannot be opened transactionally, because its identity depends on the outcome of an unresolved transaction.

    error_cant_break_transactional_dependency* =  6824.WinError
      ## The operation cannot be performed because another transaction is depending on the fact that this property will not change.

    error_cant_cross_rm_boundary* =      6825.WinError
      ## The operation would involve a single file with two transactional resource managers and is therefore not allowed.

    error_txf_dir_not_empty* =           6826.WinError
      ## The $Txf directory must be empty for this operation to succeed.

    error_indoubt_transactions_exist* =  6827.WinError
      ## The operation would leave a transactional resource manager in an inconsistent state and is therefore not allowed.

    error_tm_volatile* =                 6828.WinError
      ## The operation could not be completed because the transaction manager does not have a log.

    error_rollback_timer_expired* =      6829.WinError
      ## A rollback could not be scheduled because a previously scheduled rollback has already executed or been queued for execution.

    error_txf_attribute_corrupt* =       6830.WinError
      ## The transactional metadata attribute on the file or directory is corrupt and unreadable.

    error_efs_not_allowed_in_transaction* =  6831.WinError
      ## The encryption operation could not be completed because a transaction is active.

    error_transactional_open_not_allowed* =  6832.WinError
      ## This object is not allowed to be opened in a transaction.

    error_log_growth_failed* =           6833.WinError
      ## An attempt to create space in the transactional resource manager's log failed. The failure status has been recorded in the event log.

    error_transacted_mapping_unsupported_remote* =  6834.WinError
      ## Memory mapping (creating a mapped section) a remote file under a transaction is not supported.

    error_txf_metadata_already_present* =  6835.WinError
      ## Transaction metadata is already present on this file and cannot be superseded.

    error_transaction_scope_callbacks_not_set* =  6836.WinError
      ## A transaction scope could not be entered because the scope handler has not been initialized.

    error_transaction_required_promotion* =  6837.WinError
      ## Promotion was required in order to allow the resource manager to enlist, but the transaction was set to disallow it.

    error_cannot_execute_file_in_transaction* =  6838.WinError
      ## This file is open for modification in an unresolved transaction and may be opened for execute only by a transacted reader.

    error_transactions_not_frozen* =     6839.WinError
      ## The request to thaw frozen transactions was ignored because transactions had not previously been frozen.

    error_transaction_freeze_in_progress* =  6840.WinError
      ## Transactions cannot be frozen because a freeze is already in progress.

    error_not_snapshot_volume* =         6841.WinError
      ## The target volume is not a snapshot volume. This operation is only valid on a volume mounted as a snapshot.

    error_no_savepoint_with_open_files* =  6842.WinError
      ## The savepoint operation failed because files are open on the transaction. This is not permitted.

    error_data_lost_repair* =            6843.WinError
      ## Windows has discovered corruption in a file, and that file has since been repaired. Data loss may have occurred.

    error_sparse_not_allowed_in_transaction* =  6844.WinError
      ## The sparse operation could not be completed because a transaction is active on the file.

    error_tm_identity_mismatch* =        6845.WinError
      ## The call to create a TransactionManager object failed because the Tm Identity stored in the logfile does not match the Tm Identity that was passed in as an argument.

    error_floated_section* =             6846.WinError
      ## I/O was attempted on a section object that has been floated as a result of a transaction ending. There is no valid data.

    error_cannot_accept_transacted_work* =  6847.WinError
      ## The transactional resource manager cannot currently accept transacted work due to a transient condition such as low resources.

    error_cannot_abort_transactions* =   6848.WinError
      ## The transactional resource manager had too many tranactions outstanding that could not be aborted. The transactional resource manger has been shut down.

    error_bad_clusters* =                6849.WinError
      ## The operation could not be completed due to bad clusters on disk.

    error_compression_not_allowed_in_transaction* =  6850.WinError
      ## The compression operation could not be completed because a transaction is active on the file.

    error_volume_dirty* =                6851.WinError
      ## The operation could not be completed because the volume is dirty. Please run chkdsk and try again.

    error_no_link_tracking_in_transaction* =  6852.WinError
      ## The link tracking operation could not be completed because a transaction is active.

    error_operation_not_supported_in_transaction* =  6853.WinError
      ## This operation cannot be performed in a transaction.

    error_expired_handle* =              6854.WinError
      ## The handle is no longer properly associated with its transaction.  It may have been opened in a transactional resource manager that was subsequently forced to restart.  Please close the handle and open a new one.

    error_transaction_not_enlisted* =    6855.WinError
      ## The specified operation could not be performed because the resource manager is not enlisted in the transaction.


    ##################################################
    #                                               ##
    #                  Available                    ##
    #                                               ##
    #                 6900 to 6999                  ##
    ##################################################

    ##################################################
    #                                               ##
    #          Terminal Server Error codes          ##
    #                                               ##
    #                 7000 to 7099                  ##
    ##################################################

    error_ctx_winstation_name_invalid* =  7001.WinError
      ## The specified session name is invalid.

    error_ctx_invalid_pd* =              7002.WinError
      ## The specified protocol driver is invalid.

    error_ctx_pd_not_found* =            7003.WinError
      ## The specified protocol driver was not found in the system path.

    error_ctx_wd_not_found* =            7004.WinError
      ## The specified terminal connection driver was not found in the system path.

    error_ctx_cannot_make_eventlog_entry* =  7005.WinError
      ## A registry key for event logging could not be created for this session.

    error_ctx_service_name_collision* =  7006.WinError
      ## A service with the same name already exists on the system.

    error_ctx_close_pending* =           7007.WinError
      ## A close operation is pending on the session.

    error_ctx_no_outbuf* =               7008.WinError
      ## There are no free output buffers available.

    error_ctx_modem_inf_not_found* =     7009.WinError
      ## The MODEM.INF file was not found.

    error_ctx_invalid_modemname* =       7010.WinError
      ## The modem name was not found in MODEM.INF.

    error_ctx_modem_response_error* =    7011.WinError
      ## The modem did not accept the command sent to it. Verify that the configured modem name matches the attached modem.

    error_ctx_modem_response_timeout* =  7012.WinError
      ## The modem did not respond to the command sent to it. Verify that the modem is properly cabled and powered on.

    error_ctx_modem_response_no_carrier* =  7013.WinError
      ## Carrier detect has failed or carrier has been dropped due to disconnect.

    error_ctx_modem_response_no_dialtone* =  7014.WinError
      ## Dial tone not detected within the required time. Verify that the phone cable is properly attached and functional.

    error_ctx_modem_response_busy* =     7015.WinError
      ## Busy signal detected at remote site on callback.

    error_ctx_modem_response_voice* =    7016.WinError
      ## Voice detected at remote site on callback.

    error_ctx_td_error* =                7017.WinError
      ## Transport driver error

    error_ctx_winstation_not_found* =    7022.WinError
      ## The specified session cannot be found.

    error_ctx_winstation_already_exists* =  7023.WinError
      ## The specified session name is already in use.

    error_ctx_winstation_busy* =         7024.WinError
      ## The task you are trying to do can't be completed because Remote Desktop Services is currently busy. Please try again in a few minutes. Other users should still be able to log on.

    error_ctx_bad_video_mode* =          7025.WinError
      ## An attempt has been made to connect to a session whose video mode is not supported by the current client.

    error_ctx_graphics_invalid* =        7035.WinError
      ## The application attempted to enable DOS graphics mode. DOS graphics mode is not supported.

    error_ctx_logon_disabled* =          7037.WinError
      ## Your interactive logon privilege has been disabled. Please contact your administrator.

    error_ctx_not_console* =             7038.WinError
      ## The requested operation can be performed only on the system console. This is most often the result of a driver or system DLL requiring direct console access.

    error_ctx_client_query_timeout* =    7040.WinError
      ## The client failed to respond to the server connect message.

    error_ctx_console_disconnect* =      7041.WinError
      ## Disconnecting the console session is not supported.

    error_ctx_console_connect* =         7042.WinError
      ## Reconnecting a disconnected session to the console is not supported.

    error_ctx_shadow_denied* =           7044.WinError
      ## The request to control another session remotely was denied.

    error_ctx_winstation_access_denied* =  7045.WinError
      ## The requested session access is denied.

    error_ctx_invalid_wd* =              7049.WinError
      ## The specified terminal connection driver is invalid.

    error_ctx_shadow_invalid* =          7050.WinError
      ## The requested session cannot be controlled remotely.
      ## This may be because the session is disconnected or does not currently have a user logged on.

    error_ctx_shadow_disabled* =         7051.WinError
      ## The requested session is not configured to allow remote control.

    error_ctx_client_license_in_use* =   7052.WinError
      ## Your request to connect to this Terminal Server has been rejected. Your Terminal Server client license number is currently being used by another user. Please call your system administrator to obtain a unique license number.

    error_ctx_client_license_not_set* =  7053.WinError
      ## Your request to connect to this Terminal Server has been rejected. Your Terminal Server client license number has not been entered for this copy of the Terminal Server client. Please contact your system administrator.

    error_ctx_license_not_available* =   7054.WinError
      ## The number of connections to this computer is limited and all connections are in use right now. Try connecting later or contact your system administrator.

    error_ctx_license_client_invalid* =  7055.WinError
      ## The client you are using is not licensed to use this system. Your logon request is denied.

    error_ctx_license_expired* =         7056.WinError
      ## The system license has expired. Your logon request is denied.

    error_ctx_shadow_not_running* =      7057.WinError
      ## Remote control could not be terminated because the specified session is not currently being remotely controlled.

    error_ctx_shadow_ended_by_mode_change* =  7058.WinError
      ## The remote control of the console was terminated because the display mode was changed. Changing the display mode in a remote control session is not supported.

    error_activation_count_exceeded* =   7059.WinError
      ## Activation has already been reset the maximum number of times for this installation. Your activation timer will not be cleared.

    error_ctx_winstations_disabled* =    7060.WinError
      ## Remote logins are currently disabled.

    error_ctx_encryption_level_required* =  7061.WinError
      ## You do not have the proper encryption level to access this Session.

    error_ctx_session_in_use* =          7062.WinError
      ## The user %s\\%s is currently logged on to this computer. Only the current user or an administrator can log on to this computer.

    error_ctx_no_force_logoff* =         7063.WinError
      ## The user %s\\%s is already logged on to the console of this computer. You do not have permission to log in at this time. To resolve this issue, contact %s\\%s and have them log off.

    error_ctx_account_restriction* =     7064.WinError
      ## Unable to log you on because of an account restriction.

    error_rdp_protocol_error* =          7065.WinError
      ## The RDP protocol component %2 detected an error in the protocol stream and has disconnected the client.

    error_ctx_cdm_connect* =             7066.WinError
      ## The Client Drive Mapping Service Has Connected on Terminal Connection.

    error_ctx_cdm_disconnect* =          7067.WinError
      ## The Client Drive Mapping Service Has Disconnected on Terminal Connection.

    error_ctx_security_layer_error* =    7068.WinError
      ## The Terminal Server security layer detected an error in the protocol stream and has disconnected the client.

    error_ts_incompatible_sessions* =    7069.WinError
      ## The target session is incompatible with the current session.

    error_ts_video_subsystem_error* =    7070.WinError
      ## Windows can't connect to your session because a problem occurred in the Windows video subsystem. Try connecting again later, or contact the server administrator for assistance.

    ##################################################
    #                                               ##
    #          Windows Fabric Error Codes           ##
    #                                               ##
    #                 7100 to 7499                  ##
    #                                               ##
    #          defined in FabricCommon.idl          ##
    #                                               ##
    ##################################################


    ##################################################
    #                                                /
    #           Traffic Control Error Codes          /
    #                                                /
    #                  7500 to 7999                  /
    #                                                /
    #            defined in: tcerror.h               /
    ##################################################


    ##################################################
    #                                               ##
    #           Active Directory Error codes        ##
    #                                               ##
    #                 8000 to 8999                  ##
    ##################################################

    # *****************
    # FACILITY_FILE_REPLICATION_SERVICE
    # *****************
    frs_err_invalid_api_sequence* =      8001.WinError
      ## The file replication service API was called incorrectly.

    frs_err_starting_service* =          8002.WinError
      ## The file replication service cannot be started.

    frs_err_stopping_service* =          8003.WinError
      ## The file replication service cannot be stopped.

    frs_err_internal_api* =              8004.WinError
      ## The file replication service API terminated the request. The event log may have more information.

    frs_err_internal* =                  8005.WinError
      ## The file replication service terminated the request. The event log may have more information.

    frs_err_service_comm* =              8006.WinError
      ## The file replication service cannot be contacted. The event log may have more information.

    frs_err_insufficient_priv* =         8007.WinError
      ## The file replication service cannot satisfy the request because the user has insufficient privileges. The event log may have more information.

    frs_err_authentication* =            8008.WinError
      ## The file replication service cannot satisfy the request because authenticated RPC is not available. The event log may have more information.

    frs_err_parent_insufficient_priv* =  8009.WinError
      ## The file replication service cannot satisfy the request because the user has insufficient privileges on the domain controller. The event log may have more information.

    frs_err_parent_authentication* =     8010.WinError
      ## The file replication service cannot satisfy the request because authenticated RPC is not available on the domain controller. The event log may have more information.

    frs_err_child_to_parent_comm* =      8011.WinError
      ## The file replication service cannot communicate with the file replication service on the domain controller. The event log may have more information.

    frs_err_parent_to_child_comm* =      8012.WinError
      ## The file replication service on the domain controller cannot communicate with the file replication service on this computer. The event log may have more information.

    frs_err_sysvol_populate* =           8013.WinError
      ## The file replication service cannot populate the system volume because of an internal error. The event log may have more information.

    frs_err_sysvol_populate_timeout* =   8014.WinError
      ## The file replication service cannot populate the system volume because of an internal timeout. The event log may have more information.

    frs_err_sysvol_is_busy* =            8015.WinError
      ## The file replication service cannot process the request. The system volume is busy with a previous request.

    frs_err_sysvol_demote* =             8016.WinError
      ## The file replication service cannot stop replicating the system volume because of an internal error. The event log may have more information.

    frs_err_invalid_service_parameter* =  8017.WinError
      ## The file replication service detected an invalid parameter.

    # *****************
    # FACILITY DIRECTORY SERVICE
    # *****************
    ds_s_success* = no_error
    error_ds_not_installed* =            8200.WinError
      ## An error occurred while installing the directory service. For more information, see the event log.

    error_ds_membership_evaluated_locally* =  8201.WinError
      ## The directory service evaluated group memberships locally.

    error_ds_no_attribute_or_value* =    8202.WinError
      ## The specified directory service attribute or value does not exist.

    error_ds_invalid_attribute_syntax* =  8203.WinError
      ## The attribute syntax specified to the directory service is invalid.

    error_ds_attribute_type_undefined* =  8204.WinError
      ## The attribute type specified to the directory service is not defined.

    error_ds_attribute_or_value_exists* =  8205.WinError
      ## The specified directory service attribute or value already exists.

    error_ds_busy* =                     8206.WinError
      ## The directory service is busy.

    error_ds_unavailable* =              8207.WinError
      ## The directory service is unavailable.

    error_ds_no_rids_allocated* =        8208.WinError
      ## The directory service was unable to allocate a relative identifier.

    error_ds_no_more_rids* =             8209.WinError
      ## The directory service has exhausted the pool of relative identifiers.

    error_ds_incorrect_role_owner* =     8210.WinError
      ## The requested operation could not be performed because the directory service is not the master for that type of operation.

    error_ds_ridmgr_init_error* =        8211.WinError
      ## The directory service was unable to initialize the subsystem that allocates relative identifiers.

    error_ds_obj_class_violation* =      8212.WinError
      ## The requested operation did not satisfy one or more constraints associated with the class of the object.

    error_ds_cant_on_non_leaf* =         8213.WinError
      ## The directory service can perform the requested operation only on a leaf object.

    error_ds_cant_on_rdn* =              8214.WinError
      ## The directory service cannot perform the requested operation on the RDN attribute of an object.

    error_ds_cant_mod_obj_class* =       8215.WinError
      ## The directory service detected an attempt to modify the object class of an object.

    error_ds_cross_dom_move_error* =     8216.WinError
      ## The requested cross-domain move operation could not be performed.

    error_ds_gc_not_available* =         8217.WinError
      ## Unable to contact the global catalog server.

    error_shared_policy* =               8218.WinError
      ## The policy object is shared and can only be modified at the root.

    error_policy_object_not_found* =     8219.WinError
      ## The policy object does not exist.

    error_policy_only_in_ds* =           8220.WinError
      ## The requested policy information is only in the directory service.

    error_promotion_active* =            8221.WinError
      ## A domain controller promotion is currently active.

    error_no_promotion_active* =         8222.WinError
      ## A domain controller promotion is not currently active

    # 8223 unused
    error_ds_operations_error* =         8224.WinError
      ## An operations error occurred.

    error_ds_protocol_error* =           8225.WinError
      ## A protocol error occurred.

    error_ds_timelimit_exceeded* =       8226.WinError
      ## The time limit for this request was exceeded.

    error_ds_sizelimit_exceeded* =       8227.WinError
      ## The size limit for this request was exceeded.

    error_ds_admin_limit_exceeded* =     8228.WinError
      ## The administrative limit for this request was exceeded.

    error_ds_compare_false* =            8229.WinError
      ## The compare response was false.

    error_ds_compare_true* =             8230.WinError
      ## The compare response was true.

    error_ds_auth_method_not_supported* =  8231.WinError
      ## The requested authentication method is not supported by the server.

    error_ds_strong_auth_required* =     8232.WinError
      ## A more secure authentication method is required for this server.

    error_ds_inappropriate_auth* =       8233.WinError
      ## Inappropriate authentication.

    error_ds_auth_unknown* =             8234.WinError
      ## The authentication mechanism is unknown.

    error_ds_referral* =                 8235.WinError
      ## A referral was returned from the server.

    error_ds_unavailable_crit_extension* =  8236.WinError
      ## The server does not support the requested critical extension.

    error_ds_confidentiality_required* =  8237.WinError
      ## This request requires a secure connection.

    error_ds_inappropriate_matching* =   8238.WinError
      ## Inappropriate matching.

    error_ds_constraint_violation* =     8239.WinError
      ## A constraint violation occurred.

    error_ds_no_such_object* =           8240.WinError
      ## There is no such object on the server.

    error_ds_alias_problem* =            8241.WinError
      ## There is an alias problem.

    error_ds_invalid_dn_syntax* =        8242.WinError
      ## An invalid dn syntax has been specified.

    error_ds_is_leaf* =                  8243.WinError
      ## The object is a leaf object.

    error_ds_alias_deref_problem* =      8244.WinError
      ## There is an alias dereferencing problem.

    error_ds_unwilling_to_perform* =     8245.WinError
      ## The server is unwilling to process the request.

    error_ds_loop_detect* =              8246.WinError
      ## A loop has been detected.

    error_ds_naming_violation* =         8247.WinError
      ## There is a naming violation.

    error_ds_object_results_too_large* =  8248.WinError
      ## The result set is too large.

    error_ds_affects_multiple_dsas* =    8249.WinError
      ## The operation affects multiple DSAs

    error_ds_server_down* =              8250.WinError
      ## The server is not operational.

    error_ds_local_error* =              8251.WinError
      ## A local error has occurred.

    error_ds_encoding_error* =           8252.WinError
      ## An encoding error has occurred.

    error_ds_decoding_error* =           8253.WinError
      ## A decoding error has occurred.

    error_ds_filter_unknown* =           8254.WinError
      ## The search filter cannot be recognized.

    error_ds_param_error* =              8255.WinError
      ## One or more parameters are illegal.

    error_ds_not_supported* =            8256.WinError
      ## The specified method is not supported.

    error_ds_no_results_returned* =      8257.WinError
      ## No results were returned.

    error_ds_control_not_found* =        8258.WinError
      ## The specified control is not supported by the server.

    error_ds_client_loop* =              8259.WinError
      ## A referral loop was detected by the client.

    error_ds_referral_limit_exceeded* =  8260.WinError
      ## The preset referral limit was exceeded.

    error_ds_sort_control_missing* =     8261.WinError
      ## The search requires a SORT control.

    error_ds_offset_range_error* =       8262.WinError
      ## The search results exceed the offset range specified.

    error_ds_ridmgr_disabled* =          8263.WinError
      ## The directory service detected the subsystem that allocates relative identifiers is disabled. This can occur as a protective mechanism when the system determines a significant portion of relative identifiers (RIDs) have been exhausted. Please see http:##go.microsoft.com/fwlink/?LinkId=228610 for recommended diagnostic steps and the procedure to re-enable account creation.

    error_ds_root_must_be_nc* =          8301.WinError
      ## The root object must be the head of a naming context. The root object cannot have an instantiated parent.

    error_ds_add_replica_inhibited* =    8302.WinError
      ## The add replica operation cannot be performed. The naming context must be writeable in order to create the replica.

    error_ds_att_not_def_in_schema* =    8303.WinError
      ## A reference to an attribute that is not defined in the schema occurred.

    error_ds_max_obj_size_exceeded* =    8304.WinError
      ## The maximum size of an object has been exceeded.

    error_ds_obj_string_name_exists* =   8305.WinError
      ## An attempt was made to add an object to the directory with a name that is already in use.

    error_ds_no_rdn_defined_in_schema* =  8306.WinError
      ## An attempt was made to add an object of a class that does not have an RDN defined in the schema.

    error_ds_rdn_doesnt_match_schema* =  8307.WinError
      ## An attempt was made to add an object using an RDN that is not the RDN defined in the schema.

    error_ds_no_requested_atts_found* =  8308.WinError
      ## None of the requested attributes were found on the objects.

    error_ds_user_buffer_to_small* =     8309.WinError
      ## The user buffer is too small.

    error_ds_att_is_not_on_obj* =        8310.WinError
      ## The attribute specified in the operation is not present on the object.

    error_ds_illegal_mod_operation* =    8311.WinError
      ## Illegal modify operation. Some aspect of the modification is not permitted.

    error_ds_obj_too_large* =            8312.WinError
      ## The specified object is too large.

    error_ds_bad_instance_type* =        8313.WinError
      ## The specified instance type is not valid.

    error_ds_masterdsa_required* =       8314.WinError
      ## The operation must be performed at a master DSA.

    error_ds_object_class_required* =    8315.WinError
      ## The object class attribute must be specified.

    error_ds_missing_required_att* =     8316.WinError
      ## A required attribute is missing.

    error_ds_att_not_def_for_class* =    8317.WinError
      ## An attempt was made to modify an object to include an attribute that is not legal for its class.

    error_ds_att_already_exists* =       8318.WinError
      ## The specified attribute is already present on the object.

    # 8319 unused
    error_ds_cant_add_att_values* =      8320.WinError
      ## The specified attribute is not present, or has no values.

    error_ds_single_value_constraint* =  8321.WinError
      ## Multiple values were specified for an attribute that can have only one value.

    error_ds_range_constraint* =         8322.WinError
      ## A value for the attribute was not in the acceptable range of values.

    error_ds_att_val_already_exists* =   8323.WinError
      ## The specified value already exists.

    error_ds_cant_rem_missing_att* =     8324.WinError
      ## The attribute cannot be removed because it is not present on the object.

    error_ds_cant_rem_missing_att_val* =  8325.WinError
      ## The attribute value cannot be removed because it is not present on the object.

    error_ds_root_cant_be_subref* =      8326.WinError
      ## The specified root object cannot be a subref.

    error_ds_no_chaining* =              8327.WinError
      ## Chaining is not permitted.

    error_ds_no_chained_eval* =          8328.WinError
      ## Chained evaluation is not permitted.

    error_ds_no_parent_object* =         8329.WinError
      ## The operation could not be performed because the object's parent is either uninstantiated or deleted.

    error_ds_parent_is_an_alias* =       8330.WinError
      ## Having a parent that is an alias is not permitted. Aliases are leaf objects.

    error_ds_cant_mix_master_and_reps* =  8331.WinError
      ## The object and parent must be of the same type, either both masters or both replicas.

    error_ds_children_exist* =           8332.WinError
      ## The operation cannot be performed because child objects exist. This operation can only be performed on a leaf object.

    error_ds_obj_not_found* =            8333.WinError
      ## Directory object not found.

    error_ds_aliased_obj_missing* =      8334.WinError
      ## The aliased object is missing.

    error_ds_bad_name_syntax* =          8335.WinError
      ## The object name has bad syntax.

    error_ds_alias_points_to_alias* =    8336.WinError
      ## It is not permitted for an alias to refer to another alias.

    error_ds_cant_deref_alias* =         8337.WinError
      ## The alias cannot be dereferenced.

    error_ds_out_of_scope* =             8338.WinError
      ## The operation is out of scope.

    error_ds_object_being_removed* =     8339.WinError
      ## The operation cannot continue because the object is in the process of being removed.

    error_ds_cant_delete_dsa_obj* =      8340.WinError
      ## The DSA object cannot be deleted.

    error_ds_generic_error* =            8341.WinError
      ## A directory service error has occurred.

    error_ds_dsa_must_be_int_master* =   8342.WinError
      ## The operation can only be performed on an internal master DSA object.

    error_ds_class_not_dsa* =            8343.WinError
      ## The object must be of class DSA.

    error_ds_insuff_access_rights* =     8344.WinError
      ## Insufficient access rights to perform the operation.

    error_ds_illegal_superior* =         8345.WinError
      ## The object cannot be added because the parent is not on the list of possible superiors.

    error_ds_attribute_owned_by_sam* =   8346.WinError
      ## Access to the attribute is not permitted because the attribute is owned by the Security Accounts Manager (SAM).

    error_ds_name_too_many_parts* =      8347.WinError
      ## The name has too many parts.

    error_ds_name_too_long* =            8348.WinError
      ## The name is too long.

    error_ds_name_value_too_long* =      8349.WinError
      ## The name value is too long.

    error_ds_name_unparseable* =         8350.WinError
      ## The directory service encountered an error parsing a name.

    error_ds_name_type_unknown* =        8351.WinError
      ## The directory service cannot get the attribute type for a name.

    error_ds_not_an_object* =            8352.WinError
      ## The name does not identify an object; the name identifies a phantom.

    error_ds_sec_desc_too_short* =       8353.WinError
      ## The security descriptor is too short.

    error_ds_sec_desc_invalid* =         8354.WinError
      ## The security descriptor is invalid.

    error_ds_no_deleted_name* =          8355.WinError
      ## Failed to create name for deleted object.

    error_ds_subref_must_have_parent* =  8356.WinError
      ## The parent of a new subref must exist.

    error_ds_ncname_must_be_nc* =        8357.WinError
      ## The object must be a naming context.

    error_ds_cant_add_system_only* =     8358.WinError
      ## It is not permitted to add an attribute which is owned by the system.

    error_ds_class_must_be_concrete* =   8359.WinError
      ## The class of the object must be structural; you cannot instantiate an abstract class.

    error_ds_invalid_dmd* =              8360.WinError
      ## The schema object could not be found.

    error_ds_obj_guid_exists* =          8361.WinError
      ## A local object with this GUID (dead or alive) already exists.

    error_ds_not_on_backlink* =          8362.WinError
      ## The operation cannot be performed on a back link.

    error_ds_no_crossref_for_nc* =       8363.WinError
      ## The cross reference for the specified naming context could not be found.

    error_ds_shutting_down* =            8364.WinError
      ## The operation could not be performed because the directory service is shutting down.

    error_ds_unknown_operation* =        8365.WinError
      ## The directory service request is invalid.

    error_ds_invalid_role_owner* =       8366.WinError
      ## The role owner attribute could not be read.

    error_ds_couldnt_contact_fsmo* =     8367.WinError
      ## The requested FSMO operation failed. The current FSMO holder could not be contacted.

    error_ds_cross_nc_dn_rename* =       8368.WinError
      ## Modification of a DN across a naming context is not permitted.

    error_ds_cant_mod_system_only* =     8369.WinError
      ## The attribute cannot be modified because it is owned by the system.

    error_ds_replicator_only* =          8370.WinError
      ## Only the replicator can perform this function.

    error_ds_obj_class_not_defined* =    8371.WinError
      ## The specified class is not defined.

    error_ds_obj_class_not_subclass* =   8372.WinError
      ## The specified class is not a subclass.

    error_ds_name_reference_invalid* =   8373.WinError
      ## The name reference is invalid.

    error_ds_cross_ref_exists* =         8374.WinError
      ## A cross reference already exists.

    error_ds_cant_del_master_crossref* =  8375.WinError
      ## It is not permitted to delete a master cross reference.

    error_ds_subtree_notify_not_nc_head* =  8376.WinError
      ## Subtree notifications are only supported on NC heads.

    error_ds_notify_filter_too_complex* =  8377.WinError
      ## Notification filter is too complex.

    error_ds_dup_rdn* =                  8378.WinError
      ## Schema update failed: duplicate RDN.

    error_ds_dup_oid* =                  8379.WinError
      ## Schema update failed: duplicate OID.

    error_ds_dup_mapi_id* =              8380.WinError
      ## Schema update failed: duplicate MAPI identifier.

    error_ds_dup_schema_id_guid* =       8381.WinError
      ## Schema update failed: duplicate schema-id GUID.

    error_ds_dup_ldap_display_name* =    8382.WinError
      ## Schema update failed: duplicate LDAP display name.

    error_ds_semantic_att_test* =        8383.WinError
      ## Schema update failed: range-lower less than range upper.

    error_ds_syntax_mismatch* =          8384.WinError
      ## Schema update failed: syntax mismatch.

    error_ds_exists_in_must_have* =      8385.WinError
      ## Schema deletion failed: attribute is used in must-contain.

    error_ds_exists_in_may_have* =       8386.WinError
      ## Schema deletion failed: attribute is used in may-contain.

    error_ds_nonexistent_may_have* =     8387.WinError
      ## Schema update failed: attribute in may-contain does not exist.

    error_ds_nonexistent_must_have* =    8388.WinError
      ## Schema update failed: attribute in must-contain does not exist.

    error_ds_aux_cls_test_fail* =        8389.WinError
      ## Schema update failed: class in aux-class list does not exist or is not an auxiliary class.

    error_ds_nonexistent_poss_sup* =     8390.WinError
      ## Schema update failed: class in poss-superiors does not exist.

    error_ds_sub_cls_test_fail* =        8391.WinError
      ## Schema update failed: class in subclassof list does not exist or does not satisfy hierarchy rules.

    error_ds_bad_rdn_att_id_syntax* =    8392.WinError
      ## Schema update failed: Rdn-Att-Id has wrong syntax.

    error_ds_exists_in_aux_cls* =        8393.WinError
      ## Schema deletion failed: class is used as auxiliary class.

    error_ds_exists_in_sub_cls* =        8394.WinError
      ## Schema deletion failed: class is used as sub class.

    error_ds_exists_in_poss_sup* =       8395.WinError
      ## Schema deletion failed: class is used as poss superior.

    error_ds_recalcschema_failed* =      8396.WinError
      ## Schema update failed in recalculating validation cache.

    error_ds_tree_delete_not_finished* =  8397.WinError
      ## The tree deletion is not finished. The request must be made again to continue deleting the tree.

    error_ds_cant_delete* =              8398.WinError
      ## The requested delete operation could not be performed.

    error_ds_att_schema_req_id* =        8399.WinError
      ## Cannot read the governs class identifier for the schema record.

    error_ds_bad_att_schema_syntax* =    8400.WinError
      ## The attribute schema has bad syntax.

    error_ds_cant_cache_att* =           8401.WinError
      ## The attribute could not be cached.

    error_ds_cant_cache_class* =         8402.WinError
      ## The class could not be cached.

    error_ds_cant_remove_att_cache* =    8403.WinError
      ## The attribute could not be removed from the cache.

    error_ds_cant_remove_class_cache* =  8404.WinError
      ## The class could not be removed from the cache.

    error_ds_cant_retrieve_dn* =         8405.WinError
      ## The distinguished name attribute could not be read.

    error_ds_missing_supref* =           8406.WinError
      ## No superior reference has been configured for the directory service. The directory service is therefore unable to issue referrals to objects outside this forest.

    error_ds_cant_retrieve_instance* =   8407.WinError
      ## The instance type attribute could not be retrieved.

    error_ds_code_inconsistency* =       8408.WinError
      ## An internal error has occurred.

    error_ds_database_error* =           8409.WinError
      ## A database error has occurred.

    error_ds_governsid_missing* =        8410.WinError
      ## The attribute GOVERNSID is missing.

    error_ds_missing_expected_att* =     8411.WinError
      ## An expected attribute is missing.

    error_ds_ncname_missing_cr_ref* =    8412.WinError
      ## The specified naming context is missing a cross reference.

    error_ds_security_checking_error* =  8413.WinError
      ## A security checking error has occurred.

    error_ds_schema_not_loaded* =        8414.WinError
      ## The schema is not loaded.

    error_ds_schema_alloc_failed* =      8415.WinError
      ## Schema allocation failed. Please check if the machine is running low on memory.

    error_ds_att_schema_req_syntax* =    8416.WinError
      ## Failed to obtain the required syntax for the attribute schema.

    error_ds_gcverify_error* =           8417.WinError
      ## The global catalog verification failed. The global catalog is not available or does not support the operation. Some part of the directory is currently not available.

    error_ds_dra_schema_mismatch* =      8418.WinError
      ## The replication operation failed because of a schema mismatch between the servers involved.

    error_ds_cant_find_dsa_obj* =        8419.WinError
      ## The DSA object could not be found.

    error_ds_cant_find_expected_nc* =    8420.WinError
      ## The naming context could not be found.

    error_ds_cant_find_nc_in_cache* =    8421.WinError
      ## The naming context could not be found in the cache.

    error_ds_cant_retrieve_child* =      8422.WinError
      ## The child object could not be retrieved.

    error_ds_security_illegal_modify* =  8423.WinError
      ## The modification was not permitted for security reasons.

    error_ds_cant_replace_hidden_rec* =  8424.WinError
      ## The operation cannot replace the hidden record.

    error_ds_bad_hierarchy_file* =       8425.WinError
      ## The hierarchy file is invalid.

    error_ds_build_hierarchy_table_failed* =  8426.WinError
      ## The attempt to build the hierarchy table failed.

    error_ds_config_param_missing* =     8427.WinError
      ## The directory configuration parameter is missing from the registry.

    error_ds_counting_ab_indices_failed* =  8428.WinError
      ## The attempt to count the address book indices failed.

    error_ds_hierarchy_table_malloc_failed* =  8429.WinError
      ## The allocation of the hierarchy table failed.

    error_ds_internal_failure* =         8430.WinError
      ## The directory service encountered an internal failure.

    error_ds_unknown_error* =            8431.WinError
      ## The directory service encountered an unknown failure.

    error_ds_root_requires_class_top* =  8432.WinError
      ## A root object requires a class of 'top'.

    error_ds_refusing_fsmo_roles* =      8433.WinError
      ## This directory server is shutting down, and cannot take ownership of new floating single-master operation roles.

    error_ds_missing_fsmo_settings* =    8434.WinError
      ## The directory service is missing mandatory configuration information, and is unable to determine the ownership of floating single-master operation roles.

    error_ds_unable_to_surrender_roles* =  8435.WinError
      ## The directory service was unable to transfer ownership of one or more floating single-master operation roles to other servers.

    error_ds_dra_generic* =              8436.WinError
      ## The replication operation failed.

    error_ds_dra_invalid_parameter* =    8437.WinError
      ## An invalid parameter was specified for this replication operation.

    error_ds_dra_busy* =                 8438.WinError
      ## The directory service is too busy to complete the replication operation at this time.

    error_ds_dra_bad_dn* =               8439.WinError
      ## The distinguished name specified for this replication operation is invalid.

    error_ds_dra_bad_nc* =               8440.WinError
      ## The naming context specified for this replication operation is invalid.

    error_ds_dra_dn_exists* =            8441.WinError
      ## The distinguished name specified for this replication operation already exists.

    error_ds_dra_internal_error* =       8442.WinError
      ## The replication system encountered an internal error.

    error_ds_dra_inconsistent_dit* =     8443.WinError
      ## The replication operation encountered a database inconsistency.

    error_ds_dra_connection_failed* =    8444.WinError
      ## The server specified for this replication operation could not be contacted.

    error_ds_dra_bad_instance_type* =    8445.WinError
      ## The replication operation encountered an object with an invalid instance type.

    error_ds_dra_out_of_mem* =           8446.WinError
      ## The replication operation failed to allocate memory.

    error_ds_dra_mail_problem* =         8447.WinError
      ## The replication operation encountered an error with the mail system.

    error_ds_dra_ref_already_exists* =   8448.WinError
      ## The replication reference information for the target server already exists.

    error_ds_dra_ref_not_found* =        8449.WinError
      ## The replication reference information for the target server does not exist.

    error_ds_dra_obj_is_rep_source* =    8450.WinError
      ## The naming context cannot be removed because it is replicated to another server.

    error_ds_dra_db_error* =             8451.WinError
      ## The replication operation encountered a database error.

    error_ds_dra_no_replica* =           8452.WinError
      ## The naming context is in the process of being removed or is not replicated from the specified server.

    error_ds_dra_access_denied* =        8453.WinError
      ## Replication access was denied.

    error_ds_dra_not_supported* =        8454.WinError
      ## The requested operation is not supported by this version of the directory service.

    error_ds_dra_rpc_cancelled* =        8455.WinError
      ## The replication remote procedure call was cancelled.

    error_ds_dra_source_disabled* =      8456.WinError
      ## The source server is currently rejecting replication requests.

    error_ds_dra_sink_disabled* =        8457.WinError
      ## The destination server is currently rejecting replication requests.

    error_ds_dra_name_collision* =       8458.WinError
      ## The replication operation failed due to a collision of object names.

    error_ds_dra_source_reinstalled* =   8459.WinError
      ## The replication source has been reinstalled.

    error_ds_dra_missing_parent* =       8460.WinError
      ## The replication operation failed because a required parent object is missing.

    error_ds_dra_preempted* =            8461.WinError
      ## The replication operation was preempted.

    error_ds_dra_abandon_sync* =         8462.WinError
      ## The replication synchronization attempt was abandoned because of a lack of updates.

    error_ds_dra_shutdown* =             8463.WinError
      ## The replication operation was terminated because the system is shutting down.

    error_ds_dra_incompatible_partial_set* =  8464.WinError
      ## Synchronization attempt failed because the destination DC is currently waiting to synchronize new partial attributes from source. This condition is normal if a recent schema change modified the partial attribute set. The destination partial attribute set is not a subset of source partial attribute set.

    error_ds_dra_source_is_partial_replica* =  8465.WinError
      ## The replication synchronization attempt failed because a master replica attempted to sync from a partial replica.

    error_ds_dra_extn_connection_failed* =  8466.WinError
      ## The server specified for this replication operation was contacted, but that server was unable to contact an additional server needed to complete the operation.

    error_ds_install_schema_mismatch* =  8467.WinError
      ## The version of the directory service schema of the source forest is not compatible with the version of directory service on this computer.

    error_ds_dup_link_id* =              8468.WinError
      ## Schema update failed: An attribute with the same link identifier already exists.

    error_ds_name_error_resolving* =     8469.WinError
      ## Name translation: Generic processing error.

    error_ds_name_error_not_found* =     8470.WinError
      ## Name translation: Could not find the name or insufficient right to see name.

    error_ds_name_error_not_unique* =    8471.WinError
      ## Name translation: Input name mapped to more than one output name.

    error_ds_name_error_no_mapping* =    8472.WinError
      ## Name translation: Input name found, but not the associated output format.

    error_ds_name_error_domain_only* =   8473.WinError
      ## Name translation: Unable to resolve completely, only the domain was found.

    error_ds_name_error_no_syntactical_mapping* =  8474.WinError
      ## Name translation: Unable to perform purely syntactical mapping at the client without going out to the wire.

    error_ds_constructed_att_mod* =      8475.WinError
      ## Modification of a constructed attribute is not allowed.

    error_ds_wrong_om_obj_class* =       8476.WinError
      ## The OM-Object-Class specified is incorrect for an attribute with the specified syntax.

    error_ds_dra_repl_pending* =         8477.WinError
      ## The replication request has been posted; waiting for reply.

    error_ds_ds_required* =              8478.WinError
      ## The requested operation requires a directory service, and none was available.

    error_ds_invalid_ldap_display_name* =  8479.WinError
      ## The LDAP display name of the class or attribute contains non-ASCII characters.

    error_ds_non_base_search* =          8480.WinError
      ## The requested search operation is only supported for base searches.

    error_ds_cant_retrieve_atts* =       8481.WinError
      ## The search failed to retrieve attributes from the database.

    error_ds_backlink_without_link* =    8482.WinError
      ## The schema update operation tried to add a backward link attribute that has no corresponding forward link.

    error_ds_epoch_mismatch* =           8483.WinError
      ## Source and destination of a cross-domain move do not agree on the object's epoch number. Either source or destination does not have the latest version of the object.

    error_ds_src_name_mismatch* =        8484.WinError
      ## Source and destination of a cross-domain move do not agree on the object's current name. Either source or destination does not have the latest version of the object.

    error_ds_src_and_dst_nc_identical* =  8485.WinError
      ## Source and destination for the cross-domain move operation are identical. Caller should use local move operation instead of cross-domain move operation.

    error_ds_dst_nc_mismatch* =          8486.WinError
      ## Source and destination for a cross-domain move are not in agreement on the naming contexts in the forest. Either source or destination does not have the latest version of the Partitions container.

    error_ds_not_authoritive_for_dst_nc* =  8487.WinError
      ## Destination of a cross-domain move is not authoritative for the destination naming context.

    error_ds_src_guid_mismatch* =        8488.WinError
      ## Source and destination of a cross-domain move do not agree on the identity of the source object. Either source or destination does not have the latest version of the source object.

    error_ds_cant_move_deleted_object* =  8489.WinError
      ## Object being moved across-domains is already known to be deleted by the destination server. The source server does not have the latest version of the source object.

    error_ds_pdc_operation_in_progress* =  8490.WinError
      ## Another operation which requires exclusive access to the PDC FSMO is already in progress.

    error_ds_cross_domain_cleanup_reqd* =  8491.WinError
      ## A cross-domain move operation failed such that two versions of the moved object exist - one each in the source and destination domains. The destination object needs to be removed to restore the system to a consistent state.

    error_ds_illegal_xdom_move_operation* =  8492.WinError
      ## This object may not be moved across domain boundaries either because cross-domain moves for this class are disallowed, or the object has some special characteristics, e.g.: trust account or restricted RID, which prevent its move.

    error_ds_cant_with_acct_group_membershps* =  8493.WinError
      ## Can't move objects with memberships across domain boundaries as once moved, this would violate the membership conditions of the account group. Remove the object from any account group memberships and retry.

    error_ds_nc_must_have_nc_parent* =   8494.WinError
      ## A naming context head must be the immediate child of another naming context head, not of an interior node.

    error_ds_cr_impossible_to_validate* =  8495.WinError
      ## The directory cannot validate the proposed naming context name because it does not hold a replica of the naming context above the proposed naming context. Please ensure that the domain naming master role is held by a server that is configured as a global catalog server, and that the server is up to date with its replication partners. (Applies only to Windows 2000 Domain Naming masters)

    error_ds_dst_domain_not_native* =    8496.WinError
      ## Destination domain must be in native mode.

    error_ds_missing_infrastructure_container* =  8497.WinError
      ## The operation cannot be performed because the server does not have an infrastructure container in the domain of interest.

    error_ds_cant_move_account_group* =  8498.WinError
      ## Cross-domain move of non-empty account groups is not allowed.

    error_ds_cant_move_resource_group* =  8499.WinError
      ## Cross-domain move of non-empty resource groups is not allowed.

    error_ds_invalid_search_flag* =      8500.WinError
      ## The search flags for the attribute are invalid. The ANR bit is valid only on attributes of Unicode or Teletex strings.

    error_ds_no_tree_delete_above_nc* =  8501.WinError
      ## Tree deletions starting at an object which has an NC head as a descendant are not allowed.

    error_ds_couldnt_lock_tree_for_delete* =  8502.WinError
      ## The directory service failed to lock a tree in preparation for a tree deletion because the tree was in use.

    error_ds_couldnt_identify_objects_for_tree_delete* =  8503.WinError
      ## The directory service failed to identify the list of objects to delete while attempting a tree deletion.

    error_ds_sam_init_failure* =         8504.WinError
      ## Security Accounts Manager initialization failed because of the following error: %1.
      ## Error Status: 0x%2. Please shutdown this system and reboot into Directory Services Restore Mode, check the event log for more detailed information.

    error_ds_sensitive_group_violation* =  8505.WinError
      ## Only an administrator can modify the membership list of an administrative group.

    error_ds_cant_mod_primarygroupid* =  8506.WinError
      ## Cannot change the primary group ID of a domain controller account.

    error_ds_illegal_base_schema_mod* =  8507.WinError
      ## An attempt is made to modify the base schema.

    error_ds_nonsafe_schema_change* =    8508.WinError
      ## Adding a new mandatory attribute to an existing class, deleting a mandatory attribute from an existing class, or adding an optional attribute to the special class Top that is not a backlink attribute (directly or through inheritance, for example, by adding or deleting an auxiliary class) is not allowed.

    error_ds_schema_update_disallowed* =  8509.WinError
      ## Schema update is not allowed on this DC because the DC is not the schema FSMO Role Owner.

    error_ds_cant_create_under_schema* =  8510.WinError
      ## An object of this class cannot be created under the schema container. You can only create attribute-schema and class-schema objects under the schema container.

    error_ds_install_no_src_sch_version* =  8511.WinError
      ## The replica/child install failed to get the objectVersion attribute on the schema container on the source DC. Either the attribute is missing on the schema container or the credentials supplied do not have permission to read it.

    error_ds_install_no_sch_version_in_inifile* =  8512.WinError
      ## The replica/child install failed to read the objectVersion attribute in the SCHEMA section of the file schema.ini in the system32 directory.

    error_ds_invalid_group_type* =       8513.WinError
      ## The specified group type is invalid.

    error_ds_no_nest_globalgroup_in_mixeddomain* =  8514.WinError
      ## You cannot nest global groups in a mixed domain if the group is security-enabled.

    error_ds_no_nest_localgroup_in_mixeddomain* =  8515.WinError
      ## You cannot nest local groups in a mixed domain if the group is security-enabled.

    error_ds_global_cant_have_local_member* =  8516.WinError
      ## A global group cannot have a local group as a member.

    error_ds_global_cant_have_universal_member* =  8517.WinError
      ## A global group cannot have a universal group as a member.

    error_ds_universal_cant_have_local_member* =  8518.WinError
      ## A universal group cannot have a local group as a member.

    error_ds_global_cant_have_crossdomain_member* =  8519.WinError
      ## A global group cannot have a cross-domain member.

    error_ds_local_cant_have_crossdomain_local_member* =  8520.WinError
      ## A local group cannot have another cross domain local group as a member.

    error_ds_have_primary_members* =     8521.WinError
      ## A group with primary members cannot change to a security-disabled group.

    error_ds_string_sd_conversion_failed* =  8522.WinError
      ## The schema cache load failed to convert the string default SD on a class-schema object.

    error_ds_naming_master_gc* =         8523.WinError
      ## Only DSAs configured to be Global Catalog servers should be allowed to hold the Domain Naming Master FSMO role. (Applies only to Windows 2000 servers)

    error_ds_dns_lookup_failure* =       8524.WinError
      ## The DSA operation is unable to proceed because of a DNS lookup failure.

    error_ds_couldnt_update_spns* =      8525.WinError
      ## While processing a change to the DNS Host Name for an object, the Service Principal Name values could not be kept in sync.

    error_ds_cant_retrieve_sd* =         8526.WinError
      ## The Security Descriptor attribute could not be read.

    error_ds_key_not_unique* =           8527.WinError
      ## The object requested was not found, but an object with that key was found.

    error_ds_wrong_linked_att_syntax* =  8528.WinError
      ## The syntax of the linked attribute being added is incorrect. Forward links can only have syntax 2.5.5.1, 2.5.5.7, and 2.5.5.14, and backlinks can only have syntax 2.5.5.1

    error_ds_sam_need_bootkey_password* =  8529.WinError
      ## Security Account Manager needs to get the boot password.

    error_ds_sam_need_bootkey_floppy* =  8530.WinError
      ## Security Account Manager needs to get the boot key from floppy disk.

    error_ds_cant_start* =               8531.WinError
      ## Directory Service cannot start.

    error_ds_init_failure* =             8532.WinError
      ## Directory Services could not start.

    error_ds_no_pkt_privacy_on_connection* =  8533.WinError
      ## The connection between client and server requires packet privacy or better.

    error_ds_source_domain_in_forest* =  8534.WinError
      ## The source domain may not be in the same forest as destination.

    error_ds_destination_domain_not_in_forest* =  8535.WinError
      ## The destination domain must be in the forest.

    error_ds_destination_auditing_not_enabled* =  8536.WinError
      ## The operation requires that destination domain auditing be enabled.

    error_ds_cant_find_dc_for_src_domain* =  8537.WinError
      ## The operation couldn't locate a DC for the source domain.

    error_ds_src_obj_not_group_or_user* =  8538.WinError
      ## The source object must be a group or user.

    error_ds_src_sid_exists_in_forest* =  8539.WinError
      ## The source object's SID already exists in destination forest.

    error_ds_src_and_dst_object_class_mismatch* =  8540.WinError
      ## The source and destination object must be of the same type.

    error_sam_init_failure* =            8541.WinError
      ## Security Accounts Manager initialization failed because of the following error: %1.
      ## Error Status: 0x%2. Click OK to shut down the system and reboot into Safe Mode. Check the event log for detailed information.

    error_ds_dra_schema_info_ship* =     8542.WinError
      ## Schema information could not be included in the replication request.

    error_ds_dra_schema_conflict* =      8543.WinError
      ## The replication operation could not be completed due to a schema incompatibility.

    error_ds_dra_earlier_schema_conflict* =  8544.WinError
      ## The replication operation could not be completed due to a previous schema incompatibility.

    error_ds_dra_obj_nc_mismatch* =      8545.WinError
      ## The replication update could not be applied because either the source or the destination has not yet received information regarding a recent cross-domain move operation.

    error_ds_nc_still_has_dsas* =        8546.WinError
      ## The requested domain could not be deleted because there exist domain controllers that still host this domain.

    error_ds_gc_required* =              8547.WinError
      ## The requested operation can be performed only on a global catalog server.

    error_ds_local_member_of_local_only* =  8548.WinError
      ## A local group can only be a member of other local groups in the same domain.

    error_ds_no_fpo_in_universal_groups* =  8549.WinError
      ## Foreign security principals cannot be members of universal groups.

    error_ds_cant_add_to_gc* =           8550.WinError
      ## The attribute is not allowed to be replicated to the GC because of security reasons.

    error_ds_no_checkpoint_with_pdc* =   8551.WinError
      ## The checkpoint with the PDC could not be taken because there too many modifications being processed currently.

    error_ds_source_auditing_not_enabled* =  8552.WinError
      ## The operation requires that source domain auditing be enabled.

    error_ds_cant_create_in_nondomain_nc* =  8553.WinError
      ## Security principal objects can only be created inside domain naming contexts.

    error_ds_invalid_name_for_spn* =     8554.WinError
      ## A Service Principal Name (SPN) could not be constructed because the provided hostname is not in the necessary format.

    error_ds_filter_uses_contructed_attrs* =  8555.WinError
      ## A Filter was passed that uses constructed attributes.

    error_ds_unicodepwd_not_in_quotes* =  8556.WinError
      ## The unicodePwd attribute value must be enclosed in double quotes.

    error_ds_machine_account_quota_exceeded* =  8557.WinError
      ## Your computer could not be joined to the domain. You have exceeded the maximum number of computer accounts you are allowed to create in this domain. Contact your system administrator to have this limit reset or increased.

    error_ds_must_be_run_on_dst_dc* =    8558.WinError
      ## For security reasons, the operation must be run on the destination DC.

    error_ds_src_dc_must_be_sp4_or_greater* =  8559.WinError
      ## For security reasons, the source DC must be NT4SP4 or greater.

    error_ds_cant_tree_delete_critical_obj* =  8560.WinError
      ## Critical Directory Service System objects cannot be deleted during tree delete operations. The tree delete may have been partially performed.

    error_ds_init_failure_console* =     8561.WinError
      ## Directory Services could not start because of the following error: %1.
      ## Error Status: 0x%2. Please click OK to shutdown the system. You can use the recovery console to diagnose the system further.

    error_ds_sam_init_failure_console* =  8562.WinError
      ## Security Accounts Manager initialization failed because of the following error: %1.
      ## Error Status: 0x%2. Please click OK to shutdown the system. You can use the recovery console to diagnose the system further.

    error_ds_forest_version_too_high* =  8563.WinError
      ## The version of the operating system is incompatible with the current AD DS forest functional level or AD LDS Configuration Set functional level. You must upgrade to a new version of the operating system before this server can become an AD DS Domain Controller or add an AD LDS Instance in this AD DS Forest or AD LDS Configuration Set.

    error_ds_domain_version_too_high* =  8564.WinError
      ## The version of the operating system installed is incompatible with the current domain functional level. You must upgrade to a new version of the operating system before this server can become a domain controller in this domain.

    error_ds_forest_version_too_low* =   8565.WinError
      ## The version of the operating system installed on this server no longer supports the current AD DS Forest functional level or AD LDS Configuration Set functional level. You must raise the AD DS Forest functional level or AD LDS Configuration Set functional level before this server can become an AD DS Domain Controller or an AD LDS Instance in this Forest or Configuration Set.

    error_ds_domain_version_too_low* =   8566.WinError
      ## The version of the operating system installed on this server no longer supports the current domain functional level. You must raise the domain functional level before this server can become a domain controller in this domain.

    error_ds_incompatible_version* =     8567.WinError
      ## The version of the operating system installed on this server is incompatible with the functional level of the domain or forest.

    error_ds_low_dsa_version* =          8568.WinError
      ## The functional level of the domain (or forest) cannot be raised to the requested value, because there exist one or more domain controllers in the domain (or forest) that are at a lower incompatible functional level.

    error_ds_no_behavior_version_in_mixeddomain* =  8569.WinError
      ## The forest functional level cannot be raised to the requested value since one or more domains are still in mixed domain mode. All domains in the forest must be in native mode, for you to raise the forest functional level.

    error_ds_not_supported_sort_order* =  8570.WinError
      ## The sort order requested is not supported.

    error_ds_name_not_unique* =          8571.WinError
      ## The requested name already exists as a unique identifier.

    error_ds_machine_account_created_prent4* =  8572.WinError
      ## The machine account was created pre-NT4. The account needs to be recreated.

    error_ds_out_of_version_store* =     8573.WinError
      ## The database is out of version store.

    error_ds_incompatible_controls_used* =  8574.WinError
      ## Unable to continue operation because multiple conflicting controls were used.

    error_ds_no_ref_domain* =            8575.WinError
      ## Unable to find a valid security descriptor reference domain for this partition.

    error_ds_reserved_link_id* =         8576.WinError
      ## Schema update failed: The link identifier is reserved.

    error_ds_link_id_not_available* =    8577.WinError
      ## Schema update failed: There are no link identifiers available.

    error_ds_ag_cant_have_universal_member* =  8578.WinError
      ## An account group cannot have a universal group as a member.

    error_ds_modifydn_disallowed_by_instance_type* =  8579.WinError
      ## Rename or move operations on naming context heads or read-only objects are not allowed.

    error_ds_no_object_move_in_schema_nc* =  8580.WinError
      ## Move operations on objects in the schema naming context are not allowed.

    error_ds_modifydn_disallowed_by_flag* =  8581.WinError
      ## A system flag has been set on the object and does not allow the object to be moved or renamed.

    error_ds_modifydn_wrong_grandparent* =  8582.WinError
      ## This object is not allowed to change its grandparent container. Moves are not forbidden on this object, but are restricted to sibling containers.

    error_ds_name_error_trust_referral* =  8583.WinError
      ## Unable to resolve completely, a referral to another forest is generated.

    error_not_supported_on_standard_server* =  8584.WinError
      ## The requested action is not supported on standard server.

    error_ds_cant_access_remote_part_of_ad* =  8585.WinError
      ## Could not access a partition of the directory service located on a remote server. Make sure at least one server is running for the partition in question.

    error_ds_cr_impossible_to_validate_v2* =  8586.WinError
      ## The directory cannot validate the proposed naming context (or partition) name because it does not hold a replica nor can it contact a replica of the naming context above the proposed naming context. Please ensure that the parent naming context is properly registered in DNS, and at least one replica of this naming context is reachable by the Domain Naming master.

    error_ds_thread_limit_exceeded* =    8587.WinError
      ## The thread limit for this request was exceeded.

    error_ds_not_closest* =              8588.WinError
      ## The Global catalog server is not in the closest site.

    error_ds_cant_derive_spn_without_server_ref* =  8589.WinError
      ## The DS cannot derive a service principal name (SPN) with which to mutually authenticate the target server because the corresponding server object in the local DS database has no serverReference attribute.

    error_ds_single_user_mode_failed* =  8590.WinError
      ## The Directory Service failed to enter single user mode.

    error_ds_ntdscript_syntax_error* =   8591.WinError
      ## The Directory Service cannot parse the script because of a syntax error.

    error_ds_ntdscript_process_error* =  8592.WinError
      ## The Directory Service cannot process the script because of an error.

    error_ds_different_repl_epochs* =    8593.WinError
      ## The directory service cannot perform the requested operation because the servers involved are of different replication epochs (which is usually related to a domain rename that is in progress).

    error_ds_drs_extensions_changed* =   8594.WinError
      ## The directory service binding must be renegotiated due to a change in the server extensions information.

    error_ds_replica_set_change_not_allowed_on_disabled_cr* =  8595.WinError
      ## Operation not allowed on a disabled cross ref.

    error_ds_no_msds_intid* =            8596.WinError
      ## Schema update failed: No values for msDS-IntId are available.

    error_ds_dup_msds_intid* =           8597.WinError
      ## Schema update failed: Duplicate msDS-INtId. Retry the operation.

    error_ds_exists_in_rdnattid* =       8598.WinError
      ## Schema deletion failed: attribute is used in rDNAttID.

    error_ds_authorization_failed* =     8599.WinError
      ## The directory service failed to authorize the request.

    error_ds_invalid_script* =           8600.WinError
      ## The Directory Service cannot process the script because it is invalid.

    error_ds_remote_crossref_op_failed* =  8601.WinError
      ## The remote create cross reference operation failed on the Domain Naming Master FSMO. The operation's error is in the extended data.

    error_ds_cross_ref_busy* =           8602.WinError
      ## A cross reference is in use locally with the same name.

    error_ds_cant_derive_spn_for_deleted_domain* =  8603.WinError
      ## The DS cannot derive a service principal name (SPN) with which to mutually authenticate the target server because the server's domain has been deleted from the forest.

    error_ds_cant_demote_with_writeable_nc* =  8604.WinError
      ## Writeable NCs prevent this DC from demoting.

    error_ds_duplicate_id_found* =       8605.WinError
      ## The requested object has a non-unique identifier and cannot be retrieved.

    error_ds_insufficient_attr_to_create_object* =  8606.WinError
      ## Insufficient attributes were given to create an object. This object may not exist because it may have been deleted and already garbage collected.

    error_ds_group_conversion_error* =   8607.WinError
      ## The group cannot be converted due to attribute restrictions on the requested group type.

    error_ds_cant_move_app_basic_group* =  8608.WinError
      ## Cross-domain move of non-empty basic application groups is not allowed.

    error_ds_cant_move_app_query_group* =  8609.WinError
      ## Cross-domain move of non-empty query based application groups is not allowed.

    error_ds_role_not_verified* =        8610.WinError
      ## The FSMO role ownership could not be verified because its directory partition has not replicated successfully with at least one replication partner.

    error_ds_wko_container_cannot_be_special* =  8611.WinError
      ## The target container for a redirection of a well known object container cannot already be a special container.

    error_ds_domain_rename_in_progress* =  8612.WinError
      ## The Directory Service cannot perform the requested operation because a domain rename operation is in progress.

    error_ds_existing_ad_child_nc* =     8613.WinError
      ## The directory service detected a child partition below the requested partition name. The partition hierarchy must be created in a top down method.

    error_ds_repl_lifetime_exceeded* =   8614.WinError
      ## The directory service cannot replicate with this server because the time since the last replication with this server has exceeded the tombstone lifetime.

    error_ds_disallowed_in_system_container* =  8615.WinError
      ## The requested operation is not allowed on an object under the system container.

    error_ds_ldap_send_queue_full* =     8616.WinError
      ## The LDAP servers network send queue has filled up because the client is not processing the results of its requests fast enough. No more requests will be processed until the client catches up. If the client does not catch up then it will be disconnected.

    error_ds_dra_out_schedule_window* =  8617.WinError
      ## The scheduled replication did not take place because the system was too busy to execute the request within the schedule window. The replication queue is overloaded. Consider reducing the number of partners or decreasing the scheduled replication frequency.

    error_ds_policy_not_known* =         8618.WinError
      ## At this time, it cannot be determined if the branch replication policy is available on the hub domain controller. Please retry at a later time to account for replication latencies.

    error_no_site_settings_object* =     8619.WinError
      ## The site settings object for the specified site does not exist.

    error_no_secrets* =                  8620.WinError
      ## The local account store does not contain secret material for the specified account.

    error_no_writable_dc_found* =        8621.WinError
      ## Could not find a writable domain controller in the domain.

    error_ds_no_server_object* =         8622.WinError
      ## The server object for the domain controller does not exist.

    error_ds_no_ntdsa_object* =          8623.WinError
      ## The NTDS Settings object for the domain controller does not exist.

    error_ds_non_asq_search* =           8624.WinError
      ## The requested search operation is not supported for ASQ searches.

    error_ds_audit_failure* =            8625.WinError
      ## A required audit event could not be generated for the operation.

    error_ds_invalid_search_flag_subtree* =  8626.WinError
      ## The search flags for the attribute are invalid. The subtree index bit is valid only on single valued attributes.

    error_ds_invalid_search_flag_tuple* =  8627.WinError
      ## The search flags for the attribute are invalid. The tuple index bit is valid only on attributes of Unicode strings.

    error_ds_hierarchy_table_too_deep* =  8628.WinError
      ## The address books are nested too deeply. Failed to build the hierarchy table.

    error_ds_dra_corrupt_utd_vector* =   8629.WinError
      ## The specified up-to-date-ness vector is corrupt.

    error_ds_dra_secrets_denied* =       8630.WinError
      ## The request to replicate secrets is denied.

    error_ds_reserved_mapi_id* =         8631.WinError
      ## Schema update failed: The MAPI identifier is reserved.

    error_ds_mapi_id_not_available* =    8632.WinError
      ## Schema update failed: There are no MAPI identifiers available.

    error_ds_dra_missing_krbtgt_secret* =  8633.WinError
      ## The replication operation failed because the required attributes of the local krbtgt object are missing.

    error_ds_domain_name_exists_in_forest* =  8634.WinError
      ## The domain name of the trusted domain already exists in the forest.

    error_ds_flat_name_exists_in_forest* =  8635.WinError
      ## The flat name of the trusted domain already exists in the forest.

    error_invalid_user_principal_name* =  8636.WinError
      ## The User Principal Name (UPN) is invalid.

    error_ds_oid_mapped_group_cant_have_members* =  8637.WinError
      ## OID mapped groups cannot have members.

    error_ds_oid_not_found* =            8638.WinError
      ## The specified OID cannot be found.

    error_ds_dra_recycled_target* =      8639.WinError
      ## The replication operation failed because the target object referred by a link value is recycled.

    error_ds_disallowed_nc_redirect* =   8640.WinError
      ## The redirect operation failed because the target object is in a NC different from the domain NC of the current domain controller.

    error_ds_high_adlds_ffl* =           8641.WinError
      ## The functional level of the AD LDS configuration set cannot be lowered to the requested value.

    error_ds_high_dsa_version* =         8642.WinError
      ## The functional level of the domain (or forest) cannot be lowered to the requested value.

    error_ds_low_adlds_ffl* =            8643.WinError
      ## The functional level of the AD LDS configuration set cannot be raised to the requested value, because there exist one or more ADLDS instances that are at a lower incompatible functional level.

    error_domain_sid_same_as_local_workstation* =  8644.WinError
      ## The domain join cannot be completed because the SID of the domain you attempted to join was identical to the SID of this machine. This is a symptom of an improperly cloned operating system install.  You should run sysprep on this machine in order to generate a new machine SID. Please see http:##go.microsoft.com/fwlink/?LinkId=168895 for more information.

    error_ds_undelete_sam_validation_failed* =  8645.WinError
      ## The undelete operation failed because the Sam Account Name or Additional Sam Account Name of the object being undeleted conflicts with an existing live object.

    error_incorrect_account_type* =      8646.WinError
      ## The system is not authoritative for the specified account and therefore cannot complete the operation. Please retry the operation using the provider associated with this account. If this is an online provider please use the provider's online site.

    error_ds_spn_value_not_unique_in_forest* =  8647.WinError
      ## The operation failed because SPN value provided for addition/modification is not unique forest-wide.

    error_ds_upn_value_not_unique_in_forest* =  8648.WinError
      ## The operation failed because UPN value provided for addition/modification is not unique forest-wide.

    error_ds_missing_forest_trust* =     8649.WinError
      ## The operation failed because the addition/modification referenced an inbound forest-wide trust that is not present.

    error_ds_value_key_not_unique* =     8650.WinError
      ## The link value specified was not found, but a link value with that key was found.


    ##################################################
    #                                                /
    #        End of Active Directory Error Codes     /
    #                                                /
    #                  8000 to  8999                 /
    ##################################################


    ##################################################
    #                                               ##
    #               DNS Error codes                 ##
    #                                               ##
    #                 9000 to 9999                  ##
    ##################################################

    # =============================
    # Facility DNS Error Messages
    # =============================

    #
    #  DNS response codes.
    #

    dns_error_response_codes_base* = 9000.WinError

    dns_error_rcode_no_error* = no_error

    dns_error_mask* = 0x00002328.WinError ## 9000 or DNS_ERROR_RESPONSE_CODES_BASE

    # DNS_ERROR_RCODE_FORMAT_ERROR          0x00002329
    dns_error_rcode_format_error* =      9001.WinError
      ## DNS server unable to interpret format.

    # DNS_ERROR_RCODE_SERVER_FAILURE        0x0000232a
    dns_error_rcode_server_failure* =    9002.WinError
      ## DNS server failure.

    # DNS_ERROR_RCODE_NAME_ERROR            0x0000232b
    dns_error_rcode_name_error* =        9003.WinError
      ## DNS name does not exist.

    # DNS_ERROR_RCODE_NOT_IMPLEMENTED       0x0000232c
    dns_error_rcode_not_implemented* =   9004.WinError
      ## DNS request not supported by name server.

    # DNS_ERROR_RCODE_REFUSED               0x0000232d
    dns_error_rcode_refused* =           9005.WinError
      ## DNS operation refused.

    # DNS_ERROR_RCODE_YXDOMAIN              0x0000232e
    dns_error_rcode_yxdomain* =          9006.WinError
      ## DNS name that ought not exist, does exist.

    # DNS_ERROR_RCODE_YXRRSET               0x0000232f
    dns_error_rcode_yxrrset* =           9007.WinError
      ## DNS RR set that ought not exist, does exist.

    # DNS_ERROR_RCODE_NXRRSET               0x00002330
    dns_error_rcode_nxrrset* =           9008.WinError
      ## DNS RR set that ought to exist, does not exist.

    # DNS_ERROR_RCODE_NOTAUTH               0x00002331
    dns_error_rcode_notauth* =           9009.WinError
      ## DNS server not authoritative for zone.

    # DNS_ERROR_RCODE_NOTZONE               0x00002332
    dns_error_rcode_notzone* =           9010.WinError
      ## DNS name in update or prereq is not in zone.

    # DNS_ERROR_RCODE_BADSIG                0x00002338
    dns_error_rcode_badsig* =            9016.WinError
      ## DNS signature failed to verify.

    # DNS_ERROR_RCODE_BADKEY                0x00002339
    dns_error_rcode_badkey* =            9017.WinError
      ## DNS bad key.

    # DNS_ERROR_RCODE_BADTIME               0x0000233a
    dns_error_rcode_badtime* =           9018.WinError
      ## DNS signature validity expired.

    dns_error_rcode_last* = dns_error_rcode_badtime


    #
    # DNSSEC errors
    #

    dns_error_dnssec_base* = 9100.WinError

    dns_error_keymaster_required* =      9101.WinError
      ## Only the DNS server acting as the key master for the zone may perform this operation.

    dns_error_not_allowed_on_signed_zone* =  9102.WinError
      ## This operation is not allowed on a zone that is signed or has signing keys.

    dns_error_nsec3_incompatible_with_rsa_sha1* =  9103.WinError
      ## NSEC3 is not compatible with the RSA-SHA-1 algorithm. Choose a different algorithm or use NSEC.

    dns_error_not_enough_signing_key_descriptors* =  9104.WinError
      ## The zone does not have enough signing keys. There must be at least one key signing key (KSK) and at least one zone signing key (ZSK).

    dns_error_unsupported_algorithm* =   9105.WinError
      ## The specified algorithm is not supported.

    dns_error_invalid_key_size* =        9106.WinError
      ## The specified key size is not supported.

    dns_error_signing_key_not_accessible* =  9107.WinError
      ## One or more of the signing keys for a zone are not accessible to the DNS server. Zone signing will not be operational until this error is resolved.

    dns_error_ksp_does_not_support_protection* =  9108.WinError
      ## The specified key storage provider does not support DPAPI++ data protection. Zone signing will not be operational until this error is resolved.

    dns_error_unexpected_data_protection_error* =  9109.WinError
      ## An unexpected DPAPI++ error was encountered. Zone signing will not be operational until this error is resolved.

    dns_error_unexpected_cng_error* =    9110.WinError
      ## An unexpected crypto error was encountered. Zone signing may not be operational until this error is resolved.

    dns_error_unknown_signing_parameter_version* =  9111.WinError
      ## The DNS server encountered a signing key with an unknown version. Zone signing will not be operational until this error is resolved.

    dns_error_ksp_not_accessible* =      9112.WinError
      ## The specified key service provider cannot be opened by the DNS server.

    dns_error_too_many_skds* =           9113.WinError
      ## The DNS server cannot accept any more signing keys with the specified algorithm and KSK flag value for this zone.

    dns_error_invalid_rollover_period* =  9114.WinError
      ## The specified rollover period is invalid.

    dns_error_invalid_initial_rollover_offset* =  9115.WinError
      ## The specified initial rollover offset is invalid.

    dns_error_rollover_in_progress* =    9116.WinError
      ## The specified signing key is already in process of rolling over keys.

    dns_error_standby_key_not_present* =  9117.WinError
      ## The specified signing key does not have a standby key to revoke.

    dns_error_not_allowed_on_zsk* =      9118.WinError
      ## This operation is not allowed on a zone signing key (ZSK).

    dns_error_not_allowed_on_active_skd* =  9119.WinError
      ## This operation is not allowed on an active signing key.

    dns_error_rollover_already_queued* =  9120.WinError
      ## The specified signing key is already queued for rollover.

    dns_error_not_allowed_on_unsigned_zone* =  9121.WinError
      ## This operation is not allowed on an unsigned zone.

    dns_error_bad_keymaster* =           9122.WinError
      ## This operation could not be completed because the DNS server listed as the current key master for this zone is down or misconfigured. Resolve the problem on the current key master for this zone or use another DNS server to seize the key master role.

    dns_error_invalid_signature_validity_period* =  9123.WinError
      ## The specified signature validity period is invalid.

    dns_error_invalid_nsec3_iteration_count* =  9124.WinError
      ## The specified NSEC3 iteration count is higher than allowed by the minimum key length used in the zone.

    dns_error_dnssec_is_disabled* =      9125.WinError
      ## This operation could not be completed because the DNS server has been configured with DNSSEC features disabled. Enable DNSSEC on the DNS server.

    dns_error_invalid_xml* =             9126.WinError
      ## This operation could not be completed because the XML stream received is empty or syntactically invalid.

    dns_error_no_valid_trust_anchors* =  9127.WinError
      ## This operation completed, but no trust anchors were added because all of the trust anchors received were either invalid, unsupported, expired, or would not become valid in less than 30 days.

    dns_error_rollover_not_pokeable* =   9128.WinError
      ## The specified signing key is not waiting for parental DS update.

    dns_error_nsec3_name_collision* =    9129.WinError
      ## Hash collision detected during NSEC3 signing. Specify a different user-provided salt, or use a randomly generated salt, and attempt to sign the zone again.

    dns_error_nsec_incompatible_with_nsec3_rsa_sha1* =  9130.WinError
      ## NSEC is not compatible with the NSEC3-RSA-SHA-1 algorithm. Choose a different algorithm or use NSEC3.


    #
    # Packet format
    #

    dns_error_packet_fmt_base* = 9500.WinError

    # DNS_INFO_NO_RECORDS                   0x0000251d
    dns_info_no_records* =               9501.WinError
      ## No records found for given DNS query.

    # DNS_ERROR_BAD_PACKET                  0x0000251e
    dns_error_bad_packet* =              9502.WinError
      ## Bad DNS packet.

    # DNS_ERROR_NO_PACKET                   0x0000251f
    dns_error_no_packet* =               9503.WinError
      ## No DNS packet.

    # DNS_ERROR_RCODE                       0x00002520
    dns_error_rcode* =                   9504.WinError
      ## DNS error, check rcode.

    # DNS_ERROR_UNSECURE_PACKET             0x00002521
    dns_error_unsecure_packet* =         9505.WinError
      ## Unsecured DNS packet.

    dns_status_packet_unsecure* = dns_error_unsecure_packet

    # DNS_REQUEST_PENDING                     0x00002522
    dns_request_pending* =               9506.WinError
      ## DNS query request is pending.


    #
    # General API errors
    #

    dns_error_no_memory* =            error_outofmemory
    dns_error_invalid_name* =         error_invalid_name
    dns_error_invalid_data* =         error_invalid_data

    dns_error_general_api_base* = 9550.WinError

    # DNS_ERROR_INVALID_TYPE                0x0000254f
    dns_error_invalid_type* =            9551.WinError
      ## Invalid DNS type.

    # DNS_ERROR_INVALID_IP_ADDRESS          0x00002550
    dns_error_invalid_ip_address* =      9552.WinError
      ## Invalid IP address.

    # DNS_ERROR_INVALID_PROPERTY            0x00002551
    dns_error_invalid_property* =        9553.WinError
      ## Invalid property.

    # DNS_ERROR_TRY_AGAIN_LATER             0x00002552
    dns_error_try_again_later* =         9554.WinError
      ## Try DNS operation again later.

    # DNS_ERROR_NOT_UNIQUE                  0x00002553
    dns_error_not_unique* =              9555.WinError
      ## Record for given name and type is not unique.

    # DNS_ERROR_NON_RFC_NAME                0x00002554
    dns_error_non_rfc_name* =            9556.WinError
      ## DNS name does not comply with RFC specifications.

    # DNS_STATUS_FQDN                       0x00002555
    dns_status_fqdn* =                   9557.WinError
      ## DNS name is a fully-qualified DNS name.

    # DNS_STATUS_DOTTED_NAME                0x00002556
    dns_status_dotted_name* =            9558.WinError
      ## DNS name is dotted (multi-label).

    # DNS_STATUS_SINGLE_PART_NAME           0x00002557
    dns_status_single_part_name* =       9559.WinError
      ## DNS name is a single-part name.

    # DNS_ERROR_INVALID_NAME_CHAR           0x00002558
    dns_error_invalid_name_char* =       9560.WinError
      ## DNS name contains an invalid character.

    # DNS_ERROR_NUMERIC_NAME                0x00002559
    dns_error_numeric_name* =            9561.WinError
      ## DNS name is entirely numeric.

    # DNS_ERROR_NOT_ALLOWED_ON_ROOT_SERVER  0x0000255A
    dns_error_not_allowed_on_root_server* =  9562.WinError
      ## The operation requested is not permitted on a DNS root server.

    # DNS_ERROR_NOT_ALLOWED_UNDER_DELEGATION  0x0000255B
    dns_error_not_allowed_under_delegation* =  9563.WinError
      ## The record could not be created because this part of the DNS namespace has been delegated to another server.

    # DNS_ERROR_CANNOT_FIND_ROOT_HINTS  0x0000255C
    dns_error_cannot_find_root_hints* =  9564.WinError
      ## The DNS server could not find a set of root hints.

    # DNS_ERROR_INCONSISTENT_ROOT_HINTS  0x0000255D
    dns_error_inconsistent_root_hints* =  9565.WinError
      ## The DNS server found root hints but they were not consistent across all adapters.

    # DNS_ERROR_DWORD_VALUE_TOO_SMALL    0x0000255E
    dns_error_dword_value_too_small* =   9566.WinError
      ## The specified value is too small for this parameter.

    # DNS_ERROR_DWORD_VALUE_TOO_LARGE    0x0000255F
    dns_error_dword_value_too_large* =   9567.WinError
      ## The specified value is too large for this parameter.

    # DNS_ERROR_BACKGROUND_LOADING       0x00002560
    dns_error_background_loading* =      9568.WinError
      ## This operation is not allowed while the DNS server is loading zones in the background. Please try again later.

    # DNS_ERROR_NOT_ALLOWED_ON_RODC      0x00002561
    dns_error_not_allowed_on_rodc* =     9569.WinError
      ## The operation requested is not permitted on against a DNS server running on a read-only DC.

    # DNS_ERROR_NOT_ALLOWED_UNDER_DNAME   0x00002562
    dns_error_not_allowed_under_dname* =  9570.WinError
      ## No data is allowed to exist underneath a DNAME record.

    # DNS_ERROR_DELEGATION_REQUIRED       0x00002563
    dns_error_delegation_required* =     9571.WinError
      ## This operation requires credentials delegation.

    # DNS_ERROR_INVALID_POLICY_TABLE        0x00002564
    dns_error_invalid_policy_table* =    9572.WinError
      ## Name resolution policy table has been corrupted. DNS resolution will fail until it is fixed. Contact your network administrator.

    # DNS_ERROR_ADDRESS_REQUIRED        0x00002565
    dns_error_address_required* =        9573.WinError
      ## Not allowed to remove all addresses.


    #
    # Zone errors
    #

    dns_error_zone_base* = 9600.WinError

    # DNS_ERROR_ZONE_DOES_NOT_EXIST         0x00002581
    dns_error_zone_does_not_exist* =     9601.WinError
      ## DNS zone does not exist.

    # DNS_ERROR_NO_ZONE_INFO                0x00002582
    dns_error_no_zone_info* =            9602.WinError
      ## DNS zone information not available.

    # DNS_ERROR_INVALID_ZONE_OPERATION      0x00002583
    dns_error_invalid_zone_operation* =  9603.WinError
      ## Invalid operation for DNS zone.

    # DNS_ERROR_ZONE_CONFIGURATION_ERROR    0x00002584
    dns_error_zone_configuration_error* =  9604.WinError
      ## Invalid DNS zone configuration.

    # DNS_ERROR_ZONE_HAS_NO_SOA_RECORD      0x00002585
    dns_error_zone_has_no_soa_record* =  9605.WinError
      ## DNS zone has no start of authority (SOA) record.

    # DNS_ERROR_ZONE_HAS_NO_NS_RECORDS      0x00002586
    dns_error_zone_has_no_ns_records* =  9606.WinError
      ## DNS zone has no Name Server (NS) record.

    # DNS_ERROR_ZONE_LOCKED                 0x00002587
    dns_error_zone_locked* =             9607.WinError
      ## DNS zone is locked.

    # DNS_ERROR_ZONE_CREATION_FAILED        0x00002588
    dns_error_zone_creation_failed* =    9608.WinError
      ## DNS zone creation failed.

    # DNS_ERROR_ZONE_ALREADY_EXISTS         0x00002589
    dns_error_zone_already_exists* =     9609.WinError
      ## DNS zone already exists.

    # DNS_ERROR_AUTOZONE_ALREADY_EXISTS     0x0000258a
    dns_error_autozone_already_exists* =  9610.WinError
      ## DNS automatic zone already exists.

    # DNS_ERROR_INVALID_ZONE_TYPE           0x0000258b
    dns_error_invalid_zone_type* =       9611.WinError
      ## Invalid DNS zone type.

    # DNS_ERROR_SECONDARY_REQUIRES_MASTER_IP 0x0000258c
    dns_error_secondary_requires_master_ip* =  9612.WinError
      ## Secondary DNS zone requires master IP address.

    # DNS_ERROR_ZONE_NOT_SECONDARY          0x0000258d
    dns_error_zone_not_secondary* =      9613.WinError
      ## DNS zone not secondary.

    # DNS_ERROR_NEED_SECONDARY_ADDRESSES    0x0000258e
    dns_error_need_secondary_addresses* =  9614.WinError
      ## Need secondary IP address.

    # DNS_ERROR_WINS_INIT_FAILED            0x0000258f
    dns_error_wins_init_failed* =        9615.WinError
      ## WINS initialization failed.

    # DNS_ERROR_NEED_WINS_SERVERS           0x00002590
    dns_error_need_wins_servers* =       9616.WinError
      ## Need WINS servers.

    # DNS_ERROR_NBSTAT_INIT_FAILED          0x00002591
    dns_error_nbstat_init_failed* =      9617.WinError
      ## NBTSTAT initialization call failed.

    # DNS_ERROR_SOA_DELETE_INVALID          0x00002592
    dns_error_soa_delete_invalid* =      9618.WinError
      ## Invalid delete of start of authority (SOA)

    # DNS_ERROR_FORWARDER_ALREADY_EXISTS    0x00002593
    dns_error_forwarder_already_exists* =  9619.WinError
      ## A conditional forwarding zone already exists for that name.

    # DNS_ERROR_ZONE_REQUIRES_MASTER_IP     0x00002594
    dns_error_zone_requires_master_ip* =  9620.WinError
      ## This zone must be configured with one or more master DNS server IP addresses.

    # DNS_ERROR_ZONE_IS_SHUTDOWN            0x00002595
    dns_error_zone_is_shutdown* =        9621.WinError
      ## The operation cannot be performed because this zone is shut down.

    # DNS_ERROR_ZONE_LOCKED_FOR_SIGNING     0x00002596
    dns_error_zone_locked_for_signing* =  9622.WinError
      ## This operation cannot be performed because the zone is currently being signed. Please try again later.


    #
    # Datafile errors
    #

    dns_error_datafile_base* = 9650.WinError

    # DNS                                   0x000025b3
    dns_error_primary_requires_datafile* =  9651.WinError
      ## Primary DNS zone requires datafile.

    # DNS                                   0x000025b4
    dns_error_invalid_datafile_name* =   9652.WinError
      ## Invalid datafile name for DNS zone.

    # DNS                                   0x000025b5
    dns_error_datafile_open_failure* =   9653.WinError
      ## Failed to open datafile for DNS zone.

    # DNS                                   0x000025b6
    dns_error_file_writeback_failed* =   9654.WinError
      ## Failed to write datafile for DNS zone.

    # DNS                                   0x000025b7
    dns_error_datafile_parsing* =        9655.WinError
      ## Failure while reading datafile for DNS zone.


    #
    # Database errors
    #

    dns_error_database_base* = 9700.WinError

    # DNS_ERROR_RECORD_DOES_NOT_EXIST       0x000025e5
    dns_error_record_does_not_exist* =   9701.WinError
      ## DNS record does not exist.

    # DNS_ERROR_RECORD_FORMAT               0x000025e6
    dns_error_record_format* =           9702.WinError
      ## DNS record format error.

    # DNS_ERROR_NODE_CREATION_FAILED        0x000025e7
    dns_error_node_creation_failed* =    9703.WinError
      ## Node creation failure in DNS.

    # DNS_ERROR_UNKNOWN_RECORD_TYPE         0x000025e8
    dns_error_unknown_record_type* =     9704.WinError
      ## Unknown DNS record type.

    # DNS_ERROR_RECORD_TIMED_OUT            0x000025e9
    dns_error_record_timed_out* =        9705.WinError
      ## DNS record timed out.

    # DNS_ERROR_NAME_NOT_IN_ZONE            0x000025ea
    dns_error_name_not_in_zone* =        9706.WinError
      ## Name not in DNS zone.

    # DNS_ERROR_CNAME_LOOP                  0x000025eb
    dns_error_cname_loop* =              9707.WinError
      ## CNAME loop detected.

    # DNS_ERROR_NODE_IS_CNAME               0x000025ec
    dns_error_node_is_cname* =           9708.WinError
      ## Node is a CNAME DNS record.

    # DNS_ERROR_CNAME_COLLISION             0x000025ed
    dns_error_cname_collision* =         9709.WinError
      ## A CNAME record already exists for given name.

    # DNS_ERROR_RECORD_ONLY_AT_ZONE_ROOT    0x000025ee
    dns_error_record_only_at_zone_root* =  9710.WinError
      ## Record only at DNS zone root.

    # DNS_ERROR_RECORD_ALREADY_EXISTS       0x000025ef
    dns_error_record_already_exists* =   9711.WinError
      ## DNS record already exists.

    # DNS_ERROR_SECONDARY_DATA              0x000025f0
    dns_error_secondary_data* =          9712.WinError
      ## Secondary DNS zone data error.

    # DNS_ERROR_NO_CREATE_CACHE_DATA        0x000025f1
    dns_error_no_create_cache_data* =    9713.WinError
      ## Could not create DNS cache data.

    # DNS_ERROR_NAME_DOES_NOT_EXIST         0x000025f2
    dns_error_name_does_not_exist* =     9714.WinError
      ## DNS name does not exist.

    # DNS_WARNING_PTR_CREATE_FAILED         0x000025f3
    dns_warning_ptr_create_failed* =     9715.WinError
      ## Could not create pointer (PTR) record.

    # DNS_WARNING_DOMAIN_UNDELETED          0x000025f4
    dns_warning_domain_undeleted* =      9716.WinError
      ## DNS domain was undeleted.

    # DNS_ERROR_DS_UNAVAILABLE              0x000025f5
    dns_error_ds_unavailable* =          9717.WinError
      ## The directory service is unavailable.

    # DNS_ERROR_DS_ZONE_ALREADY_EXISTS      0x000025f6
    dns_error_ds_zone_already_exists* =  9718.WinError
      ## DNS zone already exists in the directory service.

    # DNS_ERROR_NO_BOOTFILE_IF_DS_ZONE      0x000025f7
    dns_error_no_bootfile_if_ds_zone* =  9719.WinError
      ## DNS server not creating or reading the boot file for the directory service integrated DNS zone.

    # DNS_ERROR_NODE_IS_DNAME               0x000025f8
    dns_error_node_is_dname* =           9720.WinError
      ## Node is a DNAME DNS record.

    # DNS_ERROR_DNAME_COLLISION             0x000025f9
    dns_error_dname_collision* =         9721.WinError
      ## A DNAME record already exists for given name.

    # DNS_ERROR_ALIAS_LOOP                  0x000025fa
    dns_error_alias_loop* =              9722.WinError
      ## An alias loop has been detected with either CNAME or DNAME records.


    #
    # Operation errors
    #

    dns_error_operation_base* = 9750.WinError

    # DNS_INFO_AXFR_COMPLETE                0x00002617
    dns_info_axfr_complete* =            9751.WinError
      ## DNS AXFR (zone transfer) complete.

    # DNS_ERROR_AXFR                        0x00002618
    dns_error_axfr* =                    9752.WinError
      ## DNS zone transfer failed.

    # DNS_INFO_ADDED_LOCAL_WINS             0x00002619
    dns_info_added_local_wins* =         9753.WinError
      ## Added local WINS server.


    #
    # Secure update
    #

    dns_error_secure_base* = 9800.WinError

    # DNS_STATUS_CONTINUE_NEEDED            0x00002649
    dns_status_continue_needed* =        9801.WinError
      ## Secure update call needs to continue update request.


    #
    # Setup errors
    #

    dns_error_setup_base* = 9850.WinError

    # DNS_ERROR_NO_TCPIP                    0x0000267b
    dns_error_no_tcpip* =                9851.WinError
      ## TCP/IP network protocol not installed.

    # DNS_ERROR_NO_DNS_SERVERS              0x0000267c
    dns_error_no_dns_servers* =          9852.WinError
      ## No DNS servers configured for local system.


    #
    # Directory partition (DP) errors
    #

    dns_error_dp_base* = 9900.WinError

    # DNS_ERROR_DP_DOES_NOT_EXIST           0x000026ad
    dns_error_dp_does_not_exist* =       9901.WinError
      ## The specified directory partition does not exist.

    # DNS_ERROR_DP_ALREADY_EXISTS           0x000026ae
    dns_error_dp_already_exists* =       9902.WinError
      ## The specified directory partition already exists.

    # DNS_ERROR_DP_NOT_ENLISTED             0x000026af
    dns_error_dp_not_enlisted* =         9903.WinError
      ## This DNS server is not enlisted in the specified directory partition.

    # DNS_ERROR_DP_ALREADY_ENLISTED         0x000026b0
    dns_error_dp_already_enlisted* =     9904.WinError
      ## This DNS server is already enlisted in the specified directory partition.

    # DNS_ERROR_DP_NOT_AVAILABLE            0x000026b1
    dns_error_dp_not_available* =        9905.WinError
      ## The directory partition is not available at this time. Please wait a few minutes and try again.

    # DNS_ERROR_DP_FSMO_ERROR               0x000026b2
    dns_error_dp_fsmo_error* =           9906.WinError
      ## The operation failed because the domain naming master FSMO role could not be reached. The domain controller holding the domain naming master FSMO role is down or unable to service the request or is not running Windows Server 2003 or later.

    #
    # DNS RRL errors from 9911 to 9920
    #
    # DNS_ERROR_RRL_NOT_ENABLED 0x000026B7
    dns_error_rrl_not_enabled* =         9911.WinError
      ## The RRL is not enabled.

    # DNS_ERROR_RRL_INVALID_WINDOW_SIZE 0x000026B8
    dns_error_rrl_invalid_window_size* =  9912.WinError
      ## The window size parameter is invalid. It should be greater than or equal to 1.

    # DNS_ERROR_RRL_INVALID_IPV4_PREFIX 0x000026B9
    dns_error_rrl_invalid_ipv4_prefix* =  9913.WinError
      ## The IPv4 prefix length parameter is invalid. It should be less than or equal to 32.

    # DNS_ERROR_RRL_INVALID_IPV6_PREFIX 0x000026BA
    dns_error_rrl_invalid_ipv6_prefix* =  9914.WinError
      ## The IPv6 prefix length parameter is invalid. It should be less than or equal to 128.

    # DNS_ERROR_RRL_INVALID_TC_RATE 0x000026BB
    dns_error_rrl_invalid_tc_rate* =     9915.WinError
      ## The TC Rate parameter is invalid. It should be less than 10.

    # DNS_ERROR_RRL_INVALID_LEAK_RATE 0x000026BC
    dns_error_rrl_invalid_leak_rate* =   9916.WinError
      ## The Leak Rate parameter is invalid. It should be either 0, or between 2 and 10.

    # DNS_ERROR_RRL_LEAK_RATE_LESSTHAN_TC_RATE 0x000026BD
    dns_error_rrl_leak_rate_lessthan_tc_rate* =  9917.WinError
      ## The Leak Rate or TC Rate parameter is invalid. Leak Rate should be greater than TC Rate.


    #
    # DNS Virtualization errors from 9921 to 9950
    #
    # DNS_ERROR_VIRTUALIZATION_INSTANCE_ALREADY_EXISTS	0x000026c1
    dns_error_virtualization_instance_already_exists* =  9921.WinError
      ## The virtualization instance already exists.

    # DNS_ERROR_VIRTUALIZATION_INSTANCE_DOES_NOT_EXIST	0x000026c2
    dns_error_virtualization_instance_does_not_exist* =  9922.WinError
      ## The virtualization instance does not exist.

    # DNS_ERROR_VIRTUALIZATION_TREE_LOCKED	0x000026c3
    dns_error_virtualization_tree_locked* =  9923.WinError
      ## The virtualization tree is locked.

    # DNS_ERROR_INVAILD_VIRTUALIZATION_INSTANCE_NAME	0x000026c4
    dns_error_invaild_virtualization_instance_name* =  9924.WinError
      ## Invalid virtualization instance name.

    # DNS_ERROR_DEFAULT_VIRTUALIZATION_INSTANCE	0x000026c5
    dns_error_default_virtualization_instance* =  9925.WinError
      ## The default virtualization instance cannot be added, removed or modified.


    #
    # DNS ZoneScope errors from 9951 to 9970
    #
    # DNS_ERROR_ZONESCOPE_ALREADY_EXISTS               0x000026df
    dns_error_zonescope_already_exists* =  9951.WinError
      ## The scope already exists for the zone.

    # DNS_ERROR_ZONESCOPE_DOES_NOT_EXIST       0x000026e0
    dns_error_zonescope_does_not_exist* =  9952.WinError
      ## The scope does not exist for the zone.

    # DNS_ERROR_DEFAULT_ZONESCOPE 0x000026e1
    dns_error_default_zonescope* =       9953.WinError
      ## The scope is the same as the default zone scope.

    # DNS_ERROR_INVALID_ZONESCOPE_NAME 0x000026e2
    dns_error_invalid_zonescope_name* =  9954.WinError
      ## The scope name contains invalid characters.

    # DNS_ERROR_NOT_ALLOWED_WITH_ZONESCOPES 0x000026e3
    dns_error_not_allowed_with_zonescopes* =  9955.WinError
      ## Operation not allowed when the zone has scopes.

    # DNS_ERROR_LOAD_ZONESCOPE_FAILED 0x000026e4
    dns_error_load_zonescope_failed* =   9956.WinError
      ## Failed to load zone scope.

    # DNS_ERROR_ZONESCOPE_FILE_WRITEBACK_FAILED 0x000026e5
    dns_error_zonescope_file_writeback_failed* =  9957.WinError
      ## Failed to write data file for DNS zone scope. Please verify the file exists and is writable.

    # DNS_ERROR_INVALID_SCOPE_NAME 0x000026e6
    dns_error_invalid_scope_name* =      9958.WinError
      ## The scope name contains invalid characters.

    # DNS_ERROR_SCOPE_DOES_NOT_EXIST       0x000026e7
    dns_error_scope_does_not_exist* =    9959.WinError
      ## The scope does not exist.

    # DNS_ERROR_DEFAULT_SCOPE 0x000026e8
    dns_error_default_scope* =           9960.WinError
      ## The scope is the same as the default scope.

    # DNS_ERROR_INVALID_SCOPE_OPERATION 0x000026e9
    dns_error_invalid_scope_operation* =  9961.WinError
      ## The operation is invalid on the scope.

    # DNS_ERROR_SCOPE_LOCKED 0x000026ea
    dns_error_scope_locked* =            9962.WinError
      ## The scope is locked.

    # DNS_ERROR_SCOPE_ALREADY_EXISTS 0x000026eb
    dns_error_scope_already_exists* =    9963.WinError
      ## The scope already exists.


    #
    # DNS Policy errors from 9971 to 9999
    #
    # DNS_ERROR_POLICY_ALREADY_EXISTS 0x000026f3
    dns_error_policy_already_exists* =   9971.WinError
      ## A policy with the same name already exists on this level (server level or zone level) on the DNS server.

    # DNS_ERROR_POLICY_DOES_NOT_EXIST 0x000026f4
    dns_error_policy_does_not_exist* =   9972.WinError
      ## No policy with this name exists on this level (server level or zone level) on the DNS server.

    # DNS_ERROR_POLICY_INVALID_CRITERIA 0x000026f5
    dns_error_policy_invalid_criteria* =  9973.WinError
      ## The criteria provided in the policy are invalid.

    # DNS_ERROR_POLICY_INVALID_SETTINGS 0x000026f6
    dns_error_policy_invalid_settings* =  9974.WinError
      ## At least one of the settings of this policy is invalid.

    # DNS_ERROR_CLIENT_SUBNET_IS_ACCESSED 0x000026f7
    dns_error_client_subnet_is_accessed* =  9975.WinError
      ## The client subnet cannot be deleted while it is being accessed by a policy.

    # DNS_ERROR_CLIENT_SUBNET_DOES_NOT_EXIST 0x000026f8
    dns_error_client_subnet_does_not_exist* =  9976.WinError
      ## The client subnet does not exist on the DNS server.

    # DNS_ERROR_CLIENT_SUBNET_ALREADY_EXISTS 0x000026f9
    dns_error_client_subnet_already_exists* =  9977.WinError
      ## A client subnet with this name already exists on the DNS server.

    # DNS_ERROR_SUBNET_DOES_NOT_EXIST 0x000026fa
    dns_error_subnet_does_not_exist* =   9978.WinError
      ## The IP subnet specified does not exist in the client subnet.

    # DNS_ERROR_SUBNET_ALREADY_EXISTS 0x000026fb
    dns_error_subnet_already_exists* =   9979.WinError
      ## The IP subnet that is being added, already exists in the client subnet.

    # DNS_ERROR_POLICY_LOCKED 0x000026fc
    dns_error_policy_locked* =           9980.WinError
      ## The policy is locked.

    # DNS_ERROR_POLICY_INVALID_WEIGHT 0x000026fd
    dns_error_policy_invalid_weight* =   9981.WinError
      ## The weight of the scope in the policy is invalid.

    # DNS_ERROR_POLICY_INVALID_NAME 0x000026fe
    dns_error_policy_invalid_name* =     9982.WinError
      ## The DNS policy name is invalid.

    # DNS_ERROR_POLICY_MISSING_CRITERIA 0x000026ff
    dns_error_policy_missing_criteria* =  9983.WinError
      ## The policy is missing criteria.

    # DNS_ERROR_INVALID_CLIENT_SUBNET_NAME 0x00002700
    dns_error_invalid_client_subnet_name* =  9984.WinError
      ## The name of the the client subnet record is invalid.

    # DNS_ERROR_POLICY_PROCESSING_ORDER_INVALID 0x00002701
    dns_error_policy_processing_order_invalid* =  9985.WinError
      ## Invalid policy processing order.

    # DNS_ERROR_POLICY_SCOPE_MISSING 0x00002702
    dns_error_policy_scope_missing* =    9986.WinError
      ## The scope information has not been provided for a policy that requires it.

    # DNS_ERROR_POLICY_SCOPE_NOT_ALLOWED 0x00002703
    dns_error_policy_scope_not_allowed* =  9987.WinError
      ## The scope information has been provided for a policy that does not require it.

    # DNS_ERROR_SERVERSCOPE_IS_REFERENCED 0x00002704
    dns_error_serverscope_is_referenced* =  9988.WinError
      ## The server scope cannot be deleted because it is referenced by a DNS Policy.

    # DNS_ERROR_ZONESCOPE_IS_REFERENCED 0x00002705
    dns_error_zonescope_is_referenced* =  9989.WinError
      ## The zone scope cannot be deleted because it is referenced by a DNS Policy.

    # DNS_ERROR_POLICY_INVALID_CRITERIA_CLIENT_SUBNET 0x00002706
    dns_error_policy_invalid_criteria_client_subnet* =  9990.WinError
      ## The criterion client subnet provided in the policy is invalid.

    # DNS_ERROR_POLICY_INVALID_CRITERIA_TRANSPORT_PROTOCOL 0x00002707
    dns_error_policy_invalid_criteria_transport_protocol* =  9991.WinError
      ## The criterion transport protocol provided in the policy is invalid.

    # DNS_ERROR_POLICY_INVALID_CRITERIA_NETWORK_PROTOCOL 0x00002708
    dns_error_policy_invalid_criteria_network_protocol* =  9992.WinError
      ## The criterion network protocol provided in the policy is invalid.

    # DNS_ERROR_POLICY_INVALID_CRITERIA_INTERFACE 0x00002709
    dns_error_policy_invalid_criteria_interface* =  9993.WinError
      ## The criterion interface provided in the policy is invalid.

    # DNS_ERROR_POLICY_INVALID_CRITERIA_FQDN 0x0000270A
    dns_error_policy_invalid_criteria_fqdn* =  9994.WinError
      ## The criterion FQDN provided in the policy is invalid.

    # DNS_ERROR_POLICY_INVALID_CRITERIA_QUERY_TYPE 0x0000270B
    dns_error_policy_invalid_criteria_query_type* =  9995.WinError
      ## The criterion query type provided in the policy is invalid.

    # DNS_ERROR_POLICY_INVALID_CRITERIA_TIME_OF_DAY 0x0000270C
    dns_error_policy_invalid_criteria_time_of_day* =  9996.WinError
      ## The criterion time of day provided in the policy is invalid.




    ##################################################
    #                                               ##
    #             End of DNS Error Codes            ##
    #                                               ##
    #                  9000 to 9999                 ##
    ##################################################


    ##################################################
    #                                               ##
    #               WinSock Error Codes             ##
    #                                               ##
    #                 10000 to 11999                ##
    ##################################################

    #
    # WinSock error codes are also defined in WinSock.h
    # and WinSock2.h, hence the IFDEF
    #
  #ifndef WSABASEERR
    wsabaseerr* = 10000.WinError
    wsaeintr* =                          10004.WinError
      ## A blocking operation was interrupted by a call to WSACancelBlockingCall.

    wsaebadf* =                          10009.WinError
      ## The file handle supplied is not valid.

    wsaeacces* =                         10013.WinError
      ## An attempt was made to access a socket in a way forbidden by its access permissions.

    wsaefault* =                         10014.WinError
      ## The system detected an invalid pointer address in attempting to use a pointer argument in a call.

    wsaeinval* =                         10022.WinError
      ## An invalid argument was supplied.

    wsaemfile* =                         10024.WinError
      ## Too many open sockets.

    wsaewouldblock* =                    10035.WinError
      ## A non-blocking socket operation could not be completed immediately.

    wsaeinprogress* =                    10036.WinError
      ## A blocking operation is currently executing.

    wsaealready* =                       10037.WinError
      ## An operation was attempted on a non-blocking socket that already had an operation in progress.

    wsaenotsock* =                       10038.WinError
      ## An operation was attempted on something that is not a socket.

    wsaedestaddrreq* =                   10039.WinError
      ## A required address was omitted from an operation on a socket.

    wsaemsgsize* =                       10040.WinError
      ## A message sent on a datagram socket was larger than the internal message buffer or some other network limit, or the buffer used to receive a datagram into was smaller than the datagram itself.

    wsaeprototype* =                     10041.WinError
      ## A protocol was specified in the socket function call that does not support the semantics of the socket type requested.

    wsaenoprotoopt* =                    10042.WinError
      ## An unknown, invalid, or unsupported option or level was specified in a getsockopt or setsockopt call.

    wsaeprotonosupport* =                10043.WinError
      ## The requested protocol has not been configured into the system, or no implementation for it exists.

    wsaesocktnosupport* =                10044.WinError
      ## The support for the specified socket type does not exist in this address family.

    wsaeopnotsupp* =                     10045.WinError
      ## The attempted operation is not supported for the type of object referenced.

    wsaepfnosupport* =                   10046.WinError
      ## The protocol family has not been configured into the system or no implementation for it exists.

    wsaeafnosupport* =                   10047.WinError
      ## An address incompatible with the requested protocol was used.

    wsaeaddrinuse* =                     10048.WinError
      ## Only one usage of each socket address (protocol/network address/port) is normally permitted.

    wsaeaddrnotavail* =                  10049.WinError
      ## The requested address is not valid in its context.

    wsaenetdown* =                       10050.WinError
      ## A socket operation encountered a dead network.

    wsaenetunreach* =                    10051.WinError
      ## A socket operation was attempted to an unreachable network.

    wsaenetreset* =                      10052.WinError
      ## The connection has been broken due to keep-alive activity detecting a failure while the operation was in progress.

    wsaeconnaborted* =                   10053.WinError
      ## An established connection was aborted by the software in your host machine.

    wsaeconnreset* =                     10054.WinError
      ## An existing connection was forcibly closed by the remote host.

    wsaenobufs* =                        10055.WinError
      ## An operation on a socket could not be performed because the system lacked sufficient buffer space or because a queue was full.

    wsaeisconn* =                        10056.WinError
      ## A connect request was made on an already connected socket.

    wsaenotconn* =                       10057.WinError
      ## A request to send or receive data was disallowed because the socket is not connected and (when sending on a datagram socket using a sendto call) no address was supplied.

    wsaeshutdown* =                      10058.WinError
      ## A request to send or receive data was disallowed because the socket had already been shut down in that direction with a previous shutdown call.

    wsaetoomanyrefs* =                   10059.WinError
      ## Too many references to some kernel object.

    wsaetimedout* =                      10060.WinError
      ## A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond.

    wsaeconnrefused* =                   10061.WinError
      ## No connection could be made because the target machine actively refused it.

    wsaeloop* =                          10062.WinError
      ## Cannot translate name.

    wsaenametoolong* =                   10063.WinError
      ## Name component or name was too long.

    wsaehostdown* =                      10064.WinError
      ## A socket operation failed because the destination host was down.

    wsaehostunreach* =                   10065.WinError
      ## A socket operation was attempted to an unreachable host.

    wsaenotempty* =                      10066.WinError
      ## Cannot remove a directory that is not empty.

    wsaeproclim* =                       10067.WinError
      ## A Windows Sockets implementation may have a limit on the number of applications that may use it simultaneously.

    wsaeusers* =                         10068.WinError
      ## Ran out of quota.

    wsaedquot* =                         10069.WinError
      ## Ran out of disk quota.

    wsaestale* =                         10070.WinError
      ## File handle reference is no longer available.

    wsaeremote* =                        10071.WinError
      ## Item is not available locally.

    wsasysnotready* =                    10091.WinError
      ## WSAStartup cannot function at this time because the underlying system it uses to provide network services is currently unavailable.

    wsavernotsupported* =                10092.WinError
      ## The Windows Sockets version requested is not supported.

    wsanotinitialised* =                 10093.WinError
      ## Either the application has not called WSAStartup, or WSAStartup failed.

    wsaediscon* =                        10101.WinError
      ## Returned by WSARecv or WSARecvFrom to indicate the remote party has initiated a graceful shutdown sequence.

    wsaenomore* =                        10102.WinError
      ## No more results can be returned by WSALookupServiceNext.

    wsaecancelled* =                     10103.WinError
      ## A call to WSALookupServiceEnd was made while this call was still processing. The call has been canceled.

    wsaeinvalidproctable* =              10104.WinError
      ## The procedure call table is invalid.

    wsaeinvalidprovider* =               10105.WinError
      ## The requested service provider is invalid.

    wsaeproviderfailedinit* =            10106.WinError
      ## The requested service provider could not be loaded or initialized.

    wsasyscallfailure* =                 10107.WinError
      ## A system call has failed.

    wsaservice_not_found* =              10108.WinError
      ## No such service is known. The service cannot be found in the specified name space.

    wsatype_not_found* =                 10109.WinError
      ## The specified class was not found.

    wsaerefused* =                       10112.WinError
      ## A database query failed because it was actively refused.

    wsahost_not_found* =                 11001.WinError
      ## No such host is known.

    wsatry_again* =                      11002.WinError
      ## This is usually a temporary error during hostname resolution and means that the local server did not receive a response from an authoritative server.

    wsano_recovery* =                    11003.WinError
      ## A non-recoverable error occurred during a database lookup.

    wsano_data* =                        11004.WinError
      ## The requested name is valid, but no data of the requested type was found.

    wsa_qos_receivers* =                 11005.WinError
      ## At least one reserve has arrived.

    wsa_qos_senders* =                   11006.WinError
      ## At least one path has arrived.

    wsa_qos_no_senders* =                11007.WinError
      ## There are no senders.

    wsa_qos_no_receivers* =              11008.WinError
      ## There are no receivers.

    wsa_qos_request_confirmed* =         11009.WinError
      ## Reserve has been confirmed.

    wsa_qos_admission_failure* =         11010.WinError
      ## Error due to lack of resources.

    wsa_qos_policy_failure* =            11011.WinError
      ## Rejected for administrative reasons - bad credentials.

    wsa_qos_bad_style* =                 11012.WinError
      ## Unknown or conflicting style.

    wsa_qos_bad_object* =                11013.WinError
      ## Problem with some part of the filterspec or providerspecific buffer in general.

    wsa_qos_traffic_ctrl_error* =        11014.WinError
      ## Problem with some part of the flowspec.

    wsa_qos_generic_error* =             11015.WinError
      ## General QOS error.

    wsa_qos_eservicetype* =              11016.WinError
      ## An invalid or unrecognized service type was found in the flowspec.

    wsa_qos_eflowspec* =                 11017.WinError
      ## An invalid or inconsistent flowspec was found in the QOS structure.

    wsa_qos_eprovspecbuf* =              11018.WinError
      ## Invalid QOS provider-specific buffer.

    wsa_qos_efilterstyle* =              11019.WinError
      ## An invalid QOS filter style was used.

    wsa_qos_efiltertype* =               11020.WinError
      ## An invalid QOS filter type was used.

    wsa_qos_efiltercount* =              11021.WinError
      ## An incorrect number of QOS FILTERSPECs were specified in the FLOWDESCRIPTOR.

    wsa_qos_eobjlength* =                11022.WinError
      ## An object with an invalid ObjectLength field was specified in the QOS provider-specific buffer.

    wsa_qos_eflowcount* =                11023.WinError
      ## An incorrect number of flow descriptors was specified in the QOS structure.

    wsa_qos_eunkownpsobj* =              11024.WinError
      ## An unrecognized object was found in the QOS provider-specific buffer.

    wsa_qos_epolicyobj* =                11025.WinError
      ## An invalid policy object was found in the QOS provider-specific buffer.

    wsa_qos_eflowdesc* =                 11026.WinError
      ## An invalid QOS flow descriptor was found in the flow descriptor list.

    wsa_qos_epsflowspec* =               11027.WinError
      ## An invalid or inconsistent flowspec was found in the QOS provider specific buffer.

    wsa_qos_epsfilterspec* =             11028.WinError
      ## An invalid FILTERSPEC was found in the QOS provider-specific buffer.

    wsa_qos_esdmodeobj* =                11029.WinError
      ## An invalid shape discard mode object was found in the QOS provider specific buffer.

    wsa_qos_eshaperateobj* =             11030.WinError
      ## An invalid shaping rate object was found in the QOS provider-specific buffer.

    wsa_qos_reserved_petype* =           11031.WinError
      ## A reserved policy element was found in the QOS provider-specific buffer.

    wsa_secure_host_not_found* =         11032.WinError
      ## No such host is known securely.

    wsa_ipsec_name_policy_error* =       11033.WinError
      ## Name based IPSEC policy could not be added.

  #endif ## defined(WSABASEERR)

    ##################################################
    #                                               ##
    #           End of WinSock Error Codes          ##
    #                                               ##
    #                 10000 to 11999                ##
    ##################################################


    ##################################################
    #                                               ##
    #                  Available                    ##
    #                                               ##
    #                 12000 to 12999                ##
    ##################################################


    ##################################################
    #                                               ##
    #           Start of IPSec Error codes          ##
    #                                               ##
    #                 13000 to 13999                ##
    ##################################################

    error_ipsec_qm_policy_exists* =      13000.WinError
      ## The specified quick mode policy already exists.

    error_ipsec_qm_policy_not_found* =   13001.WinError
      ## The specified quick mode policy was not found.

    error_ipsec_qm_policy_in_use* =      13002.WinError
      ## The specified quick mode policy is being used.

    error_ipsec_mm_policy_exists* =      13003.WinError
      ## The specified main mode policy already exists.

    error_ipsec_mm_policy_not_found* =   13004.WinError
      ## The specified main mode policy was not found

    error_ipsec_mm_policy_in_use* =      13005.WinError
      ## The specified main mode policy is being used.

    error_ipsec_mm_filter_exists* =      13006.WinError
      ## The specified main mode filter already exists.

    error_ipsec_mm_filter_not_found* =   13007.WinError
      ## The specified main mode filter was not found.

    error_ipsec_transport_filter_exists* =  13008.WinError
      ## The specified transport mode filter already exists.

    error_ipsec_transport_filter_not_found* =  13009.WinError
      ## The specified transport mode filter does not exist.

    error_ipsec_mm_auth_exists* =        13010.WinError
      ## The specified main mode authentication list exists.

    error_ipsec_mm_auth_not_found* =     13011.WinError
      ## The specified main mode authentication list was not found.

    error_ipsec_mm_auth_in_use* =        13012.WinError
      ## The specified main mode authentication list is being used.

    error_ipsec_default_mm_policy_not_found* =  13013.WinError
      ## The specified default main mode policy was not found.

    error_ipsec_default_mm_auth_not_found* =  13014.WinError
      ## The specified default main mode authentication list was not found.

    error_ipsec_default_qm_policy_not_found* =  13015.WinError
      ## The specified default quick mode policy was not found.

    error_ipsec_tunnel_filter_exists* =  13016.WinError
      ## The specified tunnel mode filter exists.

    error_ipsec_tunnel_filter_not_found* =  13017.WinError
      ## The specified tunnel mode filter was not found.

    error_ipsec_mm_filter_pending_deletion* =  13018.WinError
      ## The Main Mode filter is pending deletion.

    error_ipsec_transport_filter_pending_deletion* =  13019.WinError
      ## The transport filter is pending deletion.

    error_ipsec_tunnel_filter_pending_deletion* =  13020.WinError
      ## The tunnel filter is pending deletion.

    error_ipsec_mm_policy_pending_deletion* =  13021.WinError
      ## The Main Mode policy is pending deletion.

    error_ipsec_mm_auth_pending_deletion* =  13022.WinError
      ## The Main Mode authentication bundle is pending deletion.

    error_ipsec_qm_policy_pending_deletion* =  13023.WinError
      ## The Quick Mode policy is pending deletion.

    warning_ipsec_mm_policy_pruned* =    13024.WinError
      ## The Main Mode policy was successfully added, but some of the requested offers are not supported.

    warning_ipsec_qm_policy_pruned* =    13025.WinError
      ## The Quick Mode policy was successfully added, but some of the requested offers are not supported.

    error_ipsec_ike_neg_status_begin* =  13800.WinError
      ##  ERROR_IPSEC_IKE_NEG_STATUS_BEGIN

    error_ipsec_ike_auth_fail* =         13801.WinError
      ## IKE authentication credentials are unacceptable

    error_ipsec_ike_attrib_fail* =       13802.WinError
      ## IKE security attributes are unacceptable

    error_ipsec_ike_negotiation_pending* =  13803.WinError
      ## IKE Negotiation in progress

    error_ipsec_ike_general_processing_error* =  13804.WinError
      ## General processing error

    error_ipsec_ike_timed_out* =         13805.WinError
      ## Negotiation timed out

    error_ipsec_ike_no_cert* =           13806.WinError
      ## IKE failed to find valid machine certificate. Contact your Network Security Administrator about installing a valid certificate in the appropriate Certificate Store.

    error_ipsec_ike_sa_deleted* =        13807.WinError
      ## IKE SA deleted by peer before establishment completed

    error_ipsec_ike_sa_reaped* =         13808.WinError
      ## IKE SA deleted before establishment completed

    error_ipsec_ike_mm_acquire_drop* =   13809.WinError
      ## Negotiation request sat in Queue too long

    error_ipsec_ike_qm_acquire_drop* =   13810.WinError
      ## Negotiation request sat in Queue too long

    error_ipsec_ike_queue_drop_mm* =     13811.WinError
      ## Negotiation request sat in Queue too long

    error_ipsec_ike_queue_drop_no_mm* =  13812.WinError
      ## Negotiation request sat in Queue too long

    error_ipsec_ike_drop_no_response* =  13813.WinError
      ## No response from peer

    error_ipsec_ike_mm_delay_drop* =     13814.WinError
      ## Negotiation took too long

    error_ipsec_ike_qm_delay_drop* =     13815.WinError
      ## Negotiation took too long

    error_ipsec_ike_error* =             13816.WinError
      ## Unknown error occurred

    error_ipsec_ike_crl_failed* =        13817.WinError
      ## Certificate Revocation Check failed

    error_ipsec_ike_invalid_key_usage* =  13818.WinError
      ## Invalid certificate key usage

    error_ipsec_ike_invalid_cert_type* =  13819.WinError
      ## Invalid certificate type

    error_ipsec_ike_no_private_key* =    13820.WinError
      ## IKE negotiation failed because the machine certificate used does not have a private key. IPsec certificates require a private key. Contact your Network Security administrator about replacing with a certificate that has a private key.

    error_ipsec_ike_simultaneous_rekey* =  13821.WinError
      ## Simultaneous rekeys were detected.

    error_ipsec_ike_dh_fail* =           13822.WinError
      ## Failure in Diffie-Hellman computation

    error_ipsec_ike_critical_payload_not_recognized* =  13823.WinError
      ## Don't know how to process critical payload

    error_ipsec_ike_invalid_header* =    13824.WinError
      ## Invalid header

    error_ipsec_ike_no_policy* =         13825.WinError
      ## No policy configured

    error_ipsec_ike_invalid_signature* =  13826.WinError
      ## Failed to verify signature

    error_ipsec_ike_kerberos_error* =    13827.WinError
      ## Failed to authenticate using Kerberos

    error_ipsec_ike_no_public_key* =     13828.WinError
      ## Peer's certificate did not have a public key

    # These must stay as a unit.
    error_ipsec_ike_process_err* =       13829.WinError
      ## Error processing error payload

    error_ipsec_ike_process_err_sa* =    13830.WinError
      ## Error processing SA payload

    error_ipsec_ike_process_err_prop* =  13831.WinError
      ## Error processing Proposal payload

    error_ipsec_ike_process_err_trans* =  13832.WinError
      ## Error processing Transform payload

    error_ipsec_ike_process_err_ke* =    13833.WinError
      ## Error processing KE payload

    error_ipsec_ike_process_err_id* =    13834.WinError
      ## Error processing ID payload

    error_ipsec_ike_process_err_cert* =  13835.WinError
      ## Error processing Cert payload

    error_ipsec_ike_process_err_cert_req* =  13836.WinError
      ## Error processing Certificate Request payload

    error_ipsec_ike_process_err_hash* =  13837.WinError
      ## Error processing Hash payload

    error_ipsec_ike_process_err_sig* =   13838.WinError
      ## Error processing Signature payload

    error_ipsec_ike_process_err_nonce* =  13839.WinError
      ## Error processing Nonce payload

    error_ipsec_ike_process_err_notify* =  13840.WinError
      ## Error processing Notify payload

    error_ipsec_ike_process_err_delete* =  13841.WinError
      ## Error processing Delete Payload

    error_ipsec_ike_process_err_vendor* =  13842.WinError
      ## Error processing VendorId payload

    error_ipsec_ike_invalid_payload* =   13843.WinError
      ## Invalid payload received

    error_ipsec_ike_load_soft_sa* =      13844.WinError
      ## Soft SA loaded

    error_ipsec_ike_soft_sa_torn_down* =  13845.WinError
      ## Soft SA torn down

    error_ipsec_ike_invalid_cookie* =    13846.WinError
      ## Invalid cookie received.

    error_ipsec_ike_no_peer_cert* =      13847.WinError
      ## Peer failed to send valid machine certificate

    error_ipsec_ike_peer_crl_failed* =   13848.WinError
      ## Certification Revocation check of peer's certificate failed

    error_ipsec_ike_policy_change* =     13849.WinError
      ## New policy invalidated SAs formed with old policy

    error_ipsec_ike_no_mm_policy* =      13850.WinError
      ## There is no available Main Mode IKE policy.

    error_ipsec_ike_notcbpriv* =         13851.WinError
      ## Failed to enabled TCB privilege.

    error_ipsec_ike_secloadfail* =       13852.WinError
      ## Failed to load SECURITY.DLL.

    error_ipsec_ike_failsspinit* =       13853.WinError
      ## Failed to obtain security function table dispatch address from SSPI.

    error_ipsec_ike_failqueryssp* =      13854.WinError
      ## Failed to query Kerberos package to obtain max token size.

    error_ipsec_ike_srvacqfail* =        13855.WinError
      ## Failed to obtain Kerberos server credentials for ISAKMP/ERROR_IPSEC_IKE service. Kerberos authentication will not function. The most likely reason for this is lack of domain membership. This is normal if your computer is a member of a workgroup.

    error_ipsec_ike_srvquerycred* =      13856.WinError
      ## Failed to determine SSPI principal name for ISAKMP/ERROR_IPSEC_IKE service (QueryCredentialsAttributes).

    error_ipsec_ike_getspifail* =        13857.WinError
      ## Failed to obtain new SPI for the inbound SA from IPsec driver. The most common cause for this is that the driver does not have the correct filter. Check your policy to verify the filters.

    error_ipsec_ike_invalid_filter* =    13858.WinError
      ## Given filter is invalid

    error_ipsec_ike_out_of_memory* =     13859.WinError
      ## Memory allocation failed.

    error_ipsec_ike_add_update_key_failed* =  13860.WinError
      ## Failed to add Security Association to IPsec Driver. The most common cause for this is if the IKE negotiation took too long to complete. If the problem persists, reduce the load on the faulting machine.

    error_ipsec_ike_invalid_policy* =    13861.WinError
      ## Invalid policy

    error_ipsec_ike_unknown_doi* =       13862.WinError
      ## Invalid DOI

    error_ipsec_ike_invalid_situation* =  13863.WinError
      ## Invalid situation

    error_ipsec_ike_dh_failure* =        13864.WinError
      ## Diffie-Hellman failure

    error_ipsec_ike_invalid_group* =     13865.WinError
      ## Invalid Diffie-Hellman group

    error_ipsec_ike_encrypt* =           13866.WinError
      ## Error encrypting payload

    error_ipsec_ike_decrypt* =           13867.WinError
      ## Error decrypting payload

    error_ipsec_ike_policy_match* =      13868.WinError
      ## Policy match error

    error_ipsec_ike_unsupported_id* =    13869.WinError
      ## Unsupported ID

    error_ipsec_ike_invalid_hash* =      13870.WinError
      ## Hash verification failed

    error_ipsec_ike_invalid_hash_alg* =  13871.WinError
      ## Invalid hash algorithm

    error_ipsec_ike_invalid_hash_size* =  13872.WinError
      ## Invalid hash size

    error_ipsec_ike_invalid_encrypt_alg* =  13873.WinError
      ## Invalid encryption algorithm

    error_ipsec_ike_invalid_auth_alg* =  13874.WinError
      ## Invalid authentication algorithm

    error_ipsec_ike_invalid_sig* =       13875.WinError
      ## Invalid certificate signature

    error_ipsec_ike_load_failed* =       13876.WinError
      ## Load failed

    error_ipsec_ike_rpc_delete* =        13877.WinError
      ## Deleted via RPC call

    error_ipsec_ike_benign_reinit* =     13878.WinError
      ## Temporary state created to perform reinitialization. This is not a real failure.

    error_ipsec_ike_invalid_responder_lifetime_notify* =  13879.WinError
      ## The lifetime value received in the Responder Lifetime Notify is below the Windows 2000 configured minimum value. Please fix the policy on the peer machine.

    error_ipsec_ike_invalid_major_version* =  13880.WinError
      ## The recipient cannot handle version of IKE specified in the header.

    error_ipsec_ike_invalid_cert_keylen* =  13881.WinError
      ## Key length in certificate is too small for configured security requirements.

    error_ipsec_ike_mm_limit* =          13882.WinError
      ## Max number of established MM SAs to peer exceeded.

    error_ipsec_ike_negotiation_disabled* =  13883.WinError
      ## IKE received a policy that disables negotiation.

    error_ipsec_ike_qm_limit* =          13884.WinError
      ## Reached maximum quick mode limit for the main mode. New main mode will be started.

    error_ipsec_ike_mm_expired* =        13885.WinError
      ## Main mode SA lifetime expired or peer sent a main mode delete.

    error_ipsec_ike_peer_mm_assumed_invalid* =  13886.WinError
      ## Main mode SA assumed to be invalid because peer stopped responding.

    error_ipsec_ike_cert_chain_policy_mismatch* =  13887.WinError
      ## Certificate doesn't chain to a trusted root in IPsec policy.

    error_ipsec_ike_unexpected_message_id* =  13888.WinError
      ## Received unexpected message ID.

    error_ipsec_ike_invalid_auth_payload* =  13889.WinError
      ## Received invalid authentication offers.

    error_ipsec_ike_dos_cookie_sent* =   13890.WinError
      ## Sent DoS cookie notify to initiator.

    error_ipsec_ike_shutting_down* =     13891.WinError
      ## IKE service is shutting down.

    error_ipsec_ike_cga_auth_failed* =   13892.WinError
      ## Could not verify binding between CGA address and certificate.

    error_ipsec_ike_process_err_natoa* =  13893.WinError
      ## Error processing NatOA payload.

    error_ipsec_ike_invalid_mm_for_qm* =  13894.WinError
      ## Parameters of the main mode are invalid for this quick mode.

    error_ipsec_ike_qm_expired* =        13895.WinError
      ## Quick mode SA was expired by IPsec driver.

    error_ipsec_ike_too_many_filters* =  13896.WinError
      ## Too many dynamically added IKEEXT filters were detected.

    # Do NOT change this final value.  It is used in a public API structure
    error_ipsec_ike_neg_status_end* =    13897.WinError
      ##  ERROR_IPSEC_IKE_NEG_STATUS_END

    error_ipsec_ike_kill_dummy_nap_tunnel* =  13898.WinError
      ## NAP reauth succeeded and must delete the dummy NAP IKEv2 tunnel.

    error_ipsec_ike_inner_ip_assignment_failure* =  13899.WinError
      ## Error in assigning inner IP address to initiator in tunnel mode.

    error_ipsec_ike_require_cp_payload_missing* =  13900.WinError
      ## Require configuration payload missing.

    error_ipsec_key_module_impersonation_negotiation_pending* =  13901.WinError
      ## A negotiation running as the security principle who issued the connection is in progress

    error_ipsec_ike_coexistence_suppress* =  13902.WinError
      ## SA was deleted due to IKEv1/AuthIP co-existence suppress check.

    error_ipsec_ike_ratelimit_drop* =    13903.WinError
      ## Incoming SA request was dropped due to peer IP address rate limiting.

    error_ipsec_ike_peer_doesnt_support_mobike* =  13904.WinError
      ## Peer does not support MOBIKE.

    error_ipsec_ike_authorization_failure* =  13905.WinError
      ## SA establishment is not authorized.

    error_ipsec_ike_strong_cred_authorization_failure* =  13906.WinError
      ## SA establishment is not authorized because there is not a sufficiently strong PKINIT-based credential.

    error_ipsec_ike_authorization_failure_with_optional_retry* =  13907.WinError
      ## SA establishment is not authorized.  You may need to enter updated or different credentials such as a smartcard.

    error_ipsec_ike_strong_cred_authorization_and_certmap_failure* =  13908.WinError
      ## SA establishment is not authorized because there is not a sufficiently strong PKINIT-based credential. This might be related to certificate-to-account mapping failure for the SA.

    # Extended upper bound for IKE errors to accomodate new errors
    error_ipsec_ike_neg_status_extended_end* =  13909.WinError
      ##  ERROR_IPSEC_IKE_NEG_STATUS_EXTENDED_END

    #
    # Following error codes are returned by IPsec kernel.
    #
    error_ipsec_bad_spi* =               13910.WinError
      ## The SPI in the packet does not match a valid IPsec SA.

    error_ipsec_sa_lifetime_expired* =   13911.WinError
      ## Packet was received on an IPsec SA whose lifetime has expired.

    error_ipsec_wrong_sa* =              13912.WinError
      ## Packet was received on an IPsec SA that does not match the packet characteristics.

    error_ipsec_replay_check_failed* =   13913.WinError
      ## Packet sequence number replay check failed.

    error_ipsec_invalid_packet* =        13914.WinError
      ## IPsec header and/or trailer in the packet is invalid.

    error_ipsec_integrity_check_failed* =  13915.WinError
      ## IPsec integrity check failed.

    error_ipsec_clear_text_drop* =       13916.WinError
      ## IPsec dropped a clear text packet.

    error_ipsec_auth_firewall_drop* =    13917.WinError
      ## IPsec dropped an incoming ESP packet in authenticated firewall mode. This drop is benign.

    error_ipsec_throttle_drop* =         13918.WinError
      ## IPsec dropped a packet due to DoS throttling.

    error_ipsec_dosp_block* =            13925.WinError
      ## IPsec DoS Protection matched an explicit block rule.

    error_ipsec_dosp_received_multicast* =  13926.WinError
      ## IPsec DoS Protection received an IPsec specific multicast packet which is not allowed.

    error_ipsec_dosp_invalid_packet* =   13927.WinError
      ## IPsec DoS Protection received an incorrectly formatted packet.

    error_ipsec_dosp_state_lookup_failed* =  13928.WinError
      ## IPsec DoS Protection failed to look up state.

    error_ipsec_dosp_max_entries* =      13929.WinError
      ## IPsec DoS Protection failed to create state because the maximum number of entries allowed by policy has been reached.

    error_ipsec_dosp_keymod_not_allowed* =  13930.WinError
      ## IPsec DoS Protection received an IPsec negotiation packet for a keying module which is not allowed by policy.

    error_ipsec_dosp_not_installed* =    13931.WinError
      ## IPsec DoS Protection has not been enabled.

    error_ipsec_dosp_max_per_ip_ratelimit_queues* =  13932.WinError
      ## IPsec DoS Protection failed to create a per internal IP rate limit queue because the maximum number of queues allowed by policy has been reached.


    ##################################################
    #                                               ##
    #           End of IPSec Error codes            ##
    #                                               ##
    #                 13000 to 13999                ##
    ##################################################


    ##################################################
    #                                               ##
    #         Start of Side By Side Error Codes     ##
    #                                               ##
    #                 14000 to 14999                ##
    ##################################################

    error_sxs_section_not_found* =       14000.WinError
      ## The requested section was not present in the activation context.

    error_sxs_cant_gen_actctx* =         14001.WinError
      ## The application has failed to start because its side-by-side configuration is incorrect. Please see the application event log or use the command-line sxstrace.exe tool for more detail.

    error_sxs_invalid_actctxdata_format* =  14002.WinError
      ## The application binding data format is invalid.

    error_sxs_assembly_not_found* =      14003.WinError
      ## The referenced assembly is not installed on your system.

    error_sxs_manifest_format_error* =   14004.WinError
      ## The manifest file does not begin with the required tag and format information.

    error_sxs_manifest_parse_error* =    14005.WinError
      ## The manifest file contains one or more syntax errors.

    error_sxs_activation_context_disabled* =  14006.WinError
      ## The application attempted to activate a disabled activation context.

    error_sxs_key_not_found* =           14007.WinError
      ## The requested lookup key was not found in any active activation context.

    error_sxs_version_conflict* =        14008.WinError
      ## A component version required by the application conflicts with another component version already active.

    error_sxs_wrong_section_type* =      14009.WinError
      ## The type requested activation context section does not match the query API used.

    error_sxs_thread_queries_disabled* =  14010.WinError
      ## Lack of system resources has required isolated activation to be disabled for the current thread of execution.

    error_sxs_process_default_already_set* =  14011.WinError
      ## An attempt to set the process default activation context failed because the process default activation context was already set.

    error_sxs_unknown_encoding_group* =  14012.WinError
      ## The encoding group identifier specified is not recognized.

    error_sxs_unknown_encoding* =        14013.WinError
      ## The encoding requested is not recognized.

    error_sxs_invalid_xml_namespace_uri* =  14014.WinError
      ## The manifest contains a reference to an invalid URI.

    error_sxs_root_manifest_dependency_not_installed* =  14015.WinError
      ## The application manifest contains a reference to a dependent assembly which is not installed

    error_sxs_leaf_manifest_dependency_not_installed* =  14016.WinError
      ## The manifest for an assembly used by the application has a reference to a dependent assembly which is not installed

    error_sxs_invalid_assembly_identity_attribute* =  14017.WinError
      ## The manifest contains an attribute for the assembly identity which is not valid.

    error_sxs_manifest_missing_required_default_namespace* =  14018.WinError
      ## The manifest is missing the required default namespace specification on the assembly element.

    error_sxs_manifest_invalid_required_default_namespace* =  14019.WinError
      ## The manifest has a default namespace specified on the assembly element but its value is not "urn:schemas-microsoft-com:asm.v1".

    error_sxs_private_manifest_cross_path_with_reparse_point* =  14020.WinError
      ## The private manifest probed has crossed a path with an unsupported reparse point.

    error_sxs_duplicate_dll_name* =      14021.WinError
      ## Two or more components referenced directly or indirectly by the application manifest have files by the same name.

    error_sxs_duplicate_windowclass_name* =  14022.WinError
      ## Two or more components referenced directly or indirectly by the application manifest have window classes with the same name.

    error_sxs_duplicate_clsid* =         14023.WinError
      ## Two or more components referenced directly or indirectly by the application manifest have the same COM server CLSIDs.

    error_sxs_duplicate_iid* =           14024.WinError
      ## Two or more components referenced directly or indirectly by the application manifest have proxies for the same COM interface IIDs.

    error_sxs_duplicate_tlbid* =         14025.WinError
      ## Two or more components referenced directly or indirectly by the application manifest have the same COM type library TLBIDs.

    error_sxs_duplicate_progid* =        14026.WinError
      ## Two or more components referenced directly or indirectly by the application manifest have the same COM ProgIDs.

    error_sxs_duplicate_assembly_name* =  14027.WinError
      ## Two or more components referenced directly or indirectly by the application manifest are different versions of the same component which is not permitted.

    error_sxs_file_hash_mismatch* =      14028.WinError
      ## A component's file does not match the verification information present in the component manifest.

    error_sxs_policy_parse_error* =      14029.WinError
      ## The policy manifest contains one or more syntax errors.

    error_sxs_xml_e_missingquote* =      14030.WinError
      ## Manifest Parse Error : A string literal was expected, but no opening quote character was found.

    error_sxs_xml_e_commentsyntax* =     14031.WinError
      ## Manifest Parse Error : Incorrect syntax was used in a comment.

    error_sxs_xml_e_badstartnamechar* =  14032.WinError
      ## Manifest Parse Error : A name was started with an invalid character.

    error_sxs_xml_e_badnamechar* =       14033.WinError
      ## Manifest Parse Error : A name contained an invalid character.

    error_sxs_xml_e_badcharinstring* =   14034.WinError
      ## Manifest Parse Error : A string literal contained an invalid character.

    error_sxs_xml_e_xmldeclsyntax* =     14035.WinError
      ## Manifest Parse Error : Invalid syntax for an xml declaration.

    error_sxs_xml_e_badchardata* =       14036.WinError
      ## Manifest Parse Error : An Invalid character was found in text content.

    error_sxs_xml_e_missingwhitespace* =  14037.WinError
      ## Manifest Parse Error : Required white space was missing.

    error_sxs_xml_e_expectingtagend* =   14038.WinError
      ## Manifest Parse Error : The character '>' was expected.

    error_sxs_xml_e_missingsemicolon* =  14039.WinError
      ## Manifest Parse Error : A semi colon character was expected.

    error_sxs_xml_e_unbalancedparen* =   14040.WinError
      ## Manifest Parse Error : Unbalanced parentheses.

    error_sxs_xml_e_internalerror* =     14041.WinError
      ## Manifest Parse Error : Internal error.

    error_sxs_xml_e_unexpected_whitespace* =  14042.WinError
      ## Manifest Parse Error : Whitespace is not allowed at this location.

    error_sxs_xml_e_incomplete_encoding* =  14043.WinError
      ## Manifest Parse Error : End of file reached in invalid state for current encoding.

    error_sxs_xml_e_missing_paren* =     14044.WinError
      ## Manifest Parse Error : Missing parenthesis.

    error_sxs_xml_e_expectingclosequote* =  14045.WinError
      ## Manifest Parse Error : A single or double closing quote character (\' or \") is missing.

    error_sxs_xml_e_multiple_colons* =   14046.WinError
      ## Manifest Parse Error : Multiple colons are not allowed in a name.

    error_sxs_xml_e_invalid_decimal* =   14047.WinError
      ## Manifest Parse Error : Invalid character for decimal digit.

    error_sxs_xml_e_invalid_hexidecimal* =  14048.WinError
      ## Manifest Parse Error : Invalid character for hexadecimal digit.

    error_sxs_xml_e_invalid_unicode* =   14049.WinError
      ## Manifest Parse Error : Invalid unicode character value for this platform.

    error_sxs_xml_e_whitespaceorquestionmark* =  14050.WinError
      ## Manifest Parse Error : Expecting whitespace or '?'.

    error_sxs_xml_e_unexpectedendtag* =  14051.WinError
      ## Manifest Parse Error : End tag was not expected at this location.

    error_sxs_xml_e_unclosedtag* =       14052.WinError
      ## Manifest Parse Error : The following tags were not closed: %1.

    error_sxs_xml_e_duplicateattribute* =  14053.WinError
      ## Manifest Parse Error : Duplicate attribute.

    error_sxs_xml_e_multipleroots* =     14054.WinError
      ## Manifest Parse Error : Only one top level element is allowed in an XML document.

    error_sxs_xml_e_invalidatrootlevel* =  14055.WinError
      ## Manifest Parse Error : Invalid at the top level of the document.

    error_sxs_xml_e_badxmldecl* =        14056.WinError
      ## Manifest Parse Error : Invalid xml declaration.

    error_sxs_xml_e_missingroot* =       14057.WinError
      ## Manifest Parse Error : XML document must have a top level element.

    error_sxs_xml_e_unexpectedeof* =     14058.WinError
      ## Manifest Parse Error : Unexpected end of file.

    error_sxs_xml_e_badperefinsubset* =  14059.WinError
      ## Manifest Parse Error : Parameter entities cannot be used inside markup declarations in an internal subset.

    error_sxs_xml_e_unclosedstarttag* =  14060.WinError
      ## Manifest Parse Error : Element was not closed.

    error_sxs_xml_e_unclosedendtag* =    14061.WinError
      ## Manifest Parse Error : End element was missing the character '>'.

    error_sxs_xml_e_unclosedstring* =    14062.WinError
      ## Manifest Parse Error : A string literal was not closed.

    error_sxs_xml_e_unclosedcomment* =   14063.WinError
      ## Manifest Parse Error : A comment was not closed.

    error_sxs_xml_e_uncloseddecl* =      14064.WinError
      ## Manifest Parse Error : A declaration was not closed.

    error_sxs_xml_e_unclosedcdata* =     14065.WinError
      ## Manifest Parse Error : A CDATA section was not closed.

    error_sxs_xml_e_reservednamespace* =  14066.WinError
      ## Manifest Parse Error : The namespace prefix is not allowed to start with the reserved string "xml".

    error_sxs_xml_e_invalidencoding* =   14067.WinError
      ## Manifest Parse Error : System does not support the specified encoding.

    error_sxs_xml_e_invalidswitch* =     14068.WinError
      ## Manifest Parse Error : Switch from current encoding to specified encoding not supported.

    error_sxs_xml_e_badxmlcase* =        14069.WinError
      ## Manifest Parse Error : The name 'xml' is reserved and must be lower case.

    error_sxs_xml_e_invalid_standalone* =  14070.WinError
      ## Manifest Parse Error : The standalone attribute must have the value 'yes' or 'no'.

    error_sxs_xml_e_unexpected_standalone* =  14071.WinError
      ## Manifest Parse Error : The standalone attribute cannot be used in external entities.

    error_sxs_xml_e_invalid_version* =   14072.WinError
      ## Manifest Parse Error : Invalid version number.

    error_sxs_xml_e_missingequals* =     14073.WinError
      ## Manifest Parse Error : Missing equals sign between attribute and attribute value.

    error_sxs_protection_recovery_failed* =  14074.WinError
      ## Assembly Protection Error : Unable to recover the specified assembly.

    error_sxs_protection_public_key_too_short* =  14075.WinError
      ## Assembly Protection Error : The public key for an assembly was too short to be allowed.

    error_sxs_protection_catalog_not_valid* =  14076.WinError
      ## Assembly Protection Error : The catalog for an assembly is not valid, or does not match the assembly's manifest.

    error_sxs_untranslatable_hresult* =  14077.WinError
      ## An HRESULT could not be translated to a corresponding Win32 error code.

    error_sxs_protection_catalog_file_missing* =  14078.WinError
      ## Assembly Protection Error : The catalog for an assembly is missing.

    error_sxs_missing_assembly_identity_attribute* =  14079.WinError
      ## The supplied assembly identity is missing one or more attributes which must be present in this context.

    error_sxs_invalid_assembly_identity_attribute_name* =  14080.WinError
      ## The supplied assembly identity has one or more attribute names that contain characters not permitted in XML names.

    error_sxs_assembly_missing* =        14081.WinError
      ## The referenced assembly could not be found.

    error_sxs_corrupt_activation_stack* =  14082.WinError
      ## The activation context activation stack for the running thread of execution is corrupt.

    error_sxs_corruption* =              14083.WinError
      ## The application isolation metadata for this process or thread has become corrupt.

    error_sxs_early_deactivation* =      14084.WinError
      ## The activation context being deactivated is not the most recently activated one.

    error_sxs_invalid_deactivation* =    14085.WinError
      ## The activation context being deactivated is not active for the current thread of execution.

    error_sxs_multiple_deactivation* =   14086.WinError
      ## The activation context being deactivated has already been deactivated.

    error_sxs_process_termination_requested* =  14087.WinError
      ## A component used by the isolation facility has requested to terminate the process.

    error_sxs_release_activation_context* =  14088.WinError
      ## A kernel mode component is releasing a reference on an activation context.

    error_sxs_system_default_activation_context_empty* =  14089.WinError
      ## The activation context of system default assembly could not be generated.

    error_sxs_invalid_identity_attribute_value* =  14090.WinError
      ## The value of an attribute in an identity is not within the legal range.

    error_sxs_invalid_identity_attribute_name* =  14091.WinError
      ## The name of an attribute in an identity is not within the legal range.

    error_sxs_identity_duplicate_attribute* =  14092.WinError
      ## An identity contains two definitions for the same attribute.

    error_sxs_identity_parse_error* =    14093.WinError
      ## The identity string is malformed. This may be due to a trailing comma, more than two unnamed attributes, missing attribute name or missing attribute value.

    error_malformed_substitution_string* =  14094.WinError
      ## A string containing localized substitutable content was malformed. Either a dollar sign ($) was followed by something other than a left parenthesis or another dollar sign or an substitution's right parenthesis was not found.

    error_sxs_incorrect_public_key_token* =  14095.WinError
      ## The public key token does not correspond to the public key specified.

    error_unmapped_substitution_string* =  14096.WinError
      ## A substitution string had no mapping.

    error_sxs_assembly_not_locked* =     14097.WinError
      ## The component must be locked before making the request.

    error_sxs_component_store_corrupt* =  14098.WinError
      ## The component store has been corrupted.

    error_advanced_installer_failed* =   14099.WinError
      ## An advanced installer failed during setup or servicing.

    error_xml_encoding_mismatch* =       14100.WinError
      ## The character encoding in the XML declaration did not match the encoding used in the document.

    error_sxs_manifest_identity_same_but_contents_different* =  14101.WinError
      ## The identities of the manifests are identical but their contents are different.

    error_sxs_identities_different* =    14102.WinError
      ## The component identities are different.

    error_sxs_assembly_is_not_a_deployment* =  14103.WinError
      ## The assembly is not a deployment.

    error_sxs_file_not_part_of_assembly* =  14104.WinError
      ## The file is not a part of the assembly.

    error_sxs_manifest_too_big* =        14105.WinError
      ## The size of the manifest exceeds the maximum allowed.

    error_sxs_setting_not_registered* =  14106.WinError
      ## The setting is not registered.

    error_sxs_transaction_closure_incomplete* =  14107.WinError
      ## One or more required members of the transaction are not present.

    error_smi_primitive_installer_failed* =  14108.WinError
      ## The SMI primitive installer failed during setup or servicing.

    error_generic_command_failed* =      14109.WinError
      ## A generic command executable returned a result that indicates failure.

    error_sxs_file_hash_missing* =       14110.WinError
      ## A component is missing file verification information in its manifest.


    ##################################################
    #                                               ##
    #           End of Side By Side Error Codes     ##
    #                                               ##
    #                 14000 to 14999                ##
    ##################################################


    ##################################################
    #                                               ##
    #           Start of WinEvt Error codes         ##
    #                                               ##
    #                 15000 to 15079                ##
    ##################################################

    error_evt_invalid_channel_path* =    15000.WinError
      ## The specified channel path is invalid.

    error_evt_invalid_query* =           15001.WinError
      ## The specified query is invalid.

    error_evt_publisher_metadata_not_found* =  15002.WinError
      ## The publisher metadata cannot be found in the resource.

    error_evt_event_template_not_found* =  15003.WinError
      ## The template for an event definition cannot be found in the resource (error = %1).

    error_evt_invalid_publisher_name* =  15004.WinError
      ## The specified publisher name is invalid.

    error_evt_invalid_event_data* =      15005.WinError
      ## The event data raised by the publisher is not compatible with the event template definition in the publisher's manifest

    error_evt_channel_not_found* =       15007.WinError
      ## The specified channel could not be found. Check channel configuration.

    error_evt_malformed_xml_text* =      15008.WinError
      ## The specified xml text was not well-formed. See Extended Error for more details.

    error_evt_subscription_to_direct_channel* =  15009.WinError
      ## The caller is trying to subscribe to a direct channel which is not allowed. The events for a direct channel go directly to a logfile and cannot be subscribed to.

    error_evt_configuration_error* =     15010.WinError
      ## Configuration error.

    error_evt_query_result_stale* =      15011.WinError
      ## The query result is stale / invalid. This may be due to the log being cleared or rolling over after the query result was created. Users should handle this code by releasing the query result object and reissuing the query.

    error_evt_query_result_invalid_position* =  15012.WinError
      ## Query result is currently at an invalid position.

    error_evt_non_validating_msxml* =    15013.WinError
      ## Registered MSXML doesn't support validation.

    error_evt_filter_alreadyscoped* =    15014.WinError
      ## An expression can only be followed by a change of scope operation if it itself evaluates to a node set and is not already part of some other change of scope operation.

    error_evt_filter_noteltset* =        15015.WinError
      ## Can't perform a step operation from a term that does not represent an element set.

    error_evt_filter_invarg* =           15016.WinError
      ## Left hand side arguments to binary operators must be either attributes, nodes or variables and right hand side arguments must be constants.

    error_evt_filter_invtest* =          15017.WinError
      ## A step operation must involve either a node test or, in the case of a predicate, an algebraic expression against which to test each node in the node set identified by the preceeding node set can be evaluated.

    error_evt_filter_invtype* =          15018.WinError
      ## This data type is currently unsupported.

    error_evt_filter_parseerr* =         15019.WinError
      ## A syntax error occurred at position %1!d!

    error_evt_filter_unsupportedop* =    15020.WinError
      ## This operator is unsupported by this implementation of the filter.

    error_evt_filter_unexpectedtoken* =  15021.WinError
      ## The token encountered was unexpected.

    error_evt_invalid_operation_over_enabled_direct_channel* =  15022.WinError
      ## The requested operation cannot be performed over an enabled direct channel. The channel must first be disabled before performing the requested operation.

    error_evt_invalid_channel_property_value* =  15023.WinError
      ## Channel property %1!s! contains invalid value. The value has invalid type, is outside of valid range, can't be updated or is not supported by this type of channel.

    error_evt_invalid_publisher_property_value* =  15024.WinError
      ## Publisher property %1!s! contains invalid value. The value has invalid type, is outside of valid range, can't be updated or is not supported by this type of publisher.

    error_evt_channel_cannot_activate* =  15025.WinError
      ## The channel fails to activate.

    error_evt_filter_too_complex* =      15026.WinError
      ## The xpath expression exceeded supported complexity. Please symplify it or split it into two or more simple expressions.

    error_evt_message_not_found* =       15027.WinError
      ## the message resource is present but the message is not found in the string/message table

    error_evt_message_id_not_found* =    15028.WinError
      ## The message id for the desired message could not be found.

    error_evt_unresolved_value_insert* =  15029.WinError
      ## The substitution string for insert index (%1) could not be found.

    error_evt_unresolved_parameter_insert* =  15030.WinError
      ## The description string for parameter reference (%1) could not be found.

    error_evt_max_inserts_reached* =     15031.WinError
      ## The maximum number of replacements has been reached.

    error_evt_event_definition_not_found* =  15032.WinError
      ## The event definition could not be found for event id (%1).

    error_evt_message_locale_not_found* =  15033.WinError
      ## The locale specific resource for the desired message is not present.

    error_evt_version_too_old* =         15034.WinError
      ## The resource is too old to be compatible.

    error_evt_version_too_new* =         15035.WinError
      ## The resource is too new to be compatible.

    error_evt_cannot_open_channel_of_query* =  15036.WinError
      ## The channel at index %1!d! of the query can't be opened.

    error_evt_publisher_disabled* =      15037.WinError
      ## The publisher has been disabled and its resource is not available. This usually occurs when the publisher is in the process of being uninstalled or upgraded.

    error_evt_filter_out_of_range* =     15038.WinError
      ## Attempted to create a numeric type that is outside of its valid range.


    ##################################################
    #                                               ##
    #           Start of Wecsvc Error codes         ##
    #                                               ##
    #                 15080 to 15099                ##
    ##################################################

    error_ec_subscription_cannot_activate* =  15080.WinError
      ## The subscription fails to activate.

    error_ec_log_disabled* =             15081.WinError
      ## The log of the subscription is in disabled state, and can not be used to forward events to. The log must first be enabled before the subscription can be activated.

    error_ec_circular_forwarding* =      15082.WinError
      ## When forwarding events from local machine to itself, the query of the subscription can't contain target log of the subscription.

    error_ec_credstore_full* =           15083.WinError
      ## The credential store that is used to save credentials is full.

    error_ec_cred_not_found* =           15084.WinError
      ## The credential used by this subscription can't be found in credential store.

    error_ec_no_active_channel* =        15085.WinError
      ## No active channel is found for the query.


    ##################################################
    #                                               ##
    #           Start of MUI Error codes            ##
    #                                               ##
    #                 15100 to 15199                ##
    ##################################################

    error_mui_file_not_found* =          15100.WinError
      ## The resource loader failed to find MUI file.    

    error_mui_invalid_file* =            15101.WinError
      ## The resource loader failed to load MUI file because the file fail to pass validation.    

    error_mui_invalid_rc_config* =       15102.WinError
      ## The RC Manifest is corrupted with garbage data or unsupported version or missing required item.    

    error_mui_invalid_locale_name* =     15103.WinError
      ## The RC Manifest has invalid culture name.    

    error_mui_invalid_ultimatefallback_name* =  15104.WinError
      ## The RC Manifest has invalid ultimatefallback name.    

    error_mui_file_not_loaded* =         15105.WinError
      ## The resource loader cache doesn't have loaded MUI entry.    

    error_resource_enum_user_stop* =     15106.WinError
      ## User stopped resource enumeration.

    error_mui_intlsettings_uilang_not_installed* =  15107.WinError
      ## UI language installation failed.

    error_mui_intlsettings_invalid_locale_name* =  15108.WinError
      ## Locale installation failed.

    error_mrm_runtime_no_default_or_neutral_resource* =  15110.WinError
      ## A resource does not have default or neutral value.

    error_mrm_invalid_priconfig* =       15111.WinError
      ## Invalid PRI config file.

    error_mrm_invalid_file_type* =       15112.WinError
      ## Invalid file type.

    error_mrm_unknown_qualifier* =       15113.WinError
      ## Unknown qualifier.

    error_mrm_invalid_qualifier_value* =  15114.WinError
      ## Invalid qualifier value.

    error_mrm_no_candidate* =            15115.WinError
      ## No Candidate found.

    error_mrm_no_match_or_default_candidate* =  15116.WinError
      ## The ResourceMap or NamedResource has an item that does not have default or neutral resource..

    error_mrm_resource_type_mismatch* =  15117.WinError
      ## Invalid ResourceCandidate type.

    error_mrm_duplicate_map_name* =      15118.WinError
      ## Duplicate Resource Map.

    error_mrm_duplicate_entry* =         15119.WinError
      ## Duplicate Entry.

    error_mrm_invalid_resource_identifier* =  15120.WinError
      ## Invalid Resource Identifier.

    error_mrm_filepath_too_long* =       15121.WinError
      ## Filepath too long.

    error_mrm_unsupported_directory_type* =  15122.WinError
      ## Unsupported directory type.

    error_mrm_invalid_pri_file* =        15126.WinError
      ## Invalid PRI File.

    error_mrm_named_resource_not_found* =  15127.WinError
      ## NamedResource Not Found.

    error_mrm_map_not_found* =           15135.WinError
      ## ResourceMap Not Found.

    error_mrm_unsupported_profile_type* =  15136.WinError
      ## Unsupported MRT profile type.

    error_mrm_invalid_qualifier_operator* =  15137.WinError
      ## Invalid qualifier operator.

    error_mrm_indeterminate_qualifier_value* =  15138.WinError
      ## Unable to determine qualifier value or qualifier value has not been set.

    error_mrm_automerge_enabled* =       15139.WinError
      ## Automerge is enabled in the PRI file.

    error_mrm_too_many_resources* =      15140.WinError
      ## Too many resources defined for package.

    error_mrm_unsupported_file_type_for_merge* =  15141.WinError
      ## Resource File can not be used for merge operation.

    error_mrm_unsupported_file_type_for_load_unload_pri_file* =  15142.WinError
      ## Load/UnloadPriFiles cannot be used with resource packages.

    error_mrm_no_current_view_on_thread* =  15143.WinError
      ## Resource Contexts may not be created on threads that do not have a CoreWindow.

    error_different_profile_resource_manager_exist* =  15144.WinError
      ## The singleton Resource Manager with different profile is already created.

    error_operation_not_allowed_from_system_component* =  15145.WinError
      ## The system component cannot operate given API operation

    error_mrm_direct_ref_to_non_default_resource* =  15146.WinError
      ## The resource is a direct reference to a non-default resource candidate.

    error_mrm_generation_count_mismatch* =  15147.WinError
      ## Resource Map has been re-generated and the query string is not valid anymore.

    error_pri_merge_version_mismatch* =  15148.WinError
      ## The PRI files to be merged have incompatible versions.

    error_pri_merge_missing_schema* =    15149.WinError
      ## The primary PRI files to be merged does not contain a schema.

    error_pri_merge_load_file_failed* =  15150.WinError
      ## Unable to load one of the PRI files to be merged.

    error_pri_merge_add_file_failed* =   15151.WinError
      ## Unable to add one of the PRI files to the merged file.

    error_pri_merge_write_file_failed* =  15152.WinError
      ## Unable to create the merged PRI file.


    ##################################################
    #                                               ##
    # Start of Monitor Configuration API error codes##
    #                                               ##
    #                 15200 to 15249                ##
    ##################################################

    error_mca_invalid_capabilities_string* =  15200.WinError
      ## The monitor returned a DDC/CI capabilities string that did not comply with the ACCESS.bus 3.0, DDC/CI 1.1 or MCCS 2 Revision 1 specification.

    error_mca_invalid_vcp_version* =     15201.WinError
      ## The monitor's VCP Version (0xDF) VCP code returned an invalid version value.

    error_mca_monitor_violates_mccs_specification* =  15202.WinError
      ## The monitor does not comply with the MCCS specification it claims to support.

    error_mca_mccs_version_mismatch* =   15203.WinError
      ## The MCCS version in a monitor's mccs_ver capability does not match the MCCS version the monitor reports when the VCP Version (0xDF) VCP code is used.

    error_mca_unsupported_mccs_version* =  15204.WinError
      ## The Monitor Configuration API only works with monitors that support the MCCS 1.0 specification, MCCS 2.0 specification or the MCCS 2.0 Revision 1 specification.

    error_mca_internal_error* =          15205.WinError
      ## An internal Monitor Configuration API error occurred.

    error_mca_invalid_technology_type_returned* =  15206.WinError
      ## The monitor returned an invalid monitor technology type. CRT, Plasma and LCD (TFT) are examples of monitor technology types. This error implies that the monitor violated the MCCS 2.0 or MCCS 2.0 Revision 1 specification.

    error_mca_unsupported_color_temperature* =  15207.WinError
      ## The caller of SetMonitorColorTemperature specified a color temperature that the current monitor did not support. This error implies that the monitor violated the MCCS 2.0 or MCCS 2.0 Revision 1 specification.


    #################################################
    #                                              ##
    # End of Monitor Configuration API error codes ##
    #                                              ##
    #                15200 to 15249                ##
    #                                              ##
    #################################################
    #################################################
    #                                              ##
    #         Start of Syspart error codes         ##
    #                15250 - 15299                 ##
    #                                              ##
    #################################################

    error_ambiguous_system_device* =     15250.WinError
      ## The requested system device cannot be identified due to multiple indistinguishable devices potentially matching the identification criteria.

    error_system_device_not_found* =     15299.WinError
      ## The requested system device cannot be found.

    #################################################
    #                                              ##
    #         Start of Vortex error codes          ##
    #                15300 - 15320                 ##
    #                                              ##
    #################################################

    error_hash_not_supported* =          15300.WinError
      ## Hash generation for the specified hash version and hash type is not enabled on the server.

    error_hash_not_present* =            15301.WinError
      ## The hash requested from the server is not available or no longer valid.

    #################################################
    #                                              ##
    #         Start of GPIO error codes            ##
    #                15321 - 15340                 ##
    #                                              ##
    #################################################

    error_secondary_ic_provider_not_registered* =  15321.WinError
      ## The secondary interrupt controller instance that manages the specified interrupt is not registered.

    error_gpio_client_information_invalid* =  15322.WinError
      ## The information supplied by the GPIO client driver is invalid.

    error_gpio_version_not_supported* =  15323.WinError
      ## The version specified by the GPIO client driver is not supported.

    error_gpio_invalid_registration_packet* =  15324.WinError
      ## The registration packet supplied by the GPIO client driver is not valid.

    error_gpio_operation_denied* =       15325.WinError
      ## The requested operation is not suppported for the specified handle.

    error_gpio_incompatible_connect_mode* =  15326.WinError
      ## The requested connect mode conflicts with an existing mode on one or more of the specified pins.

    error_gpio_interrupt_already_unmasked* =  15327.WinError
      ## The interrupt requested to be unmasked is not masked.

    #################################################
    #                                              ##
    #         Start of Run Level error codes       ##
    #                15400 - 15500                 ##
    #                                              ##
    #################################################

    error_cannot_switch_runlevel* =      15400.WinError
      ## The requested run level switch cannot be completed successfully.

    error_invalid_runlevel_setting* =    15401.WinError
      ## The service has an invalid run level setting. The run level for a service
      ## must not be higher than the run level of its dependent services.

    error_runlevel_switch_timeout* =     15402.WinError
      ## The requested run level switch cannot be completed successfully since
      ## one or more services will not stop or restart within the specified timeout.

    error_runlevel_switch_agent_timeout* =  15403.WinError
      ## A run level switch agent did not respond within the specified timeout.

    error_runlevel_switch_in_progress* =  15404.WinError
      ## A run level switch is currently in progress.

    error_services_failed_autostart* =   15405.WinError
      ## One or more services failed to start during the service startup phase of a run level switch.

    #################################################
    #                                              ##
    #         Start of Com Task error codes        ##
    #                15501 - 15510                 ##
    #                                              ##
    #################################################

    error_com_task_stop_pending* =       15501.WinError
      ## The task stop request cannot be completed immediately since
      ## task needs more time to shutdown.

    #######################################
    #                                    ##
    # APPX Caller Visible Error Codes    ##
    #          15600-15699               ##
    #######################################
    error_install_open_package_failed* =  15600.WinError
      ## Package could not be opened.

    error_install_package_not_found* =   15601.WinError
      ## Package was not found.

    error_install_invalid_package* =     15602.WinError
      ## Package data is invalid.

    error_install_resolve_dependency_failed* =  15603.WinError
      ## Package failed updates, dependency or conflict validation.

    error_install_out_of_disk_space* =   15604.WinError
      ## There is not enough disk space on your computer. Please free up some space and try again.

    error_install_network_failure* =     15605.WinError
      ## There was a problem downloading your product.

    error_install_registration_failure* =  15606.WinError
      ## Package could not be registered.

    error_install_deregistration_failure* =  15607.WinError
      ## Package could not be unregistered.

    error_install_cancel* =              15608.WinError
      ## User cancelled the install request.

    error_install_failed* =              15609.WinError
      ## Install failed. Please contact your software vendor.

    error_remove_failed* =               15610.WinError
      ## Removal failed. Please contact your software vendor.

    error_package_already_exists* =      15611.WinError
      ## The provided package is already installed, and reinstallation of the package was blocked. Check the AppXDeployment-Server event log for details.

    error_needs_remediation* =           15612.WinError
      ## The application cannot be started. Try reinstalling the application to fix the problem.

    error_install_prerequisite_failed* =  15613.WinError
      ## A Prerequisite for an install could not be satisfied.

    error_package_repository_corrupted* =  15614.WinError
      ## The package repository is corrupted.

    error_install_policy_failure* =      15615.WinError
      ## To install this application you need either a Windows developer license or a sideloading-enabled system.

    error_package_updating* =            15616.WinError
      ## The application cannot be started because it is currently updating.

    error_deployment_blocked_by_policy* =  15617.WinError
      ## The package deployment operation is blocked by policy. Please contact your system administrator.

    error_packages_in_use* =             15618.WinError
      ## The package could not be installed because resources it modifies are currently in use.

    error_recovery_file_corrupt* =       15619.WinError
      ## The package could not be recovered because necessary data for recovery have been corrupted.

    error_invalid_staged_signature* =    15620.WinError
      ## The signature is invalid. To register in developer mode, AppxSignature.p7x and AppxBlockMap.xml must be valid or should not be present.

    error_deleting_existing_applicationdata_store_failed* =  15621.WinError
      ## An error occurred while deleting the package's previously existing application data.

    error_install_package_downgrade* =   15622.WinError
      ## The package could not be installed because a higher version of this package is already installed.

    error_system_needs_remediation* =    15623.WinError
      ## An error in a system binary was detected. Try refreshing the PC to fix the problem.

    error_appx_integrity_failure_clr_ngen* =  15624.WinError
      ## A corrupted CLR NGEN binary was detected on the system.

    error_resiliency_file_corrupt* =     15625.WinError
      ## The operation could not be resumed because necessary data for recovery have been corrupted.

    error_install_firewall_service_not_running* =  15626.WinError
      ## The package could not be installed because the Windows Firewall service is not running. Enable the Windows Firewall service and try again.

    error_package_move_failed* =         15627.WinError
      ## Package move failed.

    error_install_volume_not_empty* =    15628.WinError
      ## The deployment operation failed because the volume is not empty.

    error_install_volume_offline* =      15629.WinError
      ## The deployment operation failed because the volume is offline.

    error_install_volume_corrupt* =      15630.WinError
      ## The deployment operation failed because the specified volume is corrupt.

    error_needs_registration* =          15631.WinError
      ## The deployment operation failed because the specified application needs to be registered first.

    error_install_wrong_processor_architecture* =  15632.WinError
      ## The deployment operation failed because the package targets the wrong processor architecture.

    error_dev_sideload_limit_exceeded* =  15633.WinError
      ## You have reached the maximum number of developer sideloaded packages allowed on this device. Please uninstall a sideloaded package and try again.

    error_install_optional_package_requires_main_package* =  15634.WinError
      ## A main app package is required to install this optional package.  Install the main package first and try again.

    error_package_not_supported_on_filesystem* =  15635.WinError
      ## This app package type is not supported on this filesystem

    #########################
    #                      ##
    # AppModel Error Codes ##
    #     15700-15720      ##
    #                      ##
    #########################
    appmodel_error_no_package* =         15700.WinError
      ## The process has no package identity.

    appmodel_error_package_runtime_corrupt* =  15701.WinError
      ## The package runtime information is corrupted.

    appmodel_error_package_identity_corrupt* =  15702.WinError
      ## The package identity is corrupted.

    appmodel_error_no_application* =     15703.WinError
      ## The process has no application identity.

    appmodel_error_dynamic_property_read_failed* =  15704.WinError
      ## One or more AppModel Runtime group policy values could not be read. Please contact your system administrator with the contents of your AppModel Runtime event log.

    appmodel_error_dynamic_property_invalid* =  15705.WinError
      ## One or more AppModel Runtime group policy values are invalid. Please contact your system administrator with the contents of your AppModel Runtime event log.

    appmodel_error_package_not_available* =  15706.WinError
      ## The package is currently not available.

    ############################
    #                         ##
    # Appx StateManager Codes ##
    #     15800-15840         ##
    #                         ##
    ############################
    error_state_load_store_failed* =     15800.WinError
      ## Loading the state store failed.

    error_state_get_version_failed* =    15801.WinError
      ## Retrieving the state version for the application failed.

    error_state_set_version_failed* =    15802.WinError
      ## Setting the state version for the application failed.

    error_state_structured_reset_failed* =  15803.WinError
      ## Resetting the structured state of the application failed.

    error_state_open_container_failed* =  15804.WinError
      ## State Manager failed to open the container.

    error_state_create_container_failed* =  15805.WinError
      ## State Manager failed to create the container.

    error_state_delete_container_failed* =  15806.WinError
      ## State Manager failed to delete the container.

    error_state_read_setting_failed* =   15807.WinError
      ## State Manager failed to read the setting.

    error_state_write_setting_failed* =  15808.WinError
      ## State Manager failed to write the setting.

    error_state_delete_setting_failed* =  15809.WinError
      ## State Manager failed to delete the setting.

    error_state_query_setting_failed* =  15810.WinError
      ## State Manager failed to query the setting.

    error_state_read_composite_setting_failed* =  15811.WinError
      ## State Manager failed to read the composite setting.

    error_state_write_composite_setting_failed* =  15812.WinError
      ## State Manager failed to write the composite setting.

    error_state_enumerate_container_failed* =  15813.WinError
      ## State Manager failed to enumerate the containers.

    error_state_enumerate_settings_failed* =  15814.WinError
      ## State Manager failed to enumerate the settings.

    error_state_composite_setting_value_size_limit_exceeded* =  15815.WinError
      ## The size of the state manager composite setting value has exceeded the limit.

    error_state_setting_value_size_limit_exceeded* =  15816.WinError
      ## The size of the state manager setting value has exceeded the limit.

    error_state_setting_name_size_limit_exceeded* =  15817.WinError
      ## The length of the state manager setting name has exceeded the limit.

    error_state_container_name_size_limit_exceeded* =  15818.WinError
      ## The length of the state manager container name has exceeded the limit.

    ################################
    #                             ##
    # Application Partition Codes ##
    #     15841-15860             ##
    #                             ##
    ################################
    error_api_unavailable* =             15841.WinError
      ## This API cannot be used in the context of the caller's application type.

    ################################
    #                             ##
    # Windows Store Codes         ##
    #     15861-15880             ##
    #                             ##
    ################################
    store_error_unlicensed* =            15861.WinError
      ## This PC does not have a valid license for the application or product.

    store_error_unlicensed_user* =       15862.WinError
      ## The authenticated user does not have a valid license for the application or product.

    store_error_pending_com_transaction* =  15863.WinError
      ## The commerce transaction associated with this license is still pending verification.

    store_error_license_revoked* =       15864.WinError
      ## The license has been revoked for this user.

###################################
#                                ##
#     COM Error Codes            ##
#                                ##
###################################


#
# The return value of COM functions and methods is an HRESULT.
# This is not a handle to anything, but is merely a 32-bit value
# with several fields encoded in the value. The parts of an
# HRESULT are shown below.
#
# Many of the macros and functions below were orginally defined to
# operate on SCODEs. SCODEs are no longer used. The macros are
# still present for compatibility and easy porting of Win16 code.
# Newly written code should use the HRESULT macros and functions.
#

#
#  HRESULTs are 32 bit values layed out as follows:
#
#   3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
#   1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
#  +-+-+-+-+-+---------------------+-------------------------------+
#  |S|R|C|N|r|    Facility         |               Code            |
#  +-+-+-+-+-+---------------------+-------------------------------+
#
#  where
#
#      S - Severity - indicates success/fail
#
#          0 - Success
#          1 - Fail (COERROR)
#
#      R - reserved portion of the facility code, corresponds to NT's
#              second severity bit.
#
#      C - reserved portion of the facility code, corresponds to NT's
#              C field.
#
#      N - reserved portion of the facility code. Used to indicate a
#              mapped NT status value.
#
#      r - reserved portion of the facility code. Reserved for internal
#              use. Used to indicate HRESULT values that are not status
#              values, but are instead message ids for display strings.
#
#      Facility - is the facility code
#
#      Code - is the facility's status code
#

#
# Severity values
#

type SeverityCode* = enum
  severity_success =    0
  severity_error =      1

proc succeeded*(hr: HResult): bool = 
  ## Generic test for success on any status value (non-negative numbers
  ## indicate success).
  cast[int32](hr) >= 0

proc failed*(hr: HResult): bool =
  ## inverse of succeeded
  cast[int32](hr) < 0

proc is_error*(status: int32): bool =
  ## Generic test for error on any status value.
  (status shr 31) == severity_success.int32

proc code*(hr: HResult): int16 =
  ## Return the code
  (hr.int32 and 0xFFFF).int16

proc facility*(hr: HResult): FacilityCode =
  ## Return the facility
  ((hr.int32 shr 16) and (0x1fff)).FacilityCode

proc severity*(hr: HResult): SeverityCode =
  ## Return the severity
  ((hr.int32 shr 31) and 0x1).SeverityCode

proc make_hresult*(sev: SeverityCode, fac: FacilityCode, code: int16): HResult =
  ## Create an HRESULT value from component pieces
  return ((sev.uint32 shl 31) or (fac.uint32 shl 16) or (code.uint32)).HResult

const facility_nt_bit* =                 0x10000000
  ## Map a WIN32 error value into a HRESULT
  ## Note: This assumes that WIN32 errors fall in the range -32k to 32k.
  ##
  ## Define bits here so macros are guaranteed to work

proc hresult_from_win32*(x: WinError): HResult {.inline.} =
  ## Map a Windows Error code into a HRESULT 
  result = 0.HResult

#[
converter toHResult*(x: NTStatus): HResult =
  ## Map an NT status value into a HRESULT
  (x.int32 or facility_nt_bit).HResult
]#

conditionalStringify(HResult):
  const
    sec_e_ok* = 0x00000000.HResult
    
    e_not_set* =                hresult_from_win32(error_not_found)
    e_not_valid_state* =        hresult_from_win32(error_invalid_state)
    e_not_sufficient_buffer* =  hresult_from_win32(error_insufficient_buffer)

    # ---------------------- HRESULT value definitions -----------------
    #
    # HRESULT definitions
    #

    #
    # Error definitions follow
    #

    #
    # Codes 0x4000-0x40ff are reserved for OLE
    #
    #
    # Error codes
    #
    e_unexpected* =                     0x8000FFFF.HResult
      ## Catastrophic failure

    e_notimpl* =                        0x80004001.HResult
      ## Not implemented

    e_outofmemory* =                    0x8007000E.HResult
      ## Ran out of memory

    e_invalidarg* =                     0x80070057.HResult
      ## One or more arguments are invalid

    e_nointerface* =                    0x80004002.HResult
      ## No such interface supported

    e_pointer* =                        0x80004003.HResult
      ## Invalid pointer

    e_handle* =                         0x80070006.HResult
      ## Invalid handle

    e_abort* =                          0x80004004.HResult
      ## Operation aborted

    e_fail* =                           0x80004005.HResult
      ## Unspecified error

    e_accessdenied* =                   0x80070005.HResult
      ## General access denied error

    e_pending* =                        0x8000000A.HResult
      ## The data necessary to complete this operation is not yet available.

    e_bounds* =                         0x8000000B.HResult
      ## The operation attempted to access data outside the valid range

    e_changed_state* =                  0x8000000C.HResult
      ## A concurrent or interleaved operation changed the state of the object, invalidating this operation.

    e_illegal_state_change* =           0x8000000D.HResult
      ## An illegal state change was requested.

    e_illegal_method_call* =            0x8000000E.HResult
      ## A method was called at an unexpected time.

    ro_e_metadata_name_not_found* =     0x8000000F.HResult
      ## Typename or Namespace was not found in metadata file.

    ro_e_metadata_name_is_namespace* =  0x80000010.HResult
      ## Name is an existing namespace rather than a typename.

    ro_e_metadata_invalid_type_format* = 0x80000011.HResult
      ## Typename has an invalid format.

    ro_e_invalid_metadata_file* =       0x80000012.HResult
      ## Metadata file is invalid or corrupted.

    ro_e_closed* =                      0x80000013.HResult
      ## The object has been closed.

    ro_e_exclusive_write* =             0x80000014.HResult
      ## Only one thread may access the object during a write operation.

    ro_e_change_notification_in_progress* = 0x80000015.HResult
      ## Operation is prohibited during change notification.

    ro_e_error_string_not_found* =      0x80000016.HResult
      ## The text associated with this error code could not be found.

    e_string_not_null_terminated* =     0x80000017.HResult
      ## String not null terminated.

    e_illegal_delegate_assignment* =    0x80000018.HResult
      ## A delegate was assigned when not allowed.

    e_async_operation_not_started* =    0x80000019.HResult
      ## An async operation was not properly started.

    e_application_exiting* =            0x8000001A.HResult
      ## The application is exiting and cannot service this request

    e_application_view_exiting* =       0x8000001B.HResult
      ## The application view is exiting and cannot service this request

    ro_e_must_be_agile* =               0x8000001C.HResult
      ## The object must support the IAgileObject interface

    ro_e_unsupported_from_mta* =        0x8000001D.HResult
      ## Activating a single-threaded class from MTA is not supported

    ro_e_committed* =                   0x8000001E.HResult
      ## The object has been committed.

    ro_e_blocked_cross_asta_call* =     0x8000001F.HResult
      ## A COM call to an ASTA was blocked because the call chain originated in or passed through another ASTA. This call pattern is deadlock-prone and disallowed by apartment call control.

    co_e_init_tls* =                    0x80004006.HResult
      ## Thread local storage failure

    co_e_init_shared_allocator* =       0x80004007.HResult
      ## Get shared memory allocator failure

    co_e_init_memory_allocator* =       0x80004008.HResult
      ## Get memory allocator failure

    co_e_init_class_cache* =            0x80004009.HResult
      ## Unable to initialize class cache

    co_e_init_rpc_channel* =            0x8000400A.HResult
      ## Unable to initialize RPC services

    co_e_init_tls_set_channel_control* = 0x8000400B.HResult
      ## Cannot set thread local storage channel control

    co_e_init_tls_channel_control* =    0x8000400C.HResult
      ## Could not allocate thread local storage channel control

    co_e_init_unaccepted_user_allocator* = 0x8000400D.HResult
      ## The user supplied memory allocator is unacceptable

    co_e_init_scm_mutex_exists* =       0x8000400E.HResult
      ## The OLE service mutex already exists

    co_e_init_scm_file_mapping_exists* = 0x8000400F.HResult
      ## The OLE service file mapping already exists

    co_e_init_scm_map_view_of_file* =   0x80004010.HResult
      ## Unable to map view of file for OLE service

    co_e_init_scm_exec_failure* =       0x80004011.HResult
      ## Failure attempting to launch OLE service

    co_e_init_only_single_threaded* =   0x80004012.HResult
      ## There was an attempt to call CoInitialize a second time while single threaded

    co_e_cant_remote* =                 0x80004013.HResult
      ## A Remote activation was necessary but was not allowed

    co_e_bad_server_name* =             0x80004014.HResult
      ## A Remote activation was necessary but the server name provided was invalid

    co_e_wrong_server_identity* =       0x80004015.HResult
      ## The class is configured to run as a security id different from the caller

    co_e_ole1dde_disabled* =            0x80004016.HResult
      ## Use of Ole1 services requiring DDE windows is disabled

    co_e_runas_syntax* =                0x80004017.HResult
      ## A RunAs specification must be <domain name>\<user name> or simply <user name>

    co_e_createprocess_failure* =       0x80004018.HResult
      ## The server process could not be started. The pathname may be incorrect.

    co_e_runas_createprocess_failure* = 0x80004019.HResult
      ## The server process could not be started as the configured identity. The pathname may be incorrect or unavailable.

    co_e_runas_logon_failure* =         0x8000401A.HResult
      ## The server process could not be started because the configured identity is incorrect. Check the username and password.

    co_e_launch_permssion_denied* =     0x8000401B.HResult
      ## The client is not allowed to launch this server.

    co_e_start_service_failure* =       0x8000401C.HResult
      ## The service providing this server could not be started.

    co_e_remote_communication_failure* = 0x8000401D.HResult
      ## This computer was unable to communicate with the computer providing the server.

    co_e_server_start_timeout* =        0x8000401E.HResult
      ## The server did not respond after being launched.

    co_e_clsreg_inconsistent* =         0x8000401F.HResult
      ## The registration information for this server is inconsistent or incomplete.

    co_e_iidreg_inconsistent* =         0x80004020.HResult
      ## The registration information for this interface is inconsistent or incomplete.

    co_e_not_supported* =               0x80004021.HResult
      ## The operation attempted is not supported.

    co_e_reload_dll* =                  0x80004022.HResult
      ## A dll must be loaded.

    co_e_msi_error* =                   0x80004023.HResult
      ## A Microsoft Software Installer error was encountered.

    co_e_attempt_to_create_outside_client_context* = 0x80004024.HResult
      ## The specified activation could not occur in the client context as specified.

    co_e_server_paused* =               0x80004025.HResult
      ## Activations on the server are paused.

    co_e_server_not_paused* =           0x80004026.HResult
      ## Activations on the server are not paused.

    co_e_class_disabled* =              0x80004027.HResult
      ## The component or application containing the component has been disabled.

    co_e_clrnotavailable* =             0x80004028.HResult
      ## The common language runtime is not available

    co_e_async_work_rejected* =         0x80004029.HResult
      ## The thread-pool rejected the submitted asynchronous work.

    co_e_server_init_timeout* =         0x8000402A.HResult
      ## The server started, but did not finish initializing in a timely fashion.

    co_e_no_secctx_in_activate* =       0x8000402B.HResult
      ## Unable to complete the call since there is no COM+ security context inside IObjectControl.Activate.

    co_e_tracker_config* =              0x80004030.HResult
      ## The provided tracker configuration is invalid

    co_e_threadpool_config* =           0x80004031.HResult
      ## The provided thread pool configuration is invalid

    co_e_sxs_config* =                  0x80004032.HResult
      ## The provided side-by-side configuration is invalid

    co_e_malformed_spn* =               0x80004033.HResult
      ## The server principal name (SPN) obtained during security negotiation is malformed.

    co_e_unrevoked_registration_on_apartment_shutdown* = 0x80004034.HResult
      ## The caller failed to revoke a per-apartment registration before apartment shutdown.

    co_e_premature_stub_rundown* =      0x80004035.HResult
      ## The object has been rundown by the stub manager while there are external clients.


    #
    # Success codes
    #
    s_ok* =                                   0.HResult
    s_false* =                                1.HResult

    # ******************
    # FACILITY_ITF
    # ******************

    #
    # Codes 0x0-0x01ff are reserved for the OLE group of
    # interfaces.
    #


    #
    # Generic OLE errors that may be returned by many inerfaces
    #

    ole_e_first* = 0x80040000.HResult
    ole_e_last* =  0x800400FF.HResult
    ole_s_first* = 0x00040000.HResult
    ole_s_last* =  0x000400FF.HResult

    #
    # Old OLE errors
    #
    ole_e_oleverb* =                    0x80040000.HResult
      ## Invalid OLEVERB structure

    ole_e_advf* =                       0x80040001.HResult
      ## Invalid advise flags

    ole_e_enum_nomore* =                0x80040002.HResult
      ## Can't enumerate any more, because the associated data is missing

    ole_e_advisenotsupported* =         0x80040003.HResult
      ## This implementation doesn't take advises

    ole_e_noconnection* =               0x80040004.HResult
      ## There is no connection for this connection ID

    ole_e_notrunning* =                 0x80040005.HResult
      ## Need to run the object to perform this operation

    ole_e_nocache* =                    0x80040006.HResult
      ## There is no cache to operate on

    ole_e_blank* =                      0x80040007.HResult
      ## Uninitialized object

    ole_e_classdiff* =                  0x80040008.HResult
      ## Linked object's source class has changed

    ole_e_cant_getmoniker* =            0x80040009.HResult
      ## Not able to get the moniker of the object

    ole_e_cant_bindtosource* =          0x8004000A.HResult
      ## Not able to bind to the source

    ole_e_static* =                     0x8004000B.HResult
      ## Object is static; operation not allowed

    ole_e_promptsavecancelled* =        0x8004000C.HResult
      ## User canceled out of save dialog

    ole_e_invalidrect* =                0x8004000D.HResult
      ## Invalid rectangle

    ole_e_wrongcompobj* =               0x8004000E.HResult
      ## compobj.dll is too old for the ole2.dll initialized

    ole_e_invalidhwnd* =                0x8004000F.HResult
      ## Invalid window handle

    ole_e_not_inplaceactive* =          0x80040010.HResult
      ## Object is not in any of the inplace active states

    ole_e_cantconvert* =                0x80040011.HResult
      ## Not able to convert object

    ole_e_nostorage* =                  0x80040012.HResult
      ## Not able to perform the operation because object is not given storage yet

    dv_e_formatetc* =                   0x80040064.HResult
      ## Invalid FORMATETC structure

    dv_e_dvtargetdevice* =              0x80040065.HResult
      ## Invalid DVTARGETDEVICE structure

    dv_e_stgmedium* =                   0x80040066.HResult
      ## Invalid STDGMEDIUM structure

    dv_e_statdata* =                    0x80040067.HResult
      ## Invalid STATDATA structure

    dv_e_lindex* =                      0x80040068.HResult
      ## Invalid lindex

    dv_e_tymed* =                       0x80040069.HResult
      ## Invalid tymed

    dv_e_clipformat* =                  0x8004006A.HResult
      ## Invalid clipboard format

    dv_e_dvaspect* =                    0x8004006B.HResult
      ## Invalid aspect(s)

    dv_e_dvtargetdevice_size* =         0x8004006C.HResult
      ## tdSize parameter of the DVTARGETDEVICE structure is invalid

    dv_e_noiviewobject* =               0x8004006D.HResult
      ## Object doesn't support IViewObject interface

    dragdrop_e_first* = 0x80040100.HResult
    dragdrop_e_last* =  0x8004010F.HResult
    dragdrop_s_first* = 0x00040100.HResult
    dragdrop_s_last* =  0x0004010F.HResult
    dragdrop_e_notregistered* =         0x80040100.HResult
      ## Trying to revoke a drop target that has not been registered

    dragdrop_e_alreadyregistered* =     0x80040101.HResult
      ## This window has already been registered as a drop target

    dragdrop_e_invalidhwnd* =           0x80040102.HResult
      ## Invalid window handle

    dragdrop_e_concurrent_drag_attempted* = 0x80040103.HResult
      ## A drag operation is already in progress

    classfactory_e_first* =  0x80040110.HResult
    classfactory_e_last* =   0x8004011F.HResult
    classfactory_s_first* =  0x00040110.HResult
    classfactory_s_last* =   0x0004011F.HResult
    class_e_noaggregation* =            0x80040110.HResult
      ## Class does not support aggregation (or class object is remote)

    class_e_classnotavailable* =        0x80040111.HResult
      ## ClassFactory cannot supply requested class

    class_e_notlicensed* =              0x80040112.HResult
      ## Class is not licensed for use

    marshal_e_first* =  0x80040120.HResult
    marshal_e_last* =   0x8004012F.HResult
    marshal_s_first* =  0x00040120.HResult
    marshal_s_last* =   0x0004012F.HResult
    data_e_first* =     0x80040130.HResult
    data_e_last* =      0x8004013F.HResult
    data_s_first* =     0x00040130.HResult
    data_s_last* =      0x0004013F.HResult
    view_e_first* =     0x80040140.HResult
    view_e_last* =      0x8004014F.HResult
    view_s_first* =     0x00040140.HResult
    view_s_last* =      0x0004014F.HResult
    view_e_draw* =                      0x80040140.HResult
      ## Error drawing view

    regdb_e_first* =     0x80040150.HResult
    regdb_e_last* =      0x8004015F.HResult
    regdb_s_first* =     0x00040150.HResult
    regdb_s_last* =      0x0004015F.HResult
    regdb_e_readregdb* =                0x80040150.HResult
      ## Could not read key from registry

    regdb_e_writeregdb* =               0x80040151.HResult
      ## Could not write key to registry

    regdb_e_keymissing* =               0x80040152.HResult
      ## Could not find the key in the registry

    regdb_e_invalidvalue* =             0x80040153.HResult
      ## Invalid value for registry

    regdb_e_classnotreg* =              0x80040154.HResult
      ## Class not registered

    regdb_e_iidnotreg* =                0x80040155.HResult
      ## Interface not registered

    regdb_e_badthreadingmodel* =        0x80040156.HResult
      ## Threading model entry is not valid

    regdb_e_packagepolicyviolation* =   0x80040157.HResult
      ## A registration in a package violates package-specific policies

    cat_e_first* =     0x80040160.HResult
    cat_e_last* =      0x80040161.HResult
    cat_e_catidnoexist* =               0x80040160.HResult
      ## CATID does not exist

    cat_e_nodescription* =              0x80040161.HResult
      ## Description not found

    ###################################
    #                                ##
    #     Class Store Error Codes    ##
    #                                ##
    ###################################
    cs_e_first* =     0x80040164.HResult
    cs_e_last* =      0x8004016F.HResult
    cs_e_package_notfound* =            0x80040164.HResult
      ## No package in the software installation data in the Active Directory meets this criteria.

    cs_e_not_deletable* =               0x80040165.HResult
      ## Deleting this will break the referential integrity of the software installation data in the Active Directory.

    cs_e_class_notfound* =              0x80040166.HResult
      ## The CLSID was not found in the software installation data in the Active Directory.

    cs_e_invalid_version* =             0x80040167.HResult
      ## The software installation data in the Active Directory is corrupt.

    cs_e_no_classstore* =               0x80040168.HResult
      ## There is no software installation data in the Active Directory.

    cs_e_object_notfound* =             0x80040169.HResult
      ## There is no software installation data object in the Active Directory.

    cs_e_object_already_exists* =       0x8004016A.HResult
      ## The software installation data object in the Active Directory already exists.

    cs_e_invalid_path* =                0x8004016B.HResult
      ## The path to the software installation data in the Active Directory is not correct.

    cs_e_network_error* =               0x8004016C.HResult
      ## A network error interrupted the operation.

    cs_e_admin_limit_exceeded* =        0x8004016D.HResult
      ## The size of this object exceeds the maximum size set by the Administrator.

    cs_e_schema_mismatch* =             0x8004016E.HResult
      ## The schema for the software installation data in the Active Directory does not match the required schema.

    cs_e_internal_error* =              0x8004016F.HResult
      ## An error occurred in the software installation data in the Active Directory.

    cache_e_first* =     0x80040170.HResult
    cache_e_last* =      0x8004017F.HResult
    cache_s_first* =     0x00040170.HResult
    cache_s_last* =      0x0004017F.HResult
    cache_e_nocache_updated* =          0x80040170.HResult
      ## Cache not updated

    oleobj_e_first* =     0x80040180.HResult
    oleobj_e_last* =      0x8004018F.HResult
    oleobj_s_first* =     0x00040180.HResult
    oleobj_s_last* =      0x0004018F.HResult
    oleobj_e_noverbs* =                 0x80040180.HResult
      ## No verbs for OLE object

    oleobj_e_invalidverb* =             0x80040181.HResult
      ## Invalid verb for OLE object

    clientsite_e_first* =     0x80040190.HResult
    clientsite_e_last* =      0x8004019F.HResult
    clientsite_s_first* =     0x00040190.HResult
    clientsite_s_last* =      0x0004019F.HResult
    inplace_e_notundoable* =            0x800401A0.HResult
      ## Undo is not available

    inplace_e_notoolspace* =            0x800401A1.HResult
      ## Space for tools is not available

    inplace_e_first* =     0x800401A0.HResult
    inplace_e_last* =      0x800401AF.HResult
    inplace_s_first* =     0x000401A0.HResult
    inplace_s_last* =      0x000401AF.HResult
    enum_e_first* =        0x800401B0.HResult
    enum_e_last* =         0x800401BF.HResult
    enum_s_first* =        0x000401B0.HResult
    enum_s_last* =         0x000401BF.HResult
    convert10_e_first* =        0x800401C0.HResult
    convert10_e_last* =         0x800401CF.HResult
    convert10_s_first* =        0x000401C0.HResult
    convert10_s_last* =         0x000401CF.HResult
    convert10_e_olestream_get* =        0x800401C0.HResult
      ## OLESTREAM Get method failed

    convert10_e_olestream_put* =        0x800401C1.HResult
      ## OLESTREAM Put method failed

    convert10_e_olestream_fmt* =        0x800401C2.HResult
      ## Contents of the OLESTREAM not in correct format

    convert10_e_olestream_bitmap_to_dib* = 0x800401C3.HResult
      ## There was an error in a Windows GDI call while converting the bitmap to a DIB

    convert10_e_stg_fmt* =              0x800401C4.HResult
      ## Contents of the IStorage not in correct format

    convert10_e_stg_no_std_stream* =    0x800401C5.HResult
      ## Contents of IStorage is missing one of the standard streams

    convert10_e_stg_dib_to_bitmap* =    0x800401C6.HResult
      ## There was an error in a Windows GDI call while converting the DIB to a bitmap.

    clipbrd_e_first* =        0x800401D0.HResult
    clipbrd_e_last* =         0x800401DF.HResult
    clipbrd_s_first* =        0x000401D0.HResult
    clipbrd_s_last* =         0x000401DF.HResult
    clipbrd_e_cant_open* =              0x800401D0.HResult
      ## OpenClipboard Failed

    clipbrd_e_cant_empty* =             0x800401D1.HResult
      ## EmptyClipboard Failed

    clipbrd_e_cant_set* =               0x800401D2.HResult
      ## SetClipboard Failed

    clipbrd_e_bad_data* =               0x800401D3.HResult
      ## Data on clipboard is invalid

    clipbrd_e_cant_close* =             0x800401D4.HResult
      ## CloseClipboard Failed

    mk_e_first* =        0x800401E0.HResult
    mk_e_last* =         0x800401EF.HResult
    mk_s_first* =        0x000401E0.HResult
    mk_s_last* =         0x000401EF.HResult
    mk_e_connectmanually* =             0x800401E0.HResult
      ## Moniker needs to be connected manually

    mk_e_exceededdeadline* =            0x800401E1.HResult
      ## Operation exceeded deadline

    mk_e_needgeneric* =                 0x800401E2.HResult
      ## Moniker needs to be generic

    mk_e_unavailable* =                 0x800401E3.HResult
      ## Operation unavailable

    mk_e_syntax* =                      0x800401E4.HResult
      ## Invalid syntax

    mk_e_noobject* =                    0x800401E5.HResult
      ## No object for moniker

    mk_e_invalidextension* =            0x800401E6.HResult
      ## Bad extension for file

    mk_e_intermediateinterfacenotsupported* = 0x800401E7.HResult
      ## Intermediate operation failed

    mk_e_notbindable* =                 0x800401E8.HResult
      ## Moniker is not bindable

    mk_e_notbound* =                    0x800401E9.HResult
      ## Moniker is not bound

    mk_e_cantopenfile* =                0x800401EA.HResult
      ## Moniker cannot open file

    mk_e_mustbotheruser* =              0x800401EB.HResult
      ## User input required for operation to succeed

    mk_e_noinverse* =                   0x800401EC.HResult
      ## Moniker class has no inverse

    mk_e_nostorage* =                   0x800401ED.HResult
      ## Moniker does not refer to storage

    mk_e_noprefix* =                    0x800401EE.HResult
      ## No common prefix

    mk_e_enumeration_failed* =          0x800401EF.HResult
      ## Moniker could not be enumerated

    co_e_first* =        0x800401F0.HResult
    co_e_last* =         0x800401FF.HResult
    co_s_first* =        0x000401F0.HResult
    co_s_last* =         0x000401FF.HResult
    co_e_notinitialized* =              0x800401F0.HResult
      ## CoInitialize has not been called.

    co_e_alreadyinitialized* =          0x800401F1.HResult
      ## CoInitialize has already been called.

    co_e_cantdetermineclass* =          0x800401F2.HResult
      ## Class of object cannot be determined

    co_e_classstring* =                 0x800401F3.HResult
      ## Invalid class string

    co_e_iidstring* =                   0x800401F4.HResult
      ## Invalid interface string

    co_e_appnotfound* =                 0x800401F5.HResult
      ## Application not found

    co_e_appsingleuse* =                0x800401F6.HResult
      ## Application cannot be run more than once

    co_e_errorinapp* =                  0x800401F7.HResult
      ## Some error in application program

    co_e_dllnotfound* =                 0x800401F8.HResult
      ## DLL for class not found

    co_e_errorindll* =                  0x800401F9.HResult
      ## Error in the DLL

    co_e_wrongosforapp* =               0x800401FA.HResult
      ## Wrong OS or OS version for application

    co_e_objnotreg* =                   0x800401FB.HResult
      ## Object is not registered

    co_e_objisreg* =                    0x800401FC.HResult
      ## Object is already registered

    co_e_objnotconnected* =             0x800401FD.HResult
      ## Object is not connected to server

    co_e_appdidntreg* =                 0x800401FE.HResult
      ## Application was launched but it didn't register a class factory

    co_e_released* =                    0x800401FF.HResult
      ## Object has been released

    event_e_first* =        0x80040200.HResult
    event_e_last* =         0x8004021F.HResult
    event_s_first* =        0x00040200.HResult
    event_s_last* =         0x0004021F.HResult
    event_s_some_subscribers_failed* =  0x00040200.HResult
      ## An event was able to invoke some but not all of the subscribers

    event_e_all_subscribers_failed* =   0x80040201.HResult
      ## An event was unable to invoke any of the subscribers

    event_s_nosubscribers* =            0x00040202.HResult
      ## An event was delivered but there were no subscribers

    event_e_querysyntax* =              0x80040203.HResult
      ## A syntax error occurred trying to evaluate a query string

    event_e_queryfield* =               0x80040204.HResult
      ## An invalid field name was used in a query string

    event_e_internalexception* =        0x80040205.HResult
      ## An unexpected exception was raised

    event_e_internalerror* =            0x80040206.HResult
      ## An unexpected internal error was detected

    event_e_invalid_per_user_sid* =     0x80040207.HResult
      ## The owner SID on a per-user subscription doesn't exist

    event_e_user_exception* =           0x80040208.HResult
      ## A user-supplied component or subscriber raised an exception

    event_e_too_many_methods* =         0x80040209.HResult
      ## An interface has too many methods to fire events from

    event_e_missing_eventclass* =       0x8004020A.HResult
      ## A subscription cannot be stored unless its event class already exists

    event_e_not_all_removed* =          0x8004020B.HResult
      ## Not all the objects requested could be removed

    event_e_complus_not_installed* =    0x8004020C.HResult
      ## COM+ is required for this operation, but is not installed

    event_e_cant_modify_or_delete_unconfigured_object* = 0x8004020D.HResult
      ## Cannot modify or delete an object that was not added using the COM+ Admin SDK

    event_e_cant_modify_or_delete_configured_object* = 0x8004020E.HResult
      ## Cannot modify or delete an object that was added using the COM+ Admin SDK

    event_e_invalid_event_class_partition* = 0x8004020F.HResult
      ## The event class for this subscription is in an invalid partition

    event_e_per_user_sid_not_logged_on* = 0x80040210.HResult
      ## The owner of the PerUser subscription is not logged on to the system specified

    tpc_e_invalid_property* =           0x80040241.HResult
      ## TabletPC inking error code. The property was not found, or supported by the recognizer

    tpc_e_no_default_tablet* =          0x80040212.HResult
      ## TabletPC inking error code. No default tablet

    tpc_e_unknown_property* =           0x8004021B.HResult
      ## TabletPC inking error code. Unknown property specified

    tpc_e_invalid_input_rect* =         0x80040219.HResult
      ## TabletPC inking error code. An invalid input rectangle was specified

    tpc_e_invalid_stroke* =             0x80040222.HResult
      ## TabletPC inking error code. The stroke object was deleted

    tpc_e_initialize_fail* =            0x80040223.HResult
      ## TabletPC inking error code. Initialization failure

    tpc_e_not_relevant* =               0x80040232.HResult
      ## TabletPC inking error code. The data required for the operation was not supplied

    tpc_e_invalid_packet_description* = 0x80040233.HResult
      ## TabletPC inking error code. Invalid packet description

    tpc_e_recognizer_not_registered* =  0x80040235.HResult
      ## TabletPC inking error code. There are no handwriting recognizers registered

    tpc_e_invalid_rights* =             0x80040236.HResult
      ## TabletPC inking error code. User does not have the necessary rights to read recognizer information

    tpc_e_out_of_order_call* =          0x80040237.HResult
      ## TabletPC inking error code. API calls were made in an incorrect order

    tpc_e_queue_full* =                 0x80040238.HResult
      ## TabletPC inking error code. Queue is full

    tpc_e_invalid_configuration* =      0x80040239.HResult
      ## TabletPC inking error code. RtpEnabled called multiple times

    tpc_e_invalid_data_from_recognizer* = 0x8004023A.HResult
      ## TabletPC inking error code. A recognizer returned invalid data

    tpc_s_truncated* =                  0x00040252.HResult
      ## TabletPC inking error code. String was truncated

    tpc_s_interrupted* =                0x00040253.HResult
      ## TabletPC inking error code. Recognition or training was interrupted

    tpc_s_no_data_to_process* =         0x00040254.HResult
      ## TabletPC inking error code. No personalization update to the recognizer because no training data found

    xact_e_first* =   0x8004D000.HResult
    xact_e_last* =    0x8004D02B.HResult
    xact_s_first* =   0x0004D000.HResult
    xact_s_last* =    0x0004D010.HResult
    xact_e_alreadyothersinglephase* =   0x8004D000.HResult
      ## Another single phase resource manager has already been enlisted in this transaction.

    xact_e_cantretain* =                0x8004D001.HResult
      ## A retaining commit or abort is not supported

    xact_e_commitfailed* =              0x8004D002.HResult
      ## The transaction failed to commit for an unknown reason. The transaction was aborted.

    xact_e_commitprevented* =           0x8004D003.HResult
      ## Cannot call commit on this transaction object because the calling application did not initiate the transaction.

    xact_e_heuristicabort* =            0x8004D004.HResult
      ## Instead of committing, the resource heuristically aborted.

    xact_e_heuristiccommit* =           0x8004D005.HResult
      ## Instead of aborting, the resource heuristically committed.

    xact_e_heuristicdamage* =           0x8004D006.HResult
      ## Some of the states of the resource were committed while others were aborted, likely because of heuristic decisions.

    xact_e_heuristicdanger* =           0x8004D007.HResult
      ## Some of the states of the resource may have been committed while others may have been aborted, likely because of heuristic decisions.

    xact_e_isolationlevel* =            0x8004D008.HResult
      ## The requested isolation level is not valid or supported.

    xact_e_noasync* =                   0x8004D009.HResult
      ## The transaction manager doesn't support an asynchronous operation for this method.

    xact_e_noenlist* =                  0x8004D00A.HResult
      ## Unable to enlist in the transaction.

    xact_e_noisoretain* =               0x8004D00B.HResult
      ## The requested semantics of retention of isolation across retaining commit and abort boundaries cannot be supported by this transaction implementation, or isoFlags was not equal to zero.

    xact_e_noresource* =                0x8004D00C.HResult
      ## There is no resource presently associated with this enlistment

    xact_e_notcurrent* =                0x8004D00D.HResult
      ## The transaction failed to commit due to the failure of optimistic concurrency control in at least one of the resource managers.

    xact_e_notransaction* =             0x8004D00E.HResult
      ## The transaction has already been implicitly or explicitly committed or aborted

    xact_e_notsupported* =              0x8004D00F.HResult
      ## An invalid combination of flags was specified

    xact_e_unknownrmgrid* =             0x8004D010.HResult
      ## The resource manager id is not associated with this transaction or the transaction manager.

    xact_e_wrongstate* =                0x8004D011.HResult
      ## This method was called in the wrong state

    xact_e_wronguow* =                  0x8004D012.HResult
      ## The indicated unit of work does not match the unit of work expected by the resource manager.

    xact_e_xtionexists* =               0x8004D013.HResult
      ## An enlistment in a transaction already exists.

    xact_e_noimportobject* =            0x8004D014.HResult
      ## An import object for the transaction could not be found.

    xact_e_invalidcookie* =             0x8004D015.HResult
      ## The transaction cookie is invalid.

    xact_e_indoubt* =                   0x8004D016.HResult
      ## The transaction status is in doubt. A communication failure occurred, or a transaction manager or resource manager has failed

    xact_e_notimeout* =                 0x8004D017.HResult
      ## A time-out was specified, but time-outs are not supported.

    xact_e_alreadyinprogress* =         0x8004D018.HResult
      ## The requested operation is already in progress for the transaction.

    xact_e_aborted* =                   0x8004D019.HResult
      ## The transaction has already been aborted.

    xact_e_logfull* =                   0x8004D01A.HResult
      ## The Transaction Manager returned a log full error.

    xact_e_tmnotavailable* =            0x8004D01B.HResult
      ## The Transaction Manager is not available.

    xact_e_connection_down* =           0x8004D01C.HResult
      ## A connection with the transaction manager was lost.

    xact_e_connection_denied* =         0x8004D01D.HResult
      ## A request to establish a connection with the transaction manager was denied.

    xact_e_reenlisttimeout* =           0x8004D01E.HResult
      ## Resource manager reenlistment to determine transaction status timed out.

    xact_e_tip_connect_failed* =        0x8004D01F.HResult
      ## This transaction manager failed to establish a connection with another TIP transaction manager.

    xact_e_tip_protocol_error* =        0x8004D020.HResult
      ## This transaction manager encountered a protocol error with another TIP transaction manager.

    xact_e_tip_pull_failed* =           0x8004D021.HResult
      ## This transaction manager could not propagate a transaction from another TIP transaction manager.

    xact_e_dest_tmnotavailable* =       0x8004D022.HResult
      ## The Transaction Manager on the destination machine is not available.

    xact_e_tip_disabled* =              0x8004D023.HResult
      ## The Transaction Manager has disabled its support for TIP.

    xact_e_network_tx_disabled* =       0x8004D024.HResult
      ## The transaction manager has disabled its support for remote/network transactions.

    xact_e_partner_network_tx_disabled* = 0x8004D025.HResult
      ## The partner transaction manager has disabled its support for remote/network transactions.

    xact_e_xa_tx_disabled* =            0x8004D026.HResult
      ## The transaction manager has disabled its support for XA transactions.

    xact_e_unable_to_read_dtc_config* = 0x8004D027.HResult
      ## MSDTC was unable to read its configuration information.

    xact_e_unable_to_load_dtc_proxy* =  0x8004D028.HResult
      ## MSDTC was unable to load the dtc proxy dll.

    xact_e_aborting* =                  0x8004D029.HResult
      ## The local transaction has aborted.

    xact_e_push_comm_failure* =         0x8004D02A.HResult
      ## The MSDTC transaction manager was unable to push the transaction to the destination transaction manager due to communication problems. Possible causes are: a firewall is present and it doesn't have an exception for the MSDTC process, the two machines cannot find each other by their NetBIOS names, or the support for network transactions is not enabled for one of the two transaction managers.

    xact_e_pull_comm_failure* =         0x8004D02B.HResult
      ## The MSDTC transaction manager was unable to pull the transaction from the source transaction manager due to communication problems. Possible causes are: a firewall is present and it doesn't have an exception for the MSDTC process, the two machines cannot find each other by their NetBIOS names, or the support for network transactions is not enabled for one of the two transaction managers.

    xact_e_lu_tx_disabled* =            0x8004D02C.HResult
      ## The MSDTC transaction manager has disabled its support for SNA LU 6.2 transactions.

    #
    # TXF & CRM errors start 4d080.
    xact_e_clerknotfound* =             0x8004D080.HResult
      ## XACT_E_CLERKNOTFOUND

    xact_e_clerkexists* =               0x8004D081.HResult
      ## XACT_E_CLERKEXISTS

    xact_e_recoveryinprogress* =        0x8004D082.HResult
      ## XACT_E_RECOVERYINPROGRESS

    xact_e_transactionclosed* =         0x8004D083.HResult
      ## XACT_E_TRANSACTIONCLOSED

    xact_e_invalidlsn* =                0x8004D084.HResult
      ## XACT_E_INVALIDLSN

    xact_e_replayrequest* =             0x8004D085.HResult
      ## XACT_E_REPLAYREQUEST

    # Begin XACT_DTC_CONSTANTS enumerated values defined in txdtc.h

    xact_e_connection_request_denied* = 0x8004D100.HResult
      ## The request to connect to the specified transaction coordinator was denied.


    xact_e_toomany_enlistments* = 0x8004D101.HResult
      ## The maximum number of enlistments for the specified transaction has been reached.


    xact_e_duplicate_guid* = 0x8004D102.HResult
      ## A resource manager with the same identifier is already registered with the specified transaction coordinator.


    xact_e_notsinglephase* = 0x8004D103.HResult
      ## The prepare request given was not eligible for single phase optimizations.


    xact_e_recoveryalreadydone* = 0x8004D104.HResult
      ## RecoveryComplete has already been called for the given resource manager.


    xact_e_protocol* = 0x8004D105.HResult
      ## The interface call made was incorrect for the current state of the protocol.


    xact_e_rm_failure* = 0x8004D106.HResult
      ## xa_open call failed for the XA resource.


    xact_e_recovery_failed* = 0x8004D107.HResult
      ## xa_recover call failed for the XA resource.


    xact_e_lu_not_found* = 0x8004D108.HResult
      ## The Logical Unit of Work specified cannot be found.


    xact_e_duplicate_lu* = 0x8004D109.HResult
      ## The specified Logical Unit of Work already exists.


    xact_e_lu_not_connected* = 0x8004D10A.HResult
      ## Subordinate creation failed. The specified Logical Unit of Work was not connected.


    xact_e_duplicate_transid* = 0x8004D10B.HResult
      ## A transaction with the given identifier already exists.


    xact_e_lu_busy* = 0x8004D10C.HResult
      ## The resource is in use.


    xact_e_lu_no_recovery_process* = 0x8004D10D.HResult
      ## The LU Recovery process is down.


    xact_e_lu_down* = 0x8004D10E.HResult
      ## The remote session was lost.


    xact_e_lu_recovering* = 0x8004D10F.HResult
      ## The resource is currently recovering.


    xact_e_lu_recovery_mismatch* = 0x8004D110.HResult
      ## There was a mismatch in driving recovery.


    xact_e_rm_unavailable* = 0x8004D111.HResult
      ## An error occurred with the XA resource.


    # End XACT_DTC_CONSTANTS enumerated values defined in txdtc.h

    #
    # OleTx Success codes.
    #
    xact_s_async* =                     0x0004D000.HResult
      ## An asynchronous operation was specified. The operation has begun, but its outcome is not known yet.

    xact_s_defect* =                    0x0004D001.HResult
      ## XACT_S_DEFECT

    xact_s_readonly* =                  0x0004D002.HResult
      ## The method call succeeded because the transaction was read-only.

    xact_s_somenoretain* =              0x0004D003.HResult
      ## The transaction was successfully aborted. However, this is a coordinated transaction, and some number of enlisted resources were aborted outright because they could not support abort-retaining semantics

    xact_s_okinform* =                  0x0004D004.HResult
      ## No changes were made during this call, but the sink wants another chance to look if any other sinks make further changes.

    xact_s_madechangescontent* =        0x0004D005.HResult
      ## The sink is content and wishes the transaction to proceed. Changes were made to one or more resources during this call.

    xact_s_madechangesinform* =         0x0004D006.HResult
      ## The sink is for the moment and wishes the transaction to proceed, but if other changes are made following this return by other event sinks then this sink wants another chance to look

    xact_s_allnoretain* =               0x0004D007.HResult
      ## The transaction was successfully aborted. However, the abort was non-retaining.

    xact_s_aborting* =                  0x0004D008.HResult
      ## An abort operation was already in progress.

    xact_s_singlephase* =               0x0004D009.HResult
      ## The resource manager has performed a single-phase commit of the transaction.

    xact_s_locally_ok* =                0x0004D00A.HResult
      ## The local transaction has not aborted.

    xact_s_lastresourcemanager* =       0x0004D010.HResult
      ## The resource manager has requested to be the coordinator (last resource manager) for the transaction.

    context_e_first* =        0x8004E000.HResult
    context_e_last* =         0x8004E02F.HResult
    context_s_first* =        0x0004E000.HResult
    context_s_last* =         0x0004E02F.HResult
    context_e_aborted* =                0x8004E002.HResult
      ## The root transaction wanted to commit, but transaction aborted

    context_e_aborting* =               0x8004E003.HResult
      ## You made a method call on a COM+ component that has a transaction that has already aborted or in the process of aborting.

    context_e_nocontext* =              0x8004E004.HResult
      ## There is no MTS object context

    context_e_would_deadlock* =         0x8004E005.HResult
      ## The component is configured to use synchronization and this method call would cause a deadlock to occur.

    context_e_synch_timeout* =          0x8004E006.HResult
      ## The component is configured to use synchronization and a thread has timed out waiting to enter the context.

    context_e_oldref* =                 0x8004E007.HResult
      ## You made a method call on a COM+ component that has a transaction that has already committed or aborted.

    context_e_rolenotfound* =           0x8004E00C.HResult
      ## The specified role was not configured for the application

    context_e_tmnotavailable* =         0x8004E00F.HResult
      ## COM+ was unable to talk to the Microsoft Distributed Transaction Coordinator

    co_e_activationfailed* =            0x8004E021.HResult
      ## An unexpected error occurred during COM+ Activation.

    co_e_activationfailed_eventlogged* = 0x8004E022.HResult
      ## COM+ Activation failed. Check the event log for more information

    co_e_activationfailed_catalogerror* = 0x8004E023.HResult
      ## COM+ Activation failed due to a catalog or configuration error.

    co_e_activationfailed_timeout* =    0x8004E024.HResult
      ## COM+ activation failed because the activation could not be completed in the specified amount of time.

    co_e_initializationfailed* =        0x8004E025.HResult
      ## COM+ Activation failed because an initialization function failed. Check the event log for more information.

    context_e_nojit* =                  0x8004E026.HResult
      ## The requested operation requires that JIT be in the current context and it is not

    context_e_notransaction* =          0x8004E027.HResult
      ## The requested operation requires that the current context have a Transaction, and it does not

    co_e_threadingmodel_changed* =      0x8004E028.HResult
      ## The components threading model has changed after install into a COM+ Application. Please re-install component.

    co_e_noiisintrinsics* =             0x8004E029.HResult
      ## IIS intrinsics not available. Start your work with IIS.

    co_e_nocookies* =                   0x8004E02A.HResult
      ## An attempt to write a cookie failed.

    co_e_dberror* =                     0x8004E02B.HResult
      ## An attempt to use a database generated a database specific error.

    co_e_notpooled* =                   0x8004E02C.HResult
      ## The COM+ component you created must use object pooling to work.

    co_e_notconstructed* =              0x8004E02D.HResult
      ## The COM+ component you created must use object construction to work correctly.

    co_e_nosynchronization* =           0x8004E02E.HResult
      ## The COM+ component requires synchronization, and it is not configured for it.

    co_e_isolevelmismatch* =            0x8004E02F.HResult
      ## The TxIsolation Level property for the COM+ component being created is stronger than the TxIsolationLevel for the "root" component for the transaction. The creation failed.

    co_e_call_out_of_tx_scope_not_allowed* = 0x8004E030.HResult
      ## The component attempted to make a cross-context call between invocations of EnterTransactionScopeand ExitTransactionScope. This is not allowed. Cross-context calls cannot be made while inside of a transaction scope.

    co_e_exit_transaction_scope_not_called* = 0x8004E031.HResult
      ## The component made a call to EnterTransactionScope, but did not make a corresponding call to ExitTransactionScope before returning.

    #
    # Old OLE Success Codes
    #
    ole_s_usereg* =                     0x00040000.HResult
      ## Use the registry database to provide the requested information

    ole_s_static* =                     0x00040001.HResult
      ## Success, but static

    ole_s_mac_clipformat* =             0x00040002.HResult
      ## Macintosh clipboard format

    dragdrop_s_drop* =                  0x00040100.HResult
      ## Successful drop took place

    dragdrop_s_cancel* =                0x00040101.HResult
      ## Drag-drop operation canceled

    dragdrop_s_usedefaultcursors* =     0x00040102.HResult
      ## Use the default cursor

    data_s_sameformatetc* =             0x00040130.HResult
      ## Data has same FORMATETC

    view_s_already_frozen* =            0x00040140.HResult
      ## View is already frozen

    cache_s_formatetc_notsupported* =   0x00040170.HResult
      ## FORMATETC not supported

    cache_s_samecache* =                0x00040171.HResult
      ## Same cache

    cache_s_somecaches_notupdated* =    0x00040172.HResult
      ## Some cache(s) not updated

    oleobj_s_invalidverb* =             0x00040180.HResult
      ## Invalid verb for OLE object

    oleobj_s_cannot_doverb_now* =       0x00040181.HResult
      ## Verb number is valid but verb cannot be done now

    oleobj_s_invalidhwnd* =             0x00040182.HResult
      ## Invalid window handle passed

    inplace_s_truncated* =              0x000401A0.HResult
      ## Message is too long; some of it had to be truncated before displaying

    convert10_s_no_presentation* =      0x000401C0.HResult
      ## Unable to convert OLESTREAM to IStorage

    mk_s_reduced_to_self* =             0x000401E2.HResult
      ## Moniker reduced to itself

    mk_s_me* =                          0x000401E4.HResult
      ## Common prefix is this moniker

    mk_s_him* =                         0x000401E5.HResult
      ## Common prefix is input moniker

    mk_s_us* =                          0x000401E6.HResult
      ## Common prefix is both monikers

    mk_s_monikeralreadyregistered* =    0x000401E7.HResult
      ## Moniker is already registered in running object table

    #
    # Task Scheduler errors
    #
    sched_s_task_ready* =               0x00041300.HResult
      ## The task is ready to run at its next scheduled time.

    sched_s_task_running* =             0x00041301.HResult
      ## The task is currently running.

    sched_s_task_disabled* =            0x00041302.HResult
      ## The task will not run at the scheduled times because it has been disabled.

    sched_s_task_has_not_run* =         0x00041303.HResult
      ## The task has not yet run.

    sched_s_task_no_more_runs* =        0x00041304.HResult
      ## There are no more runs scheduled for this task.

    sched_s_task_not_scheduled* =       0x00041305.HResult
      ## One or more of the properties that are needed to run this task on a schedule have not been set.

    sched_s_task_terminated* =          0x00041306.HResult
      ## The last run of the task was terminated by the user.

    sched_s_task_no_valid_triggers* =   0x00041307.HResult
      ## Either the task has no triggers or the existing triggers are disabled or not set.

    sched_s_event_trigger* =            0x00041308.HResult
      ## Event triggers don't have set run times.

    sched_e_trigger_not_found* =        0x80041309.HResult
      ## Trigger not found.

    sched_e_task_not_ready* =           0x8004130A.HResult
      ## One or more of the properties that are needed to run this task have not been set.

    sched_e_task_not_running* =         0x8004130B.HResult
      ## There is no running instance of the task.

    sched_e_service_not_installed* =    0x8004130C.HResult
      ## The Task Scheduler Service is not installed on this computer.

    sched_e_cannot_open_task* =         0x8004130D.HResult
      ## The task object could not be opened.

    sched_e_invalid_task* =             0x8004130E.HResult
      ## The object is either an invalid task object or is not a task object.

    sched_e_account_information_not_set* = 0x8004130F.HResult
      ## No account information could be found in the Task Scheduler security database for the task indicated.

    sched_e_account_name_not_found* =   0x80041310.HResult
      ## Unable to establish existence of the account specified.

    sched_e_account_dbase_corrupt* =    0x80041311.HResult
      ## Corruption was detected in the Task Scheduler security database; the database has been reset.

    sched_e_no_security_services* =     0x80041312.HResult
      ## Task Scheduler security services are available only on Windows NT.

    sched_e_unknown_object_version* =   0x80041313.HResult
      ## The task object version is either unsupported or invalid.

    sched_e_unsupported_account_option* = 0x80041314.HResult
      ## The task has been configured with an unsupported combination of account settings and run time options.

    sched_e_service_not_running* =      0x80041315.HResult
      ## The Task Scheduler Service is not running.

    sched_e_unexpectednode* =           0x80041316.HResult
      ## The task XML contains an unexpected node.

    sched_e_namespace* =                0x80041317.HResult
      ## The task XML contains an element or attribute from an unexpected namespace.

    sched_e_invalidvalue* =             0x80041318.HResult
      ## The task XML contains a value which is incorrectly formatted or out of range.

    sched_e_missingnode* =              0x80041319.HResult
      ## The task XML is missing a required element or attribute.

    sched_e_malformedxml* =             0x8004131A.HResult
      ## The task XML is malformed.

    sched_s_some_triggers_failed* =     0x0004131B.HResult
      ## The task is registered, but not all specified triggers will start the task, check task scheduler event log for detailed information.

    sched_s_batch_logon_problem* =      0x0004131C.HResult
      ## The task is registered, but may fail to start. Batch logon privilege needs to be enabled for the task principal.

    sched_e_too_many_nodes* =           0x8004131D.HResult
      ## The task XML contains too many nodes of the same type.

    sched_e_past_end_boundary* =        0x8004131E.HResult
      ## The task cannot be started after the trigger's end boundary.

    sched_e_already_running* =          0x8004131F.HResult
      ## An instance of this task is already running.

    sched_e_user_not_logged_on* =       0x80041320.HResult
      ## The task will not run because the user is not logged on.

    sched_e_invalid_task_hash* =        0x80041321.HResult
      ## The task image is corrupt or has been tampered with.

    sched_e_service_not_available* =    0x80041322.HResult
      ## The Task Scheduler service is not available.

    sched_e_service_too_busy* =         0x80041323.HResult
      ## The Task Scheduler service is too busy to handle your request. Please try again later.

    sched_e_task_attempted* =           0x80041324.HResult
      ## The Task Scheduler service attempted to run the task, but the task did not run due to one of the constraints in the task definition.

    sched_s_task_queued* =              0x00041325.HResult
      ## The Task Scheduler service has asked the task to run.

    sched_e_task_disabled* =            0x80041326.HResult
      ## The task is disabled.

    sched_e_task_not_v1_compat* =       0x80041327.HResult
      ## The task has properties that are not compatible with previous versions of Windows.

    sched_e_start_on_demand* =          0x80041328.HResult
      ## The task settings do not allow the task to start on demand.

    sched_e_task_not_ubpm_compat* =     0x80041329.HResult
      ## The combination of properties that task is using is not compatible with the scheduling engine.

    sched_e_deprecated_feature_used* =  0x80041330.HResult
      ## The task definition uses a deprecated feature.

    # ******************
    # FACILITY_WINDOWS
    # ******************
    #
    # Codes 0x0-0x01ff are reserved for the OLE group of
    # interfaces.
    #
    co_e_class_create_failed* =         0x80080001.HResult
      ## Attempt to create a class object failed

    co_e_scm_error* =                   0x80080002.HResult
      ## OLE service could not bind object

    co_e_scm_rpc_failure* =             0x80080003.HResult
      ## RPC communication failed with OLE service

    co_e_bad_path* =                    0x80080004.HResult
      ## Bad path to object

    co_e_server_exec_failure* =         0x80080005.HResult
      ## Server execution failed

    co_e_objsrv_rpc_failure* =          0x80080006.HResult
      ## OLE service could not communicate with the object server

    mk_e_no_normalized* =               0x80080007.HResult
      ## Moniker path could not be normalized

    co_e_server_stopping* =             0x80080008.HResult
      ## Object server is stopping when OLE service contacts it

    mem_e_invalid_root* =               0x80080009.HResult
      ## An invalid root block pointer was specified

    mem_e_invalid_link* =               0x80080010.HResult
      ## An allocation chain contained an invalid link pointer

    mem_e_invalid_size* =               0x80080011.HResult
      ## The requested allocation size was too large

    co_s_notallinterfaces* =            0x00080012.HResult
      ## Not all the requested interfaces were available

    co_s_machinenamenotfound* =         0x00080013.HResult
      ## The specified machine name was not found in the cache.

    co_e_missing_displayname* =         0x80080015.HResult
      ## The activation requires a display name to be present under the CLSID key.

    co_e_runas_value_must_be_aaa* =     0x80080016.HResult
      ## The activation requires that the RunAs value for the application is Activate As Activator.

    co_e_elevation_disabled* =          0x80080017.HResult
      ## The class is not configured to support Elevated activation.

    #
    # Codes 0x0200-0x02ff are reserved for the APPX errors
    #
    appx_e_packaging_internal* =        0x80080200.HResult
      ## Appx packaging API has encountered an internal error.

    appx_e_interleaving_not_allowed* =  0x80080201.HResult
      ## The file is not a valid Appx package because its contents are interleaved.

    appx_e_relationships_not_allowed* = 0x80080202.HResult
      ## The file is not a valid Appx package because it contains OPC relationships.

    appx_e_missing_required_file* =     0x80080203.HResult
      ## The file is not a valid Appx package because it is missing a manifest or block map, or missing a signature file when the code integrity file is present.

    appx_e_invalid_manifest* =          0x80080204.HResult
      ## The Appx package's manifest is invalid.

    appx_e_invalid_blockmap* =          0x80080205.HResult
      ## The Appx package's block map is invalid.

    appx_e_corrupt_content* =           0x80080206.HResult
      ## The Appx package's content cannot be read because it is corrupt.

    appx_e_block_hash_invalid* =        0x80080207.HResult
      ## The computed hash value of the block does not match the one stored in the block map.

    appx_e_requested_range_too_large* = 0x80080208.HResult
      ## The requested byte range is over 4GB when translated to byte range of blocks.

    appx_e_invalid_sip_client_data* =   0x80080209.HResult
      ## The SIP_SUBJECTINFO structure used to sign the package didn't contain the required data.

    appx_e_invalid_key_info* =          0x8008020A.HResult
      ## The APPX_KEY_INFO structure used to encrypt or decrypt the package contains invalid data.

    #
    # Codes 0x0300-0x030f are reserved for background task error codes.
    #
    bt_e_spurious_activation* =         0x80080300.HResult
      ## The background task activation is spurious.

    # ******************
    # FACILITY_DISPATCH
    # ******************
    disp_e_unknowninterface* =          0x80020001.HResult
      ## Unknown interface.

    disp_e_membernotfound* =            0x80020003.HResult
      ## Member not found.

    disp_e_paramnotfound* =             0x80020004.HResult
      ## Parameter not found.

    disp_e_typemismatch* =              0x80020005.HResult
      ## Type mismatch.

    disp_e_unknownname* =               0x80020006.HResult
      ## Unknown name.

    disp_e_nonamedargs* =               0x80020007.HResult
      ## No named arguments.

    disp_e_badvartype* =                0x80020008.HResult
      ## Bad variable type.

    disp_e_exception* =                 0x80020009.HResult
      ## Exception occurred.

    disp_e_overflow* =                  0x8002000A.HResult
      ## Out of present range.

    disp_e_badindex* =                  0x8002000B.HResult
      ## Invalid index.

    disp_e_unknownlcid* =               0x8002000C.HResult
      ## Unknown language.

    disp_e_arrayislocked* =             0x8002000D.HResult
      ## Memory is locked.

    disp_e_badparamcount* =             0x8002000E.HResult
      ## Invalid number of parameters.

    disp_e_paramnotoptional* =          0x8002000F.HResult
      ## Parameter not optional.

    disp_e_badcallee* =                 0x80020010.HResult
      ## Invalid callee.

    disp_e_notacollection* =            0x80020011.HResult
      ## Does not support a collection.

    disp_e_divbyzero* =                 0x80020012.HResult
      ## Division by zero.

    disp_e_buffertoosmall* =            0x80020013.HResult
      ## Buffer too small

    type_e_buffertoosmall* =            0x80028016.HResult
      ## Buffer too small.

    type_e_fieldnotfound* =             0x80028017.HResult
      ## Field name not defined in the record.

    type_e_invdataread* =               0x80028018.HResult
      ## Old format or invalid type library.

    type_e_unsupformat* =               0x80028019.HResult
      ## Old format or invalid type library.

    type_e_registryaccess* =            0x8002801C.HResult
      ## Error accessing the OLE registry.

    type_e_libnotregistered* =          0x8002801D.HResult
      ## Library not registered.

    type_e_undefinedtype* =             0x80028027.HResult
      ## Bound to unknown type.

    type_e_qualifiednamedisallowed* =   0x80028028.HResult
      ## Qualified name disallowed.

    type_e_invalidstate* =              0x80028029.HResult
      ## Invalid forward reference, or reference to uncompiled type.

    type_e_wrongtypekind* =             0x8002802A.HResult
      ## Type mismatch.

    type_e_elementnotfound* =           0x8002802B.HResult
      ## Element not found.

    type_e_ambiguousname* =             0x8002802C.HResult
      ## Ambiguous name.

    type_e_nameconflict* =              0x8002802D.HResult
      ## Name already exists in the library.

    type_e_unknownlcid* =               0x8002802E.HResult
      ## Unknown LCID.

    type_e_dllfunctionnotfound* =       0x8002802F.HResult
      ## Function not defined in specified DLL.

    type_e_badmodulekind* =             0x800288BD.HResult
      ## Wrong module kind for the operation.

    type_e_sizetoobig* =                0x800288C5.HResult
      ## Size may not exceed 64K.

    type_e_duplicateid* =               0x800288C6.HResult
      ## Duplicate ID in inheritance hierarchy.

    type_e_invalidid* =                 0x800288CF.HResult
      ## Incorrect inheritance depth in standard OLE hmember.

    type_e_typemismatch* =              0x80028CA0.HResult
      ## Type mismatch.

    type_e_outofbounds* =               0x80028CA1.HResult
      ## Invalid number of arguments.

    type_e_ioerror* =                   0x80028CA2.HResult
      ## I/O Error.

    type_e_cantcreatetmpfile* =         0x80028CA3.HResult
      ## Error creating unique tmp file.

    type_e_cantloadlibrary* =           0x80029C4A.HResult
      ## Error loading type library/DLL.

    type_e_inconsistentpropfuncs* =     0x80029C83.HResult
      ## Inconsistent property functions.

    type_e_circulartype* =              0x80029C84.HResult
      ## Circular dependency between types/modules.

    # ******************
    # FACILITY_STORAGE
    # ******************
    stg_e_invalidfunction* =            0x80030001.HResult
      ## Unable to perform requested operation.

    stg_e_filenotfound* =               0x80030002.HResult
      ## %1 could not be found.

    stg_e_pathnotfound* =               0x80030003.HResult
      ## The path %1 could not be found.

    stg_e_toomanyopenfiles* =           0x80030004.HResult
      ## There are insufficient resources to open another file.

    stg_e_accessdenied* =               0x80030005.HResult
      ## Access Denied.

    stg_e_invalidhandle* =              0x80030006.HResult
      ## Attempted an operation on an invalid object.

    stg_e_insufficientmemory* =         0x80030008.HResult
      ## There is insufficient memory available to complete operation.

    stg_e_invalidpointer* =             0x80030009.HResult
      ## Invalid pointer error.

    stg_e_nomorefiles* =                0x80030012.HResult
      ## There are no more entries to return.

    stg_e_diskiswriteprotected* =       0x80030013.HResult
      ## Disk is write-protected.

    stg_e_seekerror* =                  0x80030019.HResult
      ## An error occurred during a seek operation.

    stg_e_writefault* =                 0x8003001D.HResult
      ## A disk error occurred during a write operation.

    stg_e_readfault* =                  0x8003001E.HResult
      ## A disk error occurred during a read operation.

    stg_e_shareviolation* =             0x80030020.HResult
      ## A share violation has occurred.

    stg_e_lockviolation* =              0x80030021.HResult
      ## A lock violation has occurred.

    stg_e_filealreadyexists* =          0x80030050.HResult
      ## %1 already exists.

    stg_e_invalidparameter* =           0x80030057.HResult
      ## Invalid parameter error.

    stg_e_mediumfull* =                 0x80030070.HResult
      ## There is insufficient disk space to complete operation.

    stg_e_propsetmismatched* =          0x800300F0.HResult
      ## Illegal write of non-simple property to simple property set.

    stg_e_abnormalapiexit* =            0x800300FA.HResult
      ## An API call exited abnormally.

    stg_e_invalidheader* =              0x800300FB.HResult
      ## The file %1 is not a valid compound file.

    stg_e_invalidname* =                0x800300FC.HResult
      ## The name %1 is not valid.

    stg_e_unknown* =                    0x800300FD.HResult
      ## An unexpected error occurred.

    stg_e_unimplementedfunction* =      0x800300FE.HResult
      ## That function is not implemented.

    stg_e_invalidflag* =                0x800300FF.HResult
      ## Invalid flag error.

    stg_e_inuse* =                      0x80030100.HResult
      ## Attempted to use an object that is busy.

    stg_e_notcurrent* =                 0x80030101.HResult
      ## The storage has been changed since the last commit.

    stg_e_reverted* =                   0x80030102.HResult
      ## Attempted to use an object that has ceased to exist.

    stg_e_cantsave* =                   0x80030103.HResult
      ## Can't save.

    stg_e_oldformat* =                  0x80030104.HResult
      ## The compound file %1 was produced with an incompatible version of storage.

    stg_e_olddll* =                     0x80030105.HResult
      ## The compound file %1 was produced with a newer version of storage.

    stg_e_sharerequired* =              0x80030106.HResult
      ## Share.exe or equivalent is required for operation.

    stg_e_notfilebasedstorage* =        0x80030107.HResult
      ## Illegal operation called on non-file based storage.

    stg_e_extantmarshallings* =         0x80030108.HResult
      ## Illegal operation called on object with extant marshallings.

    stg_e_docfilecorrupt* =             0x80030109.HResult
      ## The docfile has been corrupted.

    stg_e_badbaseaddress* =             0x80030110.HResult
      ## OLE32.DLL has been loaded at the wrong address.

    stg_e_docfiletoolarge* =            0x80030111.HResult
      ## The compound file is too large for the current implementation

    stg_e_notsimpleformat* =            0x80030112.HResult
      ## The compound file was not created with the STGM_SIMPLE flag

    stg_e_incomplete* =                 0x80030201.HResult
      ## The file download was aborted abnormally. The file is incomplete.

    stg_e_terminated* =                 0x80030202.HResult
      ## The file download has been terminated.

    stg_s_converted* =                  0x00030200.HResult
      ## The underlying file was converted to compound file format.

    stg_s_block* =                      0x00030201.HResult
      ## The storage operation should block until more data is available.

    stg_s_retrynow* =                   0x00030202.HResult
      ## The storage operation should retry immediately.

    stg_s_monitoring* =                 0x00030203.HResult
      ## The notified event sink will not influence the storage operation.

    stg_s_multipleopens* =              0x00030204.HResult
      ## Multiple opens prevent consolidated. (commit succeeded).

    stg_s_consolidationfailed* =        0x00030205.HResult
      ## Consolidation of the storage file failed. (commit succeeded).

    stg_s_cannotconsolidate* =          0x00030206.HResult
      ## Consolidation of the storage file is inappropriate. (commit succeeded).

    stg_s_power_cycle_required* =       0x00030207.HResult
      ## The device needs to be power cycled. (commit succeeded).

    stg_e_firmware_slot_invalid* =      0x80030208.HResult
      ## The specified firmware slot is invalid.

    stg_e_firmware_image_invalid* =     0x80030209.HResult
      ## The specified firmware image is invalid.

    stg_e_device_unresponsive* =        0x8003020A.HResult
      ## The storage device is unresponsive.

    #[++

  MessageId's 0x0305 - 0x031f (inclusive) are reserved for **STORAGE**
  copy protection errors.

  --  ]#
    stg_e_status_copy_protection_failure* = 0x80030305.HResult
      ## Generic Copy Protection Error.

    stg_e_css_authentication_failure* = 0x80030306.HResult
      ## Copy Protection Error - DVD CSS Authentication failed.

    stg_e_css_key_not_present* =        0x80030307.HResult
      ## Copy Protection Error - The given sector does not have a valid CSS key.

    stg_e_css_key_not_established* =    0x80030308.HResult
      ## Copy Protection Error - DVD session key not established.

    stg_e_css_scrambled_sector* =       0x80030309.HResult
      ## Copy Protection Error - The read failed because the sector is encrypted.

    stg_e_css_region_mismatch* =        0x8003030A.HResult
      ## Copy Protection Error - The current DVD's region does not correspond to the region setting of the drive.

    stg_e_resets_exhausted* =           0x8003030B.HResult
      ## Copy Protection Error - The drive's region setting may be permanent or the number of user resets has been exhausted.

    #[++

  MessageId's 0x0305 - 0x031f (inclusive) are reserved for **STORAGE**
  copy protection errors.

  --  ]#
    # ******************
    # FACILITY_RPC
    # ******************
    #
    # Codes 0x0-0x11 are propagated from 16 bit OLE.
    #
    rpc_e_call_rejected* =              0x80010001.HResult
      ## Call was rejected by callee.

    rpc_e_call_canceled* =              0x80010002.HResult
      ## Call was canceled by the message filter.

    rpc_e_cantpost_insendcall* =        0x80010003.HResult
      ## The caller is dispatching an intertask SendMessage call and cannot call out via PostMessage.

    rpc_e_cantcallout_inasynccall* =    0x80010004.HResult
      ## The caller is dispatching an asynchronous call and cannot make an outgoing call on behalf of this call.

    rpc_e_cantcallout_inexternalcall* = 0x80010005.HResult
      ## It is illegal to call out while inside message filter.

    rpc_e_connection_terminated* =      0x80010006.HResult
      ## The connection terminated or is in a bogus state and cannot be used any more. Other connections are still valid.

    rpc_e_server_died* =                0x80010007.HResult
      ## The callee (server [not server application]) is not available and disappeared; all connections are invalid. The call may have executed.

    rpc_e_client_died* =                0x80010008.HResult
      ## The caller (client) disappeared while the callee (server) was processing a call.

    rpc_e_invalid_datapacket* =         0x80010009.HResult
      ## The data packet with the marshalled parameter data is incorrect.

    rpc_e_canttransmit_call* =          0x8001000A.HResult
      ## The call was not transmitted properly; the message queue was full and was not emptied after yielding.

    rpc_e_client_cantmarshal_data* =    0x8001000B.HResult
      ## The client (caller) cannot marshall the parameter data - low memory, etc.

    rpc_e_client_cantunmarshal_data* =  0x8001000C.HResult
      ## The client (caller) cannot unmarshall the return data - low memory, etc.

    rpc_e_server_cantmarshal_data* =    0x8001000D.HResult
      ## The server (callee) cannot marshall the return data - low memory, etc.

    rpc_e_server_cantunmarshal_data* =  0x8001000E.HResult
      ## The server (callee) cannot unmarshall the parameter data - low memory, etc.

    rpc_e_invalid_data* =               0x8001000F.HResult
      ## Received data is invalid; could be server or client data.

    rpc_e_invalid_parameter* =          0x80010010.HResult
      ## A particular parameter is invalid and cannot be (un)marshalled.

    rpc_e_cantcallout_again* =          0x80010011.HResult
      ## There is no second outgoing call on same channel in DDE conversation.

    rpc_e_server_died_dne* =            0x80010012.HResult
      ## The callee (server [not server application]) is not available and disappeared; all connections are invalid. The call did not execute.

    rpc_e_sys_call_failed* =            0x80010100.HResult
      ## System call failed.

    rpc_e_out_of_resources* =           0x80010101.HResult
      ## Could not allocate some required resource (memory, events, ...)

    rpc_e_attempted_multithread* =      0x80010102.HResult
      ## Attempted to make calls on more than one thread in single threaded mode.

    rpc_e_not_registered* =             0x80010103.HResult
      ## The requested interface is not registered on the server object.

    rpc_e_fault* =                      0x80010104.HResult
      ## RPC could not call the server or could not return the results of calling the server.

    rpc_e_serverfault* =                0x80010105.HResult
      ## The server threw an exception.

    rpc_e_changed_mode* =               0x80010106.HResult
      ## Cannot change thread mode after it is set.

    rpc_e_invalidmethod* =              0x80010107.HResult
      ## The method called does not exist on the server.

    rpc_e_disconnected* =               0x80010108.HResult
      ## The object invoked has disconnected from its clients.

    rpc_e_retry* =                      0x80010109.HResult
      ## The object invoked chose not to process the call now. Try again later.

    rpc_e_servercall_retrylater* =      0x8001010A.HResult
      ## The message filter indicated that the application is busy.

    rpc_e_servercall_rejected* =        0x8001010B.HResult
      ## The message filter rejected the call.

    rpc_e_invalid_calldata* =           0x8001010C.HResult
      ## A call control interfaces was called with invalid data.

    rpc_e_cantcallout_ininputsynccall* = 0x8001010D.HResult
      ## An outgoing call cannot be made since the application is dispatching an input-synchronous call.

    rpc_e_wrong_thread* =               0x8001010E.HResult
      ## The application called an interface that was marshalled for a different thread.

    rpc_e_thread_not_init* =            0x8001010F.HResult
      ## CoInitialize has not been called on the current thread.

    rpc_e_version_mismatch* =           0x80010110.HResult
      ## The version of OLE on the client and server machines does not match.

    rpc_e_invalid_header* =             0x80010111.HResult
      ## OLE received a packet with an invalid header.

    rpc_e_invalid_extension* =          0x80010112.HResult
      ## OLE received a packet with an invalid extension.

    rpc_e_invalid_ipid* =               0x80010113.HResult
      ## The requested object or interface does not exist.

    rpc_e_invalid_object* =             0x80010114.HResult
      ## The requested object does not exist.

    rpc_s_callpending* =                0x80010115.HResult
      ## OLE has sent a request and is waiting for a reply.

    rpc_s_waitontimer* =                0x80010116.HResult
      ## OLE is waiting before retrying a request.

    rpc_e_call_complete* =              0x80010117.HResult
      ## Call context cannot be accessed after call completed.

    rpc_e_unsecure_call* =              0x80010118.HResult
      ## Impersonate on unsecure calls is not supported.

    rpc_e_too_late* =                   0x80010119.HResult
      ## Security must be initialized before any interfaces are marshalled or unmarshalled. It cannot be changed once initialized.

    rpc_e_no_good_security_packages* =  0x8001011A.HResult
      ## No security packages are installed on this machine or the user is not logged on or there are no compatible security packages between the client and server.

    rpc_e_access_denied* =              0x8001011B.HResult
      ## Access is denied.

    rpc_e_remote_disabled* =            0x8001011C.HResult
      ## Remote calls are not allowed for this process.

    rpc_e_invalid_objref* =             0x8001011D.HResult
      ## The marshaled interface data packet (OBJREF) has an invalid or unknown format.

    rpc_e_no_context* =                 0x8001011E.HResult
      ## No context is associated with this call. This happens for some custom marshalled calls and on the client side of the call.

    rpc_e_timeout* =                    0x8001011F.HResult
      ## This operation returned because the timeout period expired.

    rpc_e_no_sync* =                    0x80010120.HResult
      ## There are no synchronize objects to wait on.

    rpc_e_fullsic_required* =           0x80010121.HResult
      ## Full subject issuer chain SSL principal name expected from the server.

    rpc_e_invalid_std_name* =           0x80010122.HResult
      ## Principal name is not a valid MSSTD name.

    co_e_failedtoimpersonate* =         0x80010123.HResult
      ## Unable to impersonate DCOM client

    co_e_failedtogetsecctx* =           0x80010124.HResult
      ## Unable to obtain server's security context

    co_e_failedtoopenthreadtoken* =     0x80010125.HResult
      ## Unable to open the access token of the current thread

    co_e_failedtogettokeninfo* =        0x80010126.HResult
      ## Unable to obtain user info from an access token

    co_e_trusteedoesntmatchclient* =    0x80010127.HResult
      ## The client who called IAccessControl::IsAccessPermitted was not the trustee provided to the method

    co_e_failedtoqueryclientblanket* =  0x80010128.HResult
      ## Unable to obtain the client's security blanket

    co_e_failedtosetdacl* =             0x80010129.HResult
      ## Unable to set a discretionary ACL into a security descriptor

    co_e_accesscheckfailed* =           0x8001012A.HResult
      ## The system function, AccessCheck, returned false

    co_e_netaccessapifailed* =          0x8001012B.HResult
      ## Either NetAccessDel or NetAccessAdd returned an error code.

    co_e_wrongtrusteenamesyntax* =      0x8001012C.HResult
      ## One of the trustee strings provided by the user did not conform to the <Domain>\<Name> syntax and it was not the "*" string

    co_e_invalidsid* =                  0x8001012D.HResult
      ## One of the security identifiers provided by the user was invalid

    co_e_conversionfailed* =            0x8001012E.HResult
      ## Unable to convert a wide character trustee string to a multibyte trustee string

    co_e_nomatchingsidfound* =          0x8001012F.HResult
      ## Unable to find a security identifier that corresponds to a trustee string provided by the user

    co_e_lookupaccsidfailed* =          0x80010130.HResult
      ## The system function, LookupAccountSID, failed

    co_e_nomatchingnamefound* =         0x80010131.HResult
      ## Unable to find a trustee name that corresponds to a security identifier provided by the user

    co_e_lookupaccnamefailed* =         0x80010132.HResult
      ## The system function, LookupAccountName, failed

    co_e_setserlhndlfailed* =           0x80010133.HResult
      ## Unable to set or reset a serialization handle

    co_e_failedtogetwindir* =           0x80010134.HResult
      ## Unable to obtain the Windows directory

    co_e_pathtoolong* =                 0x80010135.HResult
      ## Path too long

    co_e_failedtogenuuid* =             0x80010136.HResult
      ## Unable to generate a uuid.

    co_e_failedtocreatefile* =          0x80010137.HResult
      ## Unable to create file

    co_e_failedtoclosehandle* =         0x80010138.HResult
      ## Unable to close a serialization handle or a file handle.

    co_e_exceedsysacllimit* =           0x80010139.HResult
      ## The number of ACEs in an ACL exceeds the system limit.

    co_e_acesinwrongorder* =            0x8001013A.HResult
      ## Not all the DENY_ACCESS ACEs are arranged in front of the GRANT_ACCESS ACEs in the stream.

    co_e_incompatiblestreamversion* =   0x8001013B.HResult
      ## The version of ACL format in the stream is not supported by this implementation of IAccessControl

    co_e_failedtoopenprocesstoken* =    0x8001013C.HResult
      ## Unable to open the access token of the server process

    co_e_decodefailed* =                0x8001013D.HResult
      ## Unable to decode the ACL in the stream provided by the user

    co_e_acnotinitialized* =            0x8001013F.HResult
      ## The COM IAccessControl object is not initialized

    co_e_cancel_disabled* =             0x80010140.HResult
      ## Call Cancellation is disabled

    rpc_e_unexpected* =                 0x8001FFFF.HResult
      ## An internal error occurred.



    #####################################
    #                                  ##
    # Additional Security Status Codes ##
    #                                  ##
    # Facility=Security                ##
    #                                  ##
    #####################################


    error_auditing_disabled* =          0xC0090001.HResult
      ## The specified event is currently not being audited.

    error_all_sids_filtered* =          0xC0090002.HResult
      ## The SID filtering operation removed all SIDs.

    error_bizrules_not_enabled* =       0xC0090003.HResult
      ## Business rule scripts are disabled for the calling application.



    ############################################
    #                                         ##
    # end of Additional Security Status Codes ##
    #                                         ##
    ############################################



    #################
    ##
    ##  FACILITY_SSPI
    ##
    #################

    nte_bad_uid* =                      0x80090001.HResult
      ## Bad UID.

    nte_bad_hash* =                     0x80090002.HResult
      ## Bad Hash.

    nte_bad_key* =                      0x80090003.HResult
      ## Bad Key.

    nte_bad_len* =                      0x80090004.HResult
      ## Bad Length.

    nte_bad_data* =                     0x80090005.HResult
      ## Bad Data.

    nte_bad_signature* =                0x80090006.HResult
      ## Invalid Signature.

    nte_bad_ver* =                      0x80090007.HResult
      ## Bad Version of provider.

    nte_bad_algid* =                    0x80090008.HResult
      ## Invalid algorithm specified.

    nte_bad_flags* =                    0x80090009.HResult
      ## Invalid flags specified.

    nte_bad_type* =                     0x8009000A.HResult
      ## Invalid type specified.

    nte_bad_key_state* =                0x8009000B.HResult
      ## Key not valid for use in specified state.

    nte_bad_hash_state* =               0x8009000C.HResult
      ## Hash not valid for use in specified state.

    nte_no_key* =                       0x8009000D.HResult
      ## Key does not exist.

    nte_no_memory* =                    0x8009000E.HResult
      ## Insufficient memory available for the operation.

    nte_exists* =                       0x8009000F.HResult
      ## Object already exists.

    nte_perm* =                         0x80090010.HResult
      ## Access denied.

    nte_not_found* =                    0x80090011.HResult
      ## Object was not found.

    nte_double_encrypt* =               0x80090012.HResult
      ## Data already encrypted.

    nte_bad_provider* =                 0x80090013.HResult
      ## Invalid provider specified.

    nte_bad_prov_type* =                0x80090014.HResult
      ## Invalid provider type specified.

    nte_bad_public_key* =               0x80090015.HResult
      ## Provider's public key is invalid.

    nte_bad_keyset* =                   0x80090016.HResult
      ## Keyset does not exist

    nte_prov_type_not_def* =            0x80090017.HResult
      ## Provider type not defined.

    nte_prov_type_entry_bad* =          0x80090018.HResult
      ## Provider type as registered is invalid.

    nte_keyset_not_def* =               0x80090019.HResult
      ## The keyset is not defined.

    nte_keyset_entry_bad* =             0x8009001A.HResult
      ## Keyset as registered is invalid.

    nte_prov_type_no_match* =           0x8009001B.HResult
      ## Provider type does not match registered value.

    nte_signature_file_bad* =           0x8009001C.HResult
      ## The digital signature file is corrupt.

    nte_provider_dll_fail* =            0x8009001D.HResult
      ## Provider DLL failed to initialize correctly.

    nte_prov_dll_not_found* =           0x8009001E.HResult
      ## Provider DLL could not be found.

    nte_bad_keyset_param* =             0x8009001F.HResult
      ## The Keyset parameter is invalid.

    nte_fail* =                         0x80090020.HResult
      ## An internal error occurred.

    nte_sys_err* =                      0x80090021.HResult
      ## A base error occurred.

    nte_silent_context* =               0x80090022.HResult
      ## Provider could not perform the action since the context was acquired as silent.

    nte_token_keyset_storage_full* =    0x80090023.HResult
      ## The security token does not have storage space available for an additional container.

    nte_temporary_profile* =            0x80090024.HResult
      ## The profile for the user is a temporary profile.

    nte_fixedparameter* =               0x80090025.HResult
      ## The key parameters could not be set because the CSP uses fixed parameters.

    nte_invalid_handle* =               0x80090026.HResult
      ## The supplied handle is invalid.

    nte_invalid_parameter* =            0x80090027.HResult
      ## The parameter is incorrect.

    nte_buffer_too_small* =             0x80090028.HResult
      ## The buffer supplied to a function was too small.

    nte_not_supported* =                0x80090029.HResult
      ## The requested operation is not supported.

    nte_no_more_items* =                0x8009002A.HResult
      ## No more data is available.

    nte_buffers_overlap* =              0x8009002B.HResult
      ## The supplied buffers overlap incorrectly.

    nte_decryption_failure* =           0x8009002C.HResult
      ## The specified data could not be decrypted.

    nte_internal_error* =               0x8009002D.HResult
      ## An internal consistency check failed.

    nte_ui_required* =                  0x8009002E.HResult
      ## This operation requires input from the user.

    nte_hmac_not_supported* =           0x8009002F.HResult
      ## The cryptographic provider does not support HMAC.

    nte_device_not_ready* =             0x80090030.HResult
      ## The device that is required by this cryptographic provider is not ready for use.

    nte_authentication_ignored* =       0x80090031.HResult
      ## The dictionary attack mitigation is triggered and the provided authorization was ignored by the provider.

    nte_validation_failed* =            0x80090032.HResult
      ## The validation of the provided data failed the integrity or signature validation.

    nte_incorrect_password* =           0x80090033.HResult
      ## Incorrect password.

    nte_encryption_failure* =           0x80090034.HResult
      ## Encryption failed.

    nte_device_not_found* =             0x80090035.HResult
      ## The device that is required by this cryptographic provider is not found on this platform.

    nte_user_cancelled* =               0x80090036.HResult
      ## The action was cancelled by the user.

    nte_password_change_required* =     0x80090037.HResult
      ## The password is no longer valid and must be changed.

    nte_not_active_console* =           0x80090038.HResult
      ## The operation cannot be completed from Terminal Server client sessions.

    sec_e_insufficient_memory* =        0x80090300.HResult
      ## Not enough memory is available to complete this request

    sec_e_invalid_handle* =             0x80090301.HResult
      ## The handle specified is invalid

    sec_e_unsupported_function* =       0x80090302.HResult
      ## The function requested is not supported

    sec_e_target_unknown* =             0x80090303.HResult
      ## The specified target is unknown or unreachable

    sec_e_internal_error* =             0x80090304.HResult
      ## The Local Security Authority cannot be contacted

    sec_e_secpkg_not_found* =           0x80090305.HResult
      ## The requested security package does not exist

    sec_e_not_owner* =                  0x80090306.HResult
      ## The caller is not the owner of the desired credentials

    sec_e_cannot_install* =             0x80090307.HResult
      ## The security package failed to initialize, and cannot be installed

    sec_e_invalid_token* =              0x80090308.HResult
      ## The token supplied to the function is invalid

    sec_e_cannot_pack* =                0x80090309.HResult
      ## The security package is not able to marshall the logon buffer, so the logon attempt has failed

    sec_e_qop_not_supported* =          0x8009030A.HResult
      ## The per-message Quality of Protection is not supported by the security package

    sec_e_no_impersonation* =           0x8009030B.HResult
      ## The security context does not allow impersonation of the client

    sec_e_logon_denied* =               0x8009030C.HResult
      ## The logon attempt failed

    sec_e_unknown_credentials* =        0x8009030D.HResult
      ## The credentials supplied to the package were not recognized

    sec_e_no_credentials* =             0x8009030E.HResult
      ## No credentials are available in the security package

    sec_e_message_altered* =            0x8009030F.HResult
      ## The message or signature supplied for verification has been altered

    sec_e_out_of_sequence* =            0x80090310.HResult
      ## The message supplied for verification is out of sequence

    sec_e_no_authenticating_authority* = 0x80090311.HResult
      ## No authority could be contacted for authentication.

    sec_i_continue_needed* =            0x00090312.HResult
      ## The function completed successfully, but must be called again to complete the context

    sec_i_complete_needed* =            0x00090313.HResult
      ## The function completed successfully, but CompleteToken must be called

    sec_i_complete_and_continue* =      0x00090314.HResult
      ## The function completed successfully, but both CompleteToken and this function must be called to complete the context

    sec_i_local_logon* =                0x00090315.HResult
      ## The logon was completed, but no network authority was available. The logon was made using locally known information

    sec_e_bad_pkgid* =                  0x80090316.HResult
      ## The requested security package does not exist

    sec_e_context_expired* =            0x80090317.HResult
      ## The context has expired and can no longer be used.

    sec_i_context_expired* =            0x00090317.HResult
      ## The context has expired and can no longer be used.

    sec_e_incomplete_message* =         0x80090318.HResult
      ## The supplied message is incomplete. The signature was not verified.

    sec_e_incomplete_credentials* =     0x80090320.HResult
      ## The credentials supplied were not complete, and could not be verified. The context could not be initialized.

    sec_e_buffer_too_small* =           0x80090321.HResult
      ## The buffers supplied to a function was too small.

    sec_i_incomplete_credentials* =     0x00090320.HResult
      ## The credentials supplied were not complete, and could not be verified. Additional information can be returned from the context.

    sec_i_renegotiate* =                0x00090321.HResult
      ## The context data must be renegotiated with the peer.

    sec_e_wrong_principal* =            0x80090322.HResult
      ## The target principal name is incorrect.

    sec_i_no_lsa_context* =             0x00090323.HResult
      ## There is no LSA mode context associated with this context.

    sec_e_time_skew* =                  0x80090324.HResult
      ## The clocks on the client and server machines are skewed.

    sec_e_untrusted_root* =             0x80090325.HResult
      ## The certificate chain was issued by an authority that is not trusted.

    sec_e_illegal_message* =            0x80090326.HResult
      ## The message received was unexpected or badly formatted.

    sec_e_cert_unknown* =               0x80090327.HResult
      ## An unknown error occurred while processing the certificate.

    sec_e_cert_expired* =               0x80090328.HResult
      ## The received certificate has expired.

    sec_e_encrypt_failure* =            0x80090329.HResult
      ## The specified data could not be encrypted.

    #
    # MessageId: SEC_E_DECRYPT_FAILURE
    #
    # MessageText:
    #
    # The specified data could not be decrypted.
    # 
    #
    sec_e_decrypt_failure* =            0x80090330.HResult

    sec_e_algorithm_mismatch* =         0x80090331.HResult
      ## The client and server cannot communicate, because they do not possess a common algorithm.

    sec_e_security_qos_failed* =        0x80090332.HResult
      ## The security context could not be established due to a failure in the requested quality of service (e.g. mutual authentication or delegation).

    sec_e_unfinished_context_deleted* = 0x80090333.HResult
      ## A security context was deleted before the context was completed. This is considered a logon failure.

    sec_e_no_tgt_reply* =               0x80090334.HResult
      ## The client is trying to negotiate a context and the server requires user-to-user but didn't send a TGT reply.

    sec_e_no_ip_addresses* =            0x80090335.HResult
      ## Unable to accomplish the requested task because the local machine does not have any IP addresses.

    sec_e_wrong_credential_handle* =    0x80090336.HResult
      ## The supplied credential handle does not match the credential associated with the security context.

    sec_e_crypto_system_invalid* =      0x80090337.HResult
      ## The crypto system or checksum function is invalid because a required function is unavailable.

    sec_e_max_referrals_exceeded* =     0x80090338.HResult
      ## The number of maximum ticket referrals has been exceeded.

    sec_e_must_be_kdc* =                0x80090339.HResult
      ## The local machine must be a Kerberos KDC (domain controller) and it is not.

    sec_e_strong_crypto_not_supported* = 0x8009033A.HResult
      ## The other end of the security negotiation is requires strong crypto but it is not supported on the local machine.

    sec_e_too_many_principals* =        0x8009033B.HResult
      ## The KDC reply contained more than one principal name.

    sec_e_no_pa_data* =                 0x8009033C.HResult
      ## Expected to find PA data for a hint of what etype to use, but it was not found.

    sec_e_pkinit_name_mismatch* =       0x8009033D.HResult
      ## The client certificate does not contain a valid UPN, or does not match the client name in the logon request. Please contact your administrator.

    sec_e_smartcard_logon_required* =   0x8009033E.HResult
      ## Smartcard logon is required and was not used.

    sec_e_shutdown_in_progress* =       0x8009033F.HResult
      ## A system shutdown is in progress.

    sec_e_kdc_invalid_request* =        0x80090340.HResult
      ## An invalid request was sent to the KDC.

    sec_e_kdc_unable_to_refer* =        0x80090341.HResult
      ## The KDC was unable to generate a referral for the service requested.

    sec_e_kdc_unknown_etype* =          0x80090342.HResult
      ## The encryption type requested is not supported by the KDC.

    sec_e_unsupported_preauth* =        0x80090343.HResult
      ## An unsupported preauthentication mechanism was presented to the Kerberos package.

    sec_e_delegation_required* =        0x80090345.HResult
      ## The requested operation cannot be completed. The computer must be trusted for delegation and the current user account must be configured to allow delegation.

    sec_e_bad_bindings* =               0x80090346.HResult
      ## Client's supplied SSPI channel bindings were incorrect.

    sec_e_multiple_accounts* =          0x80090347.HResult
      ## The received certificate was mapped to multiple accounts.

    sec_e_no_kerb_key* =                0x80090348.HResult
      ## SEC_E_NO_KERB_KEY

    sec_e_cert_wrong_usage* =           0x80090349.HResult
      ## The certificate is not valid for the requested usage.

    sec_e_downgrade_detected* =         0x80090350.HResult
      ## The system cannot contact a domain controller to service the authentication request. Please try again later.

    sec_e_smartcard_cert_revoked* =     0x80090351.HResult
      ## The smartcard certificate used for authentication has been revoked. Please contact your system administrator. There may be additional information in the event log.

    sec_e_issuing_ca_untrusted* =       0x80090352.HResult
      ## An untrusted certificate authority was detected while processing the smartcard certificate used for authentication. Please contact your system administrator.

    sec_e_revocation_offline_c* =       0x80090353.HResult
      ## The revocation status of the smartcard certificate used for authentication could not be determined. Please contact your system administrator.

    sec_e_pkinit_client_failure* =      0x80090354.HResult
      ## The smartcard certificate used for authentication was not trusted. Please contact your system administrator.

    sec_e_smartcard_cert_expired* =     0x80090355.HResult
      ## The smartcard certificate used for authentication has expired. Please contact your system administrator.

    sec_e_no_s4u_prot_support* =        0x80090356.HResult
      ## The Kerberos subsystem encountered an error. A service for user protocol request was made against a domain controller which does not support service for user.

    sec_e_crossrealm_delegation_failure* = 0x80090357.HResult
      ## An attempt was made by this server to make a Kerberos constrained delegation request for a target outside of the server's realm. This is not supported, and indicates a misconfiguration on this server's allowed to delegate to list. Please contact your administrator.

    sec_e_revocation_offline_kdc* =     0x80090358.HResult
      ## The revocation status of the domain controller certificate used for smartcard authentication could not be determined. There is additional information in the system event log. Please contact your system administrator.

    sec_e_issuing_ca_untrusted_kdc* =   0x80090359.HResult
      ## An untrusted certificate authority was detected while processing the domain controller certificate used for authentication. There is additional information in the system event log. Please contact your system administrator.

    sec_e_kdc_cert_expired* =           0x8009035A.HResult
      ## The domain controller certificate used for smartcard logon has expired. Please contact your system administrator with the contents of your system event log.

    sec_e_kdc_cert_revoked* =           0x8009035B.HResult
      ## The domain controller certificate used for smartcard logon has been revoked. Please contact your system administrator with the contents of your system event log.

    sec_i_signature_needed* =           0x0009035C.HResult
      ## A signature operation must be performed before the user can authenticate.

    sec_e_invalid_parameter* =          0x8009035D.HResult
      ## One or more of the parameters passed to the function was invalid.

    sec_e_delegation_policy* =          0x8009035E.HResult
      ## Client policy does not allow credential delegation to target server.

    sec_e_policy_nltm_only* =           0x8009035F.HResult
      ## Client policy does not allow credential delegation to target server with NLTM only authentication.

    sec_i_no_renegotiation* =           0x00090360.HResult
      ## The recipient rejected the renegotiation request.

    sec_e_no_context* =                 0x80090361.HResult
      ## The required security context does not exist.

    sec_e_pku2u_cert_failure* =         0x80090362.HResult
      ## The PKU2U protocol encountered an error while attempting to utilize the associated certificates.

    sec_e_mutual_auth_failed* =         0x80090363.HResult
      ## The identity of the server computer could not be verified.

    sec_i_message_fragment* =           0x00090364.HResult
      ## The returned buffer is only a fragment of the message.  More fragments need to be returned.

    sec_e_only_https_allowed* =         0x80090365.HResult
      ## Only https scheme is allowed.

    sec_i_continue_needed_message_ok* = 0x00090366.HResult
      ## The function completed successfully, but must be called again to complete the context.  Early start can be used.

    sec_e_application_protocol_mismatch* = 0x80090367.HResult
      ## No common application protocol exists between the client and the server. Application protocol negotiation failed.

    sec_i_async_call_pending* =         0x00090368.HResult
      ## An asynchronous SSPI routine has been called and the work is pending completion.

    sec_e_invalid_upn_name* =           0x80090369.HResult
      ## You can't sign in with a user ID in this format. Try using your email address instead.

    #
    # Provided for backwards compatibility
    #

    sec_e_no_spm* = sec_e_internal_error
    sec_e_not_supported* = sec_e_unsupported_function

    crypt_e_msg_error* =                0x80091001.HResult
      ## An error occurred while performing an operation on a cryptographic message.

    crypt_e_unknown_algo* =             0x80091002.HResult
      ## Unknown cryptographic algorithm.

    crypt_e_oid_format* =               0x80091003.HResult
      ## The object identifier is poorly formatted.

    crypt_e_invalid_msg_type* =         0x80091004.HResult
      ## Invalid cryptographic message type.

    crypt_e_unexpected_encoding* =      0x80091005.HResult
      ## Unexpected cryptographic message encoding.

    crypt_e_auth_attr_missing* =        0x80091006.HResult
      ## The cryptographic message does not contain an expected authenticated attribute.

    crypt_e_hash_value* =               0x80091007.HResult
      ## The hash value is not correct.

    crypt_e_invalid_index* =            0x80091008.HResult
      ## The index value is not valid.

    crypt_e_already_decrypted* =        0x80091009.HResult
      ## The content of the cryptographic message has already been decrypted.

    crypt_e_not_decrypted* =            0x8009100A.HResult
      ## The content of the cryptographic message has not been decrypted yet.

    crypt_e_recipient_not_found* =      0x8009100B.HResult
      ## The enveloped-data message does not contain the specified recipient.

    crypt_e_control_type* =             0x8009100C.HResult
      ## Invalid control type.

    crypt_e_issuer_serialnumber* =      0x8009100D.HResult
      ## Invalid issuer and/or serial number.

    crypt_e_signer_not_found* =         0x8009100E.HResult
      ## Cannot find the original signer.

    crypt_e_attributes_missing* =       0x8009100F.HResult
      ## The cryptographic message does not contain all of the requested attributes.

    crypt_e_stream_msg_not_ready* =     0x80091010.HResult
      ## The streamed cryptographic message is not ready to return data.

    crypt_e_stream_insufficient_data* = 0x80091011.HResult
      ## The streamed cryptographic message requires more data to complete the decode operation.

    crypt_i_new_protection_required* =  0x00091012.HResult
      ## The protected data needs to be re-protected.

    crypt_e_bad_len* =                  0x80092001.HResult
      ## The length specified for the output data was insufficient.

    crypt_e_bad_encode* =               0x80092002.HResult
      ## An error occurred during encode or decode operation.

    crypt_e_file_error* =               0x80092003.HResult
      ## An error occurred while reading or writing to a file.

    crypt_e_not_found* =                0x80092004.HResult
      ## Cannot find object or property.

    crypt_e_exists* =                   0x80092005.HResult
      ## The object or property already exists.

    crypt_e_no_provider* =              0x80092006.HResult
      ## No provider was specified for the store or object.

    crypt_e_self_signed* =              0x80092007.HResult
      ## The specified certificate is self signed.

    crypt_e_deleted_prev* =             0x80092008.HResult
      ## The previous certificate or CRL context was deleted.

    crypt_e_no_match* =                 0x80092009.HResult
      ## Cannot find the requested object.

    crypt_e_unexpected_msg_type* =      0x8009200A.HResult
      ## The certificate does not have a property that references a private key.

    crypt_e_no_key_property* =          0x8009200B.HResult
      ## Cannot find the certificate and private key for decryption.

    crypt_e_no_decrypt_cert* =          0x8009200C.HResult
      ## Cannot find the certificate and private key to use for decryption.

    crypt_e_bad_msg* =                  0x8009200D.HResult
      ## Not a cryptographic message or the cryptographic message is not formatted correctly.

    crypt_e_no_signer* =                0x8009200E.HResult
      ## The signed cryptographic message does not have a signer for the specified signer index.

    crypt_e_pending_close* =            0x8009200F.HResult
      ## Final closure is pending until additional frees or closes.

    crypt_e_revoked* =                  0x80092010.HResult
      ## The certificate is revoked.

    crypt_e_no_revocation_dll* =        0x80092011.HResult
      ## No Dll or exported function was found to verify revocation.

    crypt_e_no_revocation_check* =      0x80092012.HResult
      ## The revocation function was unable to check revocation for the certificate.

    crypt_e_revocation_offline* =       0x80092013.HResult
      ## The revocation function was unable to check revocation because the revocation server was offline.

    crypt_e_not_in_revocation_database* = 0x80092014.HResult
      ## The certificate is not in the revocation server's database.

    crypt_e_invalid_numeric_string* =   0x80092020.HResult
      ## The string contains a non-numeric character.

    crypt_e_invalid_printable_string* = 0x80092021.HResult
      ## The string contains a non-printable character.

    crypt_e_invalid_ia5_string* =       0x80092022.HResult
      ## The string contains a character not in the 7 bit ASCII character set.

    crypt_e_invalid_x500_string* =      0x80092023.HResult
      ## The string contains an invalid X500 name attribute key, oid, value or delimiter.

    crypt_e_not_char_string* =          0x80092024.HResult
      ## The dwValueType for the CERT_NAME_VALUE is not one of the character strings. Most likely it is either a CERT_RDN_ENCODED_BLOB or CERT_RDN_OCTET_STRING.

    crypt_e_fileresized* =              0x80092025.HResult
      ## The Put operation cannot continue. The file needs to be resized. However, there is already a signature present. A complete signing operation must be done.

    crypt_e_security_settings* =        0x80092026.HResult
      ## The cryptographic operation failed due to a local security option setting.

    crypt_e_no_verify_usage_dll* =      0x80092027.HResult
      ## No DLL or exported function was found to verify subject usage.

    crypt_e_no_verify_usage_check* =    0x80092028.HResult
      ## The called function was unable to do a usage check on the subject.

    crypt_e_verify_usage_offline* =     0x80092029.HResult
      ## Since the server was offline, the called function was unable to complete the usage check.

    crypt_e_not_in_ctl* =               0x8009202A.HResult
      ## The subject was not found in a Certificate Trust List (CTL).

    crypt_e_no_trusted_signer* =        0x8009202B.HResult
      ## None of the signers of the cryptographic message or certificate trust list is trusted.

    crypt_e_missing_pubkey_para* =      0x8009202C.HResult
      ## The public key's algorithm parameters are missing.

    crypt_e_object_locator_object_not_found* = 0x8009202D.HResult
      ## An object could not be located using the object locator infrastructure with the given name.

    crypt_e_oss_error* =                0x80093000.HResult
      ## OSS Certificate encode/decode error code base
      ## See asn1code.h for a definition of the OSS runtime errors. The OSS error values are offset by CRYPT_E_OSS_ERROR.

    oss_more_buf* =                     0x80093001.HResult
      ## OSS ASN.1 Error: Output Buffer is too small.

    oss_negative_uinteger* =            0x80093002.HResult
      ## OSS ASN.1 Error: Signed integer is encoded as a unsigned integer.

    oss_pdu_range* =                    0x80093003.HResult
      ## OSS ASN.1 Error: Unknown ASN.1 data type.

    oss_more_input* =                   0x80093004.HResult
      ## OSS ASN.1 Error: Output buffer is too small, the decoded data has been truncated.

    oss_data_error* =                   0x80093005.HResult
      ## OSS ASN.1 Error: Invalid data.

    oss_bad_arg* =                      0x80093006.HResult
      ## OSS ASN.1 Error: Invalid argument.

    oss_bad_version* =                  0x80093007.HResult
      ## OSS ASN.1 Error: Encode/Decode version mismatch.

    oss_out_memory* =                   0x80093008.HResult
      ## OSS ASN.1 Error: Out of memory.

    oss_pdu_mismatch* =                 0x80093009.HResult
      ## OSS ASN.1 Error: Encode/Decode Error.

    oss_limited* =                      0x8009300A.HResult
      ## OSS ASN.1 Error: Internal Error.

    oss_bad_ptr* =                      0x8009300B.HResult
      ## OSS ASN.1 Error: Invalid data.

    oss_bad_time* =                     0x8009300C.HResult
      ## OSS ASN.1 Error: Invalid data.

    oss_indefinite_not_supported* =     0x8009300D.HResult
      ## OSS ASN.1 Error: Unsupported BER indefinite-length encoding.

    oss_mem_error* =                    0x8009300E.HResult
      ## OSS ASN.1 Error: Access violation.

    oss_bad_table* =                    0x8009300F.HResult
      ## OSS ASN.1 Error: Invalid data.

    oss_too_long* =                     0x80093010.HResult
      ## OSS ASN.1 Error: Invalid data.

    oss_constraint_violated* =          0x80093011.HResult
      ## OSS ASN.1 Error: Invalid data.

    oss_fatal_error* =                  0x80093012.HResult
      ## OSS ASN.1 Error: Internal Error.

    oss_access_serialization_error* =   0x80093013.HResult
      ## OSS ASN.1 Error: Multi-threading conflict.

    oss_null_tbl* =                     0x80093014.HResult
      ## OSS ASN.1 Error: Invalid data.

    oss_null_fcn* =                     0x80093015.HResult
      ## OSS ASN.1 Error: Invalid data.

    oss_bad_encrules* =                 0x80093016.HResult
      ## OSS ASN.1 Error: Invalid data.

    oss_unavail_encrules* =             0x80093017.HResult
      ## OSS ASN.1 Error: Encode/Decode function not implemented.

    oss_cant_open_trace_window* =       0x80093018.HResult
      ## OSS ASN.1 Error: Trace file error.

    oss_unimplemented* =                0x80093019.HResult
      ## OSS ASN.1 Error: Function not implemented.

    oss_oid_dll_not_linked* =           0x8009301A.HResult
      ## OSS ASN.1 Error: Program link error.

    oss_cant_open_trace_file* =         0x8009301B.HResult
      ## OSS ASN.1 Error: Trace file error.

    oss_trace_file_already_open* =      0x8009301C.HResult
      ## OSS ASN.1 Error: Trace file error.

    oss_table_mismatch* =               0x8009301D.HResult
      ## OSS ASN.1 Error: Invalid data.

    oss_type_not_supported* =           0x8009301E.HResult
      ## OSS ASN.1 Error: Invalid data.

    oss_real_dll_not_linked* =          0x8009301F.HResult
      ## OSS ASN.1 Error: Program link error.

    oss_real_code_not_linked* =         0x80093020.HResult
      ## OSS ASN.1 Error: Program link error.

    oss_out_of_range* =                 0x80093021.HResult
      ## OSS ASN.1 Error: Program link error.

    oss_copier_dll_not_linked* =        0x80093022.HResult
      ## OSS ASN.1 Error: Program link error.

    oss_constraint_dll_not_linked* =    0x80093023.HResult
      ## OSS ASN.1 Error: Program link error.

    oss_comparator_dll_not_linked* =    0x80093024.HResult
      ## OSS ASN.1 Error: Program link error.

    oss_comparator_code_not_linked* =   0x80093025.HResult
      ## OSS ASN.1 Error: Program link error.

    oss_mem_mgr_dll_not_linked* =       0x80093026.HResult
      ## OSS ASN.1 Error: Program link error.

    oss_pdv_dll_not_linked* =           0x80093027.HResult
      ## OSS ASN.1 Error: Program link error.

    oss_pdv_code_not_linked* =          0x80093028.HResult
      ## OSS ASN.1 Error: Program link error.

    oss_api_dll_not_linked* =           0x80093029.HResult
      ## OSS ASN.1 Error: Program link error.

    oss_berder_dll_not_linked* =        0x8009302A.HResult
      ## OSS ASN.1 Error: Program link error.

    oss_per_dll_not_linked* =           0x8009302B.HResult
      ## OSS ASN.1 Error: Program link error.

    oss_open_type_error* =              0x8009302C.HResult
      ## OSS ASN.1 Error: Program link error.

    oss_mutex_not_created* =            0x8009302D.HResult
      ## OSS ASN.1 Error: System resource error.

    oss_cant_close_trace_file* =        0x8009302E.HResult
      ## OSS ASN.1 Error: Trace file error.

    crypt_e_asn1_error* =               0x80093100.HResult
      ## ASN1 Certificate encode/decode error code base. The ASN1 error values are offset by CRYPT_E_ASN1_ERROR.

    crypt_e_asn1_internal* =            0x80093101.HResult
      ## ASN1 internal encode or decode error.

    crypt_e_asn1_eod* =                 0x80093102.HResult
      ## ASN1 unexpected end of data.

    crypt_e_asn1_corrupt* =             0x80093103.HResult
      ## ASN1 corrupted data.

    crypt_e_asn1_large* =               0x80093104.HResult
      ## ASN1 value too large.

    crypt_e_asn1_constraint* =          0x80093105.HResult
      ## ASN1 constraint violated.

    crypt_e_asn1_memory* =              0x80093106.HResult
      ## ASN1 out of memory.

    crypt_e_asn1_overflow* =            0x80093107.HResult
      ## ASN1 buffer overflow.

    crypt_e_asn1_badpdu* =              0x80093108.HResult
      ## ASN1 function not supported for this PDU.

    crypt_e_asn1_badargs* =             0x80093109.HResult
      ## ASN1 bad arguments to function call.

    crypt_e_asn1_badreal* =             0x8009310A.HResult
      ## ASN1 bad real value.

    crypt_e_asn1_badtag* =              0x8009310B.HResult
      ## ASN1 bad tag value met.

    crypt_e_asn1_choice* =              0x8009310C.HResult
      ## ASN1 bad choice value.

    crypt_e_asn1_rule* =                0x8009310D.HResult
      ## ASN1 bad encoding rule.

    crypt_e_asn1_utf8* =                0x8009310E.HResult
      ## ASN1 bad unicode (UTF8).

    crypt_e_asn1_pdu_type* =            0x80093133.HResult
      ## ASN1 bad PDU type.

    crypt_e_asn1_nyi* =                 0x80093134.HResult
      ## ASN1 not yet implemented.

    crypt_e_asn1_extended* =            0x80093201.HResult
      ## ASN1 skipped unknown extension(s).

    crypt_e_asn1_noeod* =               0x80093202.HResult
      ## ASN1 end of data expected

    certsrv_e_bad_requestsubject* =     0x80094001.HResult
      ## The request subject name is invalid or too long.

    certsrv_e_no_request* =             0x80094002.HResult
      ## The request does not exist.

    certsrv_e_bad_requeststatus* =      0x80094003.HResult
      ## The request's current status does not allow this operation.

    certsrv_e_property_empty* =         0x80094004.HResult
      ## The requested property value is empty.

    certsrv_e_invalid_ca_certificate* = 0x80094005.HResult
      ## The certification authority's certificate contains invalid data.

    certsrv_e_server_suspended* =       0x80094006.HResult
      ## Certificate service has been suspended for a database restore operation.

    certsrv_e_encoding_length* =        0x80094007.HResult
      ## The certificate contains an encoded length that is potentially incompatible with older enrollment software.

    certsrv_e_roleconflict* =           0x80094008.HResult
      ## The operation is denied. The user has multiple roles assigned and the certification authority is configured to enforce role separation.

    certsrv_e_restrictedofficer* =      0x80094009.HResult
      ## The operation is denied. It can only be performed by a certificate manager that is allowed to manage certificates for the current requester.

    certsrv_e_key_archival_not_configured* = 0x8009400A.HResult
      ## Cannot archive private key. The certification authority is not configured for key archival.

    certsrv_e_no_valid_kra* =           0x8009400B.HResult
      ## Cannot archive private key. The certification authority could not verify one or more key recovery certificates.

    certsrv_e_bad_request_key_archival* = 0x8009400C.HResult
      ## The request is incorrectly formatted. The encrypted private key must be in an unauthenticated attribute in an outermost signature.

    certsrv_e_no_caadmin_defined* =     0x8009400D.HResult
      ## At least one security principal must have the permission to manage this CA.

    certsrv_e_bad_renewal_cert_attribute* = 0x8009400E.HResult
      ## The request contains an invalid renewal certificate attribute.

    certsrv_e_no_db_sessions* =         0x8009400F.HResult
      ## An attempt was made to open a Certification Authority database session, but there are already too many active sessions. The server may need to be configured to allow additional sessions.

    certsrv_e_alignment_fault* =        0x80094010.HResult
      ## A memory reference caused a data alignment fault.

    certsrv_e_enroll_denied* =          0x80094011.HResult
      ## The permissions on this certification authority do not allow the current user to enroll for certificates.

    certsrv_e_template_denied* =        0x80094012.HResult
      ## The permissions on the certificate template do not allow the current user to enroll for this type of certificate.

    certsrv_e_downlevel_dc_ssl_or_upgrade* = 0x80094013.HResult
      ## The contacted domain controller cannot support signed LDAP traffic. Update the domain controller or configure Certificate Services to use SSL for Active Directory access.

    certsrv_e_admin_denied_request* =   0x80094014.HResult
      ## The request was denied by a certificate manager or CA administrator.

    certsrv_e_no_policy_server* =       0x80094015.HResult
      ## An enrollment policy server cannot be located.

    certsrv_e_weak_signature_or_key* =  0x80094016.HResult
      ## A signature algorithm or public key length does not meet the system's minimum required strength.

    certsrv_e_key_attestation_not_supported* = 0x80094017.HResult
      ## Failed to create an attested key.  This computer or the cryptographic provider may not meet the hardware requirements to support key attestation.

    certsrv_e_encryption_cert_required* = 0x80094018.HResult
      ## No encryption certificate was specified.

    certsrv_e_unsupported_cert_type* =  0x80094800.HResult
      ## The requested certificate template is not supported by this CA.

    certsrv_e_no_cert_type* =           0x80094801.HResult
      ## The request contains no certificate template information.

    certsrv_e_template_conflict* =      0x80094802.HResult
      ## The request contains conflicting template information.

    certsrv_e_subject_alt_name_required* = 0x80094803.HResult
      ## The request is missing a required Subject Alternate name extension.

    certsrv_e_archived_key_required* =  0x80094804.HResult
      ## The request is missing a required private key for archival by the server.

    certsrv_e_smime_required* =         0x80094805.HResult
      ## The request is missing a required SMIME capabilities extension.

    certsrv_e_bad_renewal_subject* =    0x80094806.HResult
      ## The request was made on behalf of a subject other than the caller. The certificate template must be configured to require at least one signature to authorize the request.

    certsrv_e_bad_template_version* =   0x80094807.HResult
      ## The request template version is newer than the supported template version.

    certsrv_e_template_policy_required* = 0x80094808.HResult
      ## The template is missing a required signature policy attribute.

    certsrv_e_signature_policy_required* = 0x80094809.HResult
      ## The request is missing required signature policy information.

    certsrv_e_signature_count* =        0x8009480A.HResult
      ## The request is missing one or more required signatures.

    certsrv_e_signature_rejected* =     0x8009480B.HResult
      ## One or more signatures did not include the required application or issuance policies. The request is missing one or more required valid signatures.

    certsrv_e_issuance_policy_required* = 0x8009480C.HResult
      ## The request is missing one or more required signature issuance policies.

    certsrv_e_subject_upn_required* =   0x8009480D.HResult
      ## The UPN is unavailable and cannot be added to the Subject Alternate name.

    certsrv_e_subject_directory_guid_required* = 0x8009480E.HResult
      ## The Active Directory GUID is unavailable and cannot be added to the Subject Alternate name.

    certsrv_e_subject_dns_required* =   0x8009480F.HResult
      ## The DNS name is unavailable and cannot be added to the Subject Alternate name.

    certsrv_e_archived_key_unexpected* = 0x80094810.HResult
      ## The request includes a private key for archival by the server, but key archival is not enabled for the specified certificate template.

    certsrv_e_key_length* =             0x80094811.HResult
      ## The public key does not meet the minimum size required by the specified certificate template.

    certsrv_e_subject_email_required* = 0x80094812.HResult
      ## The EMail name is unavailable and cannot be added to the Subject or Subject Alternate name.

    certsrv_e_unknown_cert_type* =      0x80094813.HResult
      ## One or more certificate templates to be enabled on this certification authority could not be found.

    certsrv_e_cert_type_overlap* =      0x80094814.HResult
      ## The certificate template renewal period is longer than the certificate validity period. The template should be reconfigured or the CA certificate renewed.

    certsrv_e_too_many_signatures* =    0x80094815.HResult
      ## The certificate template requires too many RA signatures. Only one RA signature is allowed.

    certsrv_e_renewal_bad_public_key* = 0x80094816.HResult
      ## The certificate template requires renewal with the same public key, but the request uses a different public key.

    certsrv_e_invalid_ek* =             0x80094817.HResult
      ## The certification authority cannot interpret or verify the endorsement key information supplied in the request, or the information is inconsistent.

    certsrv_e_invalid_idbinding* =      0x80094818.HResult
      ## The certification authority cannot validate the Attestation Identity Key Id Binding.

    certsrv_e_invalid_attestation* =    0x80094819.HResult
      ## The certification authority cannot validate the private key attestation data.

    certsrv_e_key_attestation* =        0x8009481A.HResult
      ## The request does not support private key attestation as defined in the certificate template.

    certsrv_e_corrupt_key_attestation* = 0x8009481B.HResult
      ## The request public key is not consistent with the private key attestation data.

    certsrv_e_expired_challenge* =      0x8009481C.HResult
      ## The private key attestation challenge cannot be validated because the encryption certificate has expired, or the certificate or key is unavailable.

    certsrv_e_invalid_response* =       0x8009481D.HResult
      ## The attestation response could not be validated. It is either unexpected or incorrect.

    certsrv_e_invalid_requestid* =      0x8009481E.HResult
      ## A valid Request ID was not detected in the request attributes, or an invalid one was submitted.

    #
    # The range 0x5000-0x51ff is reserved for XENROLL errors.
    #
    xenroll_e_key_not_exportable* =     0x80095000.HResult
      ## The key is not exportable.

    xenroll_e_cannot_add_root_cert* =   0x80095001.HResult
      ## You cannot add the root CA certificate into your local store.

    xenroll_e_response_ka_hash_not_found* = 0x80095002.HResult
      ## The key archival hash attribute was not found in the response.

    xenroll_e_response_unexpected_ka_hash* = 0x80095003.HResult
      ## An unexpected key archival hash attribute was found in the response.

    xenroll_e_response_ka_hash_mismatch* = 0x80095004.HResult
      ## There is a key archival hash mismatch between the request and the response.

    xenroll_e_keyspec_smime_mismatch* = 0x80095005.HResult
      ## Signing certificate cannot include SMIME extension.

    trust_e_system_error* =             0x80096001.HResult
      ## A system-level error occurred while verifying trust.

    trust_e_no_signer_cert* =           0x80096002.HResult
      ## The certificate for the signer of the message is invalid or not found.

    trust_e_counter_signer* =           0x80096003.HResult
      ## One of the counter signatures was invalid.

    trust_e_cert_signature* =           0x80096004.HResult
      ## The signature of the certificate cannot be verified.

    trust_e_time_stamp* =               0x80096005.HResult
      ## The timestamp signature and/or certificate could not be verified or is malformed.

    trust_e_bad_digest* =               0x80096010.HResult
      ## The digital signature of the object did not verify.

    trust_e_malformed_signature* =      0x80096011.HResult
      ## The digital signature of the object is malformed. For technical detail, see security bulletin MS13-098.

    trust_e_basic_constraints* =        0x80096019.HResult
      ## A certificate's basic constraint extension has not been observed.

    trust_e_financial_criteria* =       0x8009601E.HResult
      ## The certificate does not meet or contain the Authenticode(tm) financial extensions.

    #
    # Error codes for mssipotf.dll
    # Most of the error codes can only occur when an error occurs
    #    during font file signing
    #
    #
    mssipotf_e_outofmemrange* =         0x80097001.HResult
      ## Tried to reference a part of the file outside the proper range.

    mssipotf_e_cantgetobject* =         0x80097002.HResult
      ## Could not retrieve an object from the file.

    mssipotf_e_noheadtable* =           0x80097003.HResult
      ## Could not find the head table in the file.

    mssipotf_e_bad_magicnumber* =       0x80097004.HResult
      ## The magic number in the head table is incorrect.

    mssipotf_e_bad_offset_table* =      0x80097005.HResult
      ## The offset table has incorrect values.

    mssipotf_e_table_tagorder* =        0x80097006.HResult
      ## Duplicate table tags or tags out of alphabetical order.

    mssipotf_e_table_longword* =        0x80097007.HResult
      ## A table does not start on a long word boundary.

    mssipotf_e_bad_first_table_placement* = 0x80097008.HResult
      ## First table does not appear after header information.

    mssipotf_e_tables_overlap* =        0x80097009.HResult
      ## Two or more tables overlap.

    mssipotf_e_table_padbytes* =        0x8009700A.HResult
      ## Too many pad bytes between tables or pad bytes are not 0.

    mssipotf_e_filetoosmall* =          0x8009700B.HResult
      ## File is too small to contain the last table.

    mssipotf_e_table_checksum* =        0x8009700C.HResult
      ## A table checksum is incorrect.

    mssipotf_e_file_checksum* =         0x8009700D.HResult
      ## The file checksum is incorrect.

    mssipotf_e_failed_policy* =         0x80097010.HResult
      ## The signature does not have the correct attributes for the policy.

    mssipotf_e_failed_hints_check* =    0x80097011.HResult
      ## The file did not pass the hints check.

    mssipotf_e_not_opentype* =          0x80097012.HResult
      ## The file is not an OpenType file.

    mssipotf_e_file* =                  0x80097013.HResult
      ## Failed on a file operation (open, map, read, write).

    mssipotf_e_crypt* =                 0x80097014.HResult
      ## A call to a CryptoAPI function failed.

    mssipotf_e_badversion* =            0x80097015.HResult
      ## There is a bad version number in the file.

    mssipotf_e_dsig_structure* =        0x80097016.HResult
      ## The structure of the DSIG table is incorrect.

    mssipotf_e_pconst_check* =          0x80097017.HResult
      ## A check failed in a partially constant table.

    mssipotf_e_structure* =             0x80097018.HResult
      ## Some kind of structural error.

    error_cred_requires_confirmation* = 0x80097019.HResult
      ## The requested credential requires confirmation.

    nte_op_ok* = 0.HResult

    #
    # Note that additional FACILITY_SSPI errors are in issperr.h
    #
    # ******************
    # FACILITY_CERT
    # ******************
    trust_e_provider_unknown* =         0x800B0001.HResult
      ## Unknown trust provider.

    trust_e_action_unknown* =           0x800B0002.HResult
      ## The trust verification action specified is not supported by the specified trust provider.

    trust_e_subject_form_unknown* =     0x800B0003.HResult
      ## The form specified for the subject is not one supported or known by the specified trust provider.

    trust_e_subject_not_trusted* =      0x800B0004.HResult
      ## The subject is not trusted for the specified action.

    digsig_e_encode* =                  0x800B0005.HResult
      ## Error due to problem in ASN.1 encoding process.

    digsig_e_decode* =                  0x800B0006.HResult
      ## Error due to problem in ASN.1 decoding process.

    digsig_e_extensibility* =           0x800B0007.HResult
      ## Reading / writing Extensions where Attributes are appropriate, and vice versa.

    digsig_e_crypto* =                  0x800B0008.HResult
      ## Unspecified cryptographic failure.

    persist_e_sizedefinite* =           0x800B0009.HResult
      ## The size of the data could not be determined.

    persist_e_sizeindefinite* =         0x800B000A.HResult
      ## The size of the indefinite-sized data could not be determined.

    persist_e_notselfsizing* =          0x800B000B.HResult
      ## This object does not read and write self-sizing data.

    trust_e_nosignature* =              0x800B0100.HResult
      ## No signature was present in the subject.

    cert_e_expired* =                   0x800B0101.HResult
      ## A required certificate is not within its validity period when verifying against the current system clock or the timestamp in the signed file.

    cert_e_validityperiodnesting* =     0x800B0102.HResult
      ## The validity periods of the certification chain do not nest correctly.

    cert_e_role* =                      0x800B0103.HResult
      ## A certificate that can only be used as an end-entity is being used as a CA or vice versa.

    cert_e_pathlenconst* =              0x800B0104.HResult
      ## A path length constraint in the certification chain has been violated.

    cert_e_critical* =                  0x800B0105.HResult
      ## A certificate contains an unknown extension that is marked 'critical'.

    cert_e_purpose* =                   0x800B0106.HResult
      ## A certificate being used for a purpose other than the ones specified by its CA.

    cert_e_issuerchaining* =            0x800B0107.HResult
      ## A parent of a given certificate in fact did not issue that child certificate.

    cert_e_malformed* =                 0x800B0108.HResult
      ## A certificate is missing or has an empty value for an important field, such as a subject or issuer name.

    cert_e_untrustedroot* =             0x800B0109.HResult
      ## A certificate chain processed, but terminated in a root certificate which is not trusted by the trust provider.

    cert_e_chaining* =                  0x800B010A.HResult
      ## A certificate chain could not be built to a trusted root authority.

    trust_e_fail* =                     0x800B010B.HResult
      ## Generic trust failure.

    cert_e_revoked* =                   0x800B010C.HResult
      ## A certificate was explicitly revoked by its issuer.

    cert_e_untrustedtestroot* =         0x800B010D.HResult
      ## The certification path terminates with the test root which is not trusted with the current policy settings.

    cert_e_revocation_failure* =        0x800B010E.HResult
      ## The revocation process could not continue - the certificate(s) could not be checked.

    cert_e_cn_no_match* =               0x800B010F.HResult
      ## The certificate's CN name does not match the passed value.

    cert_e_wrong_usage* =               0x800B0110.HResult
      ## The certificate is not valid for the requested usage.

    trust_e_explicit_distrust* =        0x800B0111.HResult
      ## The certificate was explicitly marked as untrusted by the user.

    cert_e_untrustedca* =               0x800B0112.HResult
      ## A certification chain processed correctly, but one of the CA certificates is not trusted by the policy provider.

    cert_e_invalid_policy* =            0x800B0113.HResult
      ## The certificate has invalid policy.

    cert_e_invalid_name* =              0x800B0114.HResult
      ## The certificate has an invalid name. The name is not included in the permitted list or is explicitly excluded.

    # *****************
    # FACILITY_MEDIASERVER
    # *****************
    #
    # Also known as FACILITY_MF and FACILITY_NS
    #
    # The error codes are defined in mferror.mc, dlnaerror.mc, nserror.mc, and neterror.mc
    #
    # *****************
    # FACILITY_SETUPAPI
    # *****************
    #
    # Since these error codes aren't in the standard Win32 range (i.e., 0-64K), define a
    # macro to map either Win32 or SetupAPI error codes into an HRESULT.
    #
    spapi_e_expected_section_name* =    0x800F0000.HResult
      ## A non-empty line was encountered in the INF before the start of a section.

    spapi_e_bad_section_name_line* =    0x800F0001.HResult
      ## A section name marker in the INF is not complete, or does not exist on a line by itself.

    spapi_e_section_name_too_long* =    0x800F0002.HResult
      ## An INF section was encountered whose name exceeds the maximum section name length.

    spapi_e_general_syntax* =           0x800F0003.HResult
      ## The syntax of the INF is invalid.

    spapi_e_wrong_inf_style* =          0x800F0100.HResult
      ## The style of the INF is different than what was requested.

    spapi_e_section_not_found* =        0x800F0101.HResult
      ## The required section was not found in the INF.

    spapi_e_line_not_found* =           0x800F0102.HResult
      ## The required line was not found in the INF.

    spapi_e_no_backup* =                0x800F0103.HResult
      ## The files affected by the installation of this file queue have not been backed up for uninstall.

    spapi_e_no_associated_class* =      0x800F0200.HResult
      ## The INF or the device information set or element does not have an associated install class.

    spapi_e_class_mismatch* =           0x800F0201.HResult
      ## The INF or the device information set or element does not match the specified install class.

    spapi_e_duplicate_found* =          0x800F0202.HResult
      ## An existing device was found that is a duplicate of the device being manually installed.

    spapi_e_no_driver_selected* =       0x800F0203.HResult
      ## There is no driver selected for the device information set or element.

    spapi_e_key_does_not_exist* =       0x800F0204.HResult
      ## The requested device registry key does not exist.

    spapi_e_invalid_devinst_name* =     0x800F0205.HResult
      ## The device instance name is invalid.

    spapi_e_invalid_class* =            0x800F0206.HResult
      ## The install class is not present or is invalid.

    spapi_e_devinst_already_exists* =   0x800F0207.HResult
      ## The device instance cannot be created because it already exists.

    spapi_e_devinfo_not_registered* =   0x800F0208.HResult
      ## The operation cannot be performed on a device information element that has not been registered.

    spapi_e_invalid_reg_property* =     0x800F0209.HResult
      ## The device property code is invalid.

    spapi_e_no_inf* =                   0x800F020A.HResult
      ## The INF from which a driver list is to be built does not exist.

    spapi_e_no_such_devinst* =          0x800F020B.HResult
      ## The device instance does not exist in the hardware tree.

    spapi_e_cant_load_class_icon* =     0x800F020C.HResult
      ## The icon representing this install class cannot be loaded.

    spapi_e_invalid_class_installer* =  0x800F020D.HResult
      ## The class installer registry entry is invalid.

    spapi_e_di_do_default* =            0x800F020E.HResult
      ## The class installer has indicated that the default action should be performed for this installation request.

    spapi_e_di_nofilecopy* =            0x800F020F.HResult
      ## The operation does not require any files to be copied.

    spapi_e_invalid_hwprofile* =        0x800F0210.HResult
      ## The specified hardware profile does not exist.

    spapi_e_no_device_selected* =       0x800F0211.HResult
      ## There is no device information element currently selected for this device information set.

    spapi_e_devinfo_list_locked* =      0x800F0212.HResult
      ## The operation cannot be performed because the device information set is locked.

    spapi_e_devinfo_data_locked* =      0x800F0213.HResult
      ## The operation cannot be performed because the device information element is locked.

    spapi_e_di_bad_path* =              0x800F0214.HResult
      ## The specified path does not contain any applicable device INFs.

    spapi_e_no_classinstall_params* =   0x800F0215.HResult
      ## No class installer parameters have been set for the device information set or element.

    spapi_e_filequeue_locked* =         0x800F0216.HResult
      ## The operation cannot be performed because the file queue is locked.

    spapi_e_bad_service_installsect* =  0x800F0217.HResult
      ## A service installation section in this INF is invalid.

    spapi_e_no_class_driver_list* =     0x800F0218.HResult
      ## There is no class driver list for the device information element.

    spapi_e_no_associated_service* =    0x800F0219.HResult
      ## The installation failed because a function driver was not specified for this device instance.

    spapi_e_no_default_device_interface* = 0x800F021A.HResult
      ## There is presently no default device interface designated for this interface class.

    spapi_e_device_interface_active* =  0x800F021B.HResult
      ## The operation cannot be performed because the device interface is currently active.

    spapi_e_device_interface_removed* = 0x800F021C.HResult
      ## The operation cannot be performed because the device interface has been removed from the system.

    spapi_e_bad_interface_installsect* = 0x800F021D.HResult
      ## An interface installation section in this INF is invalid.

    spapi_e_no_such_interface_class* =  0x800F021E.HResult
      ## This interface class does not exist in the system.

    spapi_e_invalid_reference_string* = 0x800F021F.HResult
      ## The reference string supplied for this interface device is invalid.

    spapi_e_invalid_machinename* =      0x800F0220.HResult
      ## The specified machine name does not conform to UNC naming conventions.

    spapi_e_remote_comm_failure* =      0x800F0221.HResult
      ## A general remote communication error occurred.

    spapi_e_machine_unavailable* =      0x800F0222.HResult
      ## The machine selected for remote communication is not available at this time.

    spapi_e_no_configmgr_services* =    0x800F0223.HResult
      ## The Plug and Play service is not available on the remote machine.

    spapi_e_invalid_proppage_provider* = 0x800F0224.HResult
      ## The property page provider registry entry is invalid.

    spapi_e_no_such_device_interface* = 0x800F0225.HResult
      ## The requested device interface is not present in the system.

    spapi_e_di_postprocessing_required* = 0x800F0226.HResult
      ## The device's co-installer has additional work to perform after installation is complete.

    spapi_e_invalid_coinstaller* =      0x800F0227.HResult
      ## The device's co-installer is invalid.

    spapi_e_no_compat_drivers* =        0x800F0228.HResult
      ## There are no compatible drivers for this device.

    spapi_e_no_device_icon* =           0x800F0229.HResult
      ## There is no icon that represents this device or device type.

    spapi_e_invalid_inf_logconfig* =    0x800F022A.HResult
      ## A logical configuration specified in this INF is invalid.

    spapi_e_di_dont_install* =          0x800F022B.HResult
      ## The class installer has denied the request to install or upgrade this device.

    spapi_e_invalid_filter_driver* =    0x800F022C.HResult
      ## One of the filter drivers installed for this device is invalid.

    spapi_e_non_windows_nt_driver* =    0x800F022D.HResult
      ## The driver selected for this device does not support this version of Windows.

    spapi_e_non_windows_driver* =       0x800F022E.HResult
      ## The driver selected for this device does not support Windows.

    spapi_e_no_catalog_for_oem_inf* =   0x800F022F.HResult
      ## The third-party INF does not contain digital signature information.

    spapi_e_devinstall_queue_nonnative* = 0x800F0230.HResult
      ## An invalid attempt was made to use a device installation file queue for verification of digital signatures relative to other platforms.

    spapi_e_not_disableable* =          0x800F0231.HResult
      ## The device cannot be disabled.

    spapi_e_cant_remove_devinst* =      0x800F0232.HResult
      ## The device could not be dynamically removed.

    spapi_e_invalid_target* =           0x800F0233.HResult
      ## Cannot copy to specified target.

    spapi_e_driver_nonnative* =         0x800F0234.HResult
      ## Driver is not intended for this platform.

    spapi_e_in_wow64* =                 0x800F0235.HResult
      ## Operation not allowed in WOW64.

    spapi_e_set_system_restore_point* = 0x800F0236.HResult
      ## The operation involving unsigned file copying was rolled back, so that a system restore point could be set.

    spapi_e_incorrectly_copied_inf* =   0x800F0237.HResult
      ## An INF was copied into the Windows INF directory in an improper manner.

    spapi_e_sce_disabled* =             0x800F0238.HResult
      ## The Security Configuration Editor (SCE) APIs have been disabled on this Embedded product.

    spapi_e_unknown_exception* =        0x800F0239.HResult
      ## An unknown exception was encountered.

    spapi_e_pnp_registry_error* =       0x800F023A.HResult
      ## A problem was encountered when accessing the Plug and Play registry database.

    spapi_e_remote_request_unsupported* = 0x800F023B.HResult
      ## The requested operation is not supported for a remote machine.

    spapi_e_not_an_installed_oem_inf* = 0x800F023C.HResult
      ## The specified file is not an installed OEM INF.

    spapi_e_inf_in_use_by_devices* =    0x800F023D.HResult
      ## One or more devices are presently installed using the specified INF.

    spapi_e_di_function_obsolete* =     0x800F023E.HResult
      ## The requested device install operation is obsolete.

    spapi_e_no_authenticode_catalog* =  0x800F023F.HResult
      ## A file could not be verified because it does not have an associated catalog signed via Authenticode(tm).

    spapi_e_authenticode_disallowed* =  0x800F0240.HResult
      ## Authenticode(tm) signature verification is not supported for the specified INF.

    spapi_e_authenticode_trusted_publisher* = 0x800F0241.HResult
      ## The INF was signed with an Authenticode(tm) catalog from a trusted publisher.

    spapi_e_authenticode_trust_not_established* = 0x800F0242.HResult
      ## The publisher of an Authenticode(tm) signed catalog has not yet been established as trusted.

    spapi_e_authenticode_publisher_not_trusted* = 0x800F0243.HResult
      ## The publisher of an Authenticode(tm) signed catalog was not established as trusted.

    spapi_e_signature_osattribute_mismatch* = 0x800F0244.HResult
      ## The software was tested for compliance with Windows Logo requirements on a different version of Windows, and may not be compatible with this version.

    spapi_e_only_validate_via_authenticode* = 0x800F0245.HResult
      ## The file may only be validated by a catalog signed via Authenticode(tm).

    spapi_e_device_installer_not_ready* = 0x800F0246.HResult
      ## One of the installers for this device cannot perform the installation at this time.

    spapi_e_driver_store_add_failed* =  0x800F0247.HResult
      ## A problem was encountered while attempting to add the driver to the store.

    spapi_e_device_install_blocked* =   0x800F0248.HResult
      ## The installation of this device is forbidden by system policy. Contact your system administrator.

    spapi_e_driver_install_blocked* =   0x800F0249.HResult
      ## The installation of this driver is forbidden by system policy. Contact your system administrator.

    spapi_e_wrong_inf_type* =           0x800F024A.HResult
      ## The specified INF is the wrong type for this operation.

    spapi_e_file_hash_not_in_catalog* = 0x800F024B.HResult
      ## The hash for the file is not present in the specified catalog file. The file is likely corrupt or the victim of tampering.

    spapi_e_driver_store_delete_failed* = 0x800F024C.HResult
      ## A problem was encountered while attempting to delete the driver from the store.

    spapi_e_unrecoverable_stack_overflow* = 0x800F0300.HResult
      ## An unrecoverable stack overflow was encountered.

    spapi_e_error_not_installed* =      0x800F1000.HResult
      ## No installed components were detected.

    # *****************
    # FACILITY_SCARD
    # *****************
    #
    # =============================
    # Facility SCARD Error Messages
    # =============================
    #
    scard_s_success* = (no_error.uint32).HResult
    scard_f_internal_error* =           0x80100001.HResult
      ## An internal consistency check failed.

    scard_e_cancelled* =                0x80100002.HResult
      ## The action was cancelled by an SCardCancel request.

    scard_e_invalid_handle* =           0x80100003.HResult
      ## The supplied handle was invalid.

    scard_e_invalid_parameter* =        0x80100004.HResult
      ## One or more of the supplied parameters could not be properly interpreted.

    scard_e_invalid_target* =           0x80100005.HResult
      ## Registry startup information is missing or invalid.

    scard_e_no_memory* =                0x80100006.HResult
      ## Not enough memory available to complete this command.

    scard_f_waited_too_long* =          0x80100007.HResult
      ## An internal consistency timer has expired.

    scard_e_insufficient_buffer* =      0x80100008.HResult
      ## The data buffer to receive returned data is too small for the returned data.

    scard_e_unknown_reader* =           0x80100009.HResult
      ## The specified reader name is not recognized.

    scard_e_timeout* =                  0x8010000A.HResult
      ## The user-specified timeout value has expired.

    scard_e_sharing_violation* =        0x8010000B.HResult
      ## The smart card cannot be accessed because of other connections outstanding.

    scard_e_no_smartcard* =             0x8010000C.HResult
      ## The operation requires a smart card, but no smart card is currently in the device.

    scard_e_unknown_card* =             0x8010000D.HResult
      ## The specified smart card name is not recognized.

    scard_e_cant_dispose* =             0x8010000E.HResult
      ## The system could not dispose of the media in the requested manner.

    scard_e_proto_mismatch* =           0x8010000F.HResult
      ## The requested protocols are incompatible with the protocol currently in use with the smart card.

    scard_e_not_ready* =                0x80100010.HResult
      ## The reader or smart card is not ready to accept commands.

    scard_e_invalid_value* =            0x80100011.HResult
      ## One or more of the supplied parameters values could not be properly interpreted.

    scard_e_system_cancelled* =         0x80100012.HResult
      ## The action was cancelled by the system, presumably to log off or shut down.

    scard_f_comm_error* =               0x80100013.HResult
      ## An internal communications error has been detected.

    scard_f_unknown_error* =            0x80100014.HResult
      ## An internal error has been detected, but the source is unknown.

    scard_e_invalid_atr* =              0x80100015.HResult
      ## An ATR obtained from the registry is not a valid ATR string.

    scard_e_not_transacted* =           0x80100016.HResult
      ## An attempt was made to end a non-existent transaction.

    scard_e_reader_unavailable* =       0x80100017.HResult
      ## The specified reader is not currently available for use.

    scard_p_shutdown* =                 0x80100018.HResult
      ## The operation has been aborted to allow the server application to exit.

    scard_e_pci_too_small* =            0x80100019.HResult
      ## The PCI Receive buffer was too small.

    scard_e_reader_unsupported* =       0x8010001A.HResult
      ## The reader driver does not meet minimal requirements for support.

    scard_e_duplicate_reader* =         0x8010001B.HResult
      ## The reader driver did not produce a unique reader name.

    scard_e_card_unsupported* =         0x8010001C.HResult
      ## The smart card does not meet minimal requirements for support.

    scard_e_no_service* =               0x8010001D.HResult
      ## The Smart Card Resource Manager is not running.

    scard_e_service_stopped* =          0x8010001E.HResult
      ## The Smart Card Resource Manager has shut down.

    scard_e_unexpected* =               0x8010001F.HResult
      ## An unexpected card error has occurred.

    scard_e_icc_installation* =         0x80100020.HResult
      ## No Primary Provider can be found for the smart card.

    scard_e_icc_createorder* =          0x80100021.HResult
      ## The requested order of object creation is not supported.

    scard_e_unsupported_feature* =      0x80100022.HResult
      ## This smart card does not support the requested feature.

    scard_e_dir_not_found* =            0x80100023.HResult
      ## The identified directory does not exist in the smart card.

    scard_e_file_not_found* =           0x80100024.HResult
      ## The identified file does not exist in the smart card.

    scard_e_no_dir* =                   0x80100025.HResult
      ## The supplied path does not represent a smart card directory.

    scard_e_no_file* =                  0x80100026.HResult
      ## The supplied path does not represent a smart card file.

    scard_e_no_access* =                0x80100027.HResult
      ## Access is denied to this file.

    scard_e_write_too_many* =           0x80100028.HResult
      ## The smart card does not have enough memory to store the information.

    scard_e_bad_seek* =                 0x80100029.HResult
      ## There was an error trying to set the smart card file object pointer.

    scard_e_invalid_chv* =              0x8010002A.HResult
      ## The supplied PIN is incorrect.

    scard_e_unknown_res_mng* =          0x8010002B.HResult
      ## An unrecognized error code was returned from a layered component.

    scard_e_no_such_certificate* =      0x8010002C.HResult
      ## The requested certificate does not exist.

    scard_e_certificate_unavailable* =  0x8010002D.HResult
      ## The requested certificate could not be obtained.

    scard_e_no_readers_available* =     0x8010002E.HResult
      ## Cannot find a smart card reader.

    scard_e_comm_data_lost* =           0x8010002F.HResult
      ## A communications error with the smart card has been detected. Retry the operation.

    scard_e_no_key_container* =         0x80100030.HResult
      ## The requested key container does not exist on the smart card.

    scard_e_server_too_busy* =          0x80100031.HResult
      ## The Smart Card Resource Manager is too busy to complete this operation.

    scard_e_pin_cache_expired* =        0x80100032.HResult
      ## The smart card PIN cache has expired.

    scard_e_no_pin_cache* =             0x80100033.HResult
      ## The smart card PIN cannot be cached.

    scard_e_read_only_card* =           0x80100034.HResult
      ## The smart card is read only and cannot be written to.

    #
    # These are warning codes.
    #
    scard_w_unsupported_card* =         0x80100065.HResult
      ## The reader cannot communicate with the smart card, due to ATR configuration conflicts.

    scard_w_unresponsive_card* =        0x80100066.HResult
      ## The smart card is not responding to a reset.

    scard_w_unpowered_card* =           0x80100067.HResult
      ## Power has been removed from the smart card, so that further communication is not possible.

    scard_w_reset_card* =               0x80100068.HResult
      ## The smart card has been reset, so any shared state information is invalid.

    scard_w_removed_card* =             0x80100069.HResult
      ## The smart card has been removed, so that further communication is not possible.

    scard_w_security_violation* =       0x8010006A.HResult
      ## Access was denied because of a security violation.

    scard_w_wrong_chv* =                0x8010006B.HResult
      ## The card cannot be accessed because the wrong PIN was presented.

    scard_w_chv_blocked* =              0x8010006C.HResult
      ## The card cannot be accessed because the maximum number of PIN entry attempts has been reached.

    scard_w_eof* =                      0x8010006D.HResult
      ## The end of the smart card file has been reached.

    scard_w_cancelled_by_user* =        0x8010006E.HResult
      ## The action was cancelled by the user.

    scard_w_card_not_authenticated* =   0x8010006F.HResult
      ## No PIN was presented to the smart card.

    scard_w_cache_item_not_found* =     0x80100070.HResult
      ## The requested item could not be found in the cache.

    scard_w_cache_item_stale* =         0x80100071.HResult
      ## The requested cache item is too old and was deleted from the cache.

    scard_w_cache_item_too_big* =       0x80100072.HResult
      ## The new cache item exceeds the maximum per-item size defined for the cache.

    # *****************
    # FACILITY_COMPLUS
    # *****************
    #
    # ===============================
    # Facility COMPLUS Error Messages
    # ===============================
    #
    #
    # The following are the subranges  within the COMPLUS facility
    # 0x400 - 0x4ff               COMADMIN_E_CAT
    # 0x600 - 0x6ff               COMQC errors
    # 0x700 - 0x7ff               MSDTC errors
    # 0x800 - 0x8ff               Other COMADMIN errors
    #
    # COMPLUS Admin errors
    #
    comadmin_e_objecterrors* =          0x80110401.HResult
      ## Errors occurred accessing one or more objects - the ErrorInfo collection may have more detail

    comadmin_e_objectinvalid* =         0x80110402.HResult
      ## One or more of the object's properties are missing or invalid

    comadmin_e_keymissing* =            0x80110403.HResult
      ## The object was not found in the catalog

    comadmin_e_alreadyinstalled* =      0x80110404.HResult
      ## The object is already registered

    comadmin_e_app_file_writefail* =    0x80110407.HResult
      ## Error occurred writing to the application file

    comadmin_e_app_file_readfail* =     0x80110408.HResult
      ## Error occurred reading the application file

    comadmin_e_app_file_version* =      0x80110409.HResult
      ## Invalid version number in application file

    comadmin_e_badpath* =               0x8011040A.HResult
      ## The file path is invalid

    comadmin_e_applicationexists* =     0x8011040B.HResult
      ## The application is already installed

    comadmin_e_roleexists* =            0x8011040C.HResult
      ## The role already exists

    comadmin_e_cantcopyfile* =          0x8011040D.HResult
      ## An error occurred copying the file

    comadmin_e_nouser* =                0x8011040F.HResult
      ## One or more users are not valid

    comadmin_e_invaliduserids* =        0x80110410.HResult
      ## One or more users in the application file are not valid

    comadmin_e_noregistryclsid* =       0x80110411.HResult
      ## The component's CLSID is missing or corrupt

    comadmin_e_badregistryprogid* =     0x80110412.HResult
      ## The component's progID is missing or corrupt

    comadmin_e_authenticationlevel* =   0x80110413.HResult
      ## Unable to set required authentication level for update request

    comadmin_e_userpasswdnotvalid* =    0x80110414.HResult
      ## The identity or password set on the application is not valid

    comadmin_e_clsidoriidmismatch* =    0x80110418.HResult
      ## Application file CLSIDs or IIDs do not match corresponding DLLs

    comadmin_e_remoteinterface* =       0x80110419.HResult
      ## Interface information is either missing or changed

    comadmin_e_dllregisterserver* =     0x8011041A.HResult
      ## DllRegisterServer failed on component install

    comadmin_e_noservershare* =         0x8011041B.HResult
      ## No server file share available

    comadmin_e_dllloadfailed* =         0x8011041D.HResult
      ## DLL could not be loaded

    comadmin_e_badregistrylibid* =      0x8011041E.HResult
      ## The registered TypeLib ID is not valid

    comadmin_e_appdirnotfound* =        0x8011041F.HResult
      ## Application install directory not found

    comadmin_e_registrarfailed* =       0x80110423.HResult
      ## Errors occurred while in the component registrar

    comadmin_e_compfile_doesnotexist* = 0x80110424.HResult
      ## The file does not exist

    comadmin_e_compfile_loaddllfail* =  0x80110425.HResult
      ## The DLL could not be loaded

    comadmin_e_compfile_getclassobj* =  0x80110426.HResult
      ## GetClassObject failed in the DLL

    comadmin_e_compfile_classnotavail* = 0x80110427.HResult
      ## The DLL does not support the components listed in the TypeLib

    comadmin_e_compfile_badtlb* =       0x80110428.HResult
      ## The TypeLib could not be loaded

    comadmin_e_compfile_notinstallable* = 0x80110429.HResult
      ## The file does not contain components or component information

    comadmin_e_notchangeable* =         0x8011042A.HResult
      ## Changes to this object and its sub-objects have been disabled

    comadmin_e_notdeleteable* =         0x8011042B.HResult
      ## The delete function has been disabled for this object

    comadmin_e_session* =               0x8011042C.HResult
      ## The server catalog version is not supported

    comadmin_e_comp_move_locked* =      0x8011042D.HResult
      ## The component move was disallowed, because the source or destination application is either a system application or currently locked against changes

    comadmin_e_comp_move_bad_dest* =    0x8011042E.HResult
      ## The component move failed because the destination application no longer exists

    comadmin_e_registertlb* =           0x80110430.HResult
      ## The system was unable to register the TypeLib

    comadmin_e_systemapp* =             0x80110433.HResult
      ## This operation cannot be performed on the system application

    comadmin_e_compfile_noregistrar* =  0x80110434.HResult
      ## The component registrar referenced in this file is not available

    comadmin_e_coreqcompinstalled* =    0x80110435.HResult
      ## A component in the same DLL is already installed

    comadmin_e_servicenotinstalled* =   0x80110436.HResult
      ## The service is not installed

    comadmin_e_propertysavefailed* =    0x80110437.HResult
      ## One or more property settings are either invalid or in conflict with each other

    comadmin_e_objectexists* =          0x80110438.HResult
      ## The object you are attempting to add or rename already exists

    comadmin_e_componentexists* =       0x80110439.HResult
      ## The component already exists

    comadmin_e_regfile_corrupt* =       0x8011043B.HResult
      ## The registration file is corrupt

    comadmin_e_property_overflow* =     0x8011043C.HResult
      ## The property value is too large

    comadmin_e_notinregistry* =         0x8011043E.HResult
      ## Object was not found in registry

    comadmin_e_objectnotpoolable* =     0x8011043F.HResult
      ## This object is not poolable

    comadmin_e_applid_matches_clsid* =  0x80110446.HResult
      ## A CLSID with the same GUID as the new application ID is already installed on this machine

    comadmin_e_role_does_not_exist* =   0x80110447.HResult
      ## A role assigned to a component, interface, or method did not exist in the application

    comadmin_e_start_app_needs_components* = 0x80110448.HResult
      ## You must have components in an application in order to start the application

    comadmin_e_requires_different_platform* = 0x80110449.HResult
      ## This operation is not enabled on this platform

    comadmin_e_can_not_export_app_proxy* = 0x8011044A.HResult
      ## Application Proxy is not exportable

    comadmin_e_can_not_start_app* =     0x8011044B.HResult
      ## Failed to start application because it is either a library application or an application proxy

    comadmin_e_can_not_export_sys_app* = 0x8011044C.HResult
      ## System application is not exportable

    comadmin_e_cant_subscribe_to_component* = 0x8011044D.HResult
      ## Cannot subscribe to this component (the component may have been imported)

    comadmin_e_eventclass_cant_be_subscriber* = 0x8011044E.HResult
      ## An event class cannot also be a subscriber component

    comadmin_e_lib_app_proxy_incompatible* = 0x8011044F.HResult
      ## Library applications and application proxies are incompatible

    comadmin_e_base_partition_only* =   0x80110450.HResult
      ## This function is valid for the base partition only

    comadmin_e_start_app_disabled* =    0x80110451.HResult
      ## You cannot start an application that has been disabled

    comadmin_e_cat_duplicate_partition_name* = 0x80110457.HResult
      ## The specified partition name is already in use on this computer

    comadmin_e_cat_invalid_partition_name* = 0x80110458.HResult
      ## The specified partition name is invalid. Check that the name contains at least one visible character

    comadmin_e_cat_partition_in_use* =  0x80110459.HResult
      ## The partition cannot be deleted because it is the default partition for one or more users

    comadmin_e_file_partition_duplicate_files* = 0x8011045A.HResult
      ## The partition cannot be exported, because one or more components in the partition have the same file name

    comadmin_e_cat_imported_components_not_allowed* = 0x8011045B.HResult
      ## Applications that contain one or more imported components cannot be installed into a non-base partition

    comadmin_e_ambiguous_application_name* = 0x8011045C.HResult
      ## The application name is not unique and cannot be resolved to an application id

    comadmin_e_ambiguous_partition_name* = 0x8011045D.HResult
      ## The partition name is not unique and cannot be resolved to a partition id

    comadmin_e_regdb_notinitialized* =  0x80110472.HResult
      ## The COM+ registry database has not been initialized

    comadmin_e_regdb_notopen* =         0x80110473.HResult
      ## The COM+ registry database is not open

    comadmin_e_regdb_systemerr* =       0x80110474.HResult
      ## The COM+ registry database detected a system error

    comadmin_e_regdb_alreadyrunning* =  0x80110475.HResult
      ## The COM+ registry database is already running

    comadmin_e_mig_versionnotsupported* = 0x80110480.HResult
      ## This version of the COM+ registry database cannot be migrated

    comadmin_e_mig_schemanotfound* =    0x80110481.HResult
      ## The schema version to be migrated could not be found in the COM+ registry database

    comadmin_e_cat_bitnessmismatch* =   0x80110482.HResult
      ## There was a type mismatch between binaries

    comadmin_e_cat_unacceptablebitness* = 0x80110483.HResult
      ## A binary of unknown or invalid type was provided

    comadmin_e_cat_wrongappbitness* =   0x80110484.HResult
      ## There was a type mismatch between a binary and an application

    comadmin_e_cat_pause_resume_not_supported* = 0x80110485.HResult
      ## The application cannot be paused or resumed

    comadmin_e_cat_serverfault* =       0x80110486.HResult
      ## The COM+ Catalog Server threw an exception during execution

    #
    # COMPLUS Queued component errors
    #
    comqc_e_application_not_queued* =   0x80110600.HResult
      ## Only COM+ Applications marked "queued" can be invoked using the "queue" moniker

    comqc_e_no_queueable_interfaces* =  0x80110601.HResult
      ## At least one interface must be marked "queued" in order to create a queued component instance with the "queue" moniker

    comqc_e_queuing_service_not_available* = 0x80110602.HResult
      ## MSMQ is required for the requested operation and is not installed

    comqc_e_no_ipersiststream* =        0x80110603.HResult
      ## Unable to marshal an interface that does not support IPersistStream

    comqc_e_bad_message* =              0x80110604.HResult
      ## The message is improperly formatted or was damaged in transit

    comqc_e_unauthenticated* =          0x80110605.HResult
      ## An unauthenticated message was received by an application that accepts only authenticated messages

    comqc_e_untrusted_enqueuer* =       0x80110606.HResult
      ## The message was requeued or moved by a user not in the "QC Trusted User" role

    #
    # The range 0x700-0x7ff is reserved for MSDTC errors.
    #
    msdtc_e_duplicate_resource* =       0x80110701.HResult
      ## Cannot create a duplicate resource of type Distributed Transaction Coordinator

    #
    # More COMADMIN errors from 0x8**
    #
    comadmin_e_object_parent_missing* = 0x80110808.HResult
      ## One of the objects being inserted or updated does not belong to a valid parent collection

    comadmin_e_object_does_not_exist* = 0x80110809.HResult
      ## One of the specified objects cannot be found

    comadmin_e_app_not_running* =       0x8011080A.HResult
      ## The specified application is not currently running

    comadmin_e_invalid_partition* =     0x8011080B.HResult
      ## The partition(s) specified are not valid.

    comadmin_e_svcapp_not_poolable_or_recyclable* = 0x8011080D.HResult
      ## COM+ applications that run as NT service may not be pooled or recycled

    comadmin_e_user_in_set* =           0x8011080E.HResult
      ## One or more users are already assigned to a local partition set.

    comadmin_e_cantrecyclelibraryapps* = 0x8011080F.HResult
      ## Library applications may not be recycled.

    comadmin_e_cantrecycleserviceapps* = 0x80110811.HResult
      ## Applications running as NT services may not be recycled.

    comadmin_e_processalreadyrecycled* = 0x80110812.HResult
      ## The process has already been recycled.

    comadmin_e_pausedprocessmaynotberecycled* = 0x80110813.HResult
      ## A paused process may not be recycled.

    comadmin_e_cantmakeinprocservice* = 0x80110814.HResult
      ## Library applications may not be NT services.

    comadmin_e_progidinusebyclsid* =    0x80110815.HResult
      ## The ProgID provided to the copy operation is invalid. The ProgID is in use by another registered CLSID.

    comadmin_e_default_partition_not_in_set* = 0x80110816.HResult
      ## The partition specified as default is not a member of the partition set.

    comadmin_e_recycledprocessmaynotbepaused* = 0x80110817.HResult
      ## A recycled process may not be paused.

    comadmin_e_partition_accessdenied* = 0x80110818.HResult
      ## Access to the specified partition is denied.

    comadmin_e_partition_msi_only* =    0x80110819.HResult
      ## Only Application Files (*.MSI files) can be installed into partitions.

    comadmin_e_legacycomps_not_allowed_in_1_0_format* = 0x8011081A.HResult
      ## Applications containing one or more legacy components may not be exported to 1.0 format.

    comadmin_e_legacycomps_not_allowed_in_nonbase_partitions* = 0x8011081B.HResult
      ## Legacy components may not exist in non-base partitions.

    comadmin_e_comp_move_source* =      0x8011081C.HResult
      ## A component cannot be moved (or copied) from the System Application, an application proxy or a non-changeable application

    comadmin_e_comp_move_dest* =        0x8011081D.HResult
      ## A component cannot be moved (or copied) to the System Application, an application proxy or a non-changeable application

    comadmin_e_comp_move_private* =     0x8011081E.HResult
      ## A private component cannot be moved (or copied) to a library application or to the base partition

    comadmin_e_basepartition_required_in_set* = 0x8011081F.HResult
      ## The Base Application Partition exists in all partition sets and cannot be removed.

    comadmin_e_cannot_alias_eventclass* = 0x80110820.HResult
      ## Alas, Event Class components cannot be aliased.

    comadmin_e_private_accessdenied* =  0x80110821.HResult
      ## Access is denied because the component is private.

    comadmin_e_saferinvalid* =          0x80110822.HResult
      ## The specified SAFER level is invalid.

    comadmin_e_registry_accessdenied* = 0x80110823.HResult
      ## The specified user cannot write to the system registry

    comadmin_e_partitions_disabled* =   0x80110824.HResult
      ## COM+ partitions are currently disabled.

    #
    # FACILITY_WER
    #
    wer_s_report_debug* =               0x001B0000.HResult
      ## Debugger was attached.

    wer_s_report_uploaded* =            0x001B0001.HResult
      ## Report was uploaded.

    wer_s_report_queued* =              0x001B0002.HResult
      ## Report was queued.

    wer_s_disabled* =                   0x001B0003.HResult
      ## Reporting was disabled.

    wer_s_suspended_upload* =           0x001B0004.HResult
      ## Reporting was temporarily suspended.

    wer_s_disabled_queue* =             0x001B0005.HResult
      ## Report was not queued to queueing being disabled.

    wer_s_disabled_archive* =           0x001B0006.HResult
      ## Report was uploaded, but not archived due to archiving being disabled.

    wer_s_report_async* =               0x001B0007.HResult
      ## Reporting was successfully spun off as an asynchronous operation.

    wer_s_ignore_assert_instance* =     0x001B0008.HResult
      ## The assertion was handled.

    wer_s_ignore_all_asserts* =         0x001B0009.HResult
      ## The assertion was handled and added to a permanent ignore list.

    wer_s_assert_continue* =            0x001B000A.HResult
      ## The assertion was resumed as unhandled.

    wer_s_throttled* =                  0x001B000B.HResult
      ## Report was throttled.

    wer_s_report_uploaded_cab* =        0x001B000C.HResult
      ## Report was uploaded with cab.

    wer_e_crash_failure* =              0x801B8000.HResult
      ## Crash reporting failed.

    wer_e_canceled* =                   0x801B8001.HResult
      ## Report aborted due to user cancelation.

    wer_e_network_failure* =            0x801B8002.HResult
      ## Report aborted due to network failure.

    wer_e_not_initialized* =            0x801B8003.HResult
      ## Report not initialized.

    wer_e_already_reporting* =          0x801B8004.HResult
      ## Reporting is already in progress for the specified process.

    wer_e_dump_throttled* =             0x801B8005.HResult
      ## Dump not generated due to a throttle.

    wer_e_insufficient_consent* =       0x801B8006.HResult
      ## Operation failed due to insufficient user consent.

    # ***********************
    # FACILITY_USERMODE_FILTER_MANAGER
    # ***********************
    #
    # Translation macro for converting FilterManager error codes only from:
    #     NTSTATUS  --> HRESULT
    #
  #define FILTER_HRESULT_FROM_FLT_NTSTATUS(x) (ASSERT((x & 0xfff0000) == 0x001c0000),(HRESULT) (((x) & 0x8000FFFF) | (FACILITY_USERMODE_FILTER_MANAGER << 16)))
    error_flt_io_complete* =            0x001F0001.HResult
      ## The IO was completed by a filter.

    error_flt_no_handler_defined* =     0x801F0001.HResult
      ## A handler was not defined by the filter for this operation.

    error_flt_context_already_defined* = 0x801F0002.HResult
      ## A context is already defined for this object.

    error_flt_invalid_asynchronous_request* = 0x801F0003.HResult
      ## Asynchronous requests are not valid for this operation.

    error_flt_disallow_fast_io* =       0x801F0004.HResult
      ## Disallow the Fast IO path for this operation.

    error_flt_invalid_name_request* =   0x801F0005.HResult
      ## An invalid name request was made. The name requested cannot be retrieved at this time.

    error_flt_not_safe_to_post_operation* = 0x801F0006.HResult
      ## Posting this operation to a worker thread for further processing is not safe at this time because it could lead to a system deadlock.

    error_flt_not_initialized* =        0x801F0007.HResult
      ## The Filter Manager was not initialized when a filter tried to register. Make sure that the Filter Manager is getting loaded as a driver.

    error_flt_filter_not_ready* =       0x801F0008.HResult
      ## The filter is not ready for attachment to volumes because it has not finished initializing (FltStartFiltering has not been called).

    error_flt_post_operation_cleanup* = 0x801F0009.HResult
      ## The filter must cleanup any operation specific context at this time because it is being removed from the system before the operation is completed by the lower drivers.

    error_flt_internal_error* =         0x801F000A.HResult
      ## The Filter Manager had an internal error from which it cannot recover, therefore the operation has been failed. This is usually the result of a filter returning an invalid value from a pre-operation callback.

    error_flt_deleting_object* =        0x801F000B.HResult
      ## The object specified for this action is in the process of being deleted, therefore the action requested cannot be completed at this time.

    error_flt_must_be_nonpaged_pool* =  0x801F000C.HResult
      ## Non-paged pool must be used for this type of context.

    error_flt_duplicate_entry* =        0x801F000D.HResult
      ## A duplicate handler definition has been provided for an operation.

    error_flt_cbdq_disabled* =          0x801F000E.HResult
      ## The callback data queue has been disabled.

    error_flt_do_not_attach* =          0x801F000F.HResult
      ## Do not attach the filter to the volume at this time.

    error_flt_do_not_detach* =          0x801F0010.HResult
      ## Do not detach the filter from the volume at this time.

    error_flt_instance_altitude_collision* = 0x801F0011.HResult
      ## An instance already exists at this altitude on the volume specified.

    error_flt_instance_name_collision* = 0x801F0012.HResult
      ## An instance already exists with this name on the volume specified.

    error_flt_filter_not_found* =       0x801F0013.HResult
      ## The system could not find the filter specified.

    error_flt_volume_not_found* =       0x801F0014.HResult
      ## The system could not find the volume specified.

    error_flt_instance_not_found* =     0x801F0015.HResult
      ## The system could not find the instance specified.

    error_flt_context_allocation_not_found* = 0x801F0016.HResult
      ## No registered context allocation definition was found for the given request.

    error_flt_invalid_context_registration* = 0x801F0017.HResult
      ## An invalid parameter was specified during context registration.

    error_flt_name_cache_miss* =        0x801F0018.HResult
      ## The name requested was not found in Filter Manager's name cache and could not be retrieved from the file system.

    error_flt_no_device_object* =       0x801F0019.HResult
      ## The requested device object does not exist for the given volume.

    error_flt_volume_already_mounted* = 0x801F001A.HResult
      ## The specified volume is already mounted.

    error_flt_already_enlisted* =       0x801F001B.HResult
      ## The specified Transaction Context is already enlisted in a transaction

    error_flt_context_already_linked* = 0x801F001C.HResult
      ## The specifiec context is already attached to another object

    error_flt_no_waiter_for_reply* =    0x801F0020.HResult
      ## No waiter is present for the filter's reply to this message.

    error_flt_registration_busy* =      0x801F0023.HResult
      ## The filesystem database resource is in use. Registration cannot complete at this time.

    #
    # ===============================
    # Facility Graphics Error Messages
    # ===============================
    #
    #
    # The following are the subranges within the Graphics facility
    #
    # 0x0000 - 0x0fff     Display Driver Loader driver & Video Port errors (displdr.sys, videoprt.sys)
    # 0x1000 - 0x1fff     Monitor Class Function driver errors             (monitor.sys)
    # 0x2000 - 0x2fff     Windows Graphics Kernel Subsystem errors         (dxgkrnl.sys)
    # 0x3000 - 0x3fff               Desktop Window Manager errors
    #   0x2000 - 0x20ff      Common errors
    #   0x2100 - 0x21ff      Video Memory Manager (VidMM) subsystem errors
    #   0x2200 - 0x22ff      Video GPU Scheduler (VidSch) subsystem errors
    #   0x2300 - 0x23ff      Video Display Mode Management (VidDMM) subsystem errors
    #
    # Display Driver Loader driver & Video Port errors {0x0000..0x0fff}
    #
    error_hung_display_driver_thread* = 0x80260001.HResult
      ## {Display Driver Stopped Responding}
      ## The %hs display driver has stopped working normally. Save your work and reboot the system to restore full display functionality.
      ## The next time you reboot the machine a dialog will be displayed giving you a chance to report this failure to Microsoft.

    #
    # Desktop Window Manager errors {0x3000..0x3fff}
    #
    dwm_e_compositiondisabled* =        0x80263001.HResult
      ## {Desktop composition is disabled}
      ## The operation could not be completed because desktop composition is disabled.

    dwm_e_remoting_not_supported* =     0x80263002.HResult
      ## {Some desktop composition APIs are not supported while remoting}
      ## The operation is not supported while running in a remote session.

    dwm_e_no_redirection_surface_available* = 0x80263003.HResult
      ## {No DWM redirection surface is available}
      ## The DWM was unable to provide a redireciton surface to complete the DirectX present.

    dwm_e_not_queuing_presents* =       0x80263004.HResult
      ## {DWM is not queuing presents for the specified window}
      ## The window specified is not currently using queued presents.

    dwm_e_adapter_not_found* =          0x80263005.HResult
      ## {The adapter specified by the LUID is not found}
      ## DWM can not find the adapter specified by the LUID.

    dwm_s_gdi_redirection_surface* =    0x00263005.HResult
      ## {GDI redirection surface was returned}
      ## GDI redirection surface of the top level window was returned.

    dwm_e_texture_too_large* =          0x80263007.HResult
      ## {Redirection surface can not be created.  The size of the surface is larger than what is supported on this machine}
      ## Redirection surface can not be created.  The size of the surface is larger than what is supported on this machine.

    dwm_s_gdi_redirection_surface_blt_via_gdi* = 0x00263008.HResult
      ## {GDI redirection surface is either on a different adapter or in system memory. Perform blt via GDI}
      ## GDI redirection surface is either on a different adapter or in system memory. Perform blt via GDI.

    #
    # Monitor class function driver errors {0x1000..0x1fff}
    #
    error_monitor_no_descriptor* =      0x00261001.HResult
      ## Monitor descriptor could not be obtained.

    error_monitor_unknown_descriptor_format* = 0x00261002.HResult
      ## Format of the obtained monitor descriptor is not supported by this release.

    error_monitor_invalid_descriptor_checksum* = 0xC0261003.HResult
      ## Checksum of the obtained monitor descriptor is invalid.

    error_monitor_invalid_standard_timing_block* = 0xC0261004.HResult
      ## Monitor descriptor contains an invalid standard timing block.

    error_monitor_wmi_datablock_registration_failed* = 0xC0261005.HResult
      ## WMI data block registration failed for one of the MSMonitorClass WMI subclasses.

    error_monitor_invalid_serial_number_mondsc_block* = 0xC0261006.HResult
      ## Provided monitor descriptor block is either corrupted or does not contain monitor's detailed serial number.

    error_monitor_invalid_user_friendly_mondsc_block* = 0xC0261007.HResult
      ## Provided monitor descriptor block is either corrupted or does not contain monitor's user friendly name.

    error_monitor_no_more_descriptor_data* = 0xC0261008.HResult
      ## There is no monitor descriptor data at the specified (offset, size) region.

    error_monitor_invalid_detailed_timing_block* = 0xC0261009.HResult
      ## Monitor descriptor contains an invalid detailed timing block.

    error_monitor_invalid_manufacture_date* = 0xC026100A.HResult
      ## Monitor descriptor contains invalid manufacture date.

    #
    # Windows Graphics Kernel Subsystem errors {0x2000..0x2fff}
    #
    # TODO: Add DXG Win32 errors here
    #
    # Common errors {0x2000..0x20ff}
    #
    error_graphics_not_exclusive_mode_owner* = 0xC0262000.HResult
      ## Exclusive mode ownership is needed to create unmanaged primary allocation.

    error_graphics_insufficient_dma_buffer* = 0xC0262001.HResult
      ## The driver needs more DMA buffer space in order to complete the requested operation.

    error_graphics_invalid_display_adapter* = 0xC0262002.HResult
      ## Specified display adapter handle is invalid.

    error_graphics_adapter_was_reset* = 0xC0262003.HResult
      ## Specified display adapter and all of its state has been reset.

    error_graphics_invalid_driver_model* = 0xC0262004.HResult
      ## The driver stack doesn't match the expected driver model.

    error_graphics_present_mode_changed* = 0xC0262005.HResult
      ## Present happened but ended up into the changed desktop mode

    error_graphics_present_occluded* =  0xC0262006.HResult
      ## Nothing to present due to desktop occlusion

    error_graphics_present_denied* =    0xC0262007.HResult
      ## Not able to present due to denial of desktop access

    error_graphics_cannotcolorconvert* = 0xC0262008.HResult
      ## Not able to present with color convertion

    error_graphics_driver_mismatch* =   0xC0262009.HResult
      ## The kernel driver detected a version mismatch between it and the user mode driver.

    error_graphics_partial_data_populated* = 0x4026200A.HResult
      ## Specified buffer is not big enough to contain entire requested dataset. Partial data populated up to the size of the buffer. Caller needs to provide buffer of size as specified in the partially populated buffer's content (interface specific).

    error_graphics_present_redirection_disabled* = 0xC026200B.HResult
      ## Present redirection is disabled (desktop windowing management subsystem is off).

    error_graphics_present_unoccluded* = 0xC026200C.HResult
      ## Previous exclusive VidPn source owner has released its ownership

    error_graphics_windowdc_not_available* = 0xC026200D.HResult
      ## Window DC is not available for presentation

    error_graphics_windowless_present_disabled* = 0xC026200E.HResult
      ## Windowless present is disabled (desktop windowing management subsystem is off).

    #
    # Video Memory Manager (VidMM) subsystem errors {0x2100..0x21ff}
    #
    error_graphics_no_video_memory* =   0xC0262100.HResult
      ## Not enough video memory available to complete the operation.

    error_graphics_cant_lock_memory* =  0xC0262101.HResult
      ## Couldn't probe and lock the underlying memory of an allocation.

    error_graphics_allocation_busy* =   0xC0262102.HResult
      ## The allocation is currently busy.

    error_graphics_too_many_references* = 0xC0262103.HResult
      ## An object being referenced has reach the maximum reference count already and can't be reference further.

    error_graphics_try_again_later* =   0xC0262104.HResult
      ## A problem couldn't be solved due to some currently existing condition. The problem should be tried again later.

    error_graphics_try_again_now* =     0xC0262105.HResult
      ## A problem couldn't be solved due to some currently existing condition. The problem should be tried again immediately.

    error_graphics_allocation_invalid* = 0xC0262106.HResult
      ## The allocation is invalid.

    error_graphics_unswizzling_aperture_unavailable* = 0xC0262107.HResult
      ## No more unswizzling aperture are currently available.

    error_graphics_unswizzling_aperture_unsupported* = 0xC0262108.HResult
      ## The current allocation can't be unswizzled by an aperture.

    error_graphics_cant_evict_pinned_allocation* = 0xC0262109.HResult
      ## The request failed because a pinned allocation can't be evicted.

    error_graphics_invalid_allocation_usage* = 0xC0262110.HResult
      ## The allocation can't be used from its current segment location for the specified operation.

    error_graphics_cant_render_locked_allocation* = 0xC0262111.HResult
      ## A locked allocation can't be used in the current command buffer.

    error_graphics_allocation_closed* = 0xC0262112.HResult
      ## The allocation being referenced has been closed permanently.

    error_graphics_invalid_allocation_instance* = 0xC0262113.HResult
      ## An invalid allocation instance is being referenced.

    error_graphics_invalid_allocation_handle* = 0xC0262114.HResult
      ## An invalid allocation handle is being referenced.

    error_graphics_wrong_allocation_device* = 0xC0262115.HResult
      ## The allocation being referenced doesn't belong to the current device.

    error_graphics_allocation_content_lost* = 0xC0262116.HResult
      ## The specified allocation lost its content.

    #
    # Video GPU Scheduler (VidSch) subsystem errors {0x2200..0x22ff}
    #
    error_graphics_gpu_exception_on_device* = 0xC0262200.HResult
      ## GPU exception is detected on the given device. The device is not able to be scheduled.

    error_graphics_skip_allocation_preparation* = 0x40262201.HResult
      ## Skip preparation of allocations referenced by the DMA buffer.

    #
    # Video Present Network Management (VidPNMgr) subsystem errors {0x2300..0x23ff}
    #
    error_graphics_invalid_vidpn_topology* = 0xC0262300.HResult
      ## Specified VidPN topology is invalid.

    error_graphics_vidpn_topology_not_supported* = 0xC0262301.HResult
      ## Specified VidPN topology is valid but is not supported by this model of the display adapter.

    error_graphics_vidpn_topology_currently_not_supported* = 0xC0262302.HResult
      ## Specified VidPN topology is valid but is not supported by the display adapter at this time, due to current allocation of its resources.

    error_graphics_invalid_vidpn* =     0xC0262303.HResult
      ## Specified VidPN handle is invalid.

    error_graphics_invalid_video_present_source* = 0xC0262304.HResult
      ## Specified video present source is invalid.

    error_graphics_invalid_video_present_target* = 0xC0262305.HResult
      ## Specified video present target is invalid.

    error_graphics_vidpn_modality_not_supported* = 0xC0262306.HResult
      ## Specified VidPN modality is not supported (e.g. at least two of the pinned modes are not cofunctional).

    error_graphics_mode_not_pinned* =   0x00262307.HResult
      ## No mode is pinned on the specified VidPN source/target.

    error_graphics_invalid_vidpn_sourcemodeset* = 0xC0262308.HResult
      ## Specified VidPN source mode set is invalid.

    error_graphics_invalid_vidpn_targetmodeset* = 0xC0262309.HResult
      ## Specified VidPN target mode set is invalid.

    error_graphics_invalid_frequency* = 0xC026230A.HResult
      ## Specified video signal frequency is invalid.

    error_graphics_invalid_active_region* = 0xC026230B.HResult
      ## Specified video signal active region is invalid.

    error_graphics_invalid_total_region* = 0xC026230C.HResult
      ## Specified video signal total region is invalid.

    error_graphics_invalid_video_present_source_mode* = 0xC0262310.HResult
      ## Specified video present source mode is invalid.

    error_graphics_invalid_video_present_target_mode* = 0xC0262311.HResult
      ## Specified video present target mode is invalid.

    error_graphics_pinned_mode_must_remain_in_set* = 0xC0262312.HResult
      ## Pinned mode must remain in the set on VidPN's cofunctional modality enumeration.

    error_graphics_path_already_in_topology* = 0xC0262313.HResult
      ## Specified video present path is already in VidPN's topology.

    error_graphics_mode_already_in_modeset* = 0xC0262314.HResult
      ## Specified mode is already in the mode set.

    error_graphics_invalid_videopresentsourceset* = 0xC0262315.HResult
      ## Specified video present source set is invalid.

    error_graphics_invalid_videopresenttargetset* = 0xC0262316.HResult
      ## Specified video present target set is invalid.

    error_graphics_source_already_in_set* = 0xC0262317.HResult
      ## Specified video present source is already in the video present source set.

    error_graphics_target_already_in_set* = 0xC0262318.HResult
      ## Specified video present target is already in the video present target set.

    error_graphics_invalid_vidpn_present_path* = 0xC0262319.HResult
      ## Specified VidPN present path is invalid.

    error_graphics_no_recommended_vidpn_topology* = 0xC026231A.HResult
      ## Miniport has no recommendation for augmentation of the specified VidPN's topology.

    error_graphics_invalid_monitor_frequencyrangeset* = 0xC026231B.HResult
      ## Specified monitor frequency range set is invalid.

    error_graphics_invalid_monitor_frequencyrange* = 0xC026231C.HResult
      ## Specified monitor frequency range is invalid.

    error_graphics_frequencyrange_not_in_set* = 0xC026231D.HResult
      ## Specified frequency range is not in the specified monitor frequency range set.

    error_graphics_no_preferred_mode* = 0x0026231E.HResult
      ## Specified mode set does not specify preference for one of its modes.

    error_graphics_frequencyrange_already_in_set* = 0xC026231F.HResult
      ## Specified frequency range is already in the specified monitor frequency range set.

    error_graphics_stale_modeset* =     0xC0262320.HResult
      ## Specified mode set is stale. Please reacquire the new mode set.

    error_graphics_invalid_monitor_sourcemodeset* = 0xC0262321.HResult
      ## Specified monitor source mode set is invalid.

    error_graphics_invalid_monitor_source_mode* = 0xC0262322.HResult
      ## Specified monitor source mode is invalid.

    error_graphics_no_recommended_functional_vidpn* = 0xC0262323.HResult
      ## Miniport does not have any recommendation regarding the request to provide a functional VidPN given the current display adapter configuration.

    error_graphics_mode_id_must_be_unique* = 0xC0262324.HResult
      ## ID of the specified mode is already used by another mode in the set.

    error_graphics_empty_adapter_monitor_mode_support_intersection* = 0xC0262325.HResult
      ## System failed to determine a mode that is supported by both the display adapter and the monitor connected to it.

    error_graphics_video_present_targets_less_than_sources* = 0xC0262326.HResult
      ## Number of video present targets must be greater than or equal to the number of video present sources.

    error_graphics_path_not_in_topology* = 0xC0262327.HResult
      ## Specified present path is not in VidPN's topology.

    error_graphics_adapter_must_have_at_least_one_source* = 0xC0262328.HResult
      ## Display adapter must have at least one video present source.

    error_graphics_adapter_must_have_at_least_one_target* = 0xC0262329.HResult
      ## Display adapter must have at least one video present target.

    error_graphics_invalid_monitordescriptorset* = 0xC026232A.HResult
      ## Specified monitor descriptor set is invalid.

    error_graphics_invalid_monitordescriptor* = 0xC026232B.HResult
      ## Specified monitor descriptor is invalid.

    error_graphics_monitordescriptor_not_in_set* = 0xC026232C.HResult
      ## Specified descriptor is not in the specified monitor descriptor set.

    error_graphics_monitordescriptor_already_in_set* = 0xC026232D.HResult
      ## Specified descriptor is already in the specified monitor descriptor set.

    error_graphics_monitordescriptor_id_must_be_unique* = 0xC026232E.HResult
      ## ID of the specified monitor descriptor is already used by another descriptor in the set.

    error_graphics_invalid_vidpn_target_subset_type* = 0xC026232F.HResult
      ## Specified video present target subset type is invalid.

    error_graphics_resources_not_related* = 0xC0262330.HResult
      ## Two or more of the specified resources are not related to each other, as defined by the interface semantics.

    error_graphics_source_id_must_be_unique* = 0xC0262331.HResult
      ## ID of the specified video present source is already used by another source in the set.

    error_graphics_target_id_must_be_unique* = 0xC0262332.HResult
      ## ID of the specified video present target is already used by another target in the set.

    error_graphics_no_available_vidpn_target* = 0xC0262333.HResult
      ## Specified VidPN source cannot be used because there is no available VidPN target to connect it to.

    error_graphics_monitor_could_not_be_associated_with_adapter* = 0xC0262334.HResult
      ## Newly arrived monitor could not be associated with a display adapter.

    error_graphics_no_vidpnmgr* =       0xC0262335.HResult
      ## Display adapter in question does not have an associated VidPN manager.

    error_graphics_no_active_vidpn* =   0xC0262336.HResult
      ## VidPN manager of the display adapter in question does not have an active VidPN.

    error_graphics_stale_vidpn_topology* = 0xC0262337.HResult
      ## Specified VidPN topology is stale. Please reacquire the new topology.

    error_graphics_monitor_not_connected* = 0xC0262338.HResult
      ## There is no monitor connected on the specified video present target.

    error_graphics_source_not_in_topology* = 0xC0262339.HResult
      ## Specified source is not part of the specified VidPN's topology.

    error_graphics_invalid_primarysurface_size* = 0xC026233A.HResult
      ## Specified primary surface size is invalid.

    error_graphics_invalid_visibleregion_size* = 0xC026233B.HResult
      ## Specified visible region size is invalid.

    error_graphics_invalid_stride* =    0xC026233C.HResult
      ## Specified stride is invalid.

    error_graphics_invalid_pixelformat* = 0xC026233D.HResult
      ## Specified pixel format is invalid.

    error_graphics_invalid_colorbasis* = 0xC026233E.HResult
      ## Specified color basis is invalid.

    error_graphics_invalid_pixelvalueaccessmode* = 0xC026233F.HResult
      ## Specified pixel value access mode is invalid.

    error_graphics_target_not_in_topology* = 0xC0262340.HResult
      ## Specified target is not part of the specified VidPN's topology.

    error_graphics_no_display_mode_management_support* = 0xC0262341.HResult
      ## Failed to acquire display mode management interface.

    error_graphics_vidpn_source_in_use* = 0xC0262342.HResult
      ## Specified VidPN source is already owned by a DMM client and cannot be used until that client releases it.

    error_graphics_cant_access_active_vidpn* = 0xC0262343.HResult
      ## Specified VidPN is active and cannot be accessed.

    error_graphics_invalid_path_importance_ordinal* = 0xC0262344.HResult
      ## Specified VidPN present path importance ordinal is invalid.

    error_graphics_invalid_path_content_geometry_transformation* = 0xC0262345.HResult
      ## Specified VidPN present path content geometry transformation is invalid.

    error_graphics_path_content_geometry_transformation_not_supported* = 0xC0262346.HResult
      ## Specified content geometry transformation is not supported on the respective VidPN present path.

    error_graphics_invalid_gamma_ramp* = 0xC0262347.HResult
      ## Specified gamma ramp is invalid.

    error_graphics_gamma_ramp_not_supported* = 0xC0262348.HResult
      ## Specified gamma ramp is not supported on the respective VidPN present path.

    error_graphics_multisampling_not_supported* = 0xC0262349.HResult
      ## Multi-sampling is not supported on the respective VidPN present path.

    error_graphics_mode_not_in_modeset* = 0xC026234A.HResult
      ## Specified mode is not in the specified mode set.

    error_graphics_dataset_is_empty* =  0x0026234B.HResult
      ## Specified data set (e.g. mode set, frequency range set, descriptor set, topology, etc.) is empty.

    error_graphics_no_more_elements_in_dataset* = 0x0026234C.HResult
      ## Specified data set (e.g. mode set, frequency range set, descriptor set, topology, etc.) does not contain any more elements.

    error_graphics_invalid_vidpn_topology_recommendation_reason* = 0xC026234D.HResult
      ## Specified VidPN topology recommendation reason is invalid.

    error_graphics_invalid_path_content_type* = 0xC026234E.HResult
      ## Specified VidPN present path content type is invalid.

    error_graphics_invalid_copyprotection_type* = 0xC026234F.HResult
      ## Specified VidPN present path copy protection type is invalid.

    error_graphics_unassigned_modeset_already_exists* = 0xC0262350.HResult
      ## No more than one unassigned mode set can exist at any given time for a given VidPN source/target.

    error_graphics_path_content_geometry_transformation_not_pinned* = 0x00262351.HResult
      ## Specified content transformation is not pinned on the specified VidPN present path.

    error_graphics_invalid_scanline_ordering* = 0xC0262352.HResult
      ## Specified scanline ordering type is invalid.

    error_graphics_topology_changes_not_allowed* = 0xC0262353.HResult
      ## Topology changes are not allowed for the specified VidPN.

    error_graphics_no_available_importance_ordinals* = 0xC0262354.HResult
      ## All available importance ordinals are already used in specified topology.

    error_graphics_incompatible_private_format* = 0xC0262355.HResult
      ## Specified primary surface has a different private format attribute than the current primary surface

    error_graphics_invalid_mode_pruning_algorithm* = 0xC0262356.HResult
      ## Specified mode pruning algorithm is invalid

    error_graphics_invalid_monitor_capability_origin* = 0xC0262357.HResult
      ## Specified monitor capability origin is invalid.

    error_graphics_invalid_monitor_frequencyrange_constraint* = 0xC0262358.HResult
      ## Specified monitor frequency range constraint is invalid.

    error_graphics_max_num_paths_reached* = 0xC0262359.HResult
      ## Maximum supported number of present paths has been reached.

    error_graphics_cancel_vidpn_topology_augmentation* = 0xC026235A.HResult
      ## Miniport requested that augmentation be cancelled for the specified source of the specified VidPN's topology.

    error_graphics_invalid_client_type* = 0xC026235B.HResult
      ## Specified client type was not recognized.

    error_graphics_clientvidpn_not_set* = 0xC026235C.HResult
      ## Client VidPN is not set on this adapter (e.g. no user mode initiated mode changes took place on this adapter yet).

    #
    # Port specific status codes {0x2400..0x24ff}
    #
    error_graphics_specified_child_already_connected* = 0xC0262400.HResult
      ## Specified display adapter child device already has an external device connected to it.    

    error_graphics_child_descriptor_not_supported* = 0xC0262401.HResult
      ## Specified display adapter child device does not support descriptor exposure.    

    error_graphics_unknown_child_status* = 0x4026242F.HResult
      ## Child device presence was not reliably detected.

    error_graphics_not_a_linked_adapter* = 0xC0262430.HResult
      ## The display adapter is not linked to any other adapters.

    error_graphics_leadlink_not_enumerated* = 0xC0262431.HResult
      ## Lead adapter in a linked configuration was not enumerated yet.

    error_graphics_chainlinks_not_enumerated* = 0xC0262432.HResult
      ## Some chain adapters in a linked configuration were not enumerated yet.

    error_graphics_adapter_chain_not_ready* = 0xC0262433.HResult
      ## The chain of linked adapters is not ready to start because of an unknown failure.

    error_graphics_chainlinks_not_started* = 0xC0262434.HResult
      ## An attempt was made to start a lead link display adapter when the chain links were not started yet.

    error_graphics_chainlinks_not_powered_on* = 0xC0262435.HResult
      ## An attempt was made to power up a lead link display adapter when the chain links were powered down.

    error_graphics_inconsistent_device_link_state* = 0xC0262436.HResult
      ## The adapter link was found to be in an inconsistent state. Not all adapters are in an expected PNP/Power state.

    error_graphics_leadlink_start_deferred* = 0x40262437.HResult
      ## Starting the leadlink adapter has been deferred temporarily.

    error_graphics_not_post_device_driver* = 0xC0262438.HResult
      ## The driver trying to start is not the same as the driver for the POSTed display adapter.

    error_graphics_polling_too_frequently* = 0x40262439.HResult
      ## The display adapter is being polled for children too frequently at the same polling level.

    error_graphics_start_deferred* =    0x4026243A.HResult
      ## Starting the adapter has been deferred temporarily.

    error_graphics_adapter_access_not_excluded* = 0xC026243B.HResult
      ## An operation is being attempted that requires the display adapter to be in a quiescent state.

    error_graphics_dependable_child_status* = 0x4026243C.HResult
      ## We can depend on the child device presence returned by the driver.

    #
    # OPM, UAB and PVP specific error codes {0x2500..0x257f}
    #
    error_graphics_opm_not_supported* = 0xC0262500.HResult
      ## The driver does not support OPM.    

    error_graphics_copp_not_supported* = 0xC0262501.HResult
      ## The driver does not support COPP.    

    error_graphics_uab_not_supported* = 0xC0262502.HResult
      ## The driver does not support UAB.    

    error_graphics_opm_invalid_encrypted_parameters* = 0xC0262503.HResult
      ## The specified encrypted parameters are invalid.    

    error_graphics_opm_no_video_outputs_exist* = 0xC0262505.HResult
      ## The GDI display device passed to this function does not have any active video outputs.

    error_graphics_opm_internal_error* = 0xC026250B.HResult
      ## An internal error caused this operation to fail.

    error_graphics_opm_invalid_handle* = 0xC026250C.HResult
      ## The function failed because the caller passed in an invalid OPM user mode handle.

    error_graphics_pvp_invalid_certificate_length* = 0xC026250E.HResult
      ## A certificate could not be returned because the certificate buffer passed to the function was too small.

    error_graphics_opm_spanning_mode_enabled* = 0xC026250F.HResult
      ## A video output could not be created because the frame buffer is in spanning mode.

    error_graphics_opm_theater_mode_enabled* = 0xC0262510.HResult
      ## A video output could not be created because the frame buffer is in theater mode.

    error_graphics_pvp_hfs_failed* =    0xC0262511.HResult
      ## The function failed because the display adapter's Hardware Functionality Scan failed to validate the graphics hardware.

    error_graphics_opm_invalid_srm* =   0xC0262512.HResult
      ## The HDCP System Renewability Message passed to this function did not comply with section 5 of the HDCP 1.1 specification.

    error_graphics_opm_output_does_not_support_hdcp* = 0xC0262513.HResult
      ## The video output cannot enable the High-bandwidth Digital Content Protection (HDCP) System because it does not support HDCP.

    error_graphics_opm_output_does_not_support_acp* = 0xC0262514.HResult
      ## The video output cannot enable Analogue Copy Protection (ACP) because it does not support ACP.

    error_graphics_opm_output_does_not_support_cgmsa* = 0xC0262515.HResult
      ## The video output cannot enable the Content Generation Management System Analogue (CGMS-A) protection technology because it does not support CGMS-A.

    error_graphics_opm_hdcp_srm_never_set* = 0xC0262516.HResult
      ## The IOPMVideoOutput::GetInformation method cannot return the version of the SRM being used because the application never successfully passed an SRM to the video output.

    error_graphics_opm_resolution_too_high* = 0xC0262517.HResult
      ## The IOPMVideoOutput::Configure method cannot enable the specified output protection technology because the output's screen resolution is too high.

    error_graphics_opm_all_hdcp_hardware_already_in_use* = 0xC0262518.HResult
      ## The IOPMVideoOutput::Configure method cannot enable HDCP because the display adapter's HDCP hardware is already being used by other physical outputs.

    error_graphics_opm_video_output_no_longer_exists* = 0xC026251A.HResult
      ## The operating system asynchronously destroyed this OPM video output because the operating system's state changed. This error typically occurs because the monitor PDO associated with this video output was removed, the monitor PDO associated with this video output was stopped, the video output's session became a non-console session or the video output's desktop became an inactive desktop.

    error_graphics_opm_session_type_change_in_progress* = 0xC026251B.HResult
      ## The method failed because the session is changing its type. No IOPMVideoOutput methods can be called when a session is changing its type. There are currently three types of sessions: console, disconnected and remote.

    error_graphics_opm_video_output_does_not_have_copp_semantics* = 0xC026251C.HResult
      ## Either the IOPMVideoOutput::COPPCompatibleGetInformation, IOPMVideoOutput::GetInformation, or IOPMVideoOutput::Configure method failed. This error is returned when the caller tries to use a COPP specific command while the video output has OPM semantics only.

    error_graphics_opm_invalid_information_request* = 0xC026251D.HResult
      ## The IOPMVideoOutput::GetInformation and IOPMVideoOutput::COPPCompatibleGetInformation methods return this error if the passed in sequence number is not the expected sequence number or the passed in OMAC value is invalid.

    error_graphics_opm_driver_internal_error* = 0xC026251E.HResult
      ## The method failed because an unexpected error occurred inside of a display driver.

    error_graphics_opm_video_output_does_not_have_opm_semantics* = 0xC026251F.HResult
      ## Either the IOPMVideoOutput::COPPCompatibleGetInformation, IOPMVideoOutput::GetInformation, or IOPMVideoOutput::Configure method failed. This error is returned when the caller tries to use an OPM specific command while the video output has COPP semantics only.

    error_graphics_opm_signaling_not_supported* = 0xC0262520.HResult
      ## The IOPMVideoOutput::COPPCompatibleGetInformation or IOPMVideoOutput::Configure method failed because the display driver does not support the OPM_GET_ACP_AND_CGMSA_SIGNALING and OPM_SET_ACP_AND_CGMSA_SIGNALING GUIDs.

    error_graphics_opm_invalid_configuration_request* = 0xC0262521.HResult
      ## The IOPMVideoOutput::Configure function returns this error code if the passed in sequence number is not the expected sequence number or the passed in OMAC value is invalid.

    #
    # Monitor Configuration API error codes {0x2580..0x25DF}
    #
    error_graphics_i2c_not_supported* = 0xC0262580.HResult
      ## The monitor connected to the specified video output does not have an I2C bus.    

    error_graphics_i2c_device_does_not_exist* = 0xC0262581.HResult
      ## No device on the I2C bus has the specified address.    

    error_graphics_i2c_error_transmitting_data* = 0xC0262582.HResult
      ## An error occurred while transmitting data to the device on the I2C bus.    

    error_graphics_i2c_error_receiving_data* = 0xC0262583.HResult
      ## An error occurred while receiving data from the device on the I2C bus.    

    error_graphics_ddcci_vcp_not_supported* = 0xC0262584.HResult
      ## The monitor does not support the specified VCP code.    

    error_graphics_ddcci_invalid_data* = 0xC0262585.HResult
      ## The data received from the monitor is invalid.    

    error_graphics_ddcci_monitor_returned_invalid_timing_status_byte* = 0xC0262586.HResult
      ## The function failed because a monitor returned an invalid Timing Status byte when the operating system used the DDC/CI Get Timing Report & Timing Message command to get a timing report from a monitor.

    error_graphics_mca_invalid_capabilities_string* = 0xC0262587.HResult
      ## The monitor returned a DDC/CI capabilities string which did not comply with the ACCESS.bus 3.0, DDC/CI 1.1, or MCCS 2 Revision 1 specification.

    error_graphics_mca_internal_error* = 0xC0262588.HResult
      ## An internal Monitor Configuration API error occurred.

    error_graphics_ddcci_invalid_message_command* = 0xC0262589.HResult
      ## An operation failed because a DDC/CI message had an invalid value in its command field.

    error_graphics_ddcci_invalid_message_length* = 0xC026258A.HResult
      ## An error occurred because the field length of a DDC/CI message contained an invalid value.

    error_graphics_ddcci_invalid_message_checksum* = 0xC026258B.HResult
      ## An error occurred because the checksum field in a DDC/CI message did not match the message's computed checksum value. This error implies that the data was corrupted while it was being transmitted from a monitor to a computer.

    error_graphics_invalid_physical_monitor_handle* = 0xC026258C.HResult
      ## This function failed because an invalid monitor handle was passed to it.

    error_graphics_monitor_no_longer_exists* = 0xC026258D.HResult
      ## The operating system asynchronously destroyed the monitor which corresponds to this handle because the operating system's state changed. This error typically occurs because the monitor PDO associated with this handle was removed, the monitor PDO associated with this handle was stopped, or a display mode change occurred. A display mode change occurs when windows sends a WM_DISPLAYCHANGE windows message to applications.

    error_graphics_ddcci_current_current_value_greater_than_maximum_value* = 0xC02625D8.HResult
      ## A continuous VCP code's current value is greater than its maximum value. This error code indicates that a monitor returned an invalid value.

    error_graphics_mca_invalid_vcp_version* = 0xC02625D9.HResult
      ## The monitor's VCP Version (0xDF) VCP code returned an invalid version value.

    error_graphics_mca_monitor_violates_mccs_specification* = 0xC02625DA.HResult
      ## The monitor does not comply with the MCCS specification it claims to support.

    error_graphics_mca_mccs_version_mismatch* = 0xC02625DB.HResult
      ## The MCCS version in a monitor's mccs_ver capability does not match the MCCS version the monitor reports when the VCP Version (0xDF) VCP code is used.

    error_graphics_mca_unsupported_mccs_version* = 0xC02625DC.HResult
      ## The Monitor Configuration API only works with monitors which support the MCCS 1.0 specification, MCCS 2.0 specification or the MCCS 2.0 Revision 1 specification.

    error_graphics_mca_invalid_technology_type_returned* = 0xC02625DE.HResult
      ## The monitor returned an invalid monitor technology type. CRT, Plasma and LCD (TFT) are examples of monitor technology types. This error implies that the monitor violated the MCCS 2.0 or MCCS 2.0 Revision 1 specification.

    error_graphics_mca_unsupported_color_temperature* = 0xC02625DF.HResult
      ## SetMonitorColorTemperature()'s caller passed a color temperature to it which the current monitor did not support. This error implies that the monitor violated the MCCS 2.0 or MCCS 2.0 Revision 1 specification.

    #
    # OPM, UAB, PVP and DDC/CI shared error codes {0x25E0..0x25ff}
    #
    error_graphics_only_console_session_supported* = 0xC02625E0.HResult
      ## This function can only be used if a program is running in the local console session. It cannot be used if the program is running on a remote desktop session or on a terminal server session.

    error_graphics_no_display_device_corresponds_to_name* = 0xC02625E1.HResult
      ## This function cannot find an actual GDI display device which corresponds to the specified GDI display device name.

    error_graphics_display_device_not_attached_to_desktop* = 0xC02625E2.HResult
      ## The function failed because the specified GDI display device was not attached to the Windows desktop.

    error_graphics_mirroring_devices_not_supported* = 0xC02625E3.HResult
      ## This function does not support GDI mirroring display devices because GDI mirroring display devices do not have any physical monitors associated with them.

    error_graphics_invalid_pointer* =   0xC02625E4.HResult
      ## The function failed because an invalid pointer parameter was passed to it. A pointer parameter is invalid if it is NULL, points to an invalid address, points to a kernel mode address, or is not correctly aligned.

    error_graphics_no_monitors_correspond_to_display_device* = 0xC02625E5.HResult
      ## The function failed because the specified GDI device did not have any monitors associated with it.

    error_graphics_parameter_array_too_small* = 0xC02625E6.HResult
      ## An array passed to the function cannot hold all of the data that the function must copy into the array.

    error_graphics_internal_error* =    0xC02625E7.HResult
      ## An internal error caused an operation to fail.

    error_graphics_session_type_change_in_progress* = 0xC02605E8.HResult
      ## The function failed because the current session is changing its type. This function cannot be called when the current session is changing its type. There are currently three types of sessions: console, disconnected and remote.


    # FACILITY_NAP

    nap_e_invalid_packet* =             0x80270001.HResult
      ## The NAP SoH packet is invalid.

    nap_e_missing_soh* =                0x80270002.HResult
      ## An SoH was missing from the NAP packet.

    nap_e_conflicting_id* =             0x80270003.HResult
      ## The entity ID conflicts with an already registered id.

    nap_e_no_cached_soh* =              0x80270004.HResult
      ## No cached SoH is present.

    nap_e_still_bound* =                0x80270005.HResult
      ## The entity is still bound to the NAP system.

    nap_e_not_registered* =             0x80270006.HResult
      ## The entity is not registered with the NAP system.

    nap_e_not_initialized* =            0x80270007.HResult
      ## The entity is not initialized with the NAP system.

    nap_e_mismatched_id* =              0x80270008.HResult
      ## The correlation id in the SoH-Request and SoH-Response do not match up.

    nap_e_not_pending* =                0x80270009.HResult
      ## Completion was indicated on a request that is not currently pending.

    nap_e_id_not_found* =               0x8027000A.HResult
      ## The NAP component's id was not found.

    nap_e_maxsize_too_small* =          0x8027000B.HResult
      ## The maximum size of the connection is too small for an SoH packet.

    nap_e_service_not_running* =        0x8027000C.HResult
      ## The NapAgent service is not running.

    nap_s_cert_already_present* =       0x0027000D.HResult
      ## A certificate is already present in the cert store.

    nap_e_entity_disabled* =            0x8027000E.HResult
      ## The entity is disabled with the NapAgent service.

    nap_e_netsh_grouppolicy_error* =    0x8027000F.HResult
      ## Group Policy is not configured.

    nap_e_too_many_calls* =             0x80270010.HResult
      ## Too many simultaneous calls.

    nap_e_shv_config_existed* =         0x80270011.HResult
      ## SHV configuration already existed.

    nap_e_shv_config_not_found* =       0x80270012.HResult
      ## SHV configuration is not found.

    nap_e_shv_timeout* =                0x80270013.HResult
      ## SHV timed out on the request.

    #
    # ===============================
    # TPM Services and TPM Software Error Messages
    # ===============================
    #
    # The TPM services and TPM software facilities are used by the various
    # TPM software components. There are two facilities because the services
    # errors are within the TCG-defined error space and the software errors
    # are not.
    #
    # The following are the subranges within the TPM Services facility.
    # The TPM hardware errors are defined in the document
    # TPM Main Specification 1.2 Part 2 TPM Structures.
    # The TBS errors are slotted into the TCG error namespace at the TBS layer.
    #
    # 0x0000 - 0x08ff     TPM hardware errors
    # 0x4000 - 0x40ff     TPM Base Services errors (tbssvc.dll)
    #
    # The following are the subranges within the TPM Software facility. The TBS
    # has two classes of errors - those that can be returned (the public errors,
    # defined in the TBS spec), which are in the TPM services facility,  and
    # those that are internal or implementation specific, which are here in the
    # TPM software facility.
    #
    # 0x0000 - 0x00ff     TPM device driver errors (tpm.sys)
    # 0x0100 - 0x01ff     TPM API errors (tpmapi.lib)
    # 0x0200 - 0x02ff     TBS internal errors (tbssvc.dll)
    # 0x0300 - 0x03ff     TPM Physical Presence errors
    #
    #
    # TPM hardware error codes {0x0000..0x08ff}
    # This space is further subdivided into hardware errors, vendor-specific
    # errors, and non-fatal errors.
    #
    #
    # TPM hardware errors {0x0000..0x003ff}
    #
    tpm_e_error_mask* =                 0x80280000.HResult
      ## This is an error mask to convert TPM hardware errors to win errors.

    tpm_e_authfail* =                   0x80280001.HResult
      ## Authentication failed.

    tpm_e_badindex* =                   0x80280002.HResult
      ## The index to a PCR, DIR or other register is incorrect.

    tpm_e_bad_parameter* =              0x80280003.HResult
      ## One or more parameter is bad.

    tpm_e_auditfailure* =               0x80280004.HResult
      ## An operation completed successfully but the auditing of that operation failed.

    tpm_e_clear_disabled* =             0x80280005.HResult
      ## The clear disable flag is set and all clear operations now require physical access.

    tpm_e_deactivated* =                0x80280006.HResult
      ## Activate the Trusted Platform Module (TPM).

    tpm_e_disabled* =                   0x80280007.HResult
      ## Enable the Trusted Platform Module (TPM).

    tpm_e_disabled_cmd* =               0x80280008.HResult
      ## The target command has been disabled.

    tpm_e_fail* =                       0x80280009.HResult
      ## The operation failed.

    tpm_e_bad_ordinal* =                0x8028000A.HResult
      ## The ordinal was unknown or inconsistent.

    tpm_e_install_disabled* =           0x8028000B.HResult
      ## The ability to install an owner is disabled.

    tpm_e_invalid_keyhandle* =          0x8028000C.HResult
      ## The key handle cannot be interpreted.

    tpm_e_keynotfound* =                0x8028000D.HResult
      ## The key handle points to an invalid key.

    tpm_e_inappropriate_enc* =          0x8028000E.HResult
      ## Unacceptable encryption scheme.

    tpm_e_migratefail* =                0x8028000F.HResult
      ## Migration authorization failed.

    tpm_e_invalid_pcr_info* =           0x80280010.HResult
      ## PCR information could not be interpreted.

    tpm_e_nospace* =                    0x80280011.HResult
      ## No room to load key.

    tpm_e_nosrk* =                      0x80280012.HResult
      ## There is no Storage Root Key (SRK) set.

    tpm_e_notsealed_blob* =             0x80280013.HResult
      ## An encrypted blob is invalid or was not created by this TPM.

    tpm_e_owner_set* =                  0x80280014.HResult
      ## The Trusted Platform Module (TPM) already has an owner.

    tpm_e_resources* =                  0x80280015.HResult
      ## The TPM has insufficient internal resources to perform the requested action.

    tpm_e_shortrandom* =                0x80280016.HResult
      ## A random string was too short.

    tpm_e_size* =                       0x80280017.HResult
      ## The TPM does not have the space to perform the operation.

    tpm_e_wrongpcrval* =                0x80280018.HResult
      ## The named PCR value does not match the current PCR value.

    tpm_e_bad_param_size* =             0x80280019.HResult
      ## The paramSize argument to the command has the incorrect value .

    tpm_e_sha_thread* =                 0x8028001A.HResult
      ## There is no existing SHA-1 thread.

    tpm_e_sha_error* =                  0x8028001B.HResult
      ## The calculation is unable to proceed because the existing SHA-1 thread has already encountered an error.

    tpm_e_failedselftest* =             0x8028001C.HResult
      ## The TPM hardware device reported a failure during its internal self test. Try restarting the computer to resolve the problem. If the problem continues, check for the latest BIOS or firmware update for your TPM hardware. Consult the computer manufacturer's documentation for instructions.

    tpm_e_auth2fail* =                  0x8028001D.HResult
      ## The authorization for the second key in a 2 key function failed authorization.

    tpm_e_badtag* =                     0x8028001E.HResult
      ## The tag value sent to for a command is invalid.

    tpm_e_ioerror* =                    0x8028001F.HResult
      ## An IO error occurred transmitting information to the TPM.

    tpm_e_encrypt_error* =              0x80280020.HResult
      ## The encryption process had a problem.

    tpm_e_decrypt_error* =              0x80280021.HResult
      ## The decryption process did not complete.

    tpm_e_invalid_authhandle* =         0x80280022.HResult
      ## An invalid handle was used.

    tpm_e_no_endorsement* =             0x80280023.HResult
      ## The TPM does not have an Endorsement Key (EK) installed.

    tpm_e_invalid_keyusage* =           0x80280024.HResult
      ## The usage of a key is not allowed.

    tpm_e_wrong_entitytype* =           0x80280025.HResult
      ## The submitted entity type is not allowed.

    tpm_e_invalid_postinit* =           0x80280026.HResult
      ## The command was received in the wrong sequence relative to TPM_Init and a subsequent TPM_Startup.

    tpm_e_inappropriate_sig* =          0x80280027.HResult
      ## Signed data cannot include additional DER information.

    tpm_e_bad_key_property* =           0x80280028.HResult
      ## The key properties in TPM_KEY_PARMs are not supported by this TPM.

    tpm_e_bad_migration* =              0x80280029.HResult
      ## The migration properties of this key are incorrect.

    tpm_e_bad_scheme* =                 0x8028002A.HResult
      ## The signature or encryption scheme for this key is incorrect or not permitted in this situation.

    tpm_e_bad_datasize* =               0x8028002B.HResult
      ## The size of the data (or blob) parameter is bad or inconsistent with the referenced key.

    tpm_e_bad_mode* =                   0x8028002C.HResult
      ## A mode parameter is bad, such as capArea or subCapArea for TPM_GetCapability, phsicalPresence parameter for TPM_PhysicalPresence, or migrationType for TPM_CreateMigrationBlob.

    tpm_e_bad_presence* =               0x8028002D.HResult
      ## Either the physicalPresence or physicalPresenceLock bits have the wrong value.

    tpm_e_bad_version* =                0x8028002E.HResult
      ## The TPM cannot perform this version of the capability.

    tpm_e_no_wrap_transport* =          0x8028002F.HResult
      ## The TPM does not allow for wrapped transport sessions.

    tpm_e_auditfail_unsuccessful* =     0x80280030.HResult
      ## TPM audit construction failed and the underlying command was returning a failure code also.

    tpm_e_auditfail_successful* =       0x80280031.HResult
      ## TPM audit construction failed and the underlying command was returning success.

    tpm_e_notresetable* =               0x80280032.HResult
      ## Attempt to reset a PCR register that does not have the resettable attribute.

    tpm_e_notlocal* =                   0x80280033.HResult
      ## Attempt to reset a PCR register that requires locality and locality modifier not part of command transport.

    tpm_e_bad_type* =                   0x80280034.HResult
      ## Make identity blob not properly typed.

    tpm_e_invalid_resource* =           0x80280035.HResult
      ## When saving context identified resource type does not match actual resource.

    tpm_e_notfips* =                    0x80280036.HResult
      ## The TPM is attempting to execute a command only available when in FIPS mode.

    tpm_e_invalid_family* =             0x80280037.HResult
      ## The command is attempting to use an invalid family ID.

    tpm_e_no_nv_permission* =           0x80280038.HResult
      ## The permission to manipulate the NV storage is not available.

    tpm_e_requires_sign* =              0x80280039.HResult
      ## The operation requires a signed command.

    tpm_e_key_notsupported* =           0x8028003A.HResult
      ## Wrong operation to load an NV key.

    tpm_e_auth_conflict* =              0x8028003B.HResult
      ## NV_LoadKey blob requires both owner and blob authorization.

    tpm_e_area_locked* =                0x8028003C.HResult
      ## The NV area is locked and not writtable.

    tpm_e_bad_locality* =               0x8028003D.HResult
      ## The locality is incorrect for the attempted operation.

    tpm_e_read_only* =                  0x8028003E.HResult
      ## The NV area is read only and can't be written to.

    tpm_e_per_nowrite* =                0x8028003F.HResult
      ## There is no protection on the write to the NV area.

    tpm_e_familycount* =                0x80280040.HResult
      ## The family count value does not match.

    tpm_e_write_locked* =               0x80280041.HResult
      ## The NV area has already been written to.

    tpm_e_bad_attributes* =             0x80280042.HResult
      ## The NV area attributes conflict.

    tpm_e_invalid_structure* =          0x80280043.HResult
      ## The structure tag and version are invalid or inconsistent.

    tpm_e_key_owner_control* =          0x80280044.HResult
      ## The key is under control of the TPM Owner and can only be evicted by the TPM Owner.

    tpm_e_bad_counter* =                0x80280045.HResult
      ## The counter handle is incorrect.

    tpm_e_not_fullwrite* =              0x80280046.HResult
      ## The write is not a complete write of the area.

    tpm_e_context_gap* =                0x80280047.HResult
      ## The gap between saved context counts is too large.

    tpm_e_maxnvwrites* =                0x80280048.HResult
      ## The maximum number of NV writes without an owner has been exceeded.

    tpm_e_nooperator* =                 0x80280049.HResult
      ## No operator AuthData value is set.

    tpm_e_resourcemissing* =            0x8028004A.HResult
      ## The resource pointed to by context is not loaded.

    tpm_e_delegate_lock* =              0x8028004B.HResult
      ## The delegate administration is locked.

    tpm_e_delegate_family* =            0x8028004C.HResult
      ## Attempt to manage a family other then the delegated family.

    tpm_e_delegate_admin* =             0x8028004D.HResult
      ## Delegation table management not enabled.

    tpm_e_transport_notexclusive* =     0x8028004E.HResult
      ## There was a command executed outside of an exclusive transport session.

    tpm_e_owner_control* =              0x8028004F.HResult
      ## Attempt to context save a owner evict controlled key.

    tpm_e_daa_resources* =              0x80280050.HResult
      ## The DAA command has no resources availble to execute the command.

    tpm_e_daa_input_data0* =            0x80280051.HResult
      ## The consistency check on DAA parameter inputData0 has failed.

    tpm_e_daa_input_data1* =            0x80280052.HResult
      ## The consistency check on DAA parameter inputData1 has failed.

    tpm_e_daa_issuer_settings* =        0x80280053.HResult
      ## The consistency check on DAA_issuerSettings has failed.

    tpm_e_daa_tpm_settings* =           0x80280054.HResult
      ## The consistency check on DAA_tpmSpecific has failed.

    tpm_e_daa_stage* =                  0x80280055.HResult
      ## The atomic process indicated by the submitted DAA command is not the expected process.

    tpm_e_daa_issuer_validity* =        0x80280056.HResult
      ## The issuer's validity check has detected an inconsistency.

    tpm_e_daa_wrong_w* =                0x80280057.HResult
      ## The consistency check on w has failed.

    tpm_e_bad_handle* =                 0x80280058.HResult
      ## The handle is incorrect.

    tpm_e_bad_delegate* =               0x80280059.HResult
      ## Delegation is not correct.

    tpm_e_badcontext* =                 0x8028005A.HResult
      ## The context blob is invalid.

    tpm_e_toomanycontexts* =            0x8028005B.HResult
      ## Too many contexts held by the TPM.

    tpm_e_ma_ticket_signature* =        0x8028005C.HResult
      ## Migration authority signature validation failure.

    tpm_e_ma_destination* =             0x8028005D.HResult
      ## Migration destination not authenticated.

    tpm_e_ma_source* =                  0x8028005E.HResult
      ## Migration source incorrect.

    tpm_e_ma_authority* =               0x8028005F.HResult
      ## Incorrect migration authority.

    tpm_e_permanentek* =                0x80280061.HResult
      ## Attempt to revoke the EK and the EK is not revocable.

    tpm_e_bad_signature* =              0x80280062.HResult
      ## Bad signature of CMK ticket.

    tpm_e_nocontextspace* =             0x80280063.HResult
      ## There is no room in the context list for additional contexts.

    #
    # TPM vendor specific hardware errors {0x0400..0x04ff}
    #
    tpm_e_command_blocked* =            0x80280400.HResult
      ## The command was blocked.

    tpm_e_invalid_handle* =             0x80280401.HResult
      ## The specified handle was not found.

    tpm_e_duplicate_vhandle* =          0x80280402.HResult
      ## The TPM returned a duplicate handle and the command needs to be resubmitted.

    tpm_e_embedded_command_blocked* =   0x80280403.HResult
      ## The command within the transport was blocked.

    tpm_e_embedded_command_unsupported* = 0x80280404.HResult
      ## The command within the transport is not supported.

    #
    # TPM non-fatal hardware errors {0x0800..0x08ff}
    #
    tpm_e_retry* =                      0x80280800.HResult
      ## The TPM is too busy to respond to the command immediately, but the command could be resubmitted at a later time.

    tpm_e_needs_selftest* =             0x80280801.HResult
      ## SelfTestFull has not been run.

    tpm_e_doing_selftest* =             0x80280802.HResult
      ## The TPM is currently executing a full selftest.

    tpm_e_defend_lock_running* =        0x80280803.HResult
      ## The TPM is defending against dictionary attacks and is in a time-out period.

    #
    # TPM Base Services error codes {0x4000..0x40ff}
    #
    tbs_e_internal_error* =             0x80284001.HResult
      ## An internal error has occurred within the Trusted Platform Module support program.

    tbs_e_bad_parameter* =              0x80284002.HResult
      ## One or more input parameters is bad.

    tbs_e_invalid_output_pointer* =     0x80284003.HResult
      ## A specified output pointer is bad.

    tbs_e_invalid_context* =            0x80284004.HResult
      ## The specified context handle does not refer to a valid context.

    tbs_e_insufficient_buffer* =        0x80284005.HResult
      ## A specified output buffer is too small.

    tbs_e_ioerror* =                    0x80284006.HResult
      ## An error occurred while communicating with the TPM.

    tbs_e_invalid_context_param* =      0x80284007.HResult
      ## One or more context parameters is invalid.

    tbs_e_service_not_running* =        0x80284008.HResult
      ## The TBS service is not running and could not be started.

    tbs_e_too_many_tbs_contexts* =      0x80284009.HResult
      ## A new context could not be created because there are too many open contexts.

    tbs_e_too_many_resources* =         0x8028400A.HResult
      ## A new virtual resource could not be created because there are too many open virtual resources.

    tbs_e_service_start_pending* =      0x8028400B.HResult
      ## The TBS service has been started but is not yet running.

    tbs_e_ppi_not_supported* =          0x8028400C.HResult
      ## The physical presence interface is not supported.

    tbs_e_command_canceled* =           0x8028400D.HResult
      ## The command was canceled.

    tbs_e_buffer_too_large* =           0x8028400E.HResult
      ## The input or output buffer is too large.

    tbs_e_tpm_not_found* =              0x8028400F.HResult
      ## A compatible Trusted Platform Module (TPM) Security Device cannot be found on this computer.

    tbs_e_service_disabled* =           0x80284010.HResult
      ## The TBS service has been disabled.

    tbs_e_no_event_log* =               0x80284011.HResult
      ## No TCG event log is available.

    tbs_e_access_denied* =              0x80284012.HResult
      ## The caller does not have the appropriate rights to perform the requested operation.

    tbs_e_provisioning_not_allowed* =   0x80284013.HResult
      ## The TPM provisioning action is not allowed by the specified flags.  For provisioning to be successful, one of several actions may be required.  The TPM management console (tpm.msc) action to make the TPM Ready may help.  For further information, see the documentation for the Win32_Tpm WMI method 'Provision'.  (The actions that may be required include importing the TPM Owner Authorization value into the system, calling the Win32_Tpm WMI method for provisioning the TPM and specifying TRUE for either 'ForceClear_Allowed' or 'PhysicalPresencePrompts_Allowed' (as indicated by the value returned in the Additional Information), or enabling the TPM in the system BIOS.)

    tbs_e_ppi_function_unsupported* =   0x80284014.HResult
      ## The Physical Presence Interface of this firmware does not support the requested method.

    tbs_e_ownerauth_not_found* =        0x80284015.HResult
      ## The requested TPM OwnerAuth value was not found.

    tbs_e_provisioning_incomplete* =    0x80284016.HResult
      ## The TPM provisioning did not complete.  For more information on completing the provisioning, call the Win32_Tpm WMI method for provisioning the TPM ('Provision') and check the returned Information.

    #
    # TPM API error codes {0x0100..0x01ff}
    #
    tpmapi_e_invalid_state* =           0x80290100.HResult
      ## The command buffer is not in the correct state.

    tpmapi_e_not_enough_data* =         0x80290101.HResult
      ## The command buffer does not contain enough data to satisfy the request.

    tpmapi_e_too_much_data* =           0x80290102.HResult
      ## The command buffer cannot contain any more data.

    tpmapi_e_invalid_output_pointer* =  0x80290103.HResult
      ## One or more output parameters was NULL or invalid.

    tpmapi_e_invalid_parameter* =       0x80290104.HResult
      ## One or more input parameters is invalid.

    tpmapi_e_out_of_memory* =           0x80290105.HResult
      ## Not enough memory was available to satisfy the request.

    tpmapi_e_buffer_too_small* =        0x80290106.HResult
      ## The specified buffer was too small.

    tpmapi_e_internal_error* =          0x80290107.HResult
      ## An internal error was detected.

    tpmapi_e_access_denied* =           0x80290108.HResult
      ## The caller does not have the appropriate rights to perform the requested operation.

    tpmapi_e_authorization_failed* =    0x80290109.HResult
      ## The specified authorization information was invalid.

    tpmapi_e_invalid_context_handle* =  0x8029010A.HResult
      ## The specified context handle was not valid.

    tpmapi_e_tbs_communication_error* = 0x8029010B.HResult
      ## An error occurred while communicating with the TBS.

    tpmapi_e_tpm_command_error* =       0x8029010C.HResult
      ## The TPM returned an unexpected result.

    tpmapi_e_message_too_large* =       0x8029010D.HResult
      ## The message was too large for the encoding scheme.

    tpmapi_e_invalid_encoding* =        0x8029010E.HResult
      ## The encoding in the blob was not recognized.

    tpmapi_e_invalid_key_size* =        0x8029010F.HResult
      ## The key size is not valid.

    tpmapi_e_encryption_failed* =       0x80290110.HResult
      ## The encryption operation failed.

    tpmapi_e_invalid_key_params* =      0x80290111.HResult
      ## The key parameters structure was not valid

    tpmapi_e_invalid_migration_authorization_blob* = 0x80290112.HResult
      ## The requested supplied data does not appear to be a valid migration authorization blob.

    tpmapi_e_invalid_pcr_index* =       0x80290113.HResult
      ## The specified PCR index was invalid

    tpmapi_e_invalid_delegate_blob* =   0x80290114.HResult
      ## The data given does not appear to be a valid delegate blob.

    tpmapi_e_invalid_context_params* =  0x80290115.HResult
      ## One or more of the specified context parameters was not valid.

    tpmapi_e_invalid_key_blob* =        0x80290116.HResult
      ## The data given does not appear to be a valid key blob

    tpmapi_e_invalid_pcr_data* =        0x80290117.HResult
      ## The specified PCR data was invalid.

    tpmapi_e_invalid_owner_auth* =      0x80290118.HResult
      ## The format of the owner auth data was invalid.

    tpmapi_e_fips_rng_check_failed* =   0x80290119.HResult
      ## The random number generated did not pass FIPS RNG check.

    tpmapi_e_empty_tcg_log* =           0x8029011A.HResult
      ## The TCG Event Log does not contain any data.

    tpmapi_e_invalid_tcg_log_entry* =   0x8029011B.HResult
      ## An entry in the TCG Event Log was invalid.

    tpmapi_e_tcg_separator_absent* =    0x8029011C.HResult
      ## A TCG Separator was not found.

    tpmapi_e_tcg_invalid_digest_entry* = 0x8029011D.HResult
      ## A digest value in a TCG Log entry did not match hashed data.

    tpmapi_e_policy_denies_operation* = 0x8029011E.HResult
      ## The requested operation was blocked by current TPM policy. Please contact your system administrator for assistance.

    #
    # TBS implementation error codes {0x0200..0x02ff}
    #
    tbsimp_e_buffer_too_small* =        0x80290200.HResult
      ## The specified buffer was too small.

    tbsimp_e_cleanup_failed* =          0x80290201.HResult
      ## The context could not be cleaned up.

    tbsimp_e_invalid_context_handle* =  0x80290202.HResult
      ## The specified context handle is invalid.

    tbsimp_e_invalid_context_param* =   0x80290203.HResult
      ## An invalid context parameter was specified.

    tbsimp_e_tpm_error* =               0x80290204.HResult
      ## An error occurred while communicating with the TPM

    tbsimp_e_hash_bad_key* =            0x80290205.HResult
      ## No entry with the specified key was found.

    tbsimp_e_duplicate_vhandle* =       0x80290206.HResult
      ## The specified virtual handle matches a virtual handle already in use.

    tbsimp_e_invalid_output_pointer* =  0x80290207.HResult
      ## The pointer to the returned handle location was NULL or invalid

    tbsimp_e_invalid_parameter* =       0x80290208.HResult
      ## One or more parameters is invalid

    tbsimp_e_rpc_init_failed* =         0x80290209.HResult
      ## The RPC subsystem could not be initialized.

    tbsimp_e_scheduler_not_running* =   0x8029020A.HResult
      ## The TBS scheduler is not running.

    tbsimp_e_command_canceled* =        0x8029020B.HResult
      ## The command was canceled.

    tbsimp_e_out_of_memory* =           0x8029020C.HResult
      ## There was not enough memory to fulfill the request

    tbsimp_e_list_no_more_items* =      0x8029020D.HResult
      ## The specified list is empty, or the iteration has reached the end of the list.

    tbsimp_e_list_not_found* =          0x8029020E.HResult
      ## The specified item was not found in the list.

    tbsimp_e_not_enough_space* =        0x8029020F.HResult
      ## The TPM does not have enough space to load the requested resource.

    tbsimp_e_not_enough_tpm_contexts* = 0x80290210.HResult
      ## There are too many TPM contexts in use.

    tbsimp_e_command_failed* =          0x80290211.HResult
      ## The TPM command failed.

    tbsimp_e_unknown_ordinal* =         0x80290212.HResult
      ## The TBS does not recognize the specified ordinal.

    tbsimp_e_resource_expired* =        0x80290213.HResult
      ## The requested resource is no longer available.

    tbsimp_e_invalid_resource* =        0x80290214.HResult
      ## The resource type did not match.

    tbsimp_e_nothing_to_unload* =       0x80290215.HResult
      ## No resources can be unloaded.

    tbsimp_e_hash_table_full* =         0x80290216.HResult
      ## No new entries can be added to the hash table.

    tbsimp_e_too_many_tbs_contexts* =   0x80290217.HResult
      ## A new TBS context could not be created because there are too many open contexts.

    tbsimp_e_too_many_resources* =      0x80290218.HResult
      ## A new virtual resource could not be created because there are too many open virtual resources.

    tbsimp_e_ppi_not_supported* =       0x80290219.HResult
      ## The physical presence interface is not supported.

    tbsimp_e_tpm_incompatible* =        0x8029021A.HResult
      ## TBS is not compatible with the version of TPM found on the system.

    tbsimp_e_no_event_log* =            0x8029021B.HResult
      ## No TCG event log is available.

    #
    # TPM Physical Presence implementation error codes {0x0300..0x03ff}
    #
    tpm_e_ppi_acpi_failure* =           0x80290300.HResult
      ## A general error was detected when attempting to acquire the BIOS's response to a Physical Presence command.

    tpm_e_ppi_user_abort* =             0x80290301.HResult
      ## The user failed to confirm the TPM operation request.

    tpm_e_ppi_bios_failure* =           0x80290302.HResult
      ## The BIOS failure prevented the successful execution of the requested TPM operation (e.g. invalid TPM operation request, BIOS communication error with the TPM).

    tpm_e_ppi_not_supported* =          0x80290303.HResult
      ## The BIOS does not support the physical presence interface.

    tpm_e_ppi_blocked_in_bios* =        0x80290304.HResult
      ## The Physical Presence command was blocked by current BIOS settings. The system owner may be able to reconfigure the BIOS settings to allow the command.

    #
    # Platform Crypto Provider (PCPTPM12.dll and future platform crypto providers)  error codes {0x0400..0x04ff}
    #
    tpm_e_pcp_error_mask* =             0x80290400.HResult
      ## This is an error mask to convert Platform Crypto Provider errors to win errors.

    tpm_e_pcp_device_not_ready* =       0x80290401.HResult
      ## The Platform Crypto Device is currently not ready. It needs to be fully provisioned to be operational.

    tpm_e_pcp_invalid_handle* =         0x80290402.HResult
      ## The handle provided to the Platform Crypto Provider is invalid.

    tpm_e_pcp_invalid_parameter* =      0x80290403.HResult
      ## A parameter provided to the Platform Crypto Provider is invalid.

    tpm_e_pcp_flag_not_supported* =     0x80290404.HResult
      ## A provided flag to the Platform Crypto Provider is not supported.

    tpm_e_pcp_not_supported* =          0x80290405.HResult
      ## The requested operation is not supported by this Platform Crypto Provider.

    tpm_e_pcp_buffer_too_small* =       0x80290406.HResult
      ## The buffer is too small to contain all data. No information has been written to the buffer.

    tpm_e_pcp_internal_error* =         0x80290407.HResult
      ## An unexpected internal error has occurred in the Platform Crypto Provider.

    tpm_e_pcp_authentication_failed* =  0x80290408.HResult
      ## The authorization to use a provider object has failed.

    tpm_e_pcp_authentication_ignored* = 0x80290409.HResult
      ## The Platform Crypto Device has ignored the authorization for the provider object, to mitigate against a dictionary attack.

    tpm_e_pcp_policy_not_found* =       0x8029040A.HResult
      ## The referenced policy was not found.

    tpm_e_pcp_profile_not_found* =      0x8029040B.HResult
      ## The referenced profile was not found.

    tpm_e_pcp_validation_failed* =      0x8029040C.HResult
      ## The validation was not succesful.

    #
    # If the application is designed to use TCG defined TPM return codes
    # then undefine the Windows defined codes for the same symbols. The application
    # declares usage of TCG return codes by defining WIN_OMIT_TSS_TPM_RETURN_CODES
    # before including windows.h
    #
  #ifdef WIN_OMIT_TSS_TPM_RETURN_CODES
  #undef TPM_E_AREA_LOCKED
  #undef TPM_E_AUDITFAILURE
  #undef TPM_E_AUDITFAIL_SUCCESSFUL
  #undef TPM_E_AUDITFAIL_UNSUCCESSFUL
  #undef TPM_E_AUTH2FAIL
  #undef TPM_E_AUTHFAIL
  #undef TPM_E_AUTH_CONFLICT
  #undef TPM_E_BADCONTEXT
  #undef TPM_E_BADINDEX
  #undef TPM_E_BADTAG
  #undef TPM_E_BAD_ATTRIBUTES
  #undef TPM_E_BAD_COUNTER
  #undef TPM_E_BAD_DATASIZE
  #undef TPM_E_BAD_DELEGATE
  #undef TPM_E_BAD_HANDLE
  #undef TPM_E_BAD_KEY_PROPERTY
  #undef TPM_E_BAD_LOCALITY
  #undef TPM_E_BAD_MIGRATION
  #undef TPM_E_BAD_MODE
  #undef TPM_E_BAD_ORDINAL
  #undef TPM_E_BAD_PARAMETER
  #undef TPM_E_BAD_PARAM_SIZE
  #undef TPM_E_BAD_PRESENCE
  #undef TPM_E_BAD_SCHEME
  #undef TPM_E_BAD_SIGNATURE
  #undef TPM_E_BAD_TYPE
  #undef TPM_E_BAD_VERSION
  #undef TPM_E_CLEAR_DISABLED
  #undef TPM_E_CONTEXT_GAP
  #undef TPM_E_DAA_INPUT_DATA0
  #undef TPM_E_DAA_INPUT_DATA1
  #undef TPM_E_DAA_ISSUER_SETTINGS
  #undef TPM_E_DAA_ISSUER_VALIDITY
  #undef TPM_E_DAA_RESOURCES
  #undef TPM_E_DAA_STAGE
  #undef TPM_E_DAA_TPM_SETTINGS
  #undef TPM_E_DAA_WRONG_W
  #undef TPM_E_DEACTIVATED
  #undef TPM_E_DECRYPT_ERROR
  #undef TPM_E_DEFEND_LOCK_RUNNING
  #undef TPM_E_DELEGATE_ADMIN
  #undef TPM_E_DELEGATE_FAMILY
  #undef TPM_E_DELEGATE_LOCK
  #undef TPM_E_DISABLED
  #undef TPM_E_DISABLED_CMD
  #undef TPM_E_DOING_SELFTEST
  #undef TPM_E_ENCRYPT_ERROR
  #undef TPM_E_FAIL
  #undef TPM_E_FAILEDSELFTEST
  #undef TPM_E_FAMILYCOUNT
  #undef TPM_E_INAPPROPRIATE_ENC
  #undef TPM_E_INAPPROPRIATE_SIG
  #undef TPM_E_INSTALL_DISABLED
  #undef TPM_E_INVALID_AUTHHANDLE
  #undef TPM_E_INVALID_FAMILY
  #undef TPM_E_INVALID_KEYHANDLE
  #undef TPM_E_INVALID_KEYUSAGE
  #undef TPM_E_INVALID_PCR_INFO
  #undef TPM_E_INVALID_POSTINIT
  #undef TPM_E_INVALID_RESOURCE
  #undef TPM_E_INVALID_STRUCTURE
  #undef TPM_E_IOERROR
  #undef TPM_E_KEYNOTFOUND
  #undef TPM_E_KEY_NOTSUPPORTED
  #undef TPM_E_KEY_OWNER_CONTROL
  #undef TPM_E_MAXNVWRITES
  #undef TPM_E_MA_AUTHORITY
  #undef TPM_E_MA_DESTINATION
  #undef TPM_E_MA_SOURCE
  #undef TPM_E_MA_TICKET_SIGNATURE
  #undef TPM_E_MIGRATEFAIL
  #undef TPM_E_NEEDS_SELFTEST
  #undef TPM_E_NOCONTEXTSPACE
  #undef TPM_E_NOOPERATOR
  #undef TPM_E_NOSPACE
  #undef TPM_E_NOSRK
  #undef TPM_E_NOTFIPS
  #undef TPM_E_NOTLOCAL
  #undef TPM_E_NOTRESETABLE
  #undef TPM_E_NOTSEALED_BLOB
  #undef TPM_E_NOT_FULLWRITE
  #undef TPM_E_NO_ENDORSEMENT
  #undef TPM_E_NO_NV_PERMISSION
  #undef TPM_E_NO_WRAP_TRANSPORT
  #undef TPM_E_OWNER_CONTROL
  #undef TPM_E_OWNER_SET
  #undef TPM_E_PERMANENTEK
  #undef TPM_E_PER_NOWRITE
  #undef TPM_E_READ_ONLY
  #undef TPM_E_REQUIRES_SIGN
  #undef TPM_E_RESOURCEMISSING
  #undef TPM_E_RESOURCES
  #undef TPM_E_RETRY
  #undef TPM_E_SHA_ERROR
  #undef TPM_E_SHA_THREAD
  #undef TPM_E_SHORTRANDOM
  #undef TPM_E_SIZE
  #undef TPM_E_TOOMANYCONTEXTS
  #undef TPM_E_TRANSPORT_NOTEXCLUSIVE
  #undef TPM_E_WRITE_LOCKED
  #undef TPM_E_WRONGPCRVAL
  #undef TPM_E_WRONG_ENTITYTYPE
  #undef TPM_SUCCESS
  #endif
    #
    # =======================================================
    # Facility Performance Logs & Alerts (PLA) Error Messages
    # =======================================================
    #
    pla_e_dcs_not_found* =              0x80300002.HResult
      ## Data Collector Set was not found.

    pla_e_dcs_in_use* =                 0x803000AA.HResult
      ## The Data Collector Set or one of its dependencies is already in use.

    pla_e_too_many_folders* =           0x80300045.HResult
      ## Unable to start Data Collector Set because there are too many folders.

    pla_e_no_min_disk* =                0x80300070.HResult
      ## Not enough free disk space to start Data Collector Set.

    pla_e_dcs_already_exists* =         0x803000B7.HResult
      ## Data Collector Set already exists.

    pla_s_property_ignored* =           0x00300100.HResult
      ## Property value will be ignored.

    pla_e_property_conflict* =          0x80300101.HResult
      ## Property value conflict.

    pla_e_dcs_singleton_required* =     0x80300102.HResult
      ## The current configuration for this Data Collector Set requires that it contain exactly one Data Collector.

    pla_e_credentials_required* =       0x80300103.HResult
      ## A user account is required in order to commit the current Data Collector Set properties.

    pla_e_dcs_not_running* =            0x80300104.HResult
      ## Data Collector Set is not running.

    pla_e_conflict_incl_excl_api* =     0x80300105.HResult
      ## A conflict was detected in the list of include/exclude APIs. Do not specify the same API in both the include list and the exclude list.

    pla_e_network_exe_not_valid* =      0x80300106.HResult
      ## The executable path you have specified refers to a network share or UNC path.

    pla_e_exe_already_configured* =     0x80300107.HResult
      ## The executable path you have specified is already configured for API tracing.

    pla_e_exe_path_not_valid* =         0x80300108.HResult
      ## The executable path you have specified does not exist. Verify that the specified path is correct.

    pla_e_dc_already_exists* =          0x80300109.HResult
      ## Data Collector already exists.

    pla_e_dcs_start_wait_timeout* =     0x8030010A.HResult
      ## The wait for the Data Collector Set start notification has timed out.

    pla_e_dc_start_wait_timeout* =      0x8030010B.HResult
      ## The wait for the Data Collector to start has timed out.

    pla_e_report_wait_timeout* =        0x8030010C.HResult
      ## The wait for the report generation tool to finish has timed out.

    pla_e_no_duplicates* =              0x8030010D.HResult
      ## Duplicate items are not allowed.

    pla_e_exe_full_path_required* =     0x8030010E.HResult
      ## When specifying the executable that you want to trace, you must specify a full path to the executable and not just a filename.

    pla_e_invalid_session_name* =       0x8030010F.HResult
      ## The session name provided is invalid.

    pla_e_pla_channel_not_enabled* =    0x80300110.HResult
      ## The Event Log channel Microsoft-Windows-Diagnosis-PLA/Operational must be enabled to perform this operation.

    pla_e_tasksched_channel_not_enabled* = 0x80300111.HResult
      ## The Event Log channel Microsoft-Windows-TaskScheduler must be enabled to perform this operation.

    pla_e_rules_manager_failed* =       0x80300112.HResult
      ## The execution of the Rules Manager failed.

    pla_e_cabapi_failure* =             0x80300113.HResult
      ## An error occurred while attempting to compress or extract the data.

    #
    # =======================================================
    # Full Volume Encryption Error Messages
    # =======================================================
    #
    fve_e_locked_volume* =              0x80310000.HResult
      ## This drive is locked by BitLocker Drive Encryption. You must unlock this drive from Control Panel.

    fve_e_not_encrypted* =              0x80310001.HResult
      ## This drive is not encrypted.

    fve_e_no_tpm_bios* =                0x80310002.HResult
      ## The BIOS did not correctly communicate with the Trusted Platform Module (TPM). Contact the computer manufacturer for BIOS upgrade instructions.

    fve_e_no_mbr_metric* =              0x80310003.HResult
      ## The BIOS did not correctly communicate with the master boot record (MBR). Contact the computer manufacturer for BIOS upgrade instructions.

    fve_e_no_bootsector_metric* =       0x80310004.HResult
      ## A required TPM measurement is missing. If there is a bootable CD or DVD in your computer, remove it, restart the computer, and turn on BitLocker again. If the problem persists, ensure the master boot record is up to date.

    fve_e_no_bootmgr_metric* =          0x80310005.HResult
      ## The boot sector of this drive is not compatible with BitLocker Drive Encryption. Use the Bootrec.exe tool in the Windows Recovery Environment to update or repair the boot manager (BOOTMGR).

    fve_e_wrong_bootmgr* =              0x80310006.HResult
      ## The boot manager of this operating system is not compatible with BitLocker Drive Encryption. Use the Bootrec.exe tool in the Windows Recovery Environment to update or repair the boot manager (BOOTMGR).

    fve_e_secure_key_required* =        0x80310007.HResult
      ## At least one secure key protector is required for this operation to be performed.

    fve_e_not_activated* =              0x80310008.HResult
      ## BitLocker Drive Encryption is not enabled on this drive. Turn on BitLocker.

    fve_e_action_not_allowed* =         0x80310009.HResult
      ## BitLocker Drive Encryption cannot perform the requested action. This condition may occur when two requests are issued at the same time. Wait a few moments and then try the action again.

    fve_e_ad_schema_not_installed* =    0x8031000A.HResult
      ## The Active Directory Domain Services forest does not contain the required attributes and classes to host BitLocker Drive Encryption or Trusted Platform Module information. Contact your domain administrator to verify that any required BitLocker Active Directory schema extensions have been installed.

    fve_e_ad_invalid_datatype* =        0x8031000B.HResult
      ## The type of the data obtained from Active Directory was not expected. The BitLocker recovery information may be missing or corrupted.

    fve_e_ad_invalid_datasize* =        0x8031000C.HResult
      ## The size of the data obtained from Active Directory was not expected. The BitLocker recovery information may be missing or corrupted.

    fve_e_ad_no_values* =               0x8031000D.HResult
      ## The attribute read from Active Directory does not contain any values. The BitLocker recovery information may be missing or corrupted.

    fve_e_ad_attr_not_set* =            0x8031000E.HResult
      ## The attribute was not set. Verify that you are logged on with a domain account that has the ability to write information to Active Directory objects.

    fve_e_ad_guid_not_found* =          0x8031000F.HResult
      ## The specified attribute cannot be found in Active Directory Domain Services. Contact your domain administrator to verify that any required BitLocker Active Directory schema extensions have been installed.

    fve_e_bad_information* =            0x80310010.HResult
      ## The BitLocker metadata for the encrypted drive is not valid. You can attempt to repair the drive to restore access.

    fve_e_too_small* =                  0x80310011.HResult
      ## The drive cannot be encrypted because it does not have enough free space. Delete any unnecessary data on the drive to create additional free space and then try again.

    fve_e_system_volume* =              0x80310012.HResult
      ## The drive cannot be encrypted because it contains system boot information. Create a separate partition for use as the system drive that contains the boot information and a second partition for use as the operating system drive and then encrypt the operating system drive.

    fve_e_failed_wrong_fs* =            0x80310013.HResult
      ## The drive cannot be encrypted because the file system is not supported.

    fve_e_bad_partition_size* =         0x80310014.HResult
      ## The file system size is larger than the partition size in the partition table. This drive may be corrupt or may have been tampered with. To use it with BitLocker, you must reformat the partition.

    fve_e_not_supported* =              0x80310015.HResult
      ## This drive cannot be encrypted.

    fve_e_bad_data* =                   0x80310016.HResult
      ## The data is not valid.

    fve_e_volume_not_bound* =           0x80310017.HResult
      ## The data drive specified is not set to automatically unlock on the current computer and cannot be unlocked automatically.

    fve_e_tpm_not_owned* =              0x80310018.HResult
      ## You must initialize the Trusted Platform Module (TPM) before you can use BitLocker Drive Encryption.

    fve_e_not_data_volume* =            0x80310019.HResult
      ## The operation attempted cannot be performed on an operating system drive.

    fve_e_ad_insufficient_buffer* =     0x8031001A.HResult
      ## The buffer supplied to a function was insufficient to contain the returned data. Increase the buffer size before running the function again.

    fve_e_conv_read* =                  0x8031001B.HResult
      ## A read operation failed while converting the drive. The drive was not converted. Please re-enable BitLocker.

    fve_e_conv_write* =                 0x8031001C.HResult
      ## A write operation failed while converting the drive. The drive was not converted. Please re-enable BitLocker.

    fve_e_key_required* =               0x8031001D.HResult
      ## One or more BitLocker key protectors are required. You cannot delete the last key on this drive.

    fve_e_clustering_not_supported* =   0x8031001E.HResult
      ## Cluster configurations are not supported by BitLocker Drive Encryption.

    fve_e_volume_bound_already* =       0x8031001F.HResult
      ## The drive specified is already configured to be automatically unlocked on the current computer.

    fve_e_os_not_protected* =           0x80310020.HResult
      ## The operating system drive is not protected by BitLocker Drive Encryption.

    fve_e_protection_disabled* =        0x80310021.HResult
      ## BitLocker Drive Encryption has been suspended on this drive. All BitLocker key protectors configured for this drive are effectively disabled, and the drive will be automatically unlocked using an unencrypted (clear) key.

    fve_e_recovery_key_required* =      0x80310022.HResult
      ## The drive you are attempting to lock does not have any key protectors available for encryption because BitLocker protection is currently suspended. Re-enable BitLocker to lock this drive.

    fve_e_foreign_volume* =             0x80310023.HResult
      ## BitLocker cannot use the Trusted Platform Module (TPM) to protect a data drive. TPM protection can only be used with the operating system drive.

    fve_e_overlapped_update* =          0x80310024.HResult
      ## The BitLocker metadata for the encrypted drive cannot be updated because it was locked for updating by another process. Please try this process again.

    fve_e_tpm_srk_auth_not_zero* =      0x80310025.HResult
      ## The authorization data for the storage root key (SRK) of the Trusted Platform Module (TPM) is not zero and is therefore incompatible with BitLocker. Please initialize the TPM before attempting to use it with BitLocker.

    fve_e_failed_sector_size* =         0x80310026.HResult
      ## The drive encryption algorithm cannot be used on this sector size.

    fve_e_failed_authentication* =      0x80310027.HResult
      ## The drive cannot be unlocked with the key provided. Confirm that you have provided the correct key and try again.

    fve_e_not_os_volume* =              0x80310028.HResult
      ## The drive specified is not the operating system drive.

    fve_e_autounlock_enabled* =         0x80310029.HResult
      ## BitLocker Drive Encryption cannot be turned off on the operating system drive until the auto unlock feature has been disabled for the fixed data drives and removable data drives associated with this computer.

    fve_e_wrong_bootsector* =           0x8031002A.HResult
      ## The system partition boot sector does not perform Trusted Platform Module (TPM) measurements. Use the Bootrec.exe tool in the Windows Recovery Environment to update or repair the boot sector.

    fve_e_wrong_system_fs* =            0x8031002B.HResult
      ## BitLocker Drive Encryption operating system drives must be formatted with the NTFS file system in order to be encrypted. Convert the drive to NTFS, and then turn on BitLocker.

    fve_e_policy_password_required* =   0x8031002C.HResult
      ## Group Policy settings require that a recovery password be specified before encrypting the drive.

    fve_e_cannot_set_fvek_encrypted* =  0x8031002D.HResult
      ## The drive encryption algorithm and key cannot be set on a previously encrypted drive. To encrypt this drive with BitLocker Drive Encryption, remove the previous encryption and then turn on BitLocker.

    fve_e_cannot_encrypt_no_key* =      0x8031002E.HResult
      ## BitLocker Drive Encryption cannot encrypt the specified drive because an encryption key is not available. Add a key protector to encrypt this drive.

    fve_e_bootable_cddvd* =             0x80310030.HResult
      ## BitLocker Drive Encryption detected bootable media (CD or DVD) in the computer. Remove the media and restart the computer before configuring BitLocker.

    fve_e_protector_exists* =           0x80310031.HResult
      ## This key protector cannot be added. Only one key protector of this type is allowed for this drive.

    fve_e_relative_path* =              0x80310032.HResult
      ## The recovery password file was not found because a relative path was specified. Recovery passwords must be saved to a fully qualified path. Environment variables configured on the computer can be used in the path.

    fve_e_protector_not_found* =        0x80310033.HResult
      ## The specified key protector was not found on the drive. Try another key protector.

    fve_e_invalid_key_format* =         0x80310034.HResult
      ## The recovery key provided is corrupt and cannot be used to access the drive. An alternative recovery method, such as recovery password, a data recovery agent, or a backup version of the recovery key must be used to recover access to the drive.

    fve_e_invalid_password_format* =    0x80310035.HResult
      ## The format of the recovery password provided is invalid. BitLocker recovery passwords are 48 digits. Verify that the recovery password is in the correct format and then try again.

    fve_e_fips_rng_check_failed* =      0x80310036.HResult
      ## The random number generator check test failed.

    fve_e_fips_prevents_recovery_password* = 0x80310037.HResult
      ## The Group Policy setting requiring FIPS compliance prevents a local recovery password from being generated or used by BitLocker Drive Encryption. When operating in FIPS-compliant mode, BitLocker recovery options can be either a recovery key stored on a USB drive or recovery through a data recovery agent.

    fve_e_fips_prevents_external_key_export* = 0x80310038.HResult
      ## The Group Policy setting requiring FIPS compliance prevents the recovery password from being saved to Active Directory. When operating in FIPS-compliant mode, BitLocker recovery options can be either a recovery key stored on a USB drive or recovery through a data recovery agent. Check your Group Policy settings configuration.

    fve_e_not_decrypted* =              0x80310039.HResult
      ## The drive must be fully decrypted to complete this operation.

    fve_e_invalid_protector_type* =     0x8031003A.HResult
      ## The key protector specified cannot be used for this operation.

    fve_e_no_protectors_to_test* =      0x8031003B.HResult
      ## No key protectors exist on the drive to perform the hardware test.

    fve_e_keyfile_not_found* =          0x8031003C.HResult
      ## The BitLocker startup key or recovery password cannot be found on the USB device. Verify that you have the correct USB device, that the USB device is plugged into the computer on an active USB port, restart the computer, and then try again. If the problem persists, contact the computer manufacturer for BIOS upgrade instructions.

    fve_e_keyfile_invalid* =            0x8031003D.HResult
      ## The BitLocker startup key or recovery password file provided is corrupt or invalid. Verify that you have the correct startup key or recovery password file and try again.

    fve_e_keyfile_no_vmk* =             0x8031003E.HResult
      ## The BitLocker encryption key cannot be obtained from the startup key or recovery password. Verify that you have the correct startup key or recovery password and try again.

    fve_e_tpm_disabled* =               0x8031003F.HResult
      ## The Trusted Platform Module (TPM) is disabled. The TPM must be enabled, initialized, and have valid ownership before it can be used with BitLocker Drive Encryption.

    fve_e_not_allowed_in_safe_mode* =   0x80310040.HResult
      ## The BitLocker configuration of the specified drive cannot be managed because this computer is currently operating in Safe Mode. While in Safe Mode, BitLocker Drive Encryption can only be used for recovery purposes.

    fve_e_tpm_invalid_pcr* =            0x80310041.HResult
      ## The Trusted Platform Module (TPM) was unable to unlock the drive. Either the system boot information changed after choosing BitLocker settings or the PIN did not match. If the problem persists after several tries, there may be a hardware or firmware problem.

    fve_e_tpm_no_vmk* =                 0x80310042.HResult
      ## The BitLocker encryption key cannot be obtained from the Trusted Platform Module (TPM).

    fve_e_pin_invalid* =                0x80310043.HResult
      ## The BitLocker encryption key cannot be obtained from the Trusted Platform Module (TPM) and PIN.

    fve_e_auth_invalid_application* =   0x80310044.HResult
      ## A boot application has changed since BitLocker Drive Encryption was enabled.

    fve_e_auth_invalid_config* =        0x80310045.HResult
      ## The Boot Configuration Data (BCD) settings have changed since BitLocker Drive Encryption was enabled.

    fve_e_fips_disable_protection_not_allowed* = 0x80310046.HResult
      ## The Group Policy setting requiring FIPS compliance prohibits the use of unencrypted keys, which prevents BitLocker from being suspended on this drive. Please contact your domain administrator for more information.

    fve_e_fs_not_extended* =            0x80310047.HResult
      ## This drive cannot be encrypted by BitLocker Drive Encryption because the file system does not extend to the end of the drive. Repartition this drive and then try again.

    fve_e_firmware_type_not_supported* = 0x80310048.HResult
      ## BitLocker Drive Encryption cannot be enabled on the operating system drive. Contact the computer manufacturer for BIOS upgrade instructions.

    fve_e_no_license* =                 0x80310049.HResult
      ## This version of Windows does not include BitLocker Drive Encryption. To use BitLocker Drive Encryption, please upgrade the operating system.

    fve_e_not_on_stack* =               0x8031004A.HResult
      ## BitLocker Drive Encryption cannot be used because critical BitLocker system files are missing or corrupted. Use Windows Startup Repair to restore these files to your computer.

    fve_e_fs_mounted* =                 0x8031004B.HResult
      ## The drive cannot be locked when the drive is in use.

    fve_e_token_not_impersonated* =     0x8031004C.HResult
      ## The access token associated with the current thread is not an impersonated token.

    fve_e_dry_run_failed* =             0x8031004D.HResult
      ## The BitLocker encryption key cannot be obtained. Verify that the Trusted Platform Module (TPM) is enabled and ownership has been taken. If this computer does not have a TPM, verify that the USB drive is inserted and available.

    fve_e_reboot_required* =            0x8031004E.HResult
      ## You must restart your computer before continuing with BitLocker Drive Encryption.

    fve_e_debugger_enabled* =           0x8031004F.HResult
      ## Drive encryption cannot occur while boot debugging is enabled. Use the bcdedit command-line tool to turn off boot debugging.

    fve_e_raw_access* =                 0x80310050.HResult
      ## No action was taken as BitLocker Drive Encryption is in raw access mode.

    fve_e_raw_blocked* =                0x80310051.HResult
      ## BitLocker Drive Encryption cannot enter raw access mode for this drive because the drive is currently in use.

    fve_e_bcd_applications_path_incorrect* = 0x80310052.HResult
      ## The path specified in the Boot Configuration Data (BCD) for a BitLocker Drive Encryption integrity-protected application is incorrect. Please verify and correct your BCD settings and try again.

    fve_e_not_allowed_in_version* =     0x80310053.HResult
      ## BitLocker Drive Encryption can only be used for limited provisioning or recovery purposes when the computer is running in pre-installation or recovery environments.

    fve_e_no_autounlock_master_key* =   0x80310054.HResult
      ## The auto-unlock master key was not available from the operating system drive.

    fve_e_mor_failed* =                 0x80310055.HResult
      ## The system firmware failed to enable clearing of system memory when the computer was restarted.

    fve_e_hidden_volume* =              0x80310056.HResult
      ## The hidden drive cannot be encrypted.

    fve_e_transient_state* =            0x80310057.HResult
      ## BitLocker encryption keys were ignored because the drive was in a transient state.

    fve_e_pubkey_not_allowed* =         0x80310058.HResult
      ## Public key based protectors are not allowed on this drive.

    fve_e_volume_handle_open* =         0x80310059.HResult
      ## BitLocker Drive Encryption is already performing an operation on this drive. Please complete all operations before continuing.

    fve_e_no_feature_license* =         0x8031005A.HResult
      ## This version of Windows does not support this feature of BitLocker Drive Encryption. To use this feature, upgrade the operating system.

    fve_e_invalid_startup_options* =    0x8031005B.HResult
      ## The Group Policy settings for BitLocker startup options are in conflict and cannot be applied. Contact your system administrator for more information.

    fve_e_policy_recovery_password_not_allowed* = 0x8031005C.HResult
      ## Group Policy settings do not permit the creation of a recovery password.

    fve_e_policy_recovery_password_required* = 0x8031005D.HResult
      ## Group Policy settings require the creation of a recovery password.

    fve_e_policy_recovery_key_not_allowed* = 0x8031005E.HResult
      ## Group Policy settings do not permit the creation of a recovery key.

    fve_e_policy_recovery_key_required* = 0x8031005F.HResult
      ## Group Policy settings require the creation of a recovery key.

    fve_e_policy_startup_pin_not_allowed* = 0x80310060.HResult
      ## Group Policy settings do not permit the use of a PIN at startup. Please choose a different BitLocker startup option.

    fve_e_policy_startup_pin_required* = 0x80310061.HResult
      ## Group Policy settings require the use of a PIN at startup. Please choose this BitLocker startup option.

    fve_e_policy_startup_key_not_allowed* = 0x80310062.HResult
      ## Group Policy settings do not permit the use of a startup key. Please choose a different BitLocker startup option.

    fve_e_policy_startup_key_required* = 0x80310063.HResult
      ## Group Policy settings require the use of a startup key. Please choose this BitLocker startup option.

    fve_e_policy_startup_pin_key_not_allowed* = 0x80310064.HResult
      ## Group Policy settings do not permit the use of a startup key and PIN. Please choose a different BitLocker startup option.

    fve_e_policy_startup_pin_key_required* = 0x80310065.HResult
      ## Group Policy settings require the use of a startup key and PIN. Please choose this BitLocker startup option.

    fve_e_policy_startup_tpm_not_allowed* = 0x80310066.HResult
      ## Group policy does not permit the use of TPM-only at startup. Please choose a different BitLocker startup option.

    fve_e_policy_startup_tpm_required* = 0x80310067.HResult
      ## Group Policy settings require the use of TPM-only at startup. Please choose this BitLocker startup option.

    fve_e_policy_invalid_pin_length* =  0x80310068.HResult
      ## The PIN provided does not meet minimum or maximum length requirements.

    fve_e_key_protector_not_supported* = 0x80310069.HResult
      ## The key protector is not supported by the version of BitLocker Drive Encryption currently on the drive. Upgrade the drive to add the key protector.

    fve_e_policy_passphrase_not_allowed* = 0x8031006A.HResult
      ## Group Policy settings do not permit the creation of a password.

    fve_e_policy_passphrase_required* = 0x8031006B.HResult
      ## Group Policy settings require the creation of a password.

    fve_e_fips_prevents_passphrase* =   0x8031006C.HResult
      ## The Group Policy setting requiring FIPS compliance prevents passwords from being generated or used. Please contact your system administrator for more information.

    fve_e_os_volume_passphrase_not_allowed* = 0x8031006D.HResult
      ## A password cannot be added to the operating system drive.

    fve_e_invalid_bitlocker_oid* =      0x8031006E.HResult
      ## The BitLocker object identifier (OID) on the drive appears to be invalid or corrupt. Use manage-BDE to reset the OID on this drive.

    fve_e_volume_too_small* =           0x8031006F.HResult
      ## The drive is too small to be protected using BitLocker Drive Encryption.

    fve_e_dv_not_supported_on_fs* =     0x80310070.HResult
      ## The selected discovery drive type is incompatible with the file system on the drive. BitLocker To Go discovery drives must be created on FAT formatted drives.

    fve_e_dv_not_allowed_by_gp* =       0x80310071.HResult
      ## The selected discovery drive type is not allowed by the computer's Group Policy settings. Verify that Group Policy settings allow the creation of discovery drives for use with BitLocker To Go.

    fve_e_policy_user_certificate_not_allowed* = 0x80310072.HResult
      ## Group Policy settings do not permit user certificates such as smart cards to be used with BitLocker Drive Encryption.

    fve_e_policy_user_certificate_required* = 0x80310073.HResult
      ## Group Policy settings require that you have a valid user certificate, such as a smart card, to be used with BitLocker Drive Encryption.

    fve_e_policy_user_cert_must_be_hw* = 0x80310074.HResult
      ## Group Policy settings requires that you use a smart card-based key protector with BitLocker Drive Encryption.

    fve_e_policy_user_configure_fdv_autounlock_not_allowed* = 0x80310075.HResult
      ## Group Policy settings do not permit BitLocker-protected fixed data drives to be automatically unlocked.

    fve_e_policy_user_configure_rdv_autounlock_not_allowed* = 0x80310076.HResult
      ## Group Policy settings do not permit BitLocker-protected removable data drives to be automatically unlocked.

    fve_e_policy_user_configure_rdv_not_allowed* = 0x80310077.HResult
      ## Group Policy settings do not permit you to configure BitLocker Drive Encryption on removable data drives.

    fve_e_policy_user_enable_rdv_not_allowed* = 0x80310078.HResult
      ## Group Policy settings do not permit you to turn on BitLocker Drive Encryption on removable data drives. Please contact your system administrator if you need to turn on BitLocker.

    fve_e_policy_user_disable_rdv_not_allowed* = 0x80310079.HResult
      ## Group Policy settings do not permit turning off BitLocker Drive Encryption on removable data drives. Please contact your system administrator if you need to turn off BitLocker.

    fve_e_policy_invalid_passphrase_length* = 0x80310080.HResult
      ## Your password does not meet minimum password length requirements. By default, passwords must be at least 8 characters in length. Check with your system administrator for the password length requirement in your organization.

    fve_e_policy_passphrase_too_simple* = 0x80310081.HResult
      ## Your password does not meet the complexity requirements set by your system administrator. Try adding upper and lowercase characters, numbers, and symbols.

    fve_e_recovery_partition* =         0x80310082.HResult
      ## This drive cannot be encrypted because it is reserved for Windows System Recovery Options.

    fve_e_policy_conflict_fdv_rk_off_auk_on* = 0x80310083.HResult
      ## BitLocker Drive Encryption cannot be applied to this drive because of conflicting Group Policy settings. BitLocker cannot be configured to automatically unlock fixed data drives when user recovery options are disabled. If you want BitLocker-protected fixed data drives to be automatically unlocked after key validation has occurred, please ask your system administrator to resolve the settings conflict before enabling BitLocker.

    fve_e_policy_conflict_rdv_rk_off_auk_on* = 0x80310084.HResult
      ## BitLocker Drive Encryption cannot be applied to this drive because of conflicting Group Policy settings. BitLocker cannot be configured to automatically unlock removable data drives when user recovery option are disabled. If you want BitLocker-protected removable data drives to be automatically unlocked after key validation has occurred, please ask your system administrator to resolve the settings conflict before enabling BitLocker.

    fve_e_non_bitlocker_oid* =          0x80310085.HResult
      ## The Enhanced Key Usage (EKU) attribute of the specified certificate does not permit it to be used for BitLocker Drive Encryption. BitLocker does not require that a certificate have an EKU attribute, but if one is configured it must be set to an object identifier (OID) that matches the OID configured for BitLocker.

    fve_e_policy_prohibits_selfsigned* = 0x80310086.HResult
      ## BitLocker Drive Encryption cannot be applied to this drive as currently configured because of Group Policy settings. The certificate you provided for drive encryption is self-signed. Current Group Policy settings do not permit the use of self-signed certificates. Obtain a new certificate from your certification authority before attempting to enable BitLocker.

    fve_e_policy_conflict_ro_and_startup_key_required* = 0x80310087.HResult
      ## BitLocker Encryption cannot be applied to this drive because of conflicting Group Policy settings. When write access to drives not protected by BitLocker is denied, the use of a USB startup key cannot be required. Please have your system administrator resolve these policy conflicts before attempting to enable BitLocker.

    fve_e_conv_recovery_failed* =       0x80310088.HResult
      ## BitLocker Drive Encryption failed to recover from an abruptly terminated conversion. This could be due to either all conversion logs being corrupted or the media being write-protected.

    fve_e_virtualized_space_too_big* =  0x80310089.HResult
      ## The requested virtualization size is too big.

    fve_e_policy_conflict_osv_rp_off_adb_on* = 0x80310090.HResult
      ## BitLocker Drive Encryption cannot be applied to this drive because there are conflicting Group Policy settings for recovery options on operating system drives. Storing recovery information to Active Directory Domain Services cannot be required when the generation of recovery passwords is not permitted. Please have your system administrator resolve these policy conflicts before attempting to enable BitLocker.

    fve_e_policy_conflict_fdv_rp_off_adb_on* = 0x80310091.HResult
      ## BitLocker Drive Encryption cannot be applied to this drive because there are conflicting Group Policy settings for recovery options on fixed data drives. Storing recovery information to Active Directory Domain Services cannot be required when the generation of recovery passwords is not permitted. Please have your system administrator resolve these policy conflicts before attempting to enable BitLocker.

    fve_e_policy_conflict_rdv_rp_off_adb_on* = 0x80310092.HResult
      ## BitLocker Drive Encryption cannot be applied to this drive because there are conflicting Group Policy settings for recovery options on removable data drives. Storing recovery information to Active Directory Domain Services cannot be required when the generation of recovery passwords is not permitted. Please have your system administrator resolve these policy conflicts before attempting to enable BitLocker.

    fve_e_non_bitlocker_ku* =           0x80310093.HResult
      ## The Key Usage (KU) attribute of the specified certificate does not permit it to be used for BitLocker Drive Encryption. BitLocker does not require that a certificate have a KU attribute, but if one is configured it must be set to either Key Encipherment or Key Agreement.

    fve_e_privatekey_auth_failed* =     0x80310094.HResult
      ## The private key associated with the specified certificate cannot be authorized. The private key authorization was either not provided or the provided authorization was invalid.

    fve_e_removal_of_dra_failed* =      0x80310095.HResult
      ## Removal of the data recovery agent certificate must be done using the Certificates snap-in.

    fve_e_operation_not_supported_on_vista_volume* = 0x80310096.HResult
      ## This drive was encrypted using the version of BitLocker Drive Encryption included with Windows Vista and Windows Server 2008 which does not support organizational identifiers. To specify organizational identifiers for this drive upgrade the drive encryption to the latest version using the "manage-bde -upgrade" command.

    fve_e_cant_lock_autounlock_enabled_volume* = 0x80310097.HResult
      ## The drive cannot be locked because it is automatically unlocked on this computer.  Remove the automatic unlock protector to lock this drive.

    fve_e_fips_hash_kdf_not_allowed* =  0x80310098.HResult
      ## The default BitLocker Key Derivation Function SP800-56A for ECC smart cards is not supported by your smart card. The Group Policy setting requiring FIPS-compliance prevents BitLocker from using any other key derivation function for encryption. You have to use a FIPS compliant smart card in FIPS restricted environments.

    fve_e_enh_pin_invalid* =            0x80310099.HResult
      ## The BitLocker encryption key could not be obtained from the Trusted Platform Module (TPM) and enhanced PIN. Try using a PIN containing only numerals.

    fve_e_invalid_pin_chars* =          0x8031009A.HResult
      ## The requested TPM PIN contains invalid characters.

    fve_e_invalid_datum_type* =         0x8031009B.HResult
      ## The management information stored on the drive contained an unknown type. If you are using an old version of Windows, try accessing the drive from the latest version.

    fve_e_efi_only* =                   0x8031009C.HResult
      ## The feature is only supported on EFI systems.

    fve_e_multiple_nkp_certs* =         0x8031009D.HResult
      ## More than one Network Key Protector certificate has been found on the system.

    fve_e_removal_of_nkp_failed* =      0x8031009E.HResult
      ## Removal of the Network Key Protector certificate must be done using the Certificates snap-in.

    fve_e_invalid_nkp_cert* =           0x8031009F.HResult
      ## An invalid certificate has been found in the Network Key Protector certificate store.

    fve_e_no_existing_pin* =            0x803100A0.HResult
      ## This drive isn't protected with a PIN.

    fve_e_protector_change_pin_mismatch* = 0x803100A1.HResult
      ## Please enter the correct current PIN.

    fve_e_pin_protector_change_by_std_user_disallowed* = 0x803100A2.HResult
      ## You must be logged on with an administrator account to change the PIN. Click the link to reset the PIN as an administrator.

    fve_e_protector_change_max_pin_change_attempts_reached* = 0x803100A3.HResult
      ## BitLocker has disabled PIN changes after too many failed requests. Click the link to reset the PIN as an administrator.

    fve_e_policy_passphrase_requires_ascii* = 0x803100A4.HResult
      ## Your system administrator requires that passwords contain only printable ASCII characters. This includes unaccented letters (A-Z, a-z), numbers (0-9), space, arithmetic signs, common punctuation, separators, and the following symbols: # $ & @ ^ _ ~ .

    fve_e_full_encryption_not_allowed_on_tp_storage* = 0x803100A5.HResult
      ## BitLocker Drive Encryption only supports Used Space Only encryption on thin provisioned storage.

    fve_e_wipe_not_allowed_on_tp_storage* = 0x803100A6.HResult
      ## BitLocker Drive Encryption does not support wiping free space on thin provisioned storage.

    fve_e_key_length_not_supported_by_edrive* = 0x803100A7.HResult
      ## The required authentication key length is not supported by the drive.

    fve_e_no_existing_passphrase* =     0x803100A8.HResult
      ## This drive isn't protected with a password.

    fve_e_protector_change_passphrase_mismatch* = 0x803100A9.HResult
      ## Please enter the correct current password.

    fve_e_passphrase_too_long* =        0x803100AA.HResult
      ## The password cannot exceed 256 characters.

    fve_e_no_passphrase_with_tpm* =     0x803100AB.HResult
      ## A password key protector cannot be added because a TPM protector exists on the drive.

    fve_e_no_tpm_with_passphrase* =     0x803100AC.HResult
      ## A TPM key protector cannot be added because a password protector exists on the drive.

    fve_e_not_allowed_on_csv_stack* =   0x803100AD.HResult
      ## This command can only be performed from the coordinator node for the specified CSV volume.

    fve_e_not_allowed_on_cluster* =     0x803100AE.HResult
      ## This command cannot be performed on a volume when it is part of a cluster.

    fve_e_edrive_no_failover_to_sw* =   0x803100AF.HResult
      ## BitLocker did not revert to using BitLocker software encryption due to group policy configuration.

    fve_e_edrive_band_in_use* =         0x803100B0.HResult
      ## The drive cannot be managed by BitLocker because the drive's hardware encryption feature is already in use.

    fve_e_edrive_disallowed_by_gp* =    0x803100B1.HResult
      ## Group Policy settings do not allow the use of hardware-based encryption.

    fve_e_edrive_incompatible_volume* = 0x803100B2.HResult
      ## The drive specified does not support hardware-based encryption.

    fve_e_not_allowed_to_upgrade_while_converting* = 0x803100B3.HResult
      ## BitLocker cannot be upgraded during disk encryption or decryption.

    fve_e_edrive_dv_not_supported* =    0x803100B4.HResult
      ## Discovery Volumes are not supported for volumes using hardware encryption.

    fve_e_no_preboot_keyboard_detected* = 0x803100B5.HResult
      ## No pre-boot keyboard detected. The user may not be able to provide required input to unlock the volume.

    fve_e_no_preboot_keyboard_or_winre_detected* = 0x803100B6.HResult
      ## No pre-boot keyboard or Windows Recovery Environment detected. The user may not be able to provide required input to unlock the volume.

    fve_e_policy_requires_startup_pin_on_touch_device* = 0x803100B7.HResult
      ## Group Policy settings require the creation of a startup PIN, but a pre-boot keyboard is not available on this device. The user may not be able to provide required input to unlock the volume.

    fve_e_policy_requires_recovery_password_on_touch_device* = 0x803100B8.HResult
      ## Group Policy settings require the creation of a recovery password, but neither a pre-boot keyboard nor Windows Recovery Environment is available on this device. The user may not be able to provide required input to unlock the volume.

    fve_e_wipe_cancel_not_applicable* = 0x803100B9.HResult
      ## Wipe of free space is not currently taking place.

    fve_e_secureboot_disabled* =        0x803100BA.HResult
      ## BitLocker cannot use Secure Boot for platform integrity because Secure Boot has been disabled.

    fve_e_secureboot_configuration_invalid* = 0x803100BB.HResult
      ## BitLocker cannot use Secure Boot for platform integrity because the Secure Boot configuration does not meet the requirements for BitLocker.

    fve_e_edrive_dry_run_failed* =      0x803100BC.HResult
      ## Your computer doesn't support BitLocker hardware-based encryption. Check with your computer manufacturer for firmware updates.

    fve_e_shadow_copy_present* =        0x803100BD.HResult
      ## BitLocker cannot be enabled on the volume because it contains a Volume Shadow Copy. Remove all Volume Shadow Copies before encrypting the volume.

    fve_e_policy_invalid_enhanced_bcd_settings* = 0x803100BE.HResult
      ## BitLocker Drive Encryption cannot be applied to this drive because the Group Policy setting for Enhanced Boot Configuration Data contains invalid data. Please have your system administrator resolve this invalid configuration before attempting to enable BitLocker.

    fve_e_edrive_incompatible_firmware* = 0x803100BF.HResult
      ## This PC's firmware is not capable of supporting hardware encryption.

    fve_e_protector_change_max_passphrase_change_attempts_reached* = 0x803100C0.HResult
      ## BitLocker has disabled password changes after too many failed requests. Click the link to reset the password as an administrator.

    fve_e_passphrase_protector_change_by_std_user_disallowed* = 0x803100C1.HResult
      ## You must be logged on with an administrator account to change the password. Click the link to reset the password as an administrator.

    fve_e_liveid_account_suspended* =   0x803100C2.HResult
      ## BitLocker cannot save the recovery password because the specified Microsoft account is Suspended.

    fve_e_liveid_account_blocked* =     0x803100C3.HResult
      ## BitLocker cannot save the recovery password because the specified Microsoft account is Blocked.

    fve_e_not_provisioned_on_all_volumes* = 0x803100C4.HResult
      ## This PC is not provisioned to support device encryption. Please enable BitLocker on all volumes to comply with device encryption policy.

    fve_e_de_fixed_data_not_supported* = 0x803100C5.HResult
      ## This PC cannot support device encryption because unencrypted fixed data volumes are present.

    fve_e_de_hardware_not_compliant* =  0x803100C6.HResult
      ## This PC does not meet the hardware requirements to support device encryption.

    fve_e_de_winre_not_configured* =    0x803100C7.HResult
      ## This PC cannot support device encryption because WinRE is not properly configured.

    fve_e_de_protection_suspended* =    0x803100C8.HResult
      ## Protection is enabled on the volume but has been suspended. This is likely to have happened due to an update being applied to your system. Please try again after a reboot.

    fve_e_de_os_volume_not_protected* = 0x803100C9.HResult
      ## This PC is not provisioned to support device encryption.

    fve_e_de_device_lockedout* =        0x803100CA.HResult
      ## Device Lock has been triggered due to too many incorrect password attempts.

    fve_e_de_protection_not_yet_enabled* = 0x803100CB.HResult
      ## Protection has not been enabled on the volume. Enabling protection requires a connected account. If you already have a connected account and are seeing this error, please refer to the event log for more information.

    fve_e_invalid_pin_chars_detailed* = 0x803100CC.HResult
      ## Your PIN can only contain numbers from 0 to 9.

    fve_e_device_lockout_counter_unavailable* = 0x803100CD.HResult
      ## BitLocker cannot use hardware replay protection because no counter is available on your PC.

    fve_e_devicelockout_counter_mismatch* = 0x803100CE.HResult
      ## Device Lockout state validation failed due to counter mismatch.

    fve_e_buffer_too_large* =           0x803100CF.HResult
      ## The input buffer is too large.

    fve_e_no_such_capability_on_target* = 0x803100D0.HResult
      ## The target of an invocation does not support requested capability.

    fve_e_de_prevented_for_os* =        0x803100D1.HResult
      ## Device encryption is currently blocked by this PC's configuration.

    fve_e_de_volume_opted_out* =        0x803100D2.HResult
      ## This drive has been opted out of device encryption.

    fve_e_de_volume_not_supported* =    0x803100D3.HResult
      ## Device encryption isn't available for this drive.

    fve_e_eow_not_supported_in_version* = 0x803100D4.HResult
      ## The encrypt on write mode for BitLocker is not supported in this version of Windows. You can turn on BitLocker without using the encrypt on write mode.

    fve_e_adbackup_not_enabled* =       0x803100D5.HResult
      ## Group policy prevents you from backing up your recovery password to Active Directory for this drive type. For more info, contact your system administrator.

    fve_e_volume_extend_prevents_eow_decrypt* = 0x803100D6.HResult
      ## Device encryption can't be turned off while this drive is being encrypted. Please try again later.

    fve_e_not_de_volume* =              0x803100D7.HResult
      ## This action isn't supported because this drive isn't automatically managed with device encryption.

    fve_e_protection_cannot_be_disabled* = 0x803100D8.HResult
      ## BitLocker can't be suspended on this drive until the next restart.

    fve_e_osv_ksr_not_allowed* =        0x803100D9.HResult
      ## BitLocker Drive Encryption policy does not allow KSR operation with protected OS volume.

    #
    # =======================================================
    # Windows Filtering Platform Error Messages
    # =======================================================
    #
    fwp_e_callout_not_found* =          0x80320001.HResult
      ## The callout does not exist.

    fwp_e_condition_not_found* =        0x80320002.HResult
      ## The filter condition does not exist.

    fwp_e_filter_not_found* =           0x80320003.HResult
      ## The filter does not exist.

    fwp_e_layer_not_found* =            0x80320004.HResult
      ## The layer does not exist.

    fwp_e_provider_not_found* =         0x80320005.HResult
      ## The provider does not exist.

    fwp_e_provider_context_not_found* = 0x80320006.HResult
      ## The provider context does not exist.

    fwp_e_sublayer_not_found* =         0x80320007.HResult
      ## The sublayer does not exist.

    fwp_e_not_found* =                  0x80320008.HResult
      ## The object does not exist.

    fwp_e_already_exists* =             0x80320009.HResult
      ## An object with that GUID or LUID already exists.

    fwp_e_in_use* =                     0x8032000A.HResult
      ## The object is referenced by other objects so cannot be deleted.

    fwp_e_dynamic_session_in_progress* = 0x8032000B.HResult
      ## The call is not allowed from within a dynamic session.

    fwp_e_wrong_session* =              0x8032000C.HResult
      ## The call was made from the wrong session so cannot be completed.

    fwp_e_no_txn_in_progress* =         0x8032000D.HResult
      ## The call must be made from within an explicit transaction.

    fwp_e_txn_in_progress* =            0x8032000E.HResult
      ## The call is not allowed from within an explicit transaction.

    fwp_e_txn_aborted* =                0x8032000F.HResult
      ## The explicit transaction has been forcibly cancelled.

    fwp_e_session_aborted* =            0x80320010.HResult
      ## The session has been cancelled.

    fwp_e_incompatible_txn* =           0x80320011.HResult
      ## The call is not allowed from within a read-only transaction.

    fwp_e_timeout* =                    0x80320012.HResult
      ## The call timed out while waiting to acquire the transaction lock.

    fwp_e_net_events_disabled* =        0x80320013.HResult
      ## Collection of network diagnostic events is disabled.

    fwp_e_incompatible_layer* =         0x80320014.HResult
      ## The operation is not supported by the specified layer.

    fwp_e_km_clients_only* =            0x80320015.HResult
      ## The call is allowed for kernel-mode callers only.

    fwp_e_lifetime_mismatch* =          0x80320016.HResult
      ## The call tried to associate two objects with incompatible lifetimes.

    fwp_e_builtin_object* =             0x80320017.HResult
      ## The object is built in so cannot be deleted.

    fwp_e_too_many_callouts* =          0x80320018.HResult
      ## The maximum number of callouts has been reached.

    fwp_e_notification_dropped* =       0x80320019.HResult
      ## A notification could not be delivered because a message queue is at its maximum capacity.

    fwp_e_traffic_mismatch* =           0x8032001A.HResult
      ## The traffic parameters do not match those for the security association context.

    fwp_e_incompatible_sa_state* =      0x8032001B.HResult
      ## The call is not allowed for the current security association state.

    fwp_e_null_pointer* =               0x8032001C.HResult
      ## A required pointer is null.

    fwp_e_invalid_enumerator* =         0x8032001D.HResult
      ## An enumerator is not valid.

    fwp_e_invalid_flags* =              0x8032001E.HResult
      ## The flags field contains an invalid value.

    fwp_e_invalid_net_mask* =           0x8032001F.HResult
      ## A network mask is not valid.

    fwp_e_invalid_range* =              0x80320020.HResult
      ## An FWP_RANGE is not valid.

    fwp_e_invalid_interval* =           0x80320021.HResult
      ## The time interval is not valid.

    fwp_e_zero_length_array* =          0x80320022.HResult
      ## An array that must contain at least one element is zero length.

    fwp_e_null_display_name* =          0x80320023.HResult
      ## The displayData.name field cannot be null.

    fwp_e_invalid_action_type* =        0x80320024.HResult
      ## The action type is not one of the allowed action types for a filter.

    fwp_e_invalid_weight* =             0x80320025.HResult
      ## The filter weight is not valid.

    fwp_e_match_type_mismatch* =        0x80320026.HResult
      ## A filter condition contains a match type that is not compatible with the operands.

    fwp_e_type_mismatch* =              0x80320027.HResult
      ## An FWP_VALUE or FWPM_CONDITION_VALUE is of the wrong type.

    fwp_e_out_of_bounds* =              0x80320028.HResult
      ## An integer value is outside the allowed range.

    fwp_e_reserved* =                   0x80320029.HResult
      ## A reserved field is non-zero.

    fwp_e_duplicate_condition* =        0x8032002A.HResult
      ## A filter cannot contain multiple conditions operating on a single field.

    fwp_e_duplicate_keymod* =           0x8032002B.HResult
      ## A policy cannot contain the same keying module more than once.

    fwp_e_action_incompatible_with_layer* = 0x8032002C.HResult
      ## The action type is not compatible with the layer.

    fwp_e_action_incompatible_with_sublayer* = 0x8032002D.HResult
      ## The action type is not compatible with the sublayer.

    fwp_e_context_incompatible_with_layer* = 0x8032002E.HResult
      ## The raw context or the provider context is not compatible with the layer.

    fwp_e_context_incompatible_with_callout* = 0x8032002F.HResult
      ## The raw context or the provider context is not compatible with the callout.

    fwp_e_incompatible_auth_method* =   0x80320030.HResult
      ## The authentication method is not compatible with the policy type.

    fwp_e_incompatible_dh_group* =      0x80320031.HResult
      ## The Diffie-Hellman group is not compatible with the policy type.

    fwp_e_em_not_supported* =           0x80320032.HResult
      ## An IKE policy cannot contain an Extended Mode policy.

    fwp_e_never_match* =                0x80320033.HResult
      ## The enumeration template or subscription will never match any objects.

    fwp_e_provider_context_mismatch* =  0x80320034.HResult
      ## The provider context is of the wrong type.

    fwp_e_invalid_parameter* =          0x80320035.HResult
      ## The parameter is incorrect.

    fwp_e_too_many_sublayers* =         0x80320036.HResult
      ## The maximum number of sublayers has been reached.

    fwp_e_callout_notification_failed* = 0x80320037.HResult
      ## The notification function for a callout returned an error.

    fwp_e_invalid_auth_transform* =     0x80320038.HResult
      ## The IPsec authentication transform is not valid.

    fwp_e_invalid_cipher_transform* =   0x80320039.HResult
      ## The IPsec cipher transform is not valid.

    fwp_e_incompatible_cipher_transform* = 0x8032003A.HResult
      ## The IPsec cipher transform is not compatible with the policy.

    fwp_e_invalid_transform_combination* = 0x8032003B.HResult
      ## The combination of IPsec transform types is not valid.

    fwp_e_duplicate_auth_method* =      0x8032003C.HResult
      ## A policy cannot contain the same auth method more than once.

    fwp_e_invalid_tunnel_endpoint* =    0x8032003D.HResult
      ## A tunnel endpoint configuration is invalid.

    fwp_e_l2_driver_not_ready* =        0x8032003E.HResult
      ## The WFP MAC Layers are not ready.

    fwp_e_key_dictator_already_registered* = 0x8032003F.HResult
      ## A key manager capable of key dictation is already registered

    fwp_e_key_dictation_invalid_keying_material* = 0x80320040.HResult
      ## A key manager dictated invalid keys

    fwp_e_connections_disabled* =       0x80320041.HResult
      ## The BFE IPsec Connection Tracking is disabled.

    fwp_e_invalid_dns_name* =           0x80320042.HResult
      ## The DNS name is invalid.

    fwp_e_still_on* =                   0x80320043.HResult
      ## The engine option is still enabled due to other configuration settings.

    fwp_e_ikeext_not_running* =         0x80320044.HResult
      ## The IKEEXT service is not running.  This service only runs when there is IPsec policy applied to the machine.

    fwp_e_drop_noicmp* =                0x80320104.HResult
      ## The packet should be dropped, no ICMP should be sent.


    ##################################################
    #                                               ##
    #       Web Services Platform Error Codes       ##
    #                                               ##
    ##################################################

    ws_s_async* =                       0x003D0000.HResult
      ## The function call is completing asynchronously.

    ws_s_end* =                         0x003D0001.HResult
      ## There are no more messages available on the channel.

    ws_e_invalid_format* =              0x803D0000.HResult
      ## The input data was not in the expected format or did not have the expected value.

    ws_e_object_faulted* =              0x803D0001.HResult
      ## The operation could not be completed because the object is in a faulted state due to a previous error.

    ws_e_numeric_overflow* =            0x803D0002.HResult
      ## The operation could not be completed because it would lead to numeric overflow.

    ws_e_invalid_operation* =           0x803D0003.HResult
      ## The operation is not allowed due to the current state of the object.

    ws_e_operation_aborted* =           0x803D0004.HResult
      ## The operation was aborted.

    ws_e_endpoint_access_denied* =      0x803D0005.HResult
      ## Access was denied by the remote endpoint.

    ws_e_operation_timed_out* =         0x803D0006.HResult
      ## The operation did not complete within the time allotted.

    ws_e_operation_abandoned* =         0x803D0007.HResult
      ## The operation was abandoned.

    ws_e_quota_exceeded* =              0x803D0008.HResult
      ## A quota was exceeded.

    ws_e_no_translation_available* =    0x803D0009.HResult
      ## The information was not available in the specified language.

    ws_e_security_verification_failure* = 0x803D000A.HResult
      ## Security verification was not successful for the received data.

    ws_e_address_in_use* =              0x803D000B.HResult
      ## The address is already being used.

    ws_e_address_not_available* =       0x803D000C.HResult
      ## The address is not valid for this context.

    ws_e_endpoint_not_found* =          0x803D000D.HResult
      ## The remote endpoint does not exist or could not be located.

    ws_e_endpoint_not_available* =      0x803D000E.HResult
      ## The remote endpoint is not currently in service at this location.

    ws_e_endpoint_failure* =            0x803D000F.HResult
      ## The remote endpoint could not process the request.

    ws_e_endpoint_unreachable* =        0x803D0010.HResult
      ## The remote endpoint was not reachable.

    ws_e_endpoint_action_not_supported* = 0x803D0011.HResult
      ## The operation was not supported by the remote endpoint.

    ws_e_endpoint_too_busy* =           0x803D0012.HResult
      ## The remote endpoint is unable to process the request due to being overloaded.

    ws_e_endpoint_fault_received* =     0x803D0013.HResult
      ## A message containing a fault was received from the remote endpoint.

    ws_e_endpoint_disconnected* =       0x803D0014.HResult
      ## The connection with the remote endpoint was terminated.

    ws_e_proxy_failure* =               0x803D0015.HResult
      ## The HTTP proxy server could not process the request.

    ws_e_proxy_access_denied* =         0x803D0016.HResult
      ## Access was denied by the HTTP proxy server.

    ws_e_not_supported* =               0x803D0017.HResult
      ## The requested feature is not available on this platform.

    ws_e_proxy_requires_basic_auth* =   0x803D0018.HResult
      ## The HTTP proxy server requires HTTP authentication scheme 'basic'.

    ws_e_proxy_requires_digest_auth* =  0x803D0019.HResult
      ## The HTTP proxy server requires HTTP authentication scheme 'digest'.

    ws_e_proxy_requires_ntlm_auth* =    0x803D001A.HResult
      ## The HTTP proxy server requires HTTP authentication scheme 'NTLM'.

    ws_e_proxy_requires_negotiate_auth* = 0x803D001B.HResult
      ## The HTTP proxy server requires HTTP authentication scheme 'negotiate'.

    ws_e_server_requires_basic_auth* =  0x803D001C.HResult
      ## The remote endpoint requires HTTP authentication scheme 'basic'.

    ws_e_server_requires_digest_auth* = 0x803D001D.HResult
      ## The remote endpoint requires HTTP authentication scheme 'digest'.

    ws_e_server_requires_ntlm_auth* =   0x803D001E.HResult
      ## The remote endpoint requires HTTP authentication scheme 'NTLM'.

    ws_e_server_requires_negotiate_auth* = 0x803D001F.HResult
      ## The remote endpoint requires HTTP authentication scheme 'negotiate'.

    ws_e_invalid_endpoint_url* =        0x803D0020.HResult
      ## The endpoint address URL is invalid.

    ws_e_other* =                       0x803D0021.HResult
      ## Unrecognized error occurred in the Windows Web Services framework.

    ws_e_security_token_expired* =      0x803D0022.HResult
      ## A security token was rejected by the server because it has expired.

    ws_e_security_system_failure* =     0x803D0023.HResult
      ## A security operation failed in the Windows Web Services framework.


    #
    # NDIS error codes (ndis.sys)
    #
    error_ndis_interface_closing* =     0x80340002.HResult
      ## The binding to the network interface is being closed.

    error_ndis_bad_version* =           0x80340004.HResult
      ## An invalid version was specified.

    error_ndis_bad_characteristics* =   0x80340005.HResult
      ## An invalid characteristics table was used.

    error_ndis_adapter_not_found* =     0x80340006.HResult
      ## Failed to find the network interface or network interface is not ready.

    error_ndis_open_failed* =           0x80340007.HResult
      ## Failed to open the network interface.

    error_ndis_device_failed* =         0x80340008.HResult
      ## Network interface has encountered an internal unrecoverable failure.

    error_ndis_multicast_full* =        0x80340009.HResult
      ## The multicast list on the network interface is full.

    error_ndis_multicast_exists* =      0x8034000A.HResult
      ## An attempt was made to add a duplicate multicast address to the list.

    error_ndis_multicast_not_found* =   0x8034000B.HResult
      ## At attempt was made to remove a multicast address that was never added.

    error_ndis_request_aborted* =       0x8034000C.HResult
      ## Netowork interface aborted the request.

    error_ndis_reset_in_progress* =     0x8034000D.HResult
      ## Network interface can not process the request because it is being reset.

    error_ndis_not_supported* =         0x803400BB.HResult
      ## Netword interface does not support this request.

    error_ndis_invalid_packet* =        0x8034000F.HResult
      ## An attempt was made to send an invalid packet on a network interface.

    error_ndis_adapter_not_ready* =     0x80340011.HResult
      ## Network interface is not ready to complete this operation.

    error_ndis_invalid_length* =        0x80340014.HResult
      ## The length of the buffer submitted for this operation is not valid.

    error_ndis_invalid_data* =          0x80340015.HResult
      ## The data used for this operation is not valid.

    error_ndis_buffer_too_short* =      0x80340016.HResult
      ## The length of buffer submitted for this operation is too small.

    error_ndis_invalid_oid* =           0x80340017.HResult
      ## Network interface does not support this OID (Object Identifier)

    error_ndis_adapter_removed* =       0x80340018.HResult
      ## The network interface has been removed.

    error_ndis_unsupported_media* =     0x80340019.HResult
      ## Network interface does not support this media type.

    error_ndis_group_address_in_use* =  0x8034001A.HResult
      ## An attempt was made to remove a token ring group address that is in use by other components.

    error_ndis_file_not_found* =        0x8034001B.HResult
      ## An attempt was made to map a file that can not be found.

    error_ndis_error_reading_file* =    0x8034001C.HResult
      ## An error occurred while NDIS tried to map the file.

    error_ndis_already_mapped* =        0x8034001D.HResult
      ## An attempt was made to map a file that is alreay mapped.

    error_ndis_resource_conflict* =     0x8034001E.HResult
      ## An attempt to allocate a hardware resource failed because the resource is used by another component.

    error_ndis_media_disconnected* =    0x8034001F.HResult
      ## The I/O operation failed because network media is disconnected or wireless access point is out of range.

    error_ndis_invalid_address* =       0x80340022.HResult
      ## The network address used in the request is invalid.

    error_ndis_invalid_device_request* = 0x80340010.HResult
      ## The specified request is not a valid operation for the target device.

    error_ndis_paused* =                0x8034002A.HResult
      ## The offload operation on the network interface has been paused.

    error_ndis_interface_not_found* =   0x8034002B.HResult
      ## Network interface was not found.

    error_ndis_unsupported_revision* =  0x8034002C.HResult
      ## The revision number specified in the structure is not supported.

    error_ndis_invalid_port* =          0x8034002D.HResult
      ## The specified port does not exist on this network interface.

    error_ndis_invalid_port_state* =    0x8034002E.HResult
      ## The current state of the specified port on this network interface does not support the requested operation.

    error_ndis_low_power_state* =       0x8034002F.HResult
      ## The miniport adapter is in low power state.

    error_ndis_reinit_required* =       0x80340030.HResult
      ## This operation requires the miniport adapter to be reinitialized.


    #
    # NDIS error codes (802.11 wireless LAN)
    #

    error_ndis_dot11_auto_config_enabled* = 0x80342000.HResult
      ## The wireless local area network interface is in auto configuration mode and doesn't support the requested parameter change operation.

    error_ndis_dot11_media_in_use* =    0x80342001.HResult
      ## The wireless local area network interface is busy and can not perform the requested operation.

    error_ndis_dot11_power_state_invalid* = 0x80342002.HResult
      ## The wireless local area network interface is powered down and doesn't support the requested operation.

    error_ndis_pm_wol_pattern_list_full* = 0x80342003.HResult
      ## The list of wake on LAN patterns is full.

    error_ndis_pm_protocol_offload_list_full* = 0x80342004.HResult
      ## The list of low power protocol offloads is full.

    error_ndis_dot11_ap_channel_currently_not_available* = 0x80342005.HResult
      ## The wireless local area network interface cannot start an AP on the specified channel right now.

    error_ndis_dot11_ap_band_currently_not_available* = 0x80342006.HResult
      ## The wireless local area network interface cannot start an AP on the specified band right now.

    error_ndis_dot11_ap_channel_not_allowed* = 0x80342007.HResult
      ## The wireless local area network interface cannot start an AP on this channel due to regulatory reasons.

    error_ndis_dot11_ap_band_not_allowed* = 0x80342008.HResult
      ## The wireless local area network interface cannot start an AP on this band due to regulatory reasons.

    #
    # NDIS informational code (ndis.sys)
    #

    error_ndis_indication_required* =   0x00340001.HResult
      ## The request will be completed later by NDIS status indication.

    #
    # NDIS Chimney Offload codes (ndis.sys)
    #

    error_ndis_offload_policy* =        0xC034100F.HResult
      ## The TCP connection is not offloadable because of a local policy setting.

    error_ndis_offload_connection_rejected* = 0xC0341012.HResult
      ## The TCP connection is not offloadable by the Chimney Offload target.

    error_ndis_offload_path_rejected* = 0xC0341013.HResult
      ## The IP Path object is not in an offloadable state.

    #
    # Hypervisor error codes
    #

    error_hv_invalid_hypercall_code* =  0xC0350002.HResult
      ## The hypervisor does not support the operation because the specified hypercall code is not supported.

    error_hv_invalid_hypercall_input* = 0xC0350003.HResult
      ## The hypervisor does not support the operation because the encoding for the hypercall input register is not supported.

    error_hv_invalid_alignment* =       0xC0350004.HResult
      ## The hypervisor could not perform the operation because a parameter has an invalid alignment.

    error_hv_invalid_parameter* =       0xC0350005.HResult
      ## The hypervisor could not perform the operation because an invalid parameter was specified.

    error_hv_access_denied* =           0xC0350006.HResult
      ## Access to the specified object was denied.

    error_hv_invalid_partition_state* = 0xC0350007.HResult
      ## The hypervisor could not perform the operation because the partition is entering or in an invalid state.

    error_hv_operation_denied* =        0xC0350008.HResult
      ## The operation is not allowed in the current state.

    error_hv_unknown_property* =        0xC0350009.HResult
      ## The hypervisor does not recognize the specified partition property.

    error_hv_property_value_out_of_range* = 0xC035000A.HResult
      ## The specified value of a partition property is out of range or violates an invariant.

    error_hv_insufficient_memory* =     0xC035000B.HResult
      ## There is not enough memory in the hypervisor pool to complete the operation.

    error_hv_partition_too_deep* =      0xC035000C.HResult
      ## The maximum partition depth has been exceeded for the partition hierarchy.

    error_hv_invalid_partition_id* =    0xC035000D.HResult
      ## A partition with the specified partition Id does not exist.

    error_hv_invalid_vp_index* =        0xC035000E.HResult
      ## The hypervisor could not perform the operation because the specified VP index is invalid.

    error_hv_invalid_port_id* =         0xC0350011.HResult
      ## The hypervisor could not perform the operation because the specified port identifier is invalid.

    error_hv_invalid_connection_id* =   0xC0350012.HResult
      ## The hypervisor could not perform the operation because the specified connection identifier is invalid.

    error_hv_insufficient_buffers* =    0xC0350013.HResult
      ## Not enough buffers were supplied to send a message.

    error_hv_not_acknowledged* =        0xC0350014.HResult
      ## The previous virtual interrupt has not been acknowledged.

    error_hv_invalid_vp_state* =        0xC0350015.HResult
      ## A virtual processor is not in the correct state for the indicated operation.

    error_hv_acknowledged* =            0xC0350016.HResult
      ## The previous virtual interrupt has already been acknowledged.

    error_hv_invalid_save_restore_state* = 0xC0350017.HResult
      ## The indicated partition is not in a valid state for saving or restoring.

    error_hv_invalid_synic_state* =     0xC0350018.HResult
      ## The hypervisor could not complete the operation because a required feature of the synthetic interrupt controller (SynIC) was disabled.

    error_hv_object_in_use* =           0xC0350019.HResult
      ## The hypervisor could not perform the operation because the object or value was either already in use or being used for a purpose that would not permit completing the operation.

    error_hv_invalid_proximity_domain_info* = 0xC035001A.HResult
      ## The proximity domain information is invalid.

    error_hv_no_data* =                 0xC035001B.HResult
      ## An attempt to retrieve debugging data failed because none was available.

    error_hv_inactive* =                0xC035001C.HResult
      ## The physical connection being used for debuggging has not recorded any receive activity since the last operation.

    error_hv_no_resources* =            0xC035001D.HResult
      ## There are not enough resources to complete the operation.

    error_hv_feature_unavailable* =     0xC035001E.HResult
      ## A hypervisor feature is not available to the user.

    error_hv_insufficient_buffer* =     0xC0350033.HResult
      ## The specified buffer was too small to contain all of the requested data.

    error_hv_insufficient_device_domains* = 0xC0350038.HResult
      ## The maximum number of domains supported by the platform I/O remapping hardware is currently in use. No domains are available to assign this device to this partition.

    error_hv_cpuid_feature_validation* = 0xC035003C.HResult
      ## Validation of CPUID data of the processor failed.

    error_hv_cpuid_xsave_feature_validation* = 0xC035003D.HResult
      ## Validation of XSAVE CPUID data of the processor failed.

    error_hv_processor_startup_timeout* = 0xC035003E.HResult
      ## Processor did not respond within the timeout period.

    error_hv_smx_enabled* =             0xC035003F.HResult
      ## SMX has been enabled in the BIOS.

    error_hv_invalid_lp_index* =        0xC0350041.HResult
      ## The hypervisor could not perform the operation because the specified LP index is invalid.

    error_hv_invalid_register_value* =  0xC0350050.HResult
      ## The supplied register value is invalid.

    error_hv_invalid_vtl_state* =       0xC0350051.HResult
      ## The supplied virtual trust level is not in the correct state to perform the requested operation.

    error_hv_nx_not_detected* =         0xC0350055.HResult
      ## No execute feature (NX) is not present or not enabled in the BIOS.

    error_hv_invalid_device_id* =       0xC0350057.HResult
      ## The supplied device ID is invalid.

    error_hv_invalid_device_state* =    0xC0350058.HResult
      ## The operation is not allowed in the current device state.

    error_hv_pending_page_requests* =   0x00350059.HResult
      ## The device had pending page requests which were discarded.

    error_hv_page_request_invalid* =    0xC0350060.HResult
      ## The supplied page request specifies a memory access that the guest does not have permissions to perform.

    error_hv_invalid_cpu_group_id* =    0xC035006F.HResult
      ## A CPU group with the specified CPU group Id does not exist.

    error_hv_invalid_cpu_group_state* = 0xC0350070.HResult
      ## The hypervisor could not perform the operation because the CPU group is entering or in an invalid state.

    error_hv_not_allowed_with_nested_virt_active* = 0xC0350071.HResult
      ## The hypervisor could not perform the operation because it is not allowed with nested virtualization active.

    error_hv_not_present* =             0xC0351000.HResult
      ## No hypervisor is present on this system.

    #
    # Virtualization error codes - these codes are used by the Virtualization Infrustructure Driver (VID) and other components
    #                              of the virtualization stack.
    #
    # VID errors (0x0001 - 0x00ff)
    #

    error_vid_duplicate_handler* =      0xC0370001.HResult
      ## The handler for the virtualization infrastructure driver is already registered. Restarting the virtual machine may fix the problem. If the problem persists, try restarting the physical computer.

    error_vid_too_many_handlers* =      0xC0370002.HResult
      ## The number of registered handlers for the virtualization infrastructure driver exceeded the maximum. Restarting the virtual machine may fix the problem. If the problem persists, try restarting the physical computer.

    error_vid_queue_full* =             0xC0370003.HResult
      ## The message queue for the virtualization infrastructure driver is full and cannot accept new messages. Restarting the virtual machine may fix the problem. If the problem persists, try restarting the physical computer.

    error_vid_handler_not_present* =    0xC0370004.HResult
      ## No handler exists to handle the message for the virtualization infrastructure driver. Restarting the virtual machine may fix the problem. If the problem persists, try restarting the physical computer.

    error_vid_invalid_object_name* =    0xC0370005.HResult
      ## The name of the partition or message queue for the virtualization infrastructure driver is invalid. Restarting the virtual machine may fix the problem. If the problem persists, try restarting the physical computer.

    error_vid_partition_name_too_long* = 0xC0370006.HResult
      ## The partition name of the virtualization infrastructure driver exceeds the maximum.

    error_vid_message_queue_name_too_long* = 0xC0370007.HResult
      ## The message queue name of the virtualization infrastructure driver exceeds the maximum.

    error_vid_partition_already_exists* = 0xC0370008.HResult
      ## Cannot create the partition for the virtualization infrastructure driver because another partition with the same name already exists.

    error_vid_partition_does_not_exist* = 0xC0370009.HResult
      ## The virtualization infrastructure driver has encountered an error. The requested partition does not exist. Restarting the virtual machine may fix the problem. If the problem persists, try restarting the physical computer.

    error_vid_partition_name_not_found* = 0xC037000A.HResult
      ## The virtualization infrastructure driver has encountered an error. Could not find the requested partition. Restarting the virtual machine may fix the problem. If the problem persists, try restarting the physical computer.

    error_vid_message_queue_already_exists* = 0xC037000B.HResult
      ## A message queue with the same name already exists for the virtualization infrastructure driver.

    error_vid_exceeded_mbp_entry_map_limit* = 0xC037000C.HResult
      ## The memory block page for the virtualization infrastructure driver cannot be mapped because the page map limit has been reached. Restarting the virtual machine may fix the problem. If the problem persists, try restarting the physical computer.

    error_vid_mb_still_referenced* =    0xC037000D.HResult
      ## The memory block for the virtualization infrastructure driver is still being used and cannot be destroyed.

    error_vid_child_gpa_page_set_corrupted* = 0xC037000E.HResult
      ## Cannot unlock the page array for the guest operating system memory address because it does not match a previous lock request. Restarting the virtual machine may fix the problem. If the problem persists, try restarting the physical computer.

    error_vid_invalid_numa_settings* =  0xC037000F.HResult
      ## The non-uniform memory access (NUMA) node settings do not match the system NUMA topology. In order to start the virtual machine, you will need to modify the NUMA configuration.

    error_vid_invalid_numa_node_index* = 0xC0370010.HResult
      ## The non-uniform memory access (NUMA) node index does not match a valid index in the system NUMA topology.

    error_vid_notification_queue_already_associated* = 0xC0370011.HResult
      ## The memory block for the virtualization infrastructure driver is already associated with a message queue.

    error_vid_invalid_memory_block_handle* = 0xC0370012.HResult
      ## The handle is not a valid memory block handle for the virtualization infrastructure driver.

    error_vid_page_range_overflow* =    0xC0370013.HResult
      ## The request exceeded the memory block page limit for the virtualization infrastructure driver. Restarting the virtual machine may fix the problem. If the problem persists, try restarting the physical computer.

    error_vid_invalid_message_queue_handle* = 0xC0370014.HResult
      ## The handle is not a valid message queue handle for the virtualization infrastructure driver.

    error_vid_invalid_gpa_range_handle* = 0xC0370015.HResult
      ## The handle is not a valid page range handle for the virtualization infrastructure driver.

    error_vid_no_memory_block_notification_queue* = 0xC0370016.HResult
      ## Cannot install client notifications because no message queue for the virtualization infrastructure driver is associated with the memory block.

    error_vid_memory_block_lock_count_exceeded* = 0xC0370017.HResult
      ## The request to lock or map a memory block page failed because the virtualization infrastructure driver memory block limit has been reached. Restarting the virtual machine may fix the problem. If the problem persists, try restarting the physical computer.

    error_vid_invalid_ppm_handle* =     0xC0370018.HResult
      ## The handle is not a valid parent partition mapping handle for the virtualization infrastructure driver.

    error_vid_mbps_are_locked* =        0xC0370019.HResult
      ## Notifications cannot be created on the memory block because it is use.

    error_vid_message_queue_closed* =   0xC037001A.HResult
      ## The message queue for the virtualization infrastructure driver has been closed. Restarting the virtual machine may fix the problem. If the problem persists, try restarting the physical computer.

    error_vid_virtual_processor_limit_exceeded* = 0xC037001B.HResult
      ## Cannot add a virtual processor to the partition because the maximum has been reached.

    error_vid_stop_pending* =           0xC037001C.HResult
      ## Cannot stop the virtual processor immediately because of a pending intercept.

    error_vid_invalid_processor_state* = 0xC037001D.HResult
      ## Invalid state for the virtual processor. Restarting the virtual machine may fix the problem. If the problem persists, try restarting the physical computer.

    error_vid_exceeded_km_context_count_limit* = 0xC037001E.HResult
      ## The maximum number of kernel mode clients for the virtualization infrastructure driver has been reached. Restarting the virtual machine may fix the problem. If the problem persists, try restarting the physical computer.

    error_vid_km_interface_already_initialized* = 0xC037001F.HResult
      ## This kernel mode interface for the virtualization infrastructure driver has already been initialized. Restarting the virtual machine may fix the problem. If the problem persists, try restarting the physical computer.

    error_vid_mb_property_already_set_reset* = 0xC0370020.HResult
      ## Cannot set or reset the memory block property more than once for the virtualization infrastructure driver. Restarting the virtual machine may fix the problem. If the problem persists, try restarting the physical computer.

    error_vid_mmio_range_destroyed* =   0xC0370021.HResult
      ## The memory mapped I/O for this page range no longer exists. Restarting the virtual machine may fix the problem. If the problem persists, try restarting the physical computer.

    error_vid_invalid_child_gpa_page_set* = 0xC0370022.HResult
      ## The lock or unlock request uses an invalid guest operating system memory address. Restarting the virtual machine may fix the problem. If the problem persists, try restarting the physical computer.

    error_vid_reserve_page_set_is_being_used* = 0xC0370023.HResult
      ## Cannot destroy or reuse the reserve page set for the virtualization infrastructure driver because it is in use. Restarting the virtual machine may fix the problem. If the problem persists, try restarting the physical computer.

    error_vid_reserve_page_set_too_small* = 0xC0370024.HResult
      ## The reserve page set for the virtualization infrastructure driver is too small to use in the lock request. Restarting the virtual machine may fix the problem. If the problem persists, try restarting the physical computer.

    error_vid_mbp_already_locked_using_reserved_page* = 0xC0370025.HResult
      ## Cannot lock or map the memory block page for the virtualization infrastructure driver because it has already been locked using a reserve page set page. Restarting the virtual machine may fix the problem. If the problem persists, try restarting the physical computer.

    error_vid_mbp_count_exceeded_limit* = 0xC0370026.HResult
      ## Cannot create the memory block for the virtualization infrastructure driver because the requested number of pages exceeded the limit. Restarting the virtual machine may fix the problem. If the problem persists, try restarting the physical computer.

    error_vid_saved_state_corrupt* =    0xC0370027.HResult
      ## Cannot restore this virtual machine because the saved state data cannot be read. Delete the saved state data and then try to start the virtual machine.

    error_vid_saved_state_unrecognized_item* = 0xC0370028.HResult
      ## Cannot restore this virtual machine because an item read from the saved state data is not recognized. Delete the saved state data and then try to start the virtual machine.

    error_vid_saved_state_incompatible* = 0xC0370029.HResult
      ## Cannot restore this virtual machine to the saved state because of hypervisor incompatibility. Delete the saved state data and then try to start the virtual machine.

    error_vid_vtl_access_denied* =      0xC037002A.HResult
      ## The specified VTL does not have the permission to access the resource.

    #
    # Host compute service errors (0x0100-0x01ff)
    #
    error_vmcompute_terminated_during_start* = 0xC0370100.HResult
      ## The compute system unexpectedly terminated while starting.

    error_vmcompute_image_mismatch* =   0xC0370101.HResult
      ## The operating system of the container does not match the operating system of the host.

    error_vmcompute_hyperv_not_installed* = 0xC0370102.HResult
      ## A Virtual Machine could not be started because Hyper-V is not installed.

    error_vmcompute_operation_pending* = 0xC0370103.HResult
      ## The call to start an asynchronous operation succeeded and the operation is performed in the background.

    error_vmcompute_too_many_notifications* = 0xC0370104.HResult
      ## The supported number of notification callbacks has been exceeded.

    error_vmcompute_invalid_state* =    0xC0370105.HResult
      ## The requested compute system operation is not valid in the current state.

    error_vmcompute_unexpected_exit* =  0xC0370106.HResult
      ## The compute system exited unexpectedly.

    error_vmcompute_terminated* =       0xC0370107.HResult
      ## The compute system was forcefully terminated.

    error_vmcompute_connect_failed* =   0xC0370108.HResult
      ## A connection could not be established with the Virtual Machine hosting the Container.

    error_vmcompute_timeout* =          0xC0370109.HResult
      ## The operation timed out because a response was not received from the Virtual Machine hosting the Container.

    error_vmcompute_connection_closed* = 0xC037010A.HResult
      ## The connection with the Virtual Machine hosting the container was closed.

    error_vmcompute_unknown_message* =  0xC037010B.HResult
      ## An unknown internal message was received by the Hyper-V Compute Service.

    error_vmcompute_unsupported_protocol_version* = 0xC037010C.HResult
      ## The communication protocol version between the Hyper-V Host and Guest Compute Services is not supported.

    error_vmcompute_invalid_json* =     0xC037010D.HResult
      ## The JSON document is invalid.

    error_vmcompute_system_not_found* = 0xC037010E.HResult
      ## A Compute System with the specified identifier does not exist.

    error_vmcompute_system_already_exists* = 0xC037010F.HResult
      ## A Compute System with the specified identifier already exists.

    error_vmcompute_system_already_stopped* = 0xC0370110.HResult
      ## The Compute System with the specified identifier did already stop.

    #
    # Virtual networking errors (0x0200-0x02ff)
    #
    error_vnet_virtual_switch_name_not_found* = 0xC0370200.HResult
      ## A virtual switch with the given name was not found.

    #
    # VID warnings (0x0000 - 0x00ff):
    #
    error_vid_remote_node_parent_gpa_pages_used* = 0x80370001.HResult
      ## A virtual machine is running with its memory allocated across multiple NUMA nodes. This does not indicate a problem unless the performance of your virtual machine is unusually slow. If you are experiencing performance problems, you may need to modify the NUMA configuration.


    #
    # Volume manager error codes mapped from status codes
    #

    #
    # WARNINGS
    #
    error_volmgr_incomplete_regeneration* = 0x80380001.HResult
      ## The regeneration operation was not able to copy all data from the active plexes due to bad sectors.

    error_volmgr_incomplete_disk_migration* = 0x80380002.HResult
      ## One or more disks were not fully migrated to the target pack. They may or may not require reimport after fixing the hardware problems.

    #
    # ERRORS
    #
    error_volmgr_database_full* =       0xC0380001.HResult
      ## The configuration database is full.

    error_volmgr_disk_configuration_corrupted* = 0xC0380002.HResult
      ## The configuration data on the disk is corrupted.

    error_volmgr_disk_configuration_not_in_sync* = 0xC0380003.HResult
      ## The configuration on the disk is not insync with the in-memory configuration.

    error_volmgr_pack_config_update_failed* = 0xC0380004.HResult
      ## A majority of disks failed to be updated with the new configuration.

    error_volmgr_disk_contains_non_simple_volume* = 0xC0380005.HResult
      ## The disk contains non-simple volumes.

    error_volmgr_disk_duplicate* =      0xC0380006.HResult
      ## The same disk was specified more than once in the migration list.

    error_volmgr_disk_dynamic* =        0xC0380007.HResult
      ## The disk is already dynamic.

    error_volmgr_disk_id_invalid* =     0xC0380008.HResult
      ## The specified disk id is invalid. There are no disks with the specified disk id.

    error_volmgr_disk_invalid* =        0xC0380009.HResult
      ## The specified disk is an invalid disk. Operation cannot complete on an invalid disk.

    error_volmgr_disk_last_voter* =     0xC038000A.HResult
      ## The specified disk(s) cannot be removed since it is the last remaining voter.

    error_volmgr_disk_layout_invalid* = 0xC038000B.HResult
      ## The specified disk has an invalid disk layout.

    error_volmgr_disk_layout_non_basic_between_basic_partitions* = 0xC038000C.HResult
      ## The disk layout contains non-basic partitions which appear after basic paritions. This is an invalid disk layout.

    error_volmgr_disk_layout_not_cylinder_aligned* = 0xC038000D.HResult
      ## The disk layout contains partitions which are not cylinder aligned.

    error_volmgr_disk_layout_partitions_too_small* = 0xC038000E.HResult
      ## The disk layout contains partitions which are samller than the minimum size.

    error_volmgr_disk_layout_primary_between_logical_partitions* = 0xC038000F.HResult
      ## The disk layout contains primary partitions in between logical drives. This is an invalid disk layout.

    error_volmgr_disk_layout_too_many_partitions* = 0xC0380010.HResult
      ## The disk layout contains more than the maximum number of supported partitions.

    error_volmgr_disk_missing* =        0xC0380011.HResult
      ## The specified disk is missing. The operation cannot complete on a missing disk.

    error_volmgr_disk_not_empty* =      0xC0380012.HResult
      ## The specified disk is not empty.

    error_volmgr_disk_not_enough_space* = 0xC0380013.HResult
      ## There is not enough usable space for this operation.

    error_volmgr_disk_revectoring_failed* = 0xC0380014.HResult
      ## The force revectoring of bad sectors failed.

    error_volmgr_disk_sector_size_invalid* = 0xC0380015.HResult
      ## The specified disk has an invalid sector size.

    error_volmgr_disk_set_not_contained* = 0xC0380016.HResult
      ## The specified disk set contains volumes which exist on disks outside of the set.

    error_volmgr_disk_used_by_multiple_members* = 0xC0380017.HResult
      ## A disk in the volume layout provides extents to more than one member of a plex.

    error_volmgr_disk_used_by_multiple_plexes* = 0xC0380018.HResult
      ## A disk in the volume layout provides extents to more than one plex.

    error_volmgr_dynamic_disk_not_supported* = 0xC0380019.HResult
      ## Dynamic disks are not supported on this system.

    error_volmgr_extent_already_used* = 0xC038001A.HResult
      ## The specified extent is already used by other volumes.

    error_volmgr_extent_not_contiguous* = 0xC038001B.HResult
      ## The specified volume is retained and can only be extended into a contiguous extent. The specified extent to grow the volume is not contiguous with the specified volume.

    error_volmgr_extent_not_in_public_region* = 0xC038001C.HResult
      ## The specified volume extent is not within the public region of the disk.

    error_volmgr_extent_not_sector_aligned* = 0xC038001D.HResult
      ## The specifed volume extent is not sector aligned.

    error_volmgr_extent_overlaps_ebr_partition* = 0xC038001E.HResult
      ## The specified parition overlaps an EBR (the first track of an extended partition on a MBR disks).

    error_volmgr_extent_volume_lengths_do_not_match* = 0xC038001F.HResult
      ## The specified extent lengths cannot be used to construct a volume with specified length.

    error_volmgr_fault_tolerant_not_supported* = 0xC0380020.HResult
      ## The system does not support fault tolerant volumes.

    error_volmgr_interleave_length_invalid* = 0xC0380021.HResult
      ## The specified interleave length is invalid.

    error_volmgr_maximum_registered_users* = 0xC0380022.HResult
      ## There is already a maximum number of registered users.

    error_volmgr_member_in_sync* =      0xC0380023.HResult
      ## The specified member is already in-sync with the other active members. It does not need to be regenerated.

    error_volmgr_member_index_duplicate* = 0xC0380024.HResult
      ## The same member index was specified more than once.

    error_volmgr_member_index_invalid* = 0xC0380025.HResult
      ## The specified member index is greater or equal than the number of members in the volume plex.

    error_volmgr_member_missing* =      0xC0380026.HResult
      ## The specified member is missing. It cannot be regenerated.

    error_volmgr_member_not_detached* = 0xC0380027.HResult
      ## The specified member is not detached. Cannot replace a member which is not detached.

    error_volmgr_member_regenerating* = 0xC0380028.HResult
      ## The specified member is already regenerating.

    error_volmgr_all_disks_failed* =    0xC0380029.HResult
      ## All disks belonging to the pack failed.

    error_volmgr_no_registered_users* = 0xC038002A.HResult
      ## There are currently no registered users for notifications. The task number is irrelevant unless there are registered users.

    error_volmgr_no_such_user* =        0xC038002B.HResult
      ## The specified notification user does not exist. Failed to unregister user for notifications.

    error_volmgr_notification_reset* =  0xC038002C.HResult
      ## The notifications have been reset. Notifications for the current user are invalid. Unregister and re-register for notifications.

    error_volmgr_number_of_members_invalid* = 0xC038002D.HResult
      ## The specified number of members is invalid.

    error_volmgr_number_of_plexes_invalid* = 0xC038002E.HResult
      ## The specified number of plexes is invalid.

    error_volmgr_pack_duplicate* =      0xC038002F.HResult
      ## The specified source and target packs are identical.

    error_volmgr_pack_id_invalid* =     0xC0380030.HResult
      ## The specified pack id is invalid. There are no packs with the specified pack id.

    error_volmgr_pack_invalid* =        0xC0380031.HResult
      ## The specified pack is the invalid pack. The operation cannot complete with the invalid pack.

    error_volmgr_pack_name_invalid* =   0xC0380032.HResult
      ## The specified pack name is invalid.

    error_volmgr_pack_offline* =        0xC0380033.HResult
      ## The specified pack is offline.

    error_volmgr_pack_has_quorum* =     0xC0380034.HResult
      ## The specified pack already has a quorum of healthy disks.

    error_volmgr_pack_without_quorum* = 0xC0380035.HResult
      ## The pack does not have a quorum of healthy disks.

    error_volmgr_partition_style_invalid* = 0xC0380036.HResult
      ## The specified disk has an unsupported partition style. Only MBR and GPT partition styles are supported.

    error_volmgr_partition_update_failed* = 0xC0380037.HResult
      ## Failed to update the disk's partition layout.

    error_volmgr_plex_in_sync* =        0xC0380038.HResult
      ## The specified plex is already in-sync with the other active plexes. It does not need to be regenerated.

    error_volmgr_plex_index_duplicate* = 0xC0380039.HResult
      ## The same plex index was specified more than once.

    error_volmgr_plex_index_invalid* =  0xC038003A.HResult
      ## The specified plex index is greater or equal than the number of plexes in the volume.

    error_volmgr_plex_last_active* =    0xC038003B.HResult
      ## The specified plex is the last active plex in the volume. The plex cannot be removed or else the volume will go offline.

    error_volmgr_plex_missing* =        0xC038003C.HResult
      ## The specified plex is missing.

    error_volmgr_plex_regenerating* =   0xC038003D.HResult
      ## The specified plex is currently regenerating.

    error_volmgr_plex_type_invalid* =   0xC038003E.HResult
      ## The specified plex type is invalid.

    error_volmgr_plex_not_raid5* =      0xC038003F.HResult
      ## The operation is only supported on RAID-5 plexes.

    error_volmgr_plex_not_simple* =     0xC0380040.HResult
      ## The operation is only supported on simple plexes.

    error_volmgr_structure_size_invalid* = 0xC0380041.HResult
      ## The Size fields in the VM_VOLUME_LAYOUT input structure are incorrectly set.

    error_volmgr_too_many_notification_requests* = 0xC0380042.HResult
      ## There is already a pending request for notifications. Wait for the existing request to return before requesting for more notifications.

    error_volmgr_transaction_in_progress* = 0xC0380043.HResult
      ## There is currently a transaction in process.

    error_volmgr_unexpected_disk_layout_change* = 0xC0380044.HResult
      ## An unexpected layout change occurred outside of the volume manager.

    error_volmgr_volume_contains_missing_disk* = 0xC0380045.HResult
      ## The specified volume contains a missing disk.

    error_volmgr_volume_id_invalid* =   0xC0380046.HResult
      ## The specified volume id is invalid. There are no volumes with the specified volume id.

    error_volmgr_volume_length_invalid* = 0xC0380047.HResult
      ## The specified volume length is invalid.

    error_volmgr_volume_length_not_sector_size_multiple* = 0xC0380048.HResult
      ## The specified size for the volume is not a multiple of the sector size.

    error_volmgr_volume_not_mirrored* = 0xC0380049.HResult
      ## The operation is only supported on mirrored volumes.

    error_volmgr_volume_not_retained* = 0xC038004A.HResult
      ## The specified volume does not have a retain partition.

    error_volmgr_volume_offline* =      0xC038004B.HResult
      ## The specified volume is offline.

    error_volmgr_volume_retained* =     0xC038004C.HResult
      ## The specified volume already has a retain partition.

    error_volmgr_number_of_extents_invalid* = 0xC038004D.HResult
      ## The specified number of extents is invalid.

    error_volmgr_different_sector_size* = 0xC038004E.HResult
      ## All disks participating to the volume must have the same sector size.

    error_volmgr_bad_boot_disk* =       0xC038004F.HResult
      ## The boot disk experienced failures.

    error_volmgr_pack_config_offline* = 0xC0380050.HResult
      ## The configuration of the pack is offline.

    error_volmgr_pack_config_online* =  0xC0380051.HResult
      ## The configuration of the pack is online.

    error_volmgr_not_primary_pack* =    0xC0380052.HResult
      ## The specified pack is not the primary pack.

    error_volmgr_pack_log_update_failed* = 0xC0380053.HResult
      ## All disks failed to be updated with the new content of the log.

    error_volmgr_number_of_disks_in_plex_invalid* = 0xC0380054.HResult
      ## The specified number of disks in a plex is invalid.

    error_volmgr_number_of_disks_in_member_invalid* = 0xC0380055.HResult
      ## The specified number of disks in a plex member is invalid.

    error_volmgr_volume_mirrored* =     0xC0380056.HResult
      ## The operation is not supported on mirrored volumes.

    error_volmgr_plex_not_simple_spanned* = 0xC0380057.HResult
      ## The operation is only supported on simple and spanned plexes.

    error_volmgr_no_valid_log_copies* = 0xC0380058.HResult
      ## The pack has no valid log copies.

    error_volmgr_primary_pack_present* = 0xC0380059.HResult
      ## A primary pack is already present.

    error_volmgr_number_of_disks_invalid* = 0xC038005A.HResult
      ## The specified number of disks is invalid.

    error_volmgr_mirror_not_supported* = 0xC038005B.HResult
      ## The system does not support mirrored volumes.

    error_volmgr_raid5_not_supported* = 0xC038005C.HResult
      ## The system does not support RAID-5 volumes.


    #
    # Boot Code Data (BCD) error codes
    #

    error_bcd_not_all_entries_imported* = 0x80390001.HResult
      ## Some BCD entries were not imported correctly from the BCD store.

    error_bcd_too_many_elements* =      0xC0390002.HResult
      ## Entries enumerated have exceeded the allowed threshold.

    error_bcd_not_all_entries_synchronized* = 0x80390003.HResult
      ## Some BCD entries were not synchronized correctly with the firmware.

    #
    # Vhd error codes - These codes are used by the virtual hard diskparser component.
    #
    #
    # Errors:
    #

    error_vhd_drive_footer_missing* =   0xC03A0001.HResult
      ## The virtual hard disk is corrupted. The virtual hard disk drive footer is missing.

    error_vhd_drive_footer_checksum_mismatch* = 0xC03A0002.HResult
      ## The virtual hard disk is corrupted. The virtual hard disk drive footer checksum does not match the on-disk checksum.

    error_vhd_drive_footer_corrupt* =   0xC03A0003.HResult
      ## The virtual hard disk is corrupted. The virtual hard disk drive footer in the virtual hard disk is corrupted.

    error_vhd_format_unknown* =         0xC03A0004.HResult
      ## The system does not recognize the file format of this virtual hard disk.

    error_vhd_format_unsupported_version* = 0xC03A0005.HResult
      ## The version does not support this version of the file format.

    error_vhd_sparse_header_checksum_mismatch* = 0xC03A0006.HResult
      ## The virtual hard disk is corrupted. The sparse header checksum does not match the on-disk checksum.

    error_vhd_sparse_header_unsupported_version* = 0xC03A0007.HResult
      ## The system does not support this version of the virtual hard disk.This version of the sparse header is not supported.

    error_vhd_sparse_header_corrupt* =  0xC03A0008.HResult
      ## The virtual hard disk is corrupted. The sparse header in the virtual hard disk is corrupt.

    error_vhd_block_allocation_failure* = 0xC03A0009.HResult
      ## Failed to write to the virtual hard disk failed because the system failed to allocate a new block in the virtual hard disk.

    error_vhd_block_allocation_table_corrupt* = 0xC03A000A.HResult
      ## The virtual hard disk is corrupted. The block allocation table in the virtual hard disk is corrupt.

    error_vhd_invalid_block_size* =     0xC03A000B.HResult
      ## The system does not support this version of the virtual hard disk. The block size is invalid.

    error_vhd_bitmap_mismatch* =        0xC03A000C.HResult
      ## The virtual hard disk is corrupted. The block bitmap does not match with the block data present in the virtual hard disk.

    error_vhd_parent_vhd_not_found* =   0xC03A000D.HResult
      ## The chain of virtual hard disks is broken. The system cannot locate the parent virtual hard disk for the differencing disk.

    error_vhd_child_parent_id_mismatch* = 0xC03A000E.HResult
      ## The chain of virtual hard disks is corrupted. There is a mismatch in the identifiers of the parent virtual hard disk and differencing disk.

    error_vhd_child_parent_timestamp_mismatch* = 0xC03A000F.HResult
      ## The chain of virtual hard disks is corrupted. The time stamp of the parent virtual hard disk does not match the time stamp of the differencing disk.

    error_vhd_metadata_read_failure* =  0xC03A0010.HResult
      ## Failed to read the metadata of the virtual hard disk.

    error_vhd_metadata_write_failure* = 0xC03A0011.HResult
      ## Failed to write to the metadata of the virtual hard disk.

    error_vhd_invalid_size* =           0xC03A0012.HResult
      ## The size of the virtual hard disk is not valid.

    error_vhd_invalid_file_size* =      0xC03A0013.HResult
      ## The file size of this virtual hard disk is not valid.

    error_virtdisk_provider_not_found* = 0xC03A0014.HResult
      ## A virtual disk support provider for the specified file was not found.

    error_virtdisk_not_virtual_disk* =  0xC03A0015.HResult
      ## The specified disk is not a virtual disk.

    error_vhd_parent_vhd_access_denied* = 0xC03A0016.HResult
      ## The chain of virtual hard disks is inaccessible. The process has not been granted access rights to the parent virtual hard disk for the differencing disk.

    error_vhd_child_parent_size_mismatch* = 0xC03A0017.HResult
      ## The chain of virtual hard disks is corrupted. There is a mismatch in the virtual sizes of the parent virtual hard disk and differencing disk.

    error_vhd_differencing_chain_cycle_detected* = 0xC03A0018.HResult
      ## The chain of virtual hard disks is corrupted. A differencing disk is indicated in its own parent chain.

    error_vhd_differencing_chain_error_in_parent* = 0xC03A0019.HResult
      ## The chain of virtual hard disks is inaccessible. There was an error opening a virtual hard disk further up the chain.

    error_virtual_disk_limitation* =    0xC03A001A.HResult
      ## The requested operation could not be completed due to a virtual disk system limitation.  Virtual hard disk files must be uncompressed and unencrypted and must not be sparse.

    error_vhd_invalid_type* =           0xC03A001B.HResult
      ## The requested operation cannot be performed on a virtual disk of this type.

    error_vhd_invalid_state* =          0xC03A001C.HResult
      ## The requested operation cannot be performed on the virtual disk in its current state.

    error_virtdisk_unsupported_disk_sector_size* = 0xC03A001D.HResult
      ## The sector size of the physical disk on which the virtual disk resides is not supported.

    error_virtdisk_disk_already_owned* = 0xC03A001E.HResult
      ## The disk is already owned by a different owner.

    error_virtdisk_disk_online_and_writable* = 0xC03A001F.HResult
      ## The disk must be offline or read-only.

    error_ctlog_tracking_not_initialized* = 0xC03A0020.HResult
      ## Change Tracking is not initialized for this virtual disk.

    error_ctlog_logfile_size_exceeded_maxsize* = 0xC03A0021.HResult
      ## Size of change tracking file exceeded the maximum size limit.

    error_ctlog_vhd_changed_offline* =  0xC03A0022.HResult
      ## VHD file is changed due to compaction, expansion, or offline updates.

    error_ctlog_invalid_tracking_state* = 0xC03A0023.HResult
      ## Change Tracking for the virtual disk is not in a valid state to perform this request.  Change tracking could be discontinued or already in the requested state.

    error_ctlog_inconsistent_tracking_file* = 0xC03A0024.HResult
      ## Change Tracking file for the virtual disk is not in a valid state.

    error_vhd_resize_would_truncate_data* = 0xC03A0025.HResult
      ## The requested resize operation could not be completed because it might truncate user data residing on the virtual disk.

    error_vhd_could_not_compute_minimum_virtual_size* = 0xC03A0026.HResult
      ## The requested operation could not be completed because the virtual disk's minimum safe size could not be determined.
      ## This may be due to a missing or corrupt partition table.

    error_vhd_already_at_or_below_minimum_virtual_size* = 0xC03A0027.HResult
      ## The requested operation could not be completed because the virtual disk's size cannot be safely reduced further.

    error_vhd_metadata_full* =          0xC03A0028.HResult
      ## There is not enough space in the virtual disk file for the provided metadata item.

    error_vhd_invalid_change_tracking_id* = 0xC03A0029.HResult
      ## The specified change tracking identifier is not valid.

    error_vhd_change_tracking_disabled* = 0xC03A002A.HResult
      ## Change tracking is disabled for the specified virtual hard disk, so no change tracking information is available.

    error_vhd_missing_change_tracking_information* = 0xC03A0030.HResult
      ## There is no change tracking data available associated with the specified change tracking identifier.

    #
    # Warnings:
    #
    error_query_storage_error* =        0x803A0001.HResult
      ## The virtualization storage subsystem has generated an error.

    #
    # =======================================================
    # Host Network Service (HNS) Error Messages
    # =======================================================
    #
    error_hns_port_allocated* =         0xC03B0001.HResult
      ## The port is already allocated

    error_hns_mapping_not_supported* =  0xC03B0002.HResult
      ## Port mapping is not supported on the given network

    #
    # =======================================================
    # Facility Scripted Diagnostics (SDIAG) Error Messages
    # =======================================================
    #
    sdiag_e_cancelled* =                0x803C0100.HResult
      ## The operation was cancelled.

    sdiag_e_script* =                   0x803C0101.HResult
      ## An error occurred when running a PowerShell script.

    sdiag_e_powershell* =               0x803C0102.HResult
      ## An error occurred when interacting with PowerShell runtime.

    sdiag_e_managedhost* =              0x803C0103.HResult
      ## An error occurred in the Scripted Diagnostic Managed Host.

    sdiag_e_noverifier* =               0x803C0104.HResult
      ## The troubleshooting pack does not contain a required verifier to complete the verification.

    sdiag_s_cannotrun* =                0x003C0105.HResult
      ## The troubleshooting pack cannot be executed on this system.

    sdiag_e_disabled* =                 0x803C0106.HResult
      ## Scripted diagnostics is disabled by group policy.

    sdiag_e_trust* =                    0x803C0107.HResult
      ## Trust validation of the troubleshooting pack failed.

    sdiag_e_cannotrun* =                0x803C0108.HResult
      ## The troubleshooting pack cannot be executed on this system.

    sdiag_e_version* =                  0x803C0109.HResult
      ## This version of the troubleshooting pack is not supported.

    sdiag_e_resource* =                 0x803C010A.HResult
      ## A required resource cannot be loaded.

    sdiag_e_rootcause* =                0x803C010B.HResult
      ## The troubleshooting pack reported information for a root cause without adding the root cause.

    #
    # =======================================================
    # Facility Windows Push Notifications (WPN) Error Messages
    # =======================================================
    #
    wpn_e_channel_closed* =             0x803E0100.HResult
      ## The notification channel has already been closed.

    wpn_e_channel_request_not_complete* = 0x803E0101.HResult
      ## The notification channel request did not complete successfully.

    wpn_e_invalid_app* =                0x803E0102.HResult
      ## The application identifier provided is invalid.

    wpn_e_outstanding_channel_request* = 0x803E0103.HResult
      ## A notification channel request for the provided application identifier is in progress.

    wpn_e_duplicate_channel* =          0x803E0104.HResult
      ## The channel identifier is already tied to another application endpoint.

    wpn_e_platform_unavailable* =       0x803E0105.HResult
      ## The notification platform is unavailable.

    wpn_e_notification_posted* =        0x803E0106.HResult
      ## The notification has already been posted.

    wpn_e_notification_hidden* =        0x803E0107.HResult
      ## The notification has already been hidden.

    wpn_e_notification_not_posted* =    0x803E0108.HResult
      ## The notification cannot be hidden until it has been shown.

    wpn_e_cloud_disabled* =             0x803E0109.HResult
      ## Cloud notifications have been turned off.

    wpn_e_cloud_incapable* =            0x803E0110.HResult
      ## The application does not have the cloud notification capability.

    wpn_e_cloud_auth_unavailable* =     0x803E011A.HResult
      ## The notification platform is unable to retrieve the authentication credentials required to connect to the cloud notification service.

    wpn_e_cloud_service_unavailable* =  0x803E011B.HResult
      ## The notification platform is unable to connect to the cloud notification service.

    wpn_e_failed_lock_screen_update_intialization* = 0x803E011C.HResult
      ## The notification platform is unable to initialize a callback for lock screen updates.

    wpn_e_notification_disabled* =      0x803E0111.HResult
      ## Settings prevent the notification from being delivered.

    wpn_e_notification_incapable* =     0x803E0112.HResult
      ## Application capabilities prevent the notification from being delivered.

    wpn_e_internet_incapable* =         0x803E0113.HResult
      ## The application does not have the internet access capability.

    wpn_e_notification_type_disabled* = 0x803E0114.HResult
      ## Settings prevent the notification type from being delivered.

    wpn_e_notification_size* =          0x803E0115.HResult
      ## The size of the notification content is too large.

    wpn_e_tag_size* =                   0x803E0116.HResult
      ## The size of the notification tag is too large.

    wpn_e_access_denied* =              0x803E0117.HResult
      ## The notification platform doesn't have appropriate privilege on resources.

    wpn_e_duplicate_registration* =     0x803E0118.HResult
      ## The notification platform found application is already registered.

    wpn_e_push_notification_incapable* = 0x803E0119.HResult
      ## The application background task does not have the push notification capability.

    wpn_e_dev_id_size* =                0x803E0120.HResult
      ## The size of the developer id for scheduled notification is too large.

    wpn_e_tag_alphanumeric* =           0x803E012A.HResult
      ## The notification tag is not alphanumeric.

    wpn_e_invalid_http_status_code* =   0x803E012B.HResult
      ## The notification platform has received invalid HTTP status code other than 2xx for polling.

    wpn_e_out_of_session* =             0x803E0200.HResult
      ## The notification platform has run out of presentation layer sessions.

    wpn_e_power_save* =                 0x803E0201.HResult
      ## The notification platform rejects image download request due to system in power save mode.

    wpn_e_image_not_found_in_cache* =   0x803E0202.HResult
      ## The notification platform doesn't have the requested image in its cache.

    wpn_e_all_url_not_completed* =      0x803E0203.HResult
      ## The notification platform cannot complete all of requested image.

    wpn_e_invalid_cloud_image* =        0x803E0204.HResult
      ## A cloud image downloaded from the notification platform is invalid.

    wpn_e_notification_id_matched* =    0x803E0205.HResult
      ## Notification Id provided as filter is matched with what the notification platform maintains.

    wpn_e_callback_already_registered* = 0x803E0206.HResult
      ## Notification callback interface is already registered.

    wpn_e_toast_notification_dropped* = 0x803E0207.HResult
      ## Toast Notification was dropped without being displayed to the user.

    wpn_e_storage_locked* =             0x803E0208.HResult
      ## The notification platform does not have the proper privileges to complete the request.

    wpn_e_group_size* =                 0x803E0209.HResult
      ## The size of the notification group is too large.

    wpn_e_group_alphanumeric* =         0x803E020A.HResult
      ## The notification group is not alphanumeric.

    wpn_e_cloud_disabled_for_app* =     0x803E020B.HResult
      ## Cloud notifications have been disabled for the application due to a policy setting.


    #
    # MBN error codes
    #

    e_mbn_context_not_activated* =      0x80548201.HResult
      ## Context is not activated.

    e_mbn_bad_sim* =                    0x80548202.HResult
      ## Bad SIM is inserted.

    e_mbn_data_class_not_available* =   0x80548203.HResult
      ## Requested data class is not avaialable.

    e_mbn_invalid_access_string* =      0x80548204.HResult
      ## Access point name (APN) or Access string is incorrect.

    e_mbn_max_activated_contexts* =     0x80548205.HResult
      ## Max activated contexts have reached.

    e_mbn_packet_svc_detached* =        0x80548206.HResult
      ## Device is in packet detach state.

    e_mbn_provider_not_visible* =       0x80548207.HResult
      ## Provider is not visible.

    e_mbn_radio_power_off* =            0x80548208.HResult
      ## Radio is powered off.

    e_mbn_service_not_activated* =      0x80548209.HResult
      ## MBN subscription is not activated.

    e_mbn_sim_not_inserted* =           0x8054820A.HResult
      ## SIM is not inserted.

    e_mbn_voice_call_in_progress* =     0x8054820B.HResult
      ## Voice call in progress.

    e_mbn_invalid_cache* =              0x8054820C.HResult
      ## Visible provider cache is invalid.

    e_mbn_not_registered* =             0x8054820D.HResult
      ## Device is not registered.

    e_mbn_providers_not_found* =        0x8054820E.HResult
      ## Providers not found.

    e_mbn_pin_not_supported* =          0x8054820F.HResult
      ## Pin is not supported.

    e_mbn_pin_required* =               0x80548210.HResult
      ## Pin is required.

    e_mbn_pin_disabled* =               0x80548211.HResult
      ## PIN is disabled.

    e_mbn_failure* =                    0x80548212.HResult
      ## Generic Failure.

    # Profile related error messages
    e_mbn_invalid_profile* =            0x80548218.HResult
      ## Profile is invalid.

    e_mbn_default_profile_exist* =      0x80548219.HResult
      ## Default profile exist.

    # SMS related error messages
    e_mbn_sms_encoding_not_supported* = 0x80548220.HResult
      ## SMS encoding is not supported.

    e_mbn_sms_filter_not_supported* =   0x80548221.HResult
      ## SMS filter is not supported.

    e_mbn_sms_invalid_memory_index* =   0x80548222.HResult
      ## Invalid SMS memory index is used.

    e_mbn_sms_lang_not_supported* =     0x80548223.HResult
      ## SMS language is not supported.

    e_mbn_sms_memory_failure* =         0x80548224.HResult
      ## SMS memory failure occurred.

    e_mbn_sms_network_timeout* =        0x80548225.HResult
      ## SMS network timeout happened.

    e_mbn_sms_unknown_smsc_address* =   0x80548226.HResult
      ## Unknown SMSC address is used.

    e_mbn_sms_format_not_supported* =   0x80548227.HResult
      ## SMS format is not supported.

    e_mbn_sms_operation_not_allowed* =  0x80548228.HResult
      ## SMS operation is not allowed.

    e_mbn_sms_memory_full* =            0x80548229.HResult
      ## Device SMS memory is full.


    #
    # P2P error codes
    #

    peer_e_ipv6_not_installed* =        0x80630001.HResult
      ## The IPv6 protocol is not installed.

    peer_e_not_initialized* =           0x80630002.HResult
      ## The compoment has not been initialized.

    peer_e_cannot_start_service* =      0x80630003.HResult
      ## The required service canot be started.

    peer_e_not_licensed* =              0x80630004.HResult
      ## The P2P protocol is not licensed to run on this OS.

    peer_e_invalid_graph* =             0x80630010.HResult
      ## The graph handle is invalid.

    peer_e_dbname_changed* =            0x80630011.HResult
      ## The graph database name has changed.

    peer_e_duplicate_graph* =           0x80630012.HResult
      ## A graph with the same ID already exists.

    peer_e_graph_not_ready* =           0x80630013.HResult
      ## The graph is not ready.

    peer_e_graph_shutting_down* =       0x80630014.HResult
      ## The graph is shutting down.

    peer_e_graph_in_use* =              0x80630015.HResult
      ## The graph is still in use.

    peer_e_invalid_database* =          0x80630016.HResult
      ## The graph database is corrupt.

    peer_e_too_many_attributes* =       0x80630017.HResult
      ## Too many attributes have been used.

    peer_e_connection_not_found* =      0x80630103.HResult
      ## The connection can not be found.

    peer_e_connect_self* =              0x80630106.HResult
      ## The peer attempted to connect to itself.

    peer_e_already_listening* =         0x80630107.HResult
      ## The peer is already listening for connections.

    peer_e_node_not_found* =            0x80630108.HResult
      ## The node was not found.

    peer_e_connection_failed* =         0x80630109.HResult
      ## The Connection attempt failed.

    peer_e_connection_not_authenticated* = 0x8063010A.HResult
      ## The peer connection could not be authenticated.

    peer_e_connection_refused* =        0x8063010B.HResult
      ## The connection was refused.

    peer_e_classifier_too_long* =       0x80630201.HResult
      ## The peer name classifier is too long.

    peer_e_too_many_identities* =       0x80630202.HResult
      ## The maximum number of identities have been created.

    peer_e_no_key_access* =             0x80630203.HResult
      ## Unable to access a key.

    peer_e_groups_exist* =              0x80630204.HResult
      ## The group already exists.

    # record error codes
    peer_e_record_not_found* =          0x80630301.HResult
      ## The requested record could not be found.

    peer_e_database_accessdenied* =     0x80630302.HResult
      ## Access to the database was denied.

    peer_e_dbinitialization_failed* =   0x80630303.HResult
      ## The Database could not be initialized.

    peer_e_max_record_size_exceeded* =  0x80630304.HResult
      ## The record is too big.

    peer_e_database_already_present* =  0x80630305.HResult
      ## The database already exists.

    peer_e_database_not_present* =      0x80630306.HResult
      ## The database could not be found.

    peer_e_identity_not_found* =        0x80630401.HResult
      ## The identity could not be found.

    # eventing error
    peer_e_event_handle_not_found* =    0x80630501.HResult
      ## The event handle could not be found.

    # searching error
    peer_e_invalid_search* =            0x80630601.HResult
      ## Invalid search.

    peer_e_invalid_attributes* =        0x80630602.HResult
      ## The search atributes are invalid.


    # certificate verification error codes
    peer_e_invitation_not_trusted* =    0x80630701.HResult
      ## The invitiation is not trusted.

    peer_e_chain_too_long* =            0x80630703.HResult
      ## The certchain is too long.

    peer_e_invalid_time_period* =       0x80630705.HResult
      ## The time period is invalid.

    peer_e_circular_chain_detected* =   0x80630706.HResult
      ## A circular cert chain was detected.

    peer_e_cert_store_corrupted* =      0x80630801.HResult
      ## The certstore is corrupted.

    peer_e_no_cloud* =                  0x80631001.HResult
      ## The specified PNRP cloud deos not exist.

    peer_e_cloud_name_ambiguous* =      0x80631005.HResult
      ## The cloud name is ambiguous.

    peer_e_invalid_record* =            0x80632010.HResult
      ## The record is invlaid.

    peer_e_not_authorized* =            0x80632020.HResult
      ## Not authorized.

    peer_e_password_does_not_meet_policy* = 0x80632021.HResult
      ## The password does not meet policy requirements.

    peer_e_deferred_validation* =       0x80632030.HResult
      ## The record validation has been defered.

    peer_e_invalid_group_properties* =  0x80632040.HResult
      ## The group properies are invalid.

    peer_e_invalid_peer_name* =         0x80632050.HResult
      ## The peername is invalid.

    peer_e_invalid_classifier* =        0x80632060.HResult
      ## The classifier is invalid.

    peer_e_invalid_friendly_name* =     0x80632070.HResult
      ## The friendly name is invalid.

    peer_e_invalid_role_property* =     0x80632071.HResult
      ## Invalid role property.

    peer_e_invalid_classifier_property* = 0x80632072.HResult
      ## Invalid classifer property.

    peer_e_invalid_record_expiration* = 0x80632080.HResult
      ## Invlaid record expiration.

    peer_e_invalid_credential_info* =   0x80632081.HResult
      ## Invlaid credential info.

    peer_e_invalid_credential* =        0x80632082.HResult
      ## Invalid credential.

    peer_e_invalid_record_size* =       0x80632083.HResult
      ## Invalid record size.

    peer_e_unsupported_version* =       0x80632090.HResult
      ## Unsupported version.

    peer_e_group_not_ready* =           0x80632091.HResult
      ## The group is not ready.

    peer_e_group_in_use* =              0x80632092.HResult
      ## The group is still in use.

    peer_e_invalid_group* =             0x80632093.HResult
      ## The group is invalid.

    peer_e_no_members_found* =          0x80632094.HResult
      ## No members were found.

    peer_e_no_member_connections* =     0x80632095.HResult
      ## There are no member connections.

    peer_e_unable_to_listen* =          0x80632096.HResult
      ## Unable to listen.

    peer_e_identity_deleted* =          0x806320A0.HResult
      ## The identity does not exist.

    peer_e_service_not_available* =     0x806320A1.HResult
      ## The service is not availible.

    # Contacts APIs error code
    peer_e_contact_not_found* =         0x80636001.HResult
      ## THe contact could not be found.

    # Special success codes
    peer_s_graph_data_created* =        0x00630001.HResult
      ## The graph data was created.

    peer_s_no_event_data* =             0x00630002.HResult
      ## There is not more event data.

    peer_s_already_connected* =         0x00632000.HResult
      ## The graph is already connect.

    peer_s_subscription_exists* =       0x00636000.HResult
      ## The subscription already exists.

    peer_s_no_connectivity* =           0x00630005.HResult
      ## No connectivity.

    peer_s_already_a_member* =          0x00630006.HResult
      ## Already a member.

    # Pnrp helpers errors
    peer_e_cannot_convert_peer_name* =  0x80634001.HResult
      ## The peername could not be converted to a DNS pnrp name.

    peer_e_invalid_peer_host_name* =    0x80634002.HResult
      ## Invalid peer host name.

    peer_e_no_more* =                   0x80634003.HResult
      ## No more data could be found.

    peer_e_pnrp_duplicate_peer_name* =  0x80634005.HResult
      ## The existing peer name is already registered.

    # AppInvite APIs error code
    peer_e_invite_cancelled* =          0x80637000.HResult
      ## The app invite request was cancelled by the user.

    peer_e_invite_response_not_available* = 0x80637001.HResult
      ## No response of the invite was received.

    # Serverless presence error codes
    peer_e_not_signed_in* =             0x80637003.HResult
      ## User is not signed into serverless presence.

    peer_e_privacy_declined* =          0x80637004.HResult
      ## The user declined the privacy policy prompt.

    peer_e_timeout* =                   0x80637005.HResult
      ## A timeout occurred.

    peer_e_invalid_address* =           0x80637007.HResult
      ## The address is invalid.

    peer_e_fw_exception_disabled* =     0x80637008.HResult
      ## A required firewall exception is disabled.

    peer_e_fw_blocked_by_policy* =      0x80637009.HResult
      ## The service is blocked by a firewall policy.

    peer_e_fw_blocked_by_shields_up* =  0x8063700A.HResult
      ## Firewall exceptions are disabled.

    peer_e_fw_declined* =               0x8063700B.HResult
      ## The user declined to enable the firewall exceptions.


    #
    # UI error codes
    #

    ui_e_create_failed* =               0x802A0001.HResult
      ## The object could not be created.

    ui_e_shutdown_called* =             0x802A0002.HResult
      ## Shutdown was already called on this object or the object that owns it.

    ui_e_illegal_reentrancy* =          0x802A0003.HResult
      ## This method cannot be called during this type of callback.

    ui_e_object_sealed* =               0x802A0004.HResult
      ## This object has been sealed, so this change is no longer allowed.

    ui_e_value_not_set* =               0x802A0005.HResult
      ## The requested value was never set.

    ui_e_value_not_determined* =        0x802A0006.HResult
      ## The requested value cannot be determined.

    ui_e_invalid_output* =              0x802A0007.HResult
      ## A callback returned an invalid output parameter.

    ui_e_boolean_expected* =            0x802A0008.HResult
      ## A callback returned a success code other than S_OK or S_FALSE.

    ui_e_different_owner* =             0x802A0009.HResult
      ## A parameter that should be owned by this object is owned by a different object.

    ui_e_ambiguous_match* =             0x802A000A.HResult
      ## More than one item matched the search criteria.

    ui_e_fp_overflow* =                 0x802A000B.HResult
      ## A floating-point overflow occurred.

    ui_e_wrong_thread* =                0x802A000C.HResult
      ## This method can only be called from the thread that created the object.

    ui_e_storyboard_active* =           0x802A0101.HResult
      ## The storyboard is currently in the schedule.

    ui_e_storyboard_not_playing* =      0x802A0102.HResult
      ## The storyboard is not playing.

    ui_e_start_keyframe_after_end* =    0x802A0103.HResult
      ## The start keyframe might occur after the end keyframe.

    ui_e_end_keyframe_not_determined* = 0x802A0104.HResult
      ## It might not be possible to determine the end keyframe time when the start keyframe is reached.

    ui_e_loops_overlap* =               0x802A0105.HResult
      ## Two repeated portions of a storyboard might overlap.

    ui_e_transition_already_used* =     0x802A0106.HResult
      ## The transition has already been added to a storyboard.

    ui_e_transition_not_in_storyboard* = 0x802A0107.HResult
      ## The transition has not been added to a storyboard.

    ui_e_transition_eclipsed* =         0x802A0108.HResult
      ## The transition might eclipse the beginning of another transition in the storyboard.

    ui_e_time_before_last_update* =     0x802A0109.HResult
      ## The given time is earlier than the time passed to the last update.

    ui_e_timer_client_already_connected* = 0x802A010A.HResult
      ## This client is already connected to a timer.

    ui_e_invalid_dimension* =           0x802A010B.HResult
      ## The passed dimension is invalid or does not match the object's dimension.

    ui_e_primitive_out_of_bounds* =     0x802A010C.HResult
      ## The added primitive begins at or beyond the duration of the interpolator.

    ui_e_window_closed* =               0x802A0201.HResult
      ## The operation cannot be completed because the window is being closed.


    #
    # Bluetooth Attribute Protocol Warnings
    #

    e_bluetooth_att_invalid_handle* =   0x80650001.HResult
      ## The attribute handle given was not valid on this server.

    e_bluetooth_att_read_not_permitted* = 0x80650002.HResult
      ## The attribute cannot be read.

    e_bluetooth_att_write_not_permitted* = 0x80650003.HResult
      ## The attribute cannot be written.

    e_bluetooth_att_invalid_pdu* =      0x80650004.HResult
      ## The attribute PDU was invalid.

    e_bluetooth_att_insufficient_authentication* = 0x80650005.HResult
      ## The attribute requires authentication before it can be read or written.

    e_bluetooth_att_request_not_supported* = 0x80650006.HResult
      ## Attribute server does not support the request received from the client.

    e_bluetooth_att_invalid_offset* =   0x80650007.HResult
      ## Offset specified was past the end of the attribute.

    e_bluetooth_att_insufficient_authorization* = 0x80650008.HResult
      ## The attribute requires authorization before it can be read or written.

    e_bluetooth_att_prepare_queue_full* = 0x80650009.HResult
      ## Too many prepare writes have been queued.

    e_bluetooth_att_attribute_not_found* = 0x8065000A.HResult
      ## No attribute found within the given attribute handle range.

    e_bluetooth_att_attribute_not_long* = 0x8065000B.HResult
      ## The attribute cannot be read or written using the Read Blob Request.

    e_bluetooth_att_insufficient_encryption_key_size* = 0x8065000C.HResult
      ## The Encryption Key Size used for encrypting this link is insufficient.

    e_bluetooth_att_invalid_attribute_value_length* = 0x8065000D.HResult
      ## The attribute value length is invalid for the operation.

    e_bluetooth_att_unlikely* =         0x8065000E.HResult
      ## The attribute request that was requested has encountered an error that was unlikely, and therefore could not be completed as requested.

    e_bluetooth_att_insufficient_encryption* = 0x8065000F.HResult
      ## The attribute requires encryption before it can be read or written.

    e_bluetooth_att_unsupported_group_type* = 0x80650010.HResult
      ## The attribute type is not a supported grouping attribute as defined by a higher layer specification.

    e_bluetooth_att_insufficient_resources* = 0x80650011.HResult
      ## Insufficient Resources to complete the request.

    e_bluetooth_att_unknown_error* =    0x80651000.HResult
      ## An error that lies in the reserved range has been received.


    #
    # Audio errors
    #

    e_audio_engine_node_not_found* =    0x80660001.HResult
      ## PortCls could not find an audio engine node exposed by a miniport driver claiming support for IMiniportAudioEngineNode.

    e_hdaudio_empty_connection_list* =  0x80660002.HResult
      ## HD Audio widget encountered an unexpected empty connection list.

    e_hdaudio_connection_list_not_supported* = 0x80660003.HResult
      ## HD Audio widget does not support the connection list parameter.

    e_hdaudio_no_logical_devices_created* = 0x80660004.HResult
      ## No HD Audio subdevices were successfully created.

    e_hdaudio_null_linked_list_entry* = 0x80660005.HResult
      ## An unexpected NULL pointer was encountered in a linked list.

    #
    # StateRepository errors
    #
    staterepository_e_concurrency_locking_failure* = 0x80670001.HResult
      ## Optimistic locking failure. Data cannot be updated if it has changed since it was read.

    staterepository_e_statement_inprogress* = 0x80670002.HResult
      ## A prepared statement has been stepped at least once but not run to completion or reset. This may result in busy waits.

    staterepository_e_configuration_invalid* = 0x80670003.HResult
      ## The StateRepository configuration is not valid.

    staterepository_e_unknown_schema_version* = 0x80670004.HResult
      ## The StateRepository schema version is not known.

    staterepository_error_dictionary_corrupted* = 0x80670005.HResult
      ## A StateRepository dictionary is not valid.

    staterepository_e_blocked* =        0x80670006.HResult
      ## The request failed because the StateRepository is actively blocking requests.

    staterepository_e_busy_retry* =     0x80670007.HResult
      ## The database file is locked. The request will be retried.

    staterepository_e_busy_recovery_retry* = 0x80670008.HResult
      ## The database file is locked because another process is busy recovering the database. The request will be retried.

    staterepository_e_locked_retry* =   0x80670009.HResult
      ## A table in the database is locked. The request will be retried.

    staterepository_e_locked_sharedcache_retry* = 0x8067000A.HResult
      ## The shared cache for the database is locked by another connection. The request will be retried.

    staterepository_e_transaction_required* = 0x8067000B.HResult
      ## A transaction is required to perform the request operation.

    #
    # Spaceport errors
    #
    # Success
    error_spaces_pool_was_deleted* =    0x00E70001.HResult
      ## The storage pool was deleted by the driver. The object cache should be updated.

    # Errors
    error_spaces_fault_domain_type_invalid* = 0x80E70001.HResult
      ## The specified fault domain type or combination of minimum / maximum fault domain type is not valid.

    error_spaces_internal_error* =      0x80E70002.HResult
      ## A Storage Spaces internal error occurred.

    error_spaces_resiliency_type_invalid* = 0x80E70003.HResult
      ## The specified resiliency type is not valid.

    error_spaces_drive_sector_size_invalid* = 0x80E70004.HResult
      ## The physical disk's sector size is not supported by the storage pool.

    error_spaces_drive_redundancy_invalid* = 0x80E70006.HResult
      ## The requested redundancy is outside of the supported range of values.

    error_spaces_number_of_data_copies_invalid* = 0x80E70007.HResult
      ## The number of data copies requested is outside of the supported range of values.

    error_spaces_parity_layout_invalid* = 0x80E70008.HResult
      ## The value for ParityLayout is outside of the supported range of values.

    error_spaces_interleave_length_invalid* = 0x80E70009.HResult
      ## The value for interleave length is outside of the supported range of values or is not a power of 2.

    error_spaces_number_of_columns_invalid* = 0x80E7000A.HResult
      ## The number of columns specified is outside of the supported range of values.

    error_spaces_not_enough_drives* =   0x80E7000B.HResult
      ## There were not enough physical disks to complete the requested operation.

    error_spaces_extended_error* =      0x80E7000C.HResult
      ## Extended error information is available.

    error_spaces_provisioning_type_invalid* = 0x80E7000D.HResult
      ## The specified provisioning type is not valid.

    error_spaces_allocation_size_invalid* = 0x80E7000E.HResult
      ## The allocation size is outside of the supported range of values.

    error_spaces_enclosure_aware_invalid* = 0x80E7000F.HResult
      ## Enclosure awareness is not supported for this virtual disk.

    error_spaces_write_cache_size_invalid* = 0x80E70010.HResult
      ## The write cache size is outside of the supported range of values.

    error_spaces_number_of_groups_invalid* = 0x80E70011.HResult
      ## The value for number of groups is outside of the supported range of values.

    error_spaces_drive_operational_state_invalid* = 0x80E70012.HResult
      ## The OperationalState of the physical disk is invalid for this operation.

    #
    # Volsnap errors
    #
    # Success
    error_volsnap_bootfile_not_valid* = 0x80820001.HResult
      ## The bootfile is too small to support persistent snapshots.

    error_volsnap_activation_timeout* = 0x80820002.HResult
      ## Activation of persistent snapshots on this volume took longer than was allowed.

    #
    # Tiering errors
    #
    # Errors
    error_tiering_not_supported_on_volume* = 0x80830001.HResult
      ## The specified volume does not support storage tiers.

    error_tiering_volume_dismount_in_progress* = 0x80830002.HResult
      ## The Storage Tiers Management service detected that the specified volume is in the process of being dismounted.

    error_tiering_storage_tier_not_found* = 0x80830003.HResult
      ## The specified storage tier could not be found on the volume. Confirm that the storage tier name is valid.

    error_tiering_invalid_file_id* =    0x80830004.HResult
      ## The file identifier specified is not valid on the volume.

    error_tiering_wrong_cluster_node* = 0x80830005.HResult
      ## Storage tier operations must be called on the clustering node that owns the metadata volume.

    error_tiering_already_processing* = 0x80830006.HResult
      ## The Storage Tiers Management service is already optimizing the storage tiers on the specified volume.

    error_tiering_cannot_pin_object* =  0x80830007.HResult
      ## The requested object type cannot be assigned to a storage tier.

    #
    # Embedded Security Core
    #
    # Reserved id values 0x0001 - 0x00FF
    #                    0x8xxx
    #                    0x4xxx
    error_seccore_invalid_command* =    0xC0E80000.HResult
      ## The command was not recognized by the security core

    #
    # Clip modern app and windows licensing error messages.
    #
    error_no_applicable_app_licenses_found* = 0xC0EA0001.HResult
      ## No applicable app licenses found.

    error_clip_license_not_found* =     0xC0EA0002.HResult
      ## CLiP license not found.

    error_clip_device_license_missing* = 0xC0EA0003.HResult
      ## CLiP device license not found.

    error_clip_license_invalid_signature* = 0xC0EA0004.HResult
      ## CLiP license has an invalid signature.

    error_clip_keyholder_license_missing_or_invalid* = 0xC0EA0005.HResult
      ## CLiP keyholder license is invalid or missing.

    error_clip_license_expired* =       0xC0EA0006.HResult
      ## CLiP license has expired.

    error_clip_license_signed_by_unknown_source* = 0xC0EA0007.HResult
      ## CLiP license is signed by an unknown source.

    error_clip_license_not_signed* =    0xC0EA0008.HResult
      ## CLiP license is not signed.

    error_clip_license_hardware_id_out_of_tolerance* = 0xC0EA0009.HResult
      ## CLiP license hardware ID is out of tolerance.

    error_clip_license_device_id_mismatch* = 0xC0EA000A.HResult
      ## CLiP license device ID does not match the device ID in the bound device license.

    #
    # ===============================
    # Facility Direct* Error Messages
    # ===============================
    #
    #

    #
    # DXGI status (success) codes
    #

    dxgi_status_occluded* =             0x087A0001.HResult
      ## The Present operation was invisible to the user.

    dxgi_status_clipped* =              0x087A0002.HResult
      ## The Present operation was partially invisible to the user.

    dxgi_status_no_redirection* =       0x087A0004.HResult
      ## The driver is requesting that the DXGI runtime not use shared resources to communicate with the Desktop Window Manager.

    dxgi_status_no_desktop_access* =    0x087A0005.HResult
      ## The Present operation was not visible because the Windows session has switched to another desktop (for example, ctrl-alt-del).

    dxgi_status_graphics_vidpn_source_in_use* = 0x087A0006.HResult
      ## The Present operation was not visible because the target monitor was being used for some other purpose.

    dxgi_status_mode_changed* =         0x087A0007.HResult
      ## The Present operation was not visible because the display mode changed. DXGI will have re-attempted the presentation.

    dxgi_status_mode_change_in_progress* = 0x087A0008.HResult
      ## The Present operation was not visible because another Direct3D device was attempting to take fullscreen mode at the time.


    #
    # DXGI error codes
    #

    dxgi_error_invalid_call* =          0x887A0001.HResult
      ## The application made a call that is invalid. Either the parameters of the call or the state of some object was incorrect.
      ## Enable the D3D debug layer in order to see details via debug messages.

    dxgi_error_not_found* =             0x887A0002.HResult
      ## The object was not found. If calling IDXGIFactory::EnumAdaptes, there is no adapter with the specified ordinal.

    dxgi_error_more_data* =             0x887A0003.HResult
      ## The caller did not supply a sufficiently large buffer.

    dxgi_error_unsupported* =           0x887A0004.HResult
      ## The specified device interface or feature level is not supported on this system.

    dxgi_error_device_removed* =        0x887A0005.HResult
      ## The GPU device instance has been suspended. Use GetDeviceRemovedReason to determine the appropriate action.

    dxgi_error_device_hung* =           0x887A0006.HResult
      ## The GPU will not respond to more commands, most likely because of an invalid command passed by the calling application.

    dxgi_error_device_reset* =          0x887A0007.HResult
      ## The GPU will not respond to more commands, most likely because some other application submitted invalid commands.
      ## The calling application should re-create the device and continue.

    dxgi_error_was_still_drawing* =     0x887A000A.HResult
      ## The GPU was busy at the moment when the call was made, and the call was neither executed nor scheduled.

    dxgi_error_frame_statistics_disjoint* = 0x887A000B.HResult
      ## An event (such as power cycle) interrupted the gathering of presentation statistics. Any previous statistics should be
      ## considered invalid.

    dxgi_error_graphics_vidpn_source_in_use* = 0x887A000C.HResult
      ## Fullscreen mode could not be achieved because the specified output was already in use.

    dxgi_error_driver_internal_error* = 0x887A0020.HResult
      ## An internal issue prevented the driver from carrying out the specified operation. The driver's state is probably suspect,
      ## and the application should not continue.

    dxgi_error_nonexclusive* =          0x887A0021.HResult
      ## A global counter resource was in use, and the specified counter cannot be used by this Direct3D device at this time.

    dxgi_error_not_currently_available* = 0x887A0022.HResult
      ## A resource is not available at the time of the call, but may become available later.

    dxgi_error_remote_client_disconnected* = 0x887A0023.HResult
      ## The application's remote device has been removed due to session disconnect or network disconnect.
      ## The application should call IDXGIFactory1::IsCurrent to find out when the remote device becomes available again.

    dxgi_error_remote_outofmemory* =    0x887A0024.HResult
      ## The device has been removed during a remote session because the remote computer ran out of memory.

    dxgi_error_access_lost* =           0x887A0026.HResult
      ## The keyed mutex was abandoned.

    dxgi_error_wait_timeout* =          0x887A0027.HResult
      ## The timeout value has elapsed and the resource is not yet available.

    dxgi_error_session_disconnected* =  0x887A0028.HResult
      ## The output duplication has been turned off because the Windows session ended or was disconnected.
      ## This happens when a remote user disconnects, or when "switch user" is used locally.

    dxgi_error_restrict_to_output_stale* = 0x887A0029.HResult
      ## The DXGI outuput (monitor) to which the swapchain content was restricted, has been disconnected or changed.

    dxgi_error_cannot_protect_content* = 0x887A002A.HResult
      ## DXGI is unable to provide content protection on the swapchain. This is typically caused by an older driver,
      ## or by the application using a swapchain that is incompatible with content protection.

    dxgi_error_access_denied* =         0x887A002B.HResult
      ## The application is trying to use a resource to which it does not have the required access privileges.
      ## This is most commonly caused by writing to a shared resource with read-only access.

    dxgi_error_name_already_exists* =   0x887A002C.HResult
      ## The application is trying to create a shared handle using a name that is already associated with some other resource.

    dxgi_error_sdk_component_missing* = 0x887A002D.HResult
      ## The application requested an operation that depends on an SDK component that is missing or mismatched.

    dxgi_error_not_current* =           0x887A002E.HResult
      ## The DXGI objects that the application has created are no longer current & need to be recreated for this operation to be performed.

    dxgi_error_hw_protection_outofmemory* = 0x887A0030.HResult
      ## Insufficient HW protected memory exits for proper function.


    #
    # DXGI errors that are internal to the Desktop Window Manager
    #

    dxgi_status_unoccluded* =           0x087A0009.HResult
      ## The swapchain has become unoccluded.

    dxgi_status_dda_was_still_drawing* = 0x087A000A.HResult
      ## The adapter did not have access to the required resources to complete the Desktop Duplication Present() call, the Present() call needs to be made again

    dxgi_error_mode_change_in_progress* = 0x887A0025.HResult
      ## An on-going mode change prevented completion of the call. The call may succeed if attempted later.

    dxgi_status_present_required* =     0x087A002F.HResult
      ## The present succeeded but the caller should present again on the next V-sync, even if there are no changes to the content.


    #
    # DXGI DDI
    #

    dxgi_ddi_err_wasstilldrawing* =     0x887B0001.HResult
      ## The GPU was busy when the operation was requested.

    dxgi_ddi_err_unsupported* =         0x887B0002.HResult
      ## The driver has rejected the creation of this resource.

    dxgi_ddi_err_nonexclusive* =        0x887B0003.HResult
      ## The GPU counter was in use by another process or d3d device when application requested access to it.


    #
    # Direct3D10
    #

    d3d10_error_too_many_unique_state_objects* = 0x88790001.HResult
      ## The application has exceeded the maximum number of unique state objects per Direct3D device.
      ## The limit is 4096 for feature levels up to 11.1.

    d3d10_error_file_not_found* =       0x88790002.HResult
      ## The specified file was not found.


    #
    # Direct3D11
    #

    d3d11_error_too_many_unique_state_objects* = 0x887C0001.HResult
      ## The application has exceeded the maximum number of unique state objects per Direct3D device.
      ## The limit is 4096 for feature levels up to 11.1.

    d3d11_error_file_not_found* =       0x887C0002.HResult
      ## The specified file was not found.

    d3d11_error_too_many_unique_view_objects* = 0x887C0003.HResult
      ## The application has exceeded the maximum number of unique view objects per Direct3D device.
      ## The limit is 2^20 for feature levels up to 11.1.

    d3d11_error_deferred_context_map_without_initial_discard* = 0x887C0004.HResult
      ## The application's first call per command list to Map on a deferred context did not use D3D11_MAP_WRITE_DISCARD.


    #
    # Direct3D12
    #

    d3d12_error_adapter_not_found* =    0x887E0001.HResult
      ## The blob provided does not match the adapter that the device was created on.

    d3d12_error_driver_version_mismatch* = 0x887E0002.HResult
      ## The blob provided was created for a different version of the driver, and must be re-created.


    #
    # Direct2D
    #

    d2derr_wrong_state* =               0x88990001.HResult
      ## The object was not in the correct state to process the method.

    d2derr_not_initialized* =           0x88990002.HResult
      ## The object has not yet been initialized.

    d2derr_unsupported_operation* =     0x88990003.HResult
      ## The requested operation is not supported.

    d2derr_scanner_failed* =            0x88990004.HResult
      ## The geometry scanner failed to process the data.

    d2derr_screen_access_denied* =      0x88990005.HResult
      ## Direct2D could not access the screen.

    d2derr_display_state_invalid* =     0x88990006.HResult
      ## A valid display state could not be determined.

    d2derr_zero_vector* =               0x88990007.HResult
      ## The supplied vector is zero.

    d2derr_internal_error* =            0x88990008.HResult
      ## An internal error (Direct2D bug) occurred. On checked builds, we would assert. The application should close this instance of Direct2D and should consider restarting its process.

    d2derr_display_format_not_supported* = 0x88990009.HResult
      ## The display format Direct2D needs to render is not supported by the hardware device.

    d2derr_invalid_call* =              0x8899000A.HResult
      ## A call to this method is invalid.

    d2derr_no_hardware_device* =        0x8899000B.HResult
      ## No hardware rendering device is available for this operation.

    d2derr_recreate_target* =           0x8899000C.HResult
      ## There has been a presentation error that may be recoverable. The caller needs to recreate, rerender the entire frame, and reattempt present.

    d2derr_too_many_shader_elements* =  0x8899000D.HResult
      ## Shader construction failed because it was too complex.

    d2derr_shader_compile_failed* =     0x8899000E.HResult
      ## Shader compilation failed.

    d2derr_max_texture_size_exceeded* = 0x8899000F.HResult
      ## Requested DirectX surface size exceeded maximum texture size.

    d2derr_unsupported_version* =       0x88990010.HResult
      ## The requested Direct2D version is not supported.

    d2derr_bad_number* =                0x88990011.HResult
      ## Invalid number.

    d2derr_wrong_factory* =             0x88990012.HResult
      ## Objects used together must be created from the same factory instance.

    d2derr_layer_already_in_use* =      0x88990013.HResult
      ## A layer resource can only be in use once at any point in time.

    d2derr_pop_call_did_not_match_push* = 0x88990014.HResult
      ## The pop call did not match the corresponding push call.

    d2derr_wrong_resource_domain* =     0x88990015.HResult
      ## The resource was realized on the wrong render target.

    d2derr_push_pop_unbalanced* =       0x88990016.HResult
      ## The push and pop calls were unbalanced.

    d2derr_render_target_has_layer_or_cliprect* = 0x88990017.HResult
      ## Attempt to copy from a render target while a layer or clip rect is applied.

    d2derr_incompatible_brush_types* =  0x88990018.HResult
      ## The brush types are incompatible for the call.

    d2derr_win32_error* =               0x88990019.HResult
      ## An unknown win32 failure occurred.

    d2derr_target_not_gdi_compatible* = 0x8899001A.HResult
      ## The render target is not compatible with GDI.

    d2derr_text_effect_is_wrong_type* = 0x8899001B.HResult
      ## A text client drawing effect object is of the wrong type.

    d2derr_text_renderer_not_released* = 0x8899001C.HResult
      ## The application is holding a reference to the IDWriteTextRenderer interface after the corresponding DrawText or DrawTextLayout call has returned. The IDWriteTextRenderer instance will be invalid.

    d2derr_exceeds_max_bitmap_size* =   0x8899001D.HResult
      ## The requested size is larger than the guaranteed supported texture size at the Direct3D device's current feature level.

    d2derr_invalid_graph_configuration* = 0x8899001E.HResult
      ## There was a configuration error in the graph.

    d2derr_invalid_internal_graph_configuration* = 0x8899001F.HResult
      ## There was a internal configuration error in the graph.

    d2derr_cyclic_graph* =              0x88990020.HResult
      ## There was a cycle in the graph.

    d2derr_bitmap_cannot_draw* =        0x88990021.HResult
      ## Cannot draw with a bitmap that has the D2D1_BITMAP_OPTIONS_CANNOT_DRAW option.

    d2derr_outstanding_bitmap_references* = 0x88990022.HResult
      ## The operation cannot complete while there are outstanding references to the target bitmap.

    d2derr_original_target_not_bound* = 0x88990023.HResult
      ## The operation failed because the original target is not currently bound as a target.

    d2derr_invalid_target* =            0x88990024.HResult
      ## Cannot set the image as a target because it is either an effect or is a bitmap that does not have the D2D1_BITMAP_OPTIONS_TARGET flag set.

    d2derr_bitmap_bound_as_target* =    0x88990025.HResult
      ## Cannot draw with a bitmap that is currently bound as the target bitmap.

    d2derr_insufficient_device_capabilities* = 0x88990026.HResult
      ## D3D Device does not have sufficient capabilities to perform the requested action.

    d2derr_intermediate_too_large* =    0x88990027.HResult
      ## The graph could not be rendered with the context's current tiling settings.

    d2derr_effect_is_not_registered* =  0x88990028.HResult
      ## The CLSID provided to Unregister did not correspond to a registered effect.

    d2derr_invalid_property* =          0x88990029.HResult
      ## The specified property does not exist.

    d2derr_no_subproperties* =          0x8899002A.HResult
      ## The specified sub-property does not exist.

    d2derr_print_job_closed* =          0x8899002B.HResult
      ## AddPage or Close called after print job is already closed.

    d2derr_print_format_not_supported* = 0x8899002C.HResult
      ## Error during print control creation. Indicates that none of the package target types (representing printer formats) are supported by Direct2D print control.

    d2derr_too_many_transform_inputs* = 0x8899002D.HResult
      ## An effect attempted to use a transform with too many inputs.

    d2derr_invalid_glyph_image* =       0x8899002E.HResult
      ## An error was encountered while decoding or parsing the requested glyph image.


    #
    # DirectWrite
    #

    dwrite_e_fileformat* =              0x88985000.HResult
      ## Indicates an error in an input file such as a font file.

    dwrite_e_unexpected* =              0x88985001.HResult
      ## Indicates an error originating in DirectWrite code, which is not expected to occur but is safe to recover from.

    dwrite_e_nofont* =                  0x88985002.HResult
      ## Indicates the specified font does not exist.

    dwrite_e_filenotfound* =            0x88985003.HResult
      ## A font file could not be opened because the file, directory, network location, drive, or other storage location does not exist or is unavailable.

    dwrite_e_fileaccess* =              0x88985004.HResult
      ## A font file exists but could not be opened due to access denied, sharing violation, or similar error.

    dwrite_e_fontcollectionobsolete* =  0x88985005.HResult
      ## A font collection is obsolete due to changes in the system.

    dwrite_e_alreadyregistered* =       0x88985006.HResult
      ## The given interface is already registered.

    dwrite_e_cacheformat* =             0x88985007.HResult
      ## The font cache contains invalid data.

    dwrite_e_cacheversion* =            0x88985008.HResult
      ## A font cache file corresponds to a different version of DirectWrite.

    dwrite_e_unsupportedoperation* =    0x88985009.HResult
      ## The operation is not supported for this type of font.

    dwrite_e_textrendererincompatible* = 0x8898500A.HResult
      ## The version of the text renderer interface is not compatible.

    dwrite_e_flowdirectionconflicts* =  0x8898500B.HResult
      ## The flow direction conflicts with the reading direction. They must be perpendicular to each other.

    dwrite_e_nocolor* =                 0x8898500C.HResult
      ## The font or glyph run does not contain any colored glyphs.


    #
    # Windows Codecs
    #

    wincodec_err_wrongstate* =          0x88982F04.HResult
      ## The codec is in the wrong state.

    wincodec_err_valueoutofrange* =     0x88982F05.HResult
      ## The value is out of range.

    wincodec_err_unknownimageformat* =  0x88982F07.HResult
      ## The image format is unknown.

    wincodec_err_unsupportedversion* =  0x88982F0B.HResult
      ## The SDK version is unsupported.

    wincodec_err_notinitialized* =      0x88982F0C.HResult
      ## The component is not initialized.

    wincodec_err_alreadylocked* =       0x88982F0D.HResult
      ## There is already an outstanding read or write lock.

    wincodec_err_propertynotfound* =    0x88982F40.HResult
      ## The specified bitmap property cannot be found.

    wincodec_err_propertynotsupported* = 0x88982F41.HResult
      ## The bitmap codec does not support the bitmap property.

    wincodec_err_propertysize* =        0x88982F42.HResult
      ## The bitmap property size is invalid.

    wincodec_err_codecpresent* =        0x88982F43.HResult
      ## An unknown error has occurred.

    wincodec_err_codecnothumbnail* =    0x88982F44.HResult
      ## The bitmap codec does not support a thumbnail.

    wincodec_err_paletteunavailable* =  0x88982F45.HResult
      ## The bitmap palette is unavailable.

    wincodec_err_codectoomanyscanlines* = 0x88982F46.HResult
      ## Too many scanlines were requested.

    wincodec_err_internalerror* =       0x88982F48.HResult
      ## An internal error occurred.

    wincodec_err_sourcerectdoesnotmatchdimensions* = 0x88982F49.HResult
      ## The bitmap bounds do not match the bitmap dimensions.

    wincodec_err_componentnotfound* =   0x88982F50.HResult
      ## The component cannot be found.

    wincodec_err_imagesizeoutofrange* = 0x88982F51.HResult
      ## The bitmap size is outside the valid range.

    wincodec_err_toomuchmetadata* =     0x88982F52.HResult
      ## There is too much metadata to be written to the bitmap.

    wincodec_err_badimage* =            0x88982F60.HResult
      ## The image is unrecognized.

    wincodec_err_badheader* =           0x88982F61.HResult
      ## The image header is unrecognized.

    wincodec_err_framemissing* =        0x88982F62.HResult
      ## The bitmap frame is missing.

    wincodec_err_badmetadataheader* =   0x88982F63.HResult
      ## The image metadata header is unrecognized.

    wincodec_err_badstreamdata* =       0x88982F70.HResult
      ## The stream data is unrecognized.

    wincodec_err_streamwrite* =         0x88982F71.HResult
      ## Failed to write to the stream.

    wincodec_err_streamread* =          0x88982F72.HResult
      ## Failed to read from the stream.

    wincodec_err_streamnotavailable* =  0x88982F73.HResult
      ## The stream is not available.

    wincodec_err_unsupportedpixelformat* = 0x88982F80.HResult
      ## The bitmap pixel format is unsupported.

    wincodec_err_unsupportedoperation* = 0x88982F81.HResult
      ## The operation is unsupported.

    wincodec_err_invalidregistration* = 0x88982F8A.HResult
      ## The component registration is invalid.

    wincodec_err_componentinitializefailure* = 0x88982F8B.HResult
      ## The component initialization has failed.

    wincodec_err_insufficientbuffer* =  0x88982F8C.HResult
      ## The buffer allocated is insufficient.

    wincodec_err_duplicatemetadatapresent* = 0x88982F8D.HResult
      ## Duplicate metadata is present.

    wincodec_err_propertyunexpectedtype* = 0x88982F8E.HResult
      ## The bitmap property type is unexpected.

    wincodec_err_unexpectedsize* =      0x88982F8F.HResult
      ## The size is unexpected.

    wincodec_err_invalidqueryrequest* = 0x88982F90.HResult
      ## The property query is invalid.

    wincodec_err_unexpectedmetadatatype* = 0x88982F91.HResult
      ## The metadata type is unexpected.

    wincodec_err_requestonlyvalidatmetadataroot* = 0x88982F92.HResult
      ## The specified bitmap property is only valid at root level.

    wincodec_err_invalidquerycharacter* = 0x88982F93.HResult
      ## The query string contains an invalid character.

    wincodec_err_win32error* =          0x88982F94.HResult
      ## Windows Codecs received an error from the Win32 system.

    wincodec_err_invalidprogressivelevel* = 0x88982F95.HResult
      ## The requested level of detail is not present.

    wincodec_err_invalidjpegscanindex* = 0x88982F96.HResult
      ## The scan index is invalid.


    #
    # MIL/DWM
    #

    milerr_objectbusy* =                0x88980001.HResult
      ## MILERR_OBJECTBUSY

    milerr_insufficientbuffer* =        0x88980002.HResult
      ## MILERR_INSUFFICIENTBUFFER

    milerr_win32error* =                0x88980003.HResult
      ## MILERR_WIN32ERROR

    milerr_scanner_failed* =            0x88980004.HResult
      ## MILERR_SCANNER_FAILED

    milerr_screenaccessdenied* =        0x88980005.HResult
      ## MILERR_SCREENACCESSDENIED

    milerr_displaystateinvalid* =       0x88980006.HResult
      ## MILERR_DISPLAYSTATEINVALID

    milerr_noninvertiblematrix* =       0x88980007.HResult
      ## MILERR_NONINVERTIBLEMATRIX

    milerr_zerovector* =                0x88980008.HResult
      ## MILERR_ZEROVECTOR

    milerr_terminated* =                0x88980009.HResult
      ## MILERR_TERMINATED

    milerr_badnumber* =                 0x8898000A.HResult
      ## MILERR_BADNUMBER

    milerr_internalerror* =             0x88980080.HResult
      ## An internal error (MIL bug) occurred. On checked builds, an assert would be raised.

    milerr_displayformatnotsupported* = 0x88980084.HResult
      ## The display format we need to render is not supported by the hardware device.

    milerr_invalidcall* =               0x88980085.HResult
      ## A call to this method is invalid.

    milerr_alreadylocked* =             0x88980086.HResult
      ## Lock attempted on an already locked object.

    milerr_notlocked* =                 0x88980087.HResult
      ## Unlock attempted on an unlocked object.

    milerr_devicecannotrendertext* =    0x88980088.HResult
      ## No algorithm avaliable to render text with this device

    milerr_glyphbitmapmissed* =         0x88980089.HResult
      ## Some glyph bitmaps, required for glyph run rendering, are not contained in glyph cache.

    milerr_malformedglyphcache* =       0x8898008A.HResult
      ## Some glyph bitmaps in glyph cache are unexpectedly big.

    milerr_generic_ignore* =            0x8898008B.HResult
      ## Marker error for known Win32 errors that are currently being ignored by the compositor. This is to avoid returning S_OK when an error has occurred, but still unwind the stack in the correct location.

    milerr_malformed_guideline_data* =  0x8898008C.HResult
      ## Guideline coordinates are not sorted properly or contain NaNs.

    milerr_no_hardware_device* =        0x8898008D.HResult
      ## No HW rendering device is available for this operation.

    milerr_need_recreate_and_present* = 0x8898008E.HResult
      ## There has been a presentation error that may be recoverable. The caller needs to recreate, rerender the entire frame, and reattempt present.
      ## There are two known case for this: 1) D3D Driver Internal error 2) D3D E_FAIL 2a) Unknown root cause b) When resizing too quickly for DWM and D3D stay in sync

    milerr_already_initialized* =       0x8898008F.HResult
      ## The object has already been initialized.

    milerr_mismatched_size* =           0x88980090.HResult
      ## The size of the object does not match the expected size.

    milerr_no_redirection_surface_available* = 0x88980091.HResult
      ## No Redirection surface available.

    milerr_remoting_not_supported* =    0x88980092.HResult
      ## Remoting of this content is not supported.

    milerr_queued_present_not_supported* = 0x88980093.HResult
      ## Queued Presents are not supported.

    milerr_not_queuing_presents* =      0x88980094.HResult
      ## Queued Presents are not being used.

    milerr_no_redirection_surface_retry_later* = 0x88980095.HResult
      ## No redirection surface was available. Caller should retry the call.

    milerr_toomanyshaderelemnts* =      0x88980096.HResult
      ## Shader construction failed because it was too complex.

    milerr_mrow_readlock_failed* =      0x88980097.HResult
      ## MROW attempt to get a read lock failed.

    milerr_mrow_update_failed* =        0x88980098.HResult
      ## MROW attempt to update the data failed because another update was outstanding.

    milerr_shader_compile_failed* =     0x88980099.HResult
      ## Shader compilation failed.

    milerr_max_texture_size_exceeded* = 0x8898009A.HResult
      ## Requested DX redirection surface size exceeded maximum texture size.

    milerr_qpc_time_went_backward* =    0x8898009B.HResult
      ## QueryPerformanceCounter returned a time in the past.

    milerr_dxgi_enumeration_out_of_sync* = 0x8898009D.HResult
      ## Primary Display device returned an invalid refresh rate.

    milerr_adapter_not_found* =         0x8898009E.HResult
      ## DWM can not find the adapter specified by the LUID.

    milerr_colorspace_not_supported* =  0x8898009F.HResult
      ## The requested bitmap color space is not supported.

    milerr_prefilter_not_supported* =   0x889800A0.HResult
      ## The requested bitmap pre-filtering state is not supported.

    milerr_displayid_access_denied* =   0x889800A1.HResult
      ## Access is denied to the requested bitmap for the specified display id.

    # Composition engine errors
    uceerr_invalidpacketheader* =       0x88980400.HResult
      ## UCEERR_INVALIDPACKETHEADER

    uceerr_unknownpacket* =             0x88980401.HResult
      ## UCEERR_UNKNOWNPACKET

    uceerr_illegalpacket* =             0x88980402.HResult
      ## UCEERR_ILLEGALPACKET

    uceerr_malformedpacket* =           0x88980403.HResult
      ## UCEERR_MALFORMEDPACKET

    uceerr_illegalhandle* =             0x88980404.HResult
      ## UCEERR_ILLEGALHANDLE

    uceerr_handlelookupfailed* =        0x88980405.HResult
      ## UCEERR_HANDLELOOKUPFAILED

    uceerr_renderthreadfailure* =       0x88980406.HResult
      ## UCEERR_RENDERTHREADFAILURE

    uceerr_ctxstackfrsttargetnull* =    0x88980407.HResult
      ## UCEERR_CTXSTACKFRSTTARGETNULL

    uceerr_connectionidlookupfailed* =  0x88980408.HResult
      ## UCEERR_CONNECTIONIDLOOKUPFAILED

    uceerr_blocksfull* =                0x88980409.HResult
      ## UCEERR_BLOCKSFULL

    uceerr_memoryfailure* =             0x8898040A.HResult
      ## UCEERR_MEMORYFAILURE

    uceerr_packetrecordoutofrange* =    0x8898040B.HResult
      ## UCEERR_PACKETRECORDOUTOFRANGE

    uceerr_illegalrecordtype* =         0x8898040C.HResult
      ## UCEERR_ILLEGALRECORDTYPE

    uceerr_outofhandles* =              0x8898040D.HResult
      ## UCEERR_OUTOFHANDLES

    uceerr_unchangable_update_attempted* = 0x8898040E.HResult
      ## UCEERR_UNCHANGABLE_UPDATE_ATTEMPTED

    uceerr_no_multiple_worker_threads* = 0x8898040F.HResult
      ## UCEERR_NO_MULTIPLE_WORKER_THREADS

    uceerr_remotingnotsupported* =      0x88980410.HResult
      ## UCEERR_REMOTINGNOTSUPPORTED

    uceerr_missingendcommand* =         0x88980411.HResult
      ## UCEERR_MISSINGENDCOMMAND

    uceerr_missingbegincommand* =       0x88980412.HResult
      ## UCEERR_MISSINGBEGINCOMMAND

    uceerr_channelsynctimedout* =       0x88980413.HResult
      ## UCEERR_CHANNELSYNCTIMEDOUT

    uceerr_channelsyncabandoned* =      0x88980414.HResult
      ## UCEERR_CHANNELSYNCABANDONED

    uceerr_unsupportedtransportversion* = 0x88980415.HResult
      ## UCEERR_UNSUPPORTEDTRANSPORTVERSION

    uceerr_transportunavailable* =      0x88980416.HResult
      ## UCEERR_TRANSPORTUNAVAILABLE

    uceerr_feedback_unsupported* =      0x88980417.HResult
      ## UCEERR_FEEDBACK_UNSUPPORTED

    uceerr_commandtransportdenied* =    0x88980418.HResult
      ## UCEERR_COMMANDTRANSPORTDENIED

    uceerr_graphicsstreamunavailable* = 0x88980419.HResult
      ## UCEERR_GRAPHICSSTREAMUNAVAILABLE

    uceerr_graphicsstreamalreadyopen* = 0x88980420.HResult
      ## UCEERR_GRAPHICSSTREAMALREADYOPEN

    uceerr_transportdisconnected* =     0x88980421.HResult
      ## UCEERR_TRANSPORTDISCONNECTED

    uceerr_transportoverloaded* =       0x88980422.HResult
      ## UCEERR_TRANSPORTOVERLOADED

    uceerr_partition_zombied* =         0x88980423.HResult
      ## UCEERR_PARTITION_ZOMBIED

    # MIL AV Specific errors
    milaverr_noclock* =                 0x88980500.HResult
      ## MILAVERR_NOCLOCK

    milaverr_nomediatype* =             0x88980501.HResult
      ## MILAVERR_NOMEDIATYPE

    milaverr_novideomixer* =            0x88980502.HResult
      ## MILAVERR_NOVIDEOMIXER

    milaverr_novideopresenter* =        0x88980503.HResult
      ## MILAVERR_NOVIDEOPRESENTER

    milaverr_noreadyframes* =           0x88980504.HResult
      ## MILAVERR_NOREADYFRAMES

    milaverr_modulenotloaded* =         0x88980505.HResult
      ## MILAVERR_MODULENOTLOADED

    milaverr_wmpfactorynotregistered* = 0x88980506.HResult
      ## MILAVERR_WMPFACTORYNOTREGISTERED

    milaverr_invalidwmpversion* =       0x88980507.HResult
      ## MILAVERR_INVALIDWMPVERSION

    milaverr_insufficientvideoresources* = 0x88980508.HResult
      ## MILAVERR_INSUFFICIENTVIDEORESOURCES

    milaverr_videoaccelerationnotavailable* = 0x88980509.HResult
      ## MILAVERR_VIDEOACCELERATIONNOTAVAILABLE

    milaverr_requestedtexturetoobig* =  0x8898050A.HResult
      ## MILAVERR_REQUESTEDTEXTURETOOBIG

    milaverr_seekfailed* =              0x8898050B.HResult
      ## MILAVERR_SEEKFAILED

    milaverr_unexpectedwmpfailure* =    0x8898050C.HResult
      ## MILAVERR_UNEXPECTEDWMPFAILURE

    milaverr_mediaplayerclosed* =       0x8898050D.HResult
      ## MILAVERR_MEDIAPLAYERCLOSED

    milaverr_unknownhardwareerror* =    0x8898050E.HResult
      ## MILAVERR_UNKNOWNHARDWAREERROR

    # MIL Bitmap Effet errors
    mileffectserr_unknownproperty* =    0x8898060E.HResult
      ## MILEFFECTSERR_UNKNOWNPROPERTY

    mileffectserr_effectnotpartofgroup* = 0x8898060F.HResult
      ## MILEFFECTSERR_EFFECTNOTPARTOFGROUP

    mileffectserr_noinputsourceattached* = 0x88980610.HResult
      ## MILEFFECTSERR_NOINPUTSOURCEATTACHED

    mileffectserr_connectornotconnected* = 0x88980611.HResult
      ## MILEFFECTSERR_CONNECTORNOTCONNECTED

    mileffectserr_connectornotassociatedwitheffect* = 0x88980612.HResult
      ## MILEFFECTSERR_CONNECTORNOTASSOCIATEDWITHEFFECT

    mileffectserr_reserved* =           0x88980613.HResult
      ## MILEFFECTSERR_RESERVED

    mileffectserr_cycledetected* =      0x88980614.HResult
      ## MILEFFECTSERR_CYCLEDETECTED

    mileffectserr_effectinmorethanonegraph* = 0x88980615.HResult
      ## MILEFFECTSERR_EFFECTINMORETHANONEGRAPH

    mileffectserr_effectalreadyinagraph* = 0x88980616.HResult
      ## MILEFFECTSERR_EFFECTALREADYINAGRAPH

    mileffectserr_effecthasnochildren* = 0x88980617.HResult
      ## MILEFFECTSERR_EFFECTHASNOCHILDREN

    mileffectserr_alreadyattachedtolistener* = 0x88980618.HResult
      ## MILEFFECTSERR_ALREADYATTACHEDTOLISTENER

    mileffectserr_notaffinetransform* = 0x88980619.HResult
      ## MILEFFECTSERR_NOTAFFINETRANSFORM

    mileffectserr_emptybounds* =        0x8898061A.HResult
      ## MILEFFECTSERR_EMPTYBOUNDS

    mileffectserr_outputsizetoolarge* = 0x8898061B.HResult
      ## MILEFFECTSERR_OUTPUTSIZETOOLARGE

    # DWM specific errors
    dwmerr_state_transition_failed* =   0x88980700.HResult
      ## DWMERR_STATE_TRANSITION_FAILED

    dwmerr_theme_failed* =              0x88980701.HResult
      ## DWMERR_THEME_FAILED

    dwmerr_catastrophic_failure* =      0x88980702.HResult
      ## DWMERR_CATASTROPHIC_FAILURE


    #
    # DirectComposition
    #

    dcomposition_error_window_already_composed* = 0x88980800.HResult
      ## DCOMPOSITION_ERROR_WINDOW_ALREADY_COMPOSED

    dcomposition_error_surface_being_rendered* = 0x88980801.HResult
      ## DCOMPOSITION_ERROR_SURFACE_BEING_RENDERED

    dcomposition_error_surface_not_being_rendered* = 0x88980802.HResult
      ## DCOMPOSITION_ERROR_SURFACE_NOT_BEING_RENDERED


    #
    # OnlineId
    #

    onl_e_invalid_authentication_target* = 0x80860001.HResult
      ## Authentication target is invalid or not configured correctly.

    onl_e_access_denied_by_tou* =       0x80860002.HResult
      ## Your application cannot get the Online Id properties due to the Terms of Use accepted by the user.

    onl_e_invalid_application* =        0x80860003.HResult
      ## The application requesting authentication tokens is either disabled or incorrectly configured.

    onl_e_password_update_required* =   0x80860004.HResult
      ## Online Id password must be updated before signin.

    onl_e_account_update_required* =    0x80860005.HResult
      ## Online Id account properties must be updated before signin.

    onl_e_forcesignin* =                0x80860006.HResult
      ## To help protect your Online Id account you must signin again.

    onl_e_account_locked* =             0x80860007.HResult
      ## Online Id account was locked because there have been too many attempts to sign in.

    onl_e_parental_consent_required* =  0x80860008.HResult
      ## Online Id account requires parental consent before proceeding.

    onl_e_email_verification_required* = 0x80860009.HResult
      ## Online Id signin name is not yet verified. Email verification is required before signin.

    onl_e_account_suspended_comproimise* = 0x8086000A.HResult
      ## We have noticed some unusual activity in your Online Id account. Your action is needed to make sure no one else is using your account.

    onl_e_account_suspended_abuse* =    0x8086000B.HResult
      ## We detected some suspicious activity with your Online Id account. To help protect you, we've temporarily blocked your account.

    onl_e_action_required* =            0x8086000C.HResult
      ## User interaction is required for authentication.

    onl_connection_count_limit* =       0x8086000D.HResult
      ## User has reached the maximum device associations per user limit.

    onl_e_connected_account_can_not_signout* = 0x8086000E.HResult
      ## Cannot sign out from the application since the user account is connected.

    onl_e_user_authentication_required* = 0x8086000F.HResult
      ## User authentication is required for this operation.

    onl_e_request_throttled* =          0x80860010.HResult
      ## We want to make sure this is you. User interaction is required for authentication.


    #
    # Facility Shell Error codes
    #

    fa_e_max_persisted_items_reached* = 0x80270220.HResult
      ## The maximum number of items for the access list has been reached. An item must be removed before another item is added.

    fa_e_homegroup_not_available* =     0x80270222.HResult
      ## Cannot access Homegroup. Homegroup may not be set up or may have encountered an error.

    e_monitor_resolution_too_low* =     0x80270250.HResult
      ## This app can't start because the screen resolution is below 1024x768. Choose a higher screen resolution and then try again.

    e_elevated_activation_not_supported* = 0x80270251.HResult
      ## This app can't be activated from an elevated context.

    e_uac_disabled* =                   0x80270252.HResult
      ## This app can't be activated when UAC is disabled.

    e_full_admin_not_supported* =       0x80270253.HResult
      ## This app can't be activated by the Built-in Administrator.

    e_application_not_registered* =     0x80270254.HResult
      ## This app does not support the contract specified or is not installed.

    e_multiple_extensions_for_application* = 0x80270255.HResult
      ## This app has mulitple extensions registered to support the specified contract. Activation by AppUserModelId is ambiguous.

    e_multiple_packages_for_family* =   0x80270256.HResult
      ## This app's package family has more than one package installed. This is not supported.

    e_application_manager_not_running* = 0x80270257.HResult
      ## The app manager is required to activate applications, but is not running.

    s_store_launched_for_remediation* = 0x00270258.HResult
      ## The Store was launched instead of the specified app because the app's package was in an invalid state.

    s_application_activation_error_handled_by_dialog* = 0x00270259.HResult
      ## This app failed to launch, but the error was handled with a dialog.

    e_application_activation_timed_out* = 0x8027025A.HResult
      ## The app didn't start in the required time.

    e_application_activation_exec_failure* = 0x8027025B.HResult
      ## The app didn't start.

    e_application_temporary_license_error* = 0x8027025C.HResult
      ## This app failed to launch because of an issue with its license. Please try again in a moment.

    e_application_trial_license_expired* = 0x8027025D.HResult
      ## This app failed to launch because its trial license has expired.

    e_skydrive_root_target_file_system_not_supported* = 0x80270260.HResult
      ## Please choose a folder on a drive that's formatted with the NTFS file system.

    e_skydrive_root_target_overlap* =   0x80270261.HResult
      ## This location is already being used. Please choose a different location.

    e_skydrive_root_target_cannot_index* = 0x80270262.HResult
      ## This location cannot be indexed. Please choose a different location.

    e_skydrive_file_not_uploaded* =     0x80270263.HResult
      ## Sorry, the action couldn't be completed because the file hasn't finished uploading. Try again later.

    e_skydrive_update_availability_fail* = 0x80270264.HResult
      ## Sorry, the action couldn't be completed.

    e_skydrive_root_target_volume_root_not_supported* = 0x80270265.HResult
      ## This content can only be moved to a folder. To move the content to this drive, please choose or create a folder.


    # Sync Engine File Error Codes

    e_syncengine_file_size_over_limit* = 0x8802B001.HResult
      ## The file size is larger than supported by the sync engine.

    e_syncengine_file_size_exceeds_remaining_quota* = 0x8802B002.HResult
      ## The file cannot be uploaded because it doesn't fit in the user's available service provided storage space.

    e_syncengine_unsupported_file_name* = 0x8802B003.HResult
      ## The file name contains invalid characters.

    e_syncengine_folder_item_count_limit_exceeded* = 0x8802B004.HResult
      ## The maximum file count has been reached for this folder in the sync engine.

    e_syncengine_file_sync_partner_error* = 0x8802B005.HResult
      ## The file sync has been delegated to another program and has run into an issue.

    e_syncengine_sync_paused_by_service* = 0x8802B006.HResult
      ## Sync has been delayed due to a throttling request from the service.


    # Sync Engine Stream Resolver Errors

    e_syncengine_file_identifier_unknown* = 0x8802C002.HResult
      ## We can't seem to find that file. Please try again later.

    e_syncengine_service_authentication_failed* = 0x8802C003.HResult
      ## The account you're signed in with doesn't have permission to open this file.

    e_syncengine_unknown_service_error* = 0x8802C004.HResult
      ## There was a problem connecting to the service. Please try again later.

    e_syncengine_service_returned_unexpected_size* = 0x8802C005.HResult
      ## Sorry, there was a problem downloading the file.

    e_syncengine_request_blocked_by_service* = 0x8802C006.HResult
      ## We're having trouble downloading the file right now. Please try again later.

    e_syncengine_request_blocked_due_to_client_error* = 0x8802C007.HResult
      ## We're having trouble downloading the file right now. Please try again later.


    # Sync Engine Global Errors

    e_syncengine_folder_inaccessible* = 0x8802D001.HResult
      ## The sync engine does not have permissions to access a local folder under the sync root.

    e_syncengine_unsupported_folder_name* = 0x8802D002.HResult
      ## The folder name contains invalid characters.

    e_syncengine_unsupported_market* =  0x8802D003.HResult
      ## The sync engine is not allowed to run in your current market.

    e_syncengine_path_length_limit_exceeded* = 0x8802D004.HResult
      ## All files and folders can't be uploaded because a path of a file or folder is too long.

    e_syncengine_remote_path_length_limit_exceeded* = 0x8802D005.HResult
      ## All file and folders cannot be synchronized because a path of a file or folder would exceed the local path limit.

    e_syncengine_client_update_needed* = 0x8802D006.HResult
      ## Updates are needed in order to use the sync engine.

    e_syncengine_proxy_authentication_required* = 0x8802D007.HResult
      ## The sync engine needs to authenticate with a proxy server.

    e_syncengine_storage_service_provisioning_failed* = 0x8802D008.HResult
      ## There was a problem setting up the storage services for the account.

    e_syncengine_unsupported_reparse_point* = 0x8802D009.HResult
      ## Files can't be uploaded because there's an unsupported reparse point.

    e_syncengine_storage_service_blocked* = 0x8802D00A.HResult
      ## The service has blocked your account from accessing the storage service.

    e_syncengine_folder_in_redirection* = 0x8802D00B.HResult
      ## The action can't be performed right now because this folder is being moved. Please try again later.


    #
    # EAS
    #

    eas_e_policy_not_managed_by_os* =   0x80550001.HResult
      ## Windows cannot evaluate this EAS policy since this is not managed by the operating system.

    eas_e_policy_compliant_with_actions* = 0x80550002.HResult
      ## The system can be made compliant to this EAS policy if certain actions are performed by the user.

    eas_e_requested_policy_not_enforceable* = 0x80550003.HResult
      ## The EAS policy being evaluated cannot be enforced by the system.

    eas_e_current_user_has_blank_password* = 0x80550004.HResult
      ## EAS password policies for the user cannot be evaluated as the user has a blank password.

    eas_e_requested_policy_password_expiration_incompatible* = 0x80550005.HResult
      ## EAS password expiration policy cannot be satisfied as the password expiration interval is less than the minimum password interval of the system.

    eas_e_user_cannot_change_password* = 0x80550006.HResult
      ## The user is not allowed to change her password.

    eas_e_admins_have_blank_password* = 0x80550007.HResult
      ## EAS password policies cannot be evaluated as one or more admins have blank passwords.

    eas_e_admins_cannot_change_password* = 0x80550008.HResult
      ## One or more admins are not allowed to change their password.

    eas_e_local_controlled_users_cannot_change_password* = 0x80550009.HResult
      ## There are other standard users present who are not allowed to change their password.

    eas_e_password_policy_not_enforceable_for_connected_admins* = 0x8055000A.HResult
      ## The EAS password policy cannot be enforced by the connected account provider of at least one administrator.

    eas_e_connected_admins_need_to_change_password* = 0x8055000B.HResult
      ## There is at least one administrator whose connected account password needs to be changed for EAS password policy compliance.

    eas_e_password_policy_not_enforceable_for_current_connected_user* = 0x8055000C.HResult
      ## The EAS password policy cannot be enforced by the connected account provider of the current user.

    eas_e_current_connected_user_need_to_change_password* = 0x8055000D.HResult
      ## The connected account password of the current user needs to be changed for EAS password policy compliance.

    web_e_unsupported_format* =         0x83750001.HResult
      ## Unsupported format.

    web_e_invalid_xml* =                0x83750002.HResult
      ## Invalid XML.

    web_e_missing_required_element* =   0x83750003.HResult
      ## Missing required element.

    web_e_missing_required_attribute* = 0x83750004.HResult
      ## Missing required attribute.

    web_e_unexpected_content* =         0x83750005.HResult
      ## Unexpected content.

    web_e_resource_too_large* =         0x83750006.HResult
      ## Resource too large.

    web_e_invalid_json_string* =        0x83750007.HResult
      ## Invalid JSON string.

    web_e_invalid_json_number* =        0x83750008.HResult
      ## Invalid JSON number.

    web_e_json_value_not_found* =       0x83750009.HResult
      ## JSON value not found.

    http_e_status_unexpected* =         0x80190001.HResult
      ## Unexpected HTTP status code.

    http_e_status_unexpected_redirection* = 0x80190003.HResult
      ## Unexpected redirection status code (3xx).

    http_e_status_unexpected_client_error* = 0x80190004.HResult
      ## Unexpected client error status code (4xx).

    http_e_status_unexpected_server_error* = 0x80190005.HResult
      ## Unexpected server error status code (5xx).

    http_e_status_ambiguous* =          0x8019012C.HResult
      ## Multiple choices (300).

    http_e_status_moved* =              0x8019012D.HResult
      ## Moved permanently (301).

    http_e_status_redirect* =           0x8019012E.HResult
      ## Found (302).

    http_e_status_redirect_method* =    0x8019012F.HResult
      ## See Other (303).

    http_e_status_not_modified* =       0x80190130.HResult
      ## Not modified (304).

    http_e_status_use_proxy* =          0x80190131.HResult
      ## Use proxy (305).

    http_e_status_redirect_keep_verb* = 0x80190133.HResult
      ## Temporary redirect (307).

    http_e_status_bad_request* =        0x80190190.HResult
      ## Bad request (400).

    http_e_status_denied* =             0x80190191.HResult
      ## Unauthorized (401).

    http_e_status_payment_req* =        0x80190192.HResult
      ## Payment required (402).

    http_e_status_forbidden* =          0x80190193.HResult
      ## Forbidden (403).

    http_e_status_not_found* =          0x80190194.HResult
      ## Not found (404).

    http_e_status_bad_method* =         0x80190195.HResult
      ## Method not allowed (405).

    http_e_status_none_acceptable* =    0x80190196.HResult
      ## Not acceptable (406).

    http_e_status_proxy_auth_req* =     0x80190197.HResult
      ## Proxy authentication required (407).

    http_e_status_request_timeout* =    0x80190198.HResult
      ## Request timeout (408).

    http_e_status_conflict* =           0x80190199.HResult
      ## Conflict (409).

    http_e_status_gone* =               0x8019019A.HResult
      ## Gone (410).

    http_e_status_length_required* =    0x8019019B.HResult
      ## Length required (411).

    http_e_status_precond_failed* =     0x8019019C.HResult
      ## Precondition failed (412).

    http_e_status_request_too_large* =  0x8019019D.HResult
      ## Request entity too large (413).

    http_e_status_uri_too_long* =       0x8019019E.HResult
      ## Request-URI too long (414).

    http_e_status_unsupported_media* =  0x8019019F.HResult
      ## Unsupported media type (415).

    http_e_status_range_not_satisfiable* = 0x801901A0.HResult
      ## Requested range not satisfiable (416).

    http_e_status_expectation_failed* = 0x801901A1.HResult
      ## Expectation failed (417).

    http_e_status_server_error* =       0x801901F4.HResult
      ## Internal server error (500).

    http_e_status_not_supported* =      0x801901F5.HResult
      ## Not implemented (501).

    http_e_status_bad_gateway* =        0x801901F6.HResult
      ## Bad gateway (502).

    http_e_status_service_unavail* =    0x801901F7.HResult
      ## Service unavailable (503).

    http_e_status_gateway_timeout* =    0x801901F8.HResult
      ## Gateway timeout (504).

    http_e_status_version_not_sup* =    0x801901F9.HResult
      ## Version not supported (505).


    #
    # WebSocket
    #

    e_invalid_protocol_operation* =     0x83760001.HResult
      ## Invalid operation performed by the protocol.

    e_invalid_protocol_format* =        0x83760002.HResult
      ## Invalid data format for the specific protocol operation.

    e_protocol_extensions_not_supported* = 0x83760003.HResult
      ## Protocol extensions are not supported.

    e_subprotocol_not_supported* =      0x83760004.HResult
      ## Subrotocol is not supported.

    e_protocol_version_not_supported* = 0x83760005.HResult
      ## Incorrect protocol version.


    #
    # Touch and Pen Input Platform Error Codes
    #

    input_e_out_of_order* =             0x80400000.HResult
      ## Input data cannot be processed in the non-chronological order.

    input_e_reentrancy* =               0x80400001.HResult
      ## Requested operation cannot be performed inside the callback or event handler.

    input_e_multimodal* =               0x80400002.HResult
      ## Input cannot be processed because there is ongoing interaction with another pointer type.

    input_e_packet* =                   0x80400003.HResult
      ## One or more fields in the input packet are invalid.

    input_e_frame* =                    0x80400004.HResult
      ## Packets in the frame are inconsistent. Either pointer ids are not unique or there is a discrepancy in timestamps, frame ids, pointer types or source devices.

    input_e_history* =                  0x80400005.HResult
      ## The history of frames is inconsistent. Pointer ids, types, source devices don't match, or frame ids are not unique, or timestamps are out of order.

    input_e_device_info* =              0x80400006.HResult
      ## Failed to retrieve information about the input device.

    input_e_transform* =                0x80400007.HResult
      ## Coordinate system transformation failed to transform the data.

    input_e_device_property* =          0x80400008.HResult
      ## The property is not supported or not reported correctly by the input device.

    #
    # Internet
    #
    inet_e_invalid_url* =               0x800C0002.HResult
      ## The URL is invalid.

    inet_e_no_session* =                0x800C0003.HResult
      ## No Internet session has been established.

    inet_e_cannot_connect* =            0x800C0004.HResult
      ## Unable to connect to the target server.

    inet_e_resource_not_found* =        0x800C0005.HResult
      ## The system cannot locate the resource specified.

    inet_e_object_not_found* =          0x800C0006.HResult
      ## The system cannot locate the object specified.

    inet_e_data_not_available* =        0x800C0007.HResult
      ## No data is available for the requested resource.

    inet_e_download_failure* =          0x800C0008.HResult
      ## The download of the specified resource has failed.

    inet_e_authentication_required* =   0x800C0009.HResult
      ## Authentication is required to access this resource.

    inet_e_no_valid_media* =            0x800C000A.HResult
      ## The server could not recognize the provided mime type.

    inet_e_connection_timeout* =        0x800C000B.HResult
      ## The operation was timed out.

    inet_e_invalid_request* =           0x800C000C.HResult
      ## The server did not understand the request, or the request was invalid.

    inet_e_unknown_protocol* =          0x800C000D.HResult
      ## The specified protocol is unknown.

    inet_e_security_problem* =          0x800C000E.HResult
      ## A security problem occurred.

    inet_e_cannot_load_data* =          0x800C000F.HResult
      ## The system could not load the persisted data.

    inet_e_cannot_instantiate_object* = 0x800C0010.HResult
      ## Unable to instantiate the object.

    inet_e_invalid_certificate* =       0x800C0019.HResult
      ## Security certificate required to access this resource is invalid.

    inet_e_redirect_failed* =           0x800C0014.HResult
      ## A redirection problem occurred.

    inet_e_redirect_to_dir* =           0x800C0015.HResult
      ## The requested resource is a directory, not a file.

    #
    # Debuggers
    #
    error_dbg_create_process_failure_lockdown* = 0x80B00001.HResult
      ## Could not create new process from ARM architecture device.

    error_dbg_attach_process_failure_lockdown* = 0x80B00002.HResult
      ## Could not attach to the application process from ARM architecture device.

    error_dbg_connect_server_failure_lockdown* = 0x80B00003.HResult
      ## Could not connect to dbgsrv server from ARM architecture device.

    error_dbg_start_server_failure_lockdown* = 0x80B00004.HResult
      ## Could not start dbgsrv server from ARM architecture device.

    #
    #Sdbus
    #
    error_io_preempted* =               0x89010001.HResult
      ## The operation was preempted by a higher priority operation. It must be resumed later.

    #
    #JScript
    #
    jscript_e_cantexecute* =            0x89020001.HResult
      ## Function could not execute because it was deleted or garbage collected.

    #
    #WEP - Windows Encryption Providers
    #
    wep_e_not_provisioned_on_all_volumes* = 0x88010001.HResult
      ## One or more fixed volumes are not provisioned with the 3rd party encryption providers to support device encryption. Enable encryption with the 3rd party provider to comply with policy.

    wep_e_fixed_data_not_supported* =   0x88010002.HResult
      ## This computer is not fully encrypted. There are fixed volumes present which are not supported for encryption.

    wep_e_hardware_not_compliant* =     0x88010003.HResult
      ## This computer does not meet the hardware requirements to support device encryption with the installed 3rd party provider.

    #
    #device lock feature - requires encryption software to use something like a TPM or a secure location to store failed counts of the password in an interactive logon to lock out the device
    #
    wep_e_lock_not_configured* =        0x88010004.HResult
      ## This computer cannot support device encryption because the requisites for the device lock feature are not configured.

    wep_e_protection_suspended* =       0x88010005.HResult
      ## Protection is enabled on this volume but is not in the active state.

    wep_e_no_license* =                 0x88010006.HResult
      ## The 3rd party provider has been installed, but cannot activate encryption beacuse a license has not been activated.

    wep_e_os_not_protected* =           0x88010007.HResult
      ## The operating system drive is not protected by 3rd party drive encryption.

    wep_e_unexpected_fail* =            0x88010008.HResult
      ## Unexpected failure was encountered while calling into the 3rd Party drive encryption plugin.

    wep_e_buffer_too_large* =           0x88010009.HResult
      ## The input buffer size for the lockout metadata used by the 3rd party drive encryption is too large.

    #
    # Shared VHDX status codes (svhdxflt.sys)
    #
    error_svhdx_error_stored* =         0xC05C0000.HResult
      ## The proper error code with sense data was stored on server side.

    error_svhdx_error_not_available* =  0xC05CFF00.HResult
      ## The requested error data is not available on the server.

    error_svhdx_unit_attention_available* = 0xC05CFF01.HResult
      ## Unit Attention data is available for the initiator to query.

    error_svhdx_unit_attention_capacity_data_changed* = 0xC05CFF02.HResult
      ## The data capacity of the device has changed, resulting in a Unit Attention condition.

    error_svhdx_unit_attention_reservations_preempted* = 0xC05CFF03.HResult
      ## A previous operation resulted in this initiator's reservations being preempted, resulting in a Unit Attention condition.

    error_svhdx_unit_attention_reservations_released* = 0xC05CFF04.HResult
      ## A previous operation resulted in this initiator's reservations being released, resulting in a Unit Attention condition.

    error_svhdx_unit_attention_registrations_preempted* = 0xC05CFF05.HResult
      ## A previous operation resulted in this initiator's registrations being preempted, resulting in a Unit Attention condition.

    error_svhdx_unit_attention_operating_definition_changed* = 0xC05CFF06.HResult
      ## The data storage format of the device has changed, resulting in a Unit Attention condition.

    error_svhdx_reservation_conflict* = 0xC05CFF07.HResult
      ## The current initiator is not allowed to perform the SCSI command because of a reservation conflict.

    error_svhdx_wrong_file_type* =      0xC05CFF08.HResult
      ## Multiple virtual machines sharing a virtual hard disk is supported only on Fixed or Dynamic VHDX format virtual hard disks.

    error_svhdx_version_mismatch* =     0xC05CFF09.HResult
      ## The server version does not match the requested version.

    error_vhd_shared* =                 0xC05CFF0A.HResult
      ## The requested operation cannot be performed on the virtual disk as it is currently used in shared mode.

    error_svhdx_no_initiator* =         0xC05CFF0B.HResult
      ## Invalid Shared VHDX open due to lack of initiator ID. Check for related Continuous Availability failures.

    error_vhdset_backing_storage_not_found* = 0xC05CFF0C.HResult
      ## The requested operation failed due to a missing backing storage file.

    #
    # SMB status codes
    #
    error_smb_no_preauth_integrity_hash_overlap* = 0xC05D0000.HResult
      ## Failed to negotiate a preauthentication integrity hash function.

    error_smb_bad_cluster_dialect* =    0xC05D0001.HResult
      ## The current cluster functional level does not support this SMB dialect.

    #
    # WININET.DLL errors - propagated as HRESULT's using FACILITY=WIN32
    #
    wininet_e_out_of_handles* =         0x80072EE1.HResult
      ## No more Internet handles can be allocated

    wininet_e_timeout* =                0x80072EE2.HResult
      ## The operation timed out

    wininet_e_extended_error* =         0x80072EE3.HResult
      ## The server returned extended information

    wininet_e_internal_error* =         0x80072EE4.HResult
      ## An internal error occurred in the Microsoft Internet extensions

    wininet_e_invalid_url* =            0x80072EE5.HResult
      ## The URL is invalid

    wininet_e_unrecognized_scheme* =    0x80072EE6.HResult
      ## The URL does not use a recognized protocol

    wininet_e_name_not_resolved* =      0x80072EE7.HResult
      ## The server name or address could not be resolved

    wininet_e_protocol_not_found* =     0x80072EE8.HResult
      ## A protocol with the required capabilities was not found

    wininet_e_invalid_option* =         0x80072EE9.HResult
      ## The option is invalid

    wininet_e_bad_option_length* =      0x80072EEA.HResult
      ## The length is incorrect for the option type

    wininet_e_option_not_settable* =    0x80072EEB.HResult
      ## The option value cannot be set

    wininet_e_shutdown* =               0x80072EEC.HResult
      ## Microsoft Internet Extension support has been shut down

    wininet_e_incorrect_user_name* =    0x80072EED.HResult
      ## The user name was not allowed

    wininet_e_incorrect_password* =     0x80072EEE.HResult
      ## The password was not allowed

    wininet_e_login_failure* =          0x80072EEF.HResult
      ## The login request was denied

    wininet_e_invalid_operation* =      0x80072EF0.HResult
      ## The requested operation is invalid

    wininet_e_operation_cancelled* =    0x80072EF1.HResult
      ## The operation has been canceled

    wininet_e_incorrect_handle_type* =  0x80072EF2.HResult
      ## The supplied handle is the wrong type for the requested operation

    wininet_e_incorrect_handle_state* = 0x80072EF3.HResult
      ## The handle is in the wrong state for the requested operation

    wininet_e_not_proxy_request* =      0x80072EF4.HResult
      ## The request cannot be made on a Proxy session

    wininet_e_registry_value_not_found* = 0x80072EF5.HResult
      ## The registry value could not be found

    wininet_e_bad_registry_parameter* = 0x80072EF6.HResult
      ## The registry parameter is incorrect

    wininet_e_no_direct_access* =       0x80072EF7.HResult
      ## Direct Internet access is not available

    wininet_e_no_context* =             0x80072EF8.HResult
      ## No context value was supplied

    wininet_e_no_callback* =            0x80072EF9.HResult
      ## No status callback was supplied

    wininet_e_request_pending* =        0x80072EFA.HResult
      ## There are outstanding requests

    wininet_e_incorrect_format* =       0x80072EFB.HResult
      ## The information format is incorrect

    wininet_e_item_not_found* =         0x80072EFC.HResult
      ## The requested item could not be found

    wininet_e_cannot_connect* =         0x80072EFD.HResult
      ## A connection with the server could not be established

    wininet_e_connection_aborted* =     0x80072EFE.HResult
      ## The connection with the server was terminated abnormally

    wininet_e_connection_reset* =       0x80072EFF.HResult
      ## The connection with the server was reset

    wininet_e_force_retry* =            0x80072F00.HResult
      ## The action must be retried

    wininet_e_invalid_proxy_request* =  0x80072F01.HResult
      ## The proxy request is invalid

    wininet_e_need_ui* =                0x80072F02.HResult
      ## User interaction is required to complete the operation

    wininet_e_handle_exists* =          0x80072F04.HResult
      ## The handle already exists

    wininet_e_sec_cert_date_invalid* =  0x80072F05.HResult
      ## The date in the certificate is invalid or has expired

    wininet_e_sec_cert_cn_invalid* =    0x80072F06.HResult
      ## The host name in the certificate is invalid or does not match

    wininet_e_http_to_https_on_redir* = 0x80072F07.HResult
      ## A redirect request will change a non-secure to a secure connection

    wininet_e_https_to_http_on_redir* = 0x80072F08.HResult
      ## A redirect request will change a secure to a non-secure connection

    wininet_e_mixed_security* =         0x80072F09.HResult
      ## Mixed secure and non-secure connections

    wininet_e_chg_post_is_non_secure* = 0x80072F0A.HResult
      ## Changing to non-secure post

    wininet_e_post_is_non_secure* =     0x80072F0B.HResult
      ## Data is being posted on a non-secure connection

    wininet_e_client_auth_cert_needed* = 0x80072F0C.HResult
      ## A certificate is required to complete client authentication

    wininet_e_invalid_ca* =             0x80072F0D.HResult
      ## The certificate authority is invalid or incorrect

    wininet_e_client_auth_not_setup* =  0x80072F0E.HResult
      ## Client authentication has not been correctly installed

    wininet_e_async_thread_failed* =    0x80072F0F.HResult
      ## An error has occurred in a Wininet asynchronous thread. You may need to restart

    wininet_e_redirect_scheme_change* = 0x80072F10.HResult
      ## The protocol scheme has changed during a redirect operaiton

    wininet_e_dialog_pending* =         0x80072F11.HResult
      ## There are operations awaiting retry

    wininet_e_retry_dialog* =           0x80072F12.HResult
      ## The operation must be retried

    wininet_e_no_new_containers* =      0x80072F13.HResult
      ## There are no new cache containers

    wininet_e_https_http_submit_redir* = 0x80072F14.HResult
      ## A security zone check indicates the operation must be retried

    wininet_e_sec_cert_errors* =        0x80072F17.HResult
      ## The SSL certificate contains errors.

    wininet_e_sec_cert_rev_failed* =    0x80072F19.HResult
      ## It was not possible to connect to the revocation server or a definitive response could not be obtained.

    wininet_e_header_not_found* =       0x80072F76.HResult
      ## The requested header was not found

    wininet_e_downlevel_server* =       0x80072F77.HResult
      ## The server does not support the requested protocol level

    wininet_e_invalid_server_response* = 0x80072F78.HResult
      ## The server returned an invalid or unrecognized response

    wininet_e_invalid_header* =         0x80072F79.HResult
      ## The supplied HTTP header is invalid

    wininet_e_invalid_query_request* =  0x80072F7A.HResult
      ## The request for a HTTP header is invalid

    wininet_e_header_already_exists* =  0x80072F7B.HResult
      ## The HTTP header already exists

    wininet_e_redirect_failed* =        0x80072F7C.HResult
      ## The HTTP redirect request failed

    wininet_e_security_channel_error* = 0x80072F7D.HResult
      ## An error occurred in the secure channel support

    wininet_e_unable_to_cache_file* =   0x80072F7E.HResult
      ## The file could not be written to the cache

    wininet_e_tcpip_not_installed* =    0x80072F7F.HResult
      ## The TCP/IP protocol is not installed properly

    wininet_e_disconnected* =           0x80072F83.HResult
      ## The computer is disconnected from the network

    wininet_e_server_unreachable* =     0x80072F84.HResult
      ## The server is unreachable

    wininet_e_proxy_server_unreachable* = 0x80072F85.HResult
      ## The proxy server is unreachable

    wininet_e_bad_auto_proxy_script* =  0x80072F86.HResult
      ## The proxy auto-configuration script is in error

    wininet_e_unable_to_download_script* = 0x80072F87.HResult
      ## Could not download the proxy auto-configuration script file

    wininet_e_sec_invalid_cert* =       0x80072F89.HResult
      ## The supplied certificate is invalid

    wininet_e_sec_cert_revoked* =       0x80072F8A.HResult
      ## The supplied certificate has been revoked

    wininet_e_failed_duetosecuritycheck* = 0x80072F8B.HResult
      ## The Dialup failed because file sharing was turned on and a failure was requested if security check was needed

    wininet_e_not_initialized* =        0x80072F8C.HResult
      ## Initialization of the WinINet API has not occurred

    wininet_e_login_failure_display_entity_body* = 0x80072F8E.HResult
      ## Login failed and the client should display the entity body to the user

    wininet_e_decoding_failed* =        0x80072F8F.HResult
      ## Content decoding has failed

    wininet_e_not_redirected* =         0x80072F80.HResult
      ## The HTTP request was not redirected

    wininet_e_cookie_needs_confirmation* = 0x80072F81.HResult
      ## A cookie from the server must be confirmed by the user

    wininet_e_cookie_declined* =        0x80072F82.HResult
      ## A cookie from the server has been declined acceptance

    wininet_e_redirect_needs_confirmation* = 0x80072F88.HResult
      ## The HTTP redirect request must be confirmed by the user


    #
    # SQLite
    #

    sqlite_e_error* =                   0x87AF0001.HResult
      ## SQL error or missing database

    sqlite_e_internal* =                0x87AF0002.HResult
      ## Internal logic error in SQLite

    sqlite_e_perm* =                    0x87AF0003.HResult
      ## Access permission denied

    sqlite_e_abort* =                   0x87AF0004.HResult
      ## Callback routine requested an abort

    sqlite_e_busy* =                    0x87AF0005.HResult
      ## The database file is locked

    sqlite_e_locked* =                  0x87AF0006.HResult
      ## A table in the database is locked

    sqlite_e_nomem* =                   0x87AF0007.HResult
      ## A malloc() failed

    sqlite_e_readonly* =                0x87AF0008.HResult
      ## Attempt to write a readonly database

    sqlite_e_interrupt* =               0x87AF0009.HResult
      ## Operation terminated by sqlite3_interrupt()

    sqlite_e_ioerr* =                   0x87AF000A.HResult
      ## Some kind of disk I/O error occurred

    sqlite_e_corrupt* =                 0x87AF000B.HResult
      ## The database disk image is malformed

    sqlite_e_notfound* =                0x87AF000C.HResult
      ## Unknown opcode in sqlite3_file_control()

    sqlite_e_full* =                    0x87AF000D.HResult
      ## Insertion failed because database is full

    sqlite_e_cantopen* =                0x87AF000E.HResult
      ## Unable to open the database file

    sqlite_e_protocol* =                0x87AF000F.HResult
      ## Database lock protocol error

    sqlite_e_empty* =                   0x87AF0010.HResult
      ## Database is empty

    sqlite_e_schema* =                  0x87AF0011.HResult
      ## The database schema changed

    sqlite_e_toobig* =                  0x87AF0012.HResult
      ## String or BLOB exceeds size limit

    sqlite_e_constraint* =              0x87AF0013.HResult
      ## Abort due to constraint violation

    sqlite_e_mismatch* =                0x87AF0014.HResult
      ## Data type mismatch

    sqlite_e_misuse* =                  0x87AF0015.HResult
      ## Library used incorrectly

    sqlite_e_nolfs* =                   0x87AF0016.HResult
      ## Uses OS features not supported on host

    sqlite_e_auth* =                    0x87AF0017.HResult
      ## Authorization denied

    sqlite_e_format* =                  0x87AF0018.HResult
      ## Auxiliary database format error

    sqlite_e_range* =                   0x87AF0019.HResult
      ## 2nd parameter to sqlite3_bind out of range

    sqlite_e_notadb* =                  0x87AF001A.HResult
      ## File opened that is not a database file

    sqlite_e_notice* =                  0x87AF001B.HResult
      ## Notifications from sqlite3_log()

    sqlite_e_warning* =                 0x87AF001C.HResult
      ## Warnings from sqlite3_log()

    sqlite_e_row* =                     0x87AF0064.HResult
      ## sqlite3_step() has another row ready

    sqlite_e_done* =                    0x87AF0065.HResult
      ## sqlite3_step() has finished executing

    sqlite_e_ioerr_read* =              0x87AF010A.HResult
      ## SQLITE_IOERR_READ

    sqlite_e_ioerr_short_read* =        0x87AF020A.HResult
      ## SQLITE_IOERR_SHORT_READ

    sqlite_e_ioerr_write* =             0x87AF030A.HResult
      ## SQLITE_IOERR_WRITE

    sqlite_e_ioerr_fsync* =             0x87AF040A.HResult
      ## SQLITE_IOERR_FSYNC

    sqlite_e_ioerr_dir_fsync* =         0x87AF050A.HResult
      ## SQLITE_IOERR_DIR_FSYNC

    sqlite_e_ioerr_truncate* =          0x87AF060A.HResult
      ## SQLITE_IOERR_TRUNCATE

    sqlite_e_ioerr_fstat* =             0x87AF070A.HResult
      ## SQLITE_IOERR_FSTAT

    sqlite_e_ioerr_unlock* =            0x87AF080A.HResult
      ## SQLITE_IOERR_UNLOCK

    sqlite_e_ioerr_rdlock* =            0x87AF090A.HResult
      ## SQLITE_IOERR_RDLOCK

    sqlite_e_ioerr_delete* =            0x87AF0A0A.HResult
      ## SQLITE_IOERR_DELETE

    sqlite_e_ioerr_blocked* =           0x87AF0B0A.HResult
      ## SQLITE_IOERR_BLOCKED

    sqlite_e_ioerr_nomem* =             0x87AF0C0A.HResult
      ## SQLITE_IOERR_NOMEM

    sqlite_e_ioerr_access* =            0x87AF0D0A.HResult
      ## SQLITE_IOERR_ACCESS

    sqlite_e_ioerr_checkreservedlock* = 0x87AF0E0A.HResult
      ## SQLITE_IOERR_CHECKRESERVEDLOCK

    sqlite_e_ioerr_lock* =              0x87AF0F0A.HResult
      ## SQLITE_IOERR_LOCK

    sqlite_e_ioerr_close* =             0x87AF100A.HResult
      ## SQLITE_IOERR_CLOSE

    sqlite_e_ioerr_dir_close* =         0x87AF110A.HResult
      ## SQLITE_IOERR_DIR_CLOSE

    sqlite_e_ioerr_shmopen* =           0x87AF120A.HResult
      ## SQLITE_IOERR_SHMOPEN

    sqlite_e_ioerr_shmsize* =           0x87AF130A.HResult
      ## SQLITE_IOERR_SHMSIZE

    sqlite_e_ioerr_shmlock* =           0x87AF140A.HResult
      ## SQLITE_IOERR_SHMLOCK

    sqlite_e_ioerr_shmmap* =            0x87AF150A.HResult
      ## SQLITE_IOERR_SHMMAP

    sqlite_e_ioerr_seek* =              0x87AF160A.HResult
      ## SQLITE_IOERR_SEEK

    sqlite_e_ioerr_delete_noent* =      0x87AF170A.HResult
      ## SQLITE_IOERR_DELETE_NOENT

    sqlite_e_ioerr_mmap* =              0x87AF180A.HResult
      ## SQLITE_IOERR_MMAP

    sqlite_e_ioerr_gettemppath* =       0x87AF190A.HResult
      ## SQLITE_IOERR_GETTEMPPATH

    sqlite_e_ioerr_convpath* =          0x87AF1A0A.HResult
      ## SQLITE_IOERR_CONVPATH

    sqlite_e_ioerr_vnode* =             0x87AF1A02.HResult
      ## SQLITE_IOERR_VNODE

    sqlite_e_ioerr_auth* =              0x87AF1A03.HResult
      ## SQLITE_IOERR_AUTH

    sqlite_e_locked_sharedcache* =      0x87AF0106.HResult
      ## SQLITE_LOCKED_SHAREDCACHE

    sqlite_e_busy_recovery* =           0x87AF0105.HResult
      ## SQLITE_BUSY_RECOVERY

    sqlite_e_busy_snapshot* =           0x87AF0205.HResult
      ## SQLITE_BUSY_SNAPSHOT

    sqlite_e_cantopen_notempdir* =      0x87AF010E.HResult
      ## SQLITE_CANTOPEN_NOTEMPDIR

    sqlite_e_cantopen_isdir* =          0x87AF020E.HResult
      ## SQLITE_CANTOPEN_ISDIR

    sqlite_e_cantopen_fullpath* =       0x87AF030E.HResult
      ## SQLITE_CANTOPEN_FULLPATH

    sqlite_e_cantopen_convpath* =       0x87AF040E.HResult
      ## SQLITE_CANTOPEN_CONVPATH

    sqlite_e_corrupt_vtab* =            0x87AF010B.HResult
      ## SQLITE_CORRUPT_VTAB

    sqlite_e_readonly_recovery* =       0x87AF0108.HResult
      ## SQLITE_READONLY_RECOVERY

    sqlite_e_readonly_cantlock* =       0x87AF0208.HResult
      ## SQLITE_READONLY_CANTLOCK

    sqlite_e_readonly_rollback* =       0x87AF0308.HResult
      ## SQLITE_READONLY_ROLLBACK

    sqlite_e_readonly_dbmoved* =        0x87AF0408.HResult
      ## SQLITE_READONLY_DBMOVED

    sqlite_e_abort_rollback* =          0x87AF0204.HResult
      ## SQLITE_ABORT_ROLLBACK

    sqlite_e_constraint_check* =        0x87AF0113.HResult
      ## SQLITE_CONSTRAINT_CHECK

    sqlite_e_constraint_commithook* =   0x87AF0213.HResult
      ## SQLITE_CONSTRAINT_COMMITHOOK

    sqlite_e_constraint_foreignkey* =   0x87AF0313.HResult
      ## SQLITE_CONSTRAINT_FOREIGNKEY

    sqlite_e_constraint_function* =     0x87AF0413.HResult
      ## SQLITE_CONSTRAINT_FUNCTION

    sqlite_e_constraint_notnull* =      0x87AF0513.HResult
      ## SQLITE_CONSTRAINT_NOTNULL

    sqlite_e_constraint_primarykey* =   0x87AF0613.HResult
      ## SQLITE_CONSTRAINT_PRIMARYKEY

    sqlite_e_constraint_trigger* =      0x87AF0713.HResult
      ## SQLITE_CONSTRAINT_TRIGGER

    sqlite_e_constraint_unique* =       0x87AF0813.HResult
      ## SQLITE_CONSTRAINT_UNIQUE

    sqlite_e_constraint_vtab* =         0x87AF0913.HResult
      ## SQLITE_CONSTRAINT_VTAB

    sqlite_e_constraint_rowid* =        0x87AF0A13.HResult
      ## SQLITE_CONSTRAINT_ROWID

    sqlite_e_notice_recover_wal* =      0x87AF011B.HResult
      ## SQLITE_NOTICE_RECOVER_WAL

    sqlite_e_notice_recover_rollback* = 0x87AF021B.HResult
      ## SQLITE_NOTICE_RECOVER_ROLLBACK

    sqlite_e_warning_autoindex* =       0x87AF011C.HResult
      ## SQLITE_WARNING_AUTOINDEX

    #
    # FACILITY_UTC
    #
    utc_e_toggle_trace_started* =       0x87C51001.HResult
      ## Toggle (alternative) trace started

    utc_e_alternative_trace_cannot_preempt* = 0x87C51002.HResult
      ## Cannot pre-empt running trace: The current trace has a higher priority

    utc_e_aot_not_running* =            0x87C51003.HResult
      ## The always-on-trace is not running

    utc_e_script_type_invalid* =        0x87C51004.HResult
      ## RunScriptAction contains an invalid script type

    utc_e_scenariodef_not_found* =      0x87C51005.HResult
      ## Requested scenario definition cannot be found

    utc_e_traceprofile_not_found* =     0x87C51006.HResult
      ## Requested trace profile cannot be found

    utc_e_forwarder_already_enabled* =  0x87C51007.HResult
      ## Trigger forwarder is already enabled

    utc_e_forwarder_already_disabled* = 0x87C51008.HResult
      ## Trigger forwarder is already disabled

    utc_e_eventlog_entry_malformed* =   0x87C51009.HResult
      ## Cannot parse EventLog XML: The entry is malformed

    utc_e_diagrules_schemaversion_mismatch* = 0x87C5100A.HResult
      ## <diagrules> node contains a schemaversion which is not compatible with this client

    utc_e_script_terminated* =          0x87C5100B.HResult
      ## RunScriptAction was forced to terminate a script

    utc_e_invalid_custom_filter* =      0x87C5100C.HResult
      ## ToggleTraceWithCustomFilterAction contains an invalid custom filter

    utc_e_trace_not_running* =          0x87C5100D.HResult
      ## The trace is not running

    utc_e_reescalated_too_quickly* =    0x87C5100E.HResult
      ## A scenario failed to escalate: This scenario has escalated too recently

    utc_e_escalation_already_running* = 0x87C5100F.HResult
      ## A scenario failed to escalate: This scenario is already running an escalation

    utc_e_perftrack_already_tracing* =  0x87C51010.HResult
      ## Cannot start tracing: PerfTrack component is already tracing

    utc_e_reached_max_escalations* =    0x87C51011.HResult
      ## A scenario failed to escalate: This scenario has reached max escalations for this escalation type

    utc_e_forwarder_producer_mismatch* = 0x87C51012.HResult
      ## Cannot update forwarder: The forwarder passed to the function is of a different type

    utc_e_intentional_script_failure* = 0x87C51013.HResult
      ## RunScriptAction failed intentionally to force this escalation to terminate

    utc_e_sqm_init_failed* =            0x87C51014.HResult
      ## Failed to initialize SQM logger

    utc_e_no_wer_logger_supported* =    0x87C51015.HResult
      ## Failed to initialize WER logger: This system does not support WER for UTC

    utc_e_tracers_dont_exist* =         0x87C51016.HResult
      ## The TraceManager has attempted to take a tracing action without initializing tracers

    utc_e_winrt_init_failed* =          0x87C51017.HResult
      ## WinRT initialization failed

    utc_e_scenariodef_schemaversion_mismatch* = 0x87C51018.HResult
      ## <scenario> node contains a schemaversion that is not compatible with this client

    utc_e_invalid_filter* =             0x87C51019.HResult
      ## Scenario contains an invalid filter that can never be satisfied

    utc_e_exe_terminated* =             0x87C5101A.HResult
      ## RunExeWithArgsAction was forced to terminate a running executable

    utc_e_escalation_not_authorized* =  0x87C5101B.HResult
      ## Escalation for scenario failed due to insufficient permissions

    utc_e_setup_not_authorized* =       0x87C5101C.HResult
      ## Setup for scenario failed due to insufficient permissions

    utc_e_child_process_failed* =       0x87C5101D.HResult
      ## A process launched by UTC failed with a non-zero exit code.

    utc_e_command_line_not_authorized* = 0x87C5101E.HResult
      ## A RunExeWithArgs action contains an unauthorized command line.

    utc_e_cannot_load_scenario_editor_xml* = 0x87C5101F.HResult
      ## UTC cannot load Scenario Editor XML. Convert the scenario file to a DiagTrack XML using the editor.

    utc_e_escalation_timed_out* =       0x87C51020.HResult
      ## Escalation for scenario has timed out

    utc_e_setup_timed_out* =            0x87C51021.HResult
      ## Setup for scenario has timed out

    utc_e_trigger_mismatch* =           0x87C51022.HResult
      ## The given trigger does not match the expected trigger type

    utc_e_trigger_not_found* =          0x87C51023.HResult
      ## Requested trigger cannot be found

    utc_e_sif_not_supported* =          0x87C51024.HResult
      ## SIF is not supported on the machine

    utc_e_delay_terminated* =           0x87C51025.HResult
      ## The delay action was terminated

    utc_e_device_ticket_error* =        0x87C51026.HResult
      ## The device ticket was not obtained

    utc_e_trace_buffer_limit_exceeded* = 0x87C51027.HResult
      ## The trace profile needs more memory than is available for tracing

    utc_e_api_result_unavailable* =     0x87C51028.HResult
      ## The API was not completed successfully so the result is unavailable

    utc_e_rpc_timeout* =                0x87C51029.HResult
      ## The requested API encountered a timeout in the API manager

    utc_e_rpc_wait_failed* =            0x87C5102A.HResult
      ## The synchronous API encountered a wait failure

    utc_e_api_busy* =                   0x87C5102B.HResult
      ## The UTC API is busy with another request

    utc_e_trace_min_duration_requirement_not_met* = 0x87C5102C.HResult
      ## The running trace profile does not have a sufficient runtime to fulfill the escalation request

    utc_e_exclusivity_not_available* =  0x87C5102D.HResult
      ## The trace profile could not be started because it requires exclusivity and another higher priority trace is already running

    utc_e_getfile_file_path_not_approved* = 0x87C5102E.HResult
      ## The file path is not approved for the GetFile escalation action

    utc_e_escalation_directory_already_exists* = 0x87C5102F.HResult
      ## The escalation working directory for the requested escalation could not be created because it already exists
