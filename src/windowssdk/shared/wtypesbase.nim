type ClsCtx* = distinct int32
  ## ref.: https://msdn.microsoft.com/en-us/library/ms693716.aspx
const
  clsctx_Inproc_Server* = 0x1.ClsCtx
    ## The code that creates and manages objects of this class is a DLL that runs in the same process as the caller of the function specifying the class context.
  clsctx_Inproc_Handler* = 0x2.ClsCtx
    ## The code that manages objects of this class is an in-process handler. This is a DLL that runs in the client process and implements client-side structures of this class when instances of the class are accessed remotely.
  clsctx_Local_Server* = 0x4.ClsCtx
    ## The EXE code that creates and manages objects of this class runs on same machine but is loaded in a separate process space.
  clsctx_Inproc_Server16* {.deprecated.} = 0x8.ClsCtx
    ## Obsolete.
  clsctx_Remote_Server* = 0x10.ClsCtx
    ## A remote context. The LocalServer32 or LocalService code that creates and manages objects of this class is run on a different computer.
  clsctx_Inproc_Handler16* {.deprecated.} = 0x20.ClsCtx
    ## Obsolete.
  clsctx_Reserved1* = 0x40.ClsCtx
    ## Reserved.
  clsctx_Reserved2* = 0x80.ClsCtx
    ## Reserved.
  clsctx_Reserved3* = 0x100.ClsCtx
    ## Reserved.
  clsctx_Reserved4* = 0x200.ClsCtx
    ## Reserved.
  clsctx_No_Code_Download* = 0x400.ClsCtx
    ## Disaables the downloading of code from the directory service or the Internet. This flag cannot be set at the same time as CLSCTX_ENABLE_CODE_DOWNLOAD.
  clsctx_Reserved5* = 0x800.ClsCtx
    ## Reserved.
  clsctx_No_Custom_Marshal* = 0x1000.ClsCtx
    ## Specify if you want the activation to fail if it uses custom marshalling.
  clsctx_Enable_Code_Download* = 0x2000.ClsCtx
    ## Enables the downloading of code from the directory service or the Internet. This flag cannot be set at the same time as CLSCTX_NO_CODE_DOWNLOAD.
  clsctx_No_Failure_Log* = 0x4000.ClsCtx
    ## The CLSCTX_NO_FAILURE_LOG can be used to override the logging of failures in CoCreateInstanceEx.
    ##
    ## If the ActivationFailureLoggingLevel is created, the following values can determine the status of event logging:
    ## * 0 = Discretionary logging. Log by default, but clients can override by specifying CLSCTX_NO_FAILURE_LOG in CoCreateInstanceEx.
    ## * 1 = Always log all failures no matter what the client specified.
    ## * 2 = Never log any failures no matter what client specified. If the registry entry is missing, the default is 0. If you need to control customer applications, it is recommended that you set this value to 0 and write the client code to override failures. It is strongly recommended that you do not set the value to 2. If event logging is disabled, it is more difficult to diagnose problems. 
  clsctx_Disable_Aaa* = 0x8000.ClsCtx
    ## Disables activate-as-activator (AAA) activations for this activation only. This flag overrides the setting of the EOAC_DISABLE_AAA flag from the EOLE_AUTHENTICATION_CAPABILITIES enumeration. This flag cannot be set at the same time as CLSCTX_ENABLE_AAA. Any activation where a server process would be launched under the caller's identity is known as an activate-as-activator (AAA) activation. Disabling AAA activations allows an application that runs under a privileged account (such as LocalSystem) to help prevent its identity from being used to launch untrusted components. Library applications that use activation calls should always set this flag during those calls. This helps prevent the library application from being used in an escalation-of-privilege security attack. This is the only way to disable AAA activations in a library application because the EOAC_DISABLE_AAA flag from the EOLE_AUTHENTICATION_CAPABILITIES enumeration is applied only to the server process and not to the library application.
    ## 
    ## **Windows 2000:** This flag is not supported.
  clsctx_Enable_Aaa* = 0x10000.ClsCtx
    ## Enables activate-as-activator (AAA) activations for this activation only. This flag overrides the setting of the EOAC_DISABLE_AAA flag from the EOLE_AUTHENTICATION_CAPABILITIES enumeration. This flag cannot be set at the same time as CLSCTX_DISABLE_AAA. Any activation where a server process would be launched under the caller's identity is known as an activate-as-activator (AAA) activation. Enabling this flag allows an application to transfer its identity to an activated component. 
    ## 
    ## **Windows 2000:** This flag is not supported.
  clsctx_From_Default_Context* = 0x20000.ClsCtx
    ## Begin this activation from the default context of the current apartment.
  clsctx_Activate_32_Bit_Server* = 0x40000.ClsCtx
    ## Activate or connect to a 32-bit version of the server; fail if one is not registered.
  clsctx_Activate_64_Bit_Server* = 0x80000.ClsCtx
    ## Activate or connect to a 64 bit version of the server; fail if one is not registered. 
  clsctx_Enable_Cloaking* = 0x100000.ClsCtx
    ## When this flag is specified, COM uses the impersonation token of the thread, if one is present, for the activation request made by the thread. When this flag is not specified or if the thread does not have an impersonation token, COM uses the process token of the thread's process for the activation request made by the thread. 
    ##
    ## **Windows Vista or later**: This flag is supported.
  clsctx_Appcontainer {.used.} = 0x400000.ClsCtx
    ## Indicates activation is for an app container.
    ##
    ## **Note** This flag is reserved for internal use and is not intended to be used directly from your code.
  clsctx_Activate_Aaa_As_Iu* = 0x800000.ClsCtx
    ## Specify this flag for Interactive User activation behavior for As-Activator servers. A strongly named Medium IL Windows Store app can use this flag to launch an "As Activator" COM server without a strong name. Also, you can use this flag to bind to a running instance of the COM server that's launched by a desktop application.
    ##
    ## The client must be Medium IL, it must be strongly named, which means that it has a SysAppID in the client token, it can't be in session 0, and it must have the same user as the session ID's user in the client token. If the server is out-of-process and "As Activator", it launches the server with the token of the client token's session user. This token won't be strongly named. If the server is out-of-process and RunAs "Interactive User", this flag has no effect. If the server is out-of-process and is any other RunAs type, the activation fails. This flag has no effect for in-process servers. Off-machine activations fail when they use this flag.
  clsctx_Ps_Dll* = 0x80000000.ClsCtx
    ## Used for loading Proxy/Stub DLLs.
    ##
    ## **Note** This flag is reserved for internal use and is not intended to be used directly from your code.
