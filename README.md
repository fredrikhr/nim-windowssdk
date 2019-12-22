# Windows SDK binding for Nim

This nimble package is a collection of nim modules that provide native nim FFI Foreign function interface) bindings for the types, symbols, functions and interfaces that are defined in the Windows SDK.

This package is versioned with the Windows SDK version that serves as its current reference. Currently this package uses the definitions of Windows SDK version `10.0.17134.0`.

## API structure

The definitions in this package are designed to mirror the native C definitions of the Windows SDK as much as possible.

## Usage

### Nimble package reference

This package is not published to the nimble package manager repository. In order to include this package from your own package edit your `.nimble` file and
add the following line to it:

``` nimble
requires "https://github.com/couven92/nim-windowssdk.git >= 10.0.17134.0"
```

### Use statically linked Windows SDK libraries

This package uses compile-time definitions to control if and how certain features are enabled.

If your development environment includes access to the Windows SDK referenced by this package or later, your nim code does not need to use dynamic library bindings at runtime. Instead, the compiler will use a statically linked library to optimally import the required libraries. To enable this behaviour define the compile-time symbol `useWinSdk`. To do this add `-d:useWinSdk` to your nim compilation command-line arguments.

### Generate stringify and parse methods for Windows error constants

The Windows SDK defines many C preprocessor constants (e.g. Windows Error Codes) but does not group them together in an enum definition. In order to logically group these constants together, this package makes use of the `importc_helpers` package to generate proper types for constants that are logically grouped together.

The `importc_helpers` package is also capable of generating stringify and parse functions for these distinct numeric types. But, e.g. for the `HResult` type these functions would include the names of thousands of symbol names in the binary output of your application and can increase the file size by several MiB. Because of that the string-helper functions for the Windows SDK types are disabled by default. If you want to enable string helper functions for Windows Error constants, define the compile-time symbol `useWinErrorStringify` by adding `-d:useWinErrorStringify` to your nim compilation command-line arguments.
