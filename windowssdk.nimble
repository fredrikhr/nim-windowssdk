# Package

version       = "10.0.10240"
author        = "Fredrik H\x9Bis\x91ther Rasch"
description   = "Windows SDK nimble package"
license       = "MIT"
srcDir        = "src"

# Dependencies

requires "nim >= 0.17.0"

# Setup
before build:
  mkDir "bin"
before buildWithSdk:
  mkDir "bin"

before test:
  mkDir "bin"
before testWithSdk:
  mkDir "bin"

task build, "Builds the Windows SDK bundle":
  exec "nim compile -o:bin/windowssdk --nimcache:obj src/windowssdk"

task buildWithSdk, "Builds the Windows SDK bundle":
  exec "nim compile -o:bin/windowssdk --nimcache:obj -d:useWinSdk --dynlibOverride:Secur32.dll --dynlibOverride:SspiCli.dll --dynlibOverride:CredUi.dll --passL:Secur32.lib src/windowssdk"

task test, "Runs the test module":
  exec "nim compile -r -o:bin/twindowssdk --nimcache:obj test/twindowssdk"

task testWithSdk, "Runs the test module":
  exec "nim compile -r -o:bin/twindowssdk --nimcache:obj -d:useWinSdk --dynlibOverride:Secur32.dll --dynlibOverride:SspiCli.dll --dynlibOverride:CredUi.dll --passL:Secur32.lib test/twindowssdk"
