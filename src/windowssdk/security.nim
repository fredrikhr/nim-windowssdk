#+-----------------------------------------------------------------------
#
# Microsoft Windows
#
# Copyright (c) Microsoft Corporation 1991-1999
#
# File:        Security.h
#
# Contents:    Toplevel include file for security aware components
#
#
#
#------------------------------------------------------------------------


# This file will go out and pull in all the header files that you need,
# based on defines that you issue.  The following macros are used.
#
# SECURITY_KERNEL      Use the kernel interface, not the usermode
#

#
# These are name that can be used to refer to the builtin packages
#
const
  ntlmSpName* = "NTLM"
  microsoftKerberosName* = "Kerberos"
  negoSspName* = "Negotiate"

#
# Include the master SSPI header file
#
include sspi
include secext

include issper16
