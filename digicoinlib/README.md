<p align="center">
  <a href="https://digibyte.org/"><img src="https://raw.githubusercontent.com/DigiByte-Core/digibyte/develop/share/pixmaps/digibyte256.png" width="110" alt="DigiByte logo"></a>
</p>
<p align="center">
  <a href="https://github.com/sumcoinlabs/digicoinlib"><img src="https://img.shields.io/badge/source-0.0.3--candidate-0066CC" alt="DigiCoinLib 0.0.3 source"></a>
  <a href="https://github.com/sumcoinlabs/digicoinlib/blob/master/LICENSE"><img src="https://img.shields.io/badge/license-BSD--3--Clause-blue" alt="BSD-3-Clause"></a>
  <a href="https://github.com/sumcoinlabs/digicoinlib/tree/master/digicoinlib"><img src="https://img.shields.io/badge/Dart-library-0175C2?logo=dart" alt="Dart library"></a>
  <a href="https://github.com/sumcoinlabs/digicoinlib/tree/master/digicoinlib_flutter"><img src="https://img.shields.io/badge/Flutter-plugin-02569B?logo=flutter" alt="Flutter plugin"></a>
  <a href="https://github.com/sumcoinlabs/digicoinlib/actions/workflows/dart-test-analyze.yml"><img src="https://github.com/sumcoinlabs/digicoinlib/actions/workflows/dart-test-analyze.yml/badge.svg?branch=master" alt="CI status"></a>
</p>

# DigiCoinLib Dart — 0.0.3 candidate

DigiByte-focused Dart library for secp256k1, BIP32, WIF, addresses, message signing and UTXO transactions.

Install after publication:

```sh
dart pub add digicoinlib
```

```dart
import 'package:digicoinlib/digicoinlib.dart';

Future<void> main() async {
  await loadDigiCoinlib();
  final network = Network.mainnet;
  print(network.bech32Hrp); // dgb
}
```

`Network.testnet`, `Network.signet` and `Network.regtest` use DigiByte Core constants; see [MIGRATION.md](../MIGRATION.md). Default `Bitcoin seed` HMAC key is retained to preserve BIP32 wallet recovery.

For Flutter use [`digicoinlib_flutter`](../digicoinlib_flutter/README.md), which loads platform-specific secp256k1 support. Library APIs for witness/Taproot construction do not imply network activation.

## Platform build and development reference

## Building for Linux

Docker or Podman is required to build the library for Linux.

The linux shared library can be built using `dart run digicoinlib:build_linux` in
the root directory of your package which will produce a shared library into
`build/libsecp256k1.so`. This can also be run in the `digicoinlib` root directory
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

To build the dynamic library, run `dart run digicoinlib:build_macos` which will
place the library under a `build` directory.

## Building for Windows

### Native Windows build

**Please note that native windows builds under this section can sometimes freeze
during the build process.** If this happens please use the WSL build process
described in
["Cross-compiling for Windows using WSL"](#cross-compiling-for-windows-using-wsl).

Building on Windows requires CMake as a dependency.

The Windows shared library can be built using `dart run digicoinlib:build_windows` in
the root directory of your package which will produce a shared library into
`build/libsecp256k1.dll`. This can also be run in the `digicoinlib` root directory
via `dart run bin/build_windows.dart`.

Windows builds use the Visual Studio 17 2022 generator.  Earlier Visual Studio
toolchains may work by editing `bin/build_windows.dart`.

### Cross-compiling for Windows from Linux

Cross-compile a secp256k1 DLL for Windows on an Ubuntu 20.04 host with
`dart run digicoinlib:build_windows_crosscompile`. This can also be run in the
`digicoinlib` root directory via `dart run bin/build_windows_crosscompile.dart`.

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
on a Windows host with `dart run digicoinlib:build_wsl` or
`dart run bin/build_wsl.dart` in the `digicoinlib` root directory, or complete the
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
`headers/secp256k1.h` file using `dart run ffigen` within the `digicoinlib` package.

The WebAssembly module has been pre-built to
`lib/src/secp256k1/secp256k1.wasm.g.dart`. It may be rebuilt using `dart run
bin/build_wasm.dart` in the `digicoinlib` root directory.
