<p align="center">
  <img
    src="https://raw.githubusercontent.com/sumcoinlabs/sumcoinlib/master/logo.svg"
    alt="Sumcoinlib"
    width="250px"
  >
</p>

<p align="center">
<!--  <a href="https://chainz.cryptoid.info/ppc/address.dws?p77CZFn9jvg9waCzKBzkQfSvBBzPH1nRre"> -->
  <a href="https://sumexplorer.com">
  <img src="https://badgen.net/badge/sumcoin/Donate/blue?icon=https://sumcoin.org/wp-content/uploads/2019/07/sumcoin_400x400.png" alt="Sumcoin Donate">

  </a>
  <a href="https://pub.dev/packages/sumcoinlib">
    <img alt="pub.dev" src="https://img.shields.io/pub/v/sumcoinlib?logo=dart&label=pub.dev">
  </a>
</p>

# Sumcoinlib

Sumcoinlib is a straight-forward and modular library for Sumcoin and other similar
cryptocoins including Taproot support. This library allows for the construction
and signing of transactions and management of BIP32 wallets.

## Installation and Usage

If you are using flutter, please see
[sumcoinlib_flutter](https://pub.dev/packages/sumcoinlib_flutter) instead. Otherwise
you may add `sumcoinlib` to your project via:

```
dart pub add sumcoinlib
```

If you are using the library for web, the library is ready to use. If you are
using the library on Linux, macOS, or Windows, then please see
["Building for Linux"](#building-for-linux),
["Building for macOS"](#building-for-macos), or
["Building for Windows"](#building-for-windows) below.

The library can be imported via:

```
import 'package:sumcoinlib/sumsumsumcoinlib.dart';
```

The library must be asynchronously loaded by awaiting the `loadSumCoinlib()`
function before any part of the library is used.

The library uses a functional-style of OOP. With some exceptions, objects are
immutable. New modified objects are returned from methods. For example, signing
a transaction returns a new signed transaction object:

```dart
final signedTx = unsignedTx.sign(inputN: 0, key: privateKey);
```

An example is found in the `example/` directory.

## Building for Linux

Docker or Podman is required to build the library for Linux.

The linux shared library can be built using `dart run sumcoinlib:build_linux` in
the root directory of your package which will produce a shared library into
`build/libsecp256k1.so`. This can also be run in the `sumcoinlib` root directory
via `dart run bin/build_linux.dart`.

This library can be in the `build` directory under the PWD, installed as a
system library, or within `$LD_LIBRARY_PATH`.

## Building for macOS

Building for macOS requires autotools that may be installed using homebrew:

```
brew install autoconf automake libtool
```

The macOS dynamic library must either be provided as
`$PWD/build/libsecp256k1.dylib` when running dart code, or provided as a system
framework named `secp256k1.framework`.

To build the dynamic library, run `dart run sumcoinlib:build_macos` which will
place the library under a `build` directory.

## Building for Windows

### Native Windows build

**Please note that native windows builds under this section can sometimes freeze
during the build process.** If this happens please use the WSL build process
described in
["Cross-compiling for Windows using WSL"](#cross-compiling-for-windows-using-wsl).

Building on Windows requires CMake as a dependency.

The Windows shared library can be built using `dart run sumcoinlib:build_windows` in
the root directory of your package which will produce a shared library into
`build/libsecp256k1.dll`. This can also be run in the `sumcoinlib` root directory
via `dart run bin/build_windows.dart`.

Windows builds use the Visual Studio 17 2022 generator.  Earlier Visual Studio
toolchains may work by editing `bin/build_windows.dart`.

### Cross-compiling for Windows from Linux

Cross-compile a secp256k1 DLL for Windows on an Ubuntu 20.04 host with
`dart run sumcoinlib:build_windows_crosscompile`. This can also be run in the
`sumcoinlib` root directory via `dart run bin/build_windows_crosscompile.dart`.

### Cross-compiling for Windows using WSL

Builds on Windows can be accomplished using WSL2 (Windows Subsystem for Linux).
First, install the following packages to the WSL(2) host:

 - `autoconf`
 - `libtool`
 - `build-essential`
 - `git`
 - `cmake`
 - `mingw-w64`

as in:

```
apt-get update -y
apt-get install -y autoconf libtool build-essential git cmake mingw-w64
```

Then, cross-compile a secp256k1 DLL for Windows on an Ubuntu 20.04 WSL2 instance
on a Windows host with `dart run sumcoinlib:build_wsl` or
`dart run bin/build_wsl.dart` in the `sumcoinlib` root directory, or complete the
above
["Cross-compiling for Windows on Linux"](#cross-compiling-for-windows-from-linux)
after installing Docker or Podman in WSL. The build can also be completed
without installing Flutter to WSL by following
[bitcoin-core/secp256k1's "Cross compiling" guide](https://github.com/bitcoin-core/secp256k1?tab=readme-ov-file#cross-compiling).

## Development

This section is only relevant to developers of the library.

### Bindings and WebAssembly

The WebAssembly (WASM) module is pre-compiled and ready to use. FFI bindings
are pre-generated. These only need to be updated when the underlying secp256k1
library is changed.

Bindings for the native libraries (excluding WebAssembly) are generated from the
`headers/secp256k1.h` file using `dart run ffigen` within the `sumcoinlib` package.

The WebAssembly module has been pre-built to
`lib/src/secp256k1/secp256k1.wasm.g.dart`. It may be rebuilt using `dart run
bin/build_wasm.dart` in the `sumcoinlib` root directory.
