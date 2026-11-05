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

# DigiCoinLib — Dart and Flutter libraries for DigiByte

DigiCoinLib provides DigiByte address encoding, BIP32 hierarchical keys, WIF handling, secp256k1 signing, and UTXO transaction construction. This repository contains two packages:

| Directory | Package | Purpose |
|---|---|---|
| [`digicoinlib/`](digicoinlib/) | [`digicoinlib`](https://pub.dev/packages/digicoinlib) | Pure Dart transaction and cryptographic APIs |
| [`digicoinlib_flutter/`](digicoinlib_flutter/) | [`digicoinlib_flutter`](https://pub.dev/packages/digicoinlib_flutter) | Cross-platform Flutter native/web loader |

**0.0.3 is a source release candidate until validated and published to pub.dev.** See [Changelog](CHANGELOG.md), [Migration guide](MIGRATION.md), and [Validation checklist](VALIDATION.md).

## Network configuration

| Network | P2PKH | P2SH | WIF | Bech32 HRP |
|---|---:|---:|---:|---|
| DigiByte mainnet | 30 | 63 | 128 | `dgb` |
| DigiByte testnet | 126 | 140 | 254 | `dgbt` |
| DigiByte signet | 126 | 140 | 254 | `dgbt` |
| DigiByte regtest | 126 | 140 | 254 | `dgbrt` |

These bytes were checked against [DigiByte Core](https://github.com/DigiByte-Core/digibyte/blob/develop/src/kernel/chainparams.cpp). Do not assume Taproot or any particular witness script is active on mainnet solely because the API can construct it.

## Development

```sh
cd digicoinlib && dart pub get && dart analyze && dart test -p chrome
cd ../digicoinlib_flutter && flutter pub get && flutter analyze
cd example && flutter pub get && flutter analyze
```

Before the unpublished 0.0.3 core is available on pub.dev, use local `pubspec_overrides.yaml` path overrides (the CI workflow creates them) or wait until core publication.

## Security and compatibility

The default BIP32 HMAC key **must remain `Bitcoin seed`** for standard BIP32 wallet recovery. It is a standard identifier, not inherited marketing text. Never publish real wallet seeds or keys in tests or bug reports. No claim of full backward compatibility is made without the validation checks.

## Provenance and license

BSD-3-Clause; retained upstream copyright and license notices remain in the package `LICENSE` files. DigiByte graphics are linked from [DigiByte Core's official website](https://digibyte.org/).
