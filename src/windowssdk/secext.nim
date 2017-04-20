##+-----------------------------------------------------------------------
##
## Microsoft Windows
##
## Copyright (c) Microsoft Corporation 1991-1999
##
## File:        secext.h
##
## Contents:    Security function prototypes for functions not part of
##              the SSPI interface. This file should not be directly
##              included - include security.h instead.
##
##
##
##------------------------------------------------------------------------

import .. / ansiwide, winnt

##
## Extended Name APIs for ADS
##
type
  Extended_Name_Format* = enum 
    ## Examples for the following formats assume a fictitous company
    ## which hooks into the global X.500 and DNS name spaces as follows.
    ##
    ## Enterprise root domain in DNS is
    ##
    ##      widget.com
    ##
    ## Enterprise root domain in X.500 (RFC 1779 format) is
    ##
    ##      O=Widget, C=US
    ##
    ## There exists the child domain
    ##
    ##      engineering.widget.com
    ##
    ## equivalent to
    ##
    ##      OU=Engineering, O=Widget, C=US
    ##
    ## There exists a container within the Engineering domain
    ##
    ##      OU=Software, OU=Engineering, O=Widget, C=US
    ##
    ## There exists the user
    ##
    ##      CN=John Doe, OU=Software, OU=Engineering, O=Widget, C=US
    ##
    ## And this user's downlevel (pre-ADS) user name is
    ##
    ##      Engineering\JohnDoe

    nameUnknown = 0,          ## unknown name type

    nameFullyQualifiedDN = 1, ## CN=John Doe, OU=Software, OU=Engineering, O=Widget, C=US

    nameSamCompatible = 2,    ## Engineering\JohnDoe

    nameDisplay = 3,          ## Probably "John Doe" but could be something else.  I.e. The
                              ## display name is not necessarily the defining RDN.

    nameUniqueId = 6,         ## String-ized GUID as returned by IIDFromString().
                              ## eg: {4fa050f0-f561-11cf-bdd9-00aa003a77b6}

    nameCanonical = 7,        ## engineering.widget.com/software/John Doe

    nameUserPrincipal = 8,    ## someone@example.com

    nameCanonicalEx = 9,      ## Same as NameCanonical except that rightmost '/' is
                              ## replaced with '\n' - even in domain-only case.
                              ## eg: engineering.widget.com/software\nJohn Doe

    nameServicePrincipal = 10,## www/srv.engineering.com/engineering.com

    nameDnsDomain = 12,       ## DNS domain name + SAM username
                              ## eg: engineering.widget.com\JohnDoe

    nameGivenName = 13,
    nameSurname   = 14
  PExtended_Name_Format* = Extended_Name_Format

ansiWideAllImportC(getUserNameEx,
  getUserNameExA, getUserNameExW,
  LPTStr, LPStr, LPWStr,
  "GetUserNameExA", "GetUserNameExW"):
  ## ref.: https://msdn.microsoft.com/en-us/library/ms724435.aspx
  proc getUserNameEx*(
    nameFormat: Extended_Name_Format,
    nameBuffer: LPTStr,
    len: var uint32
    ): Boolean {.stdcall, dynlib: "Secur32.dll", importc.}

ansiWideAllImportC(getComputerObjectName,
  getComputerObjectNameA, getComputerObjectNameW,
  LPTStr, LPStr, LPWStr,
  "GetComputerObjectNameA", "GetComputerObjectNameW"):
  ## ref.: https://msdn.microsoft.com/en-us/library/ms724304.aspx
  proc getComputerObjectName*(
    nameFormat: Extended_Name_Format,
    nameBuffer: LPTStr,
    len: var uint32
    ): Boolean {.stdcall, dynlib: "Secur32.dll", importc.}

ansiWideAllImportC(("translateName",
  "translateNameA", "translateNameW"),
  [("LPTStr", "LPStr", "LPWStr"),
  ("LPCTStr", "LPCStr", "LPCWStr")],
  ("TranslateNameA", "TranslateNameW")):
  proc translateName*(
    accountName: LPCTStr,
    accountNameFormat: Extended_Name_Format,
    desiredNameFormat: Extended_Name_Format,
    translatedName: LPTStr,
    len: var uint32
    ): Boolean {.stdcall, dynlib: "Secur32.dll", importc.}