# DigiCoinLib 0.0.3 migration guide

## Mainnet wallets

No intended changes to `Network.mainnet`, standard `HDPrivateKey.fromSeed(seed)`, public import names, or default DigiByte transaction serialization. **Do not change the standard BIP32 `Bitcoin seed` label**: it is part of the BIP32 specification, not Bitcoin branding.

## Testnet

`Network.testnet.bech32Hrp` is corrected from `tdgb` to `dgbt` per DigiByte Core. Applications that generated or displayed `tdgb1...` testnet addresses must review their testnet fixtures and saved address handling. Existing mainnet wallets are unaffected.

## Signet and regtest

`Network.signet` uses testnet address/key versions and `dgbt` Bech32. `Network.regtest` uses the same address/key versions and `dgbrt` Bech32. These are address/key encoding configurations, **not** a promise of automatic node or Electrum connection support.

## Custom BIP32 labels

`HDPrivateKey.fromSeed(seed, key: 'custom')` now respects `key`. Previously it silently used `Bitcoin seed` regardless of the argument. Only callers supplying a non-default value see changed derivations.

## Android

The Flutter wrapper now declares its Android namespace for modern Android Gradle Plugin builds. The Dart import and `DigiCoinlibLoader` API are unchanged.

## Release status

Both version 0.0.3 packages were published on November 5, 2026:

- [DigiCoinLib Dart 0.0.3](https://pub.dev/packages/digicoinlib/versions/0.0.3)
- [DigiCoinLib Flutter 0.0.3](https://pub.dev/packages/digicoinlib_flutter/versions/0.0.3)

DigiByte Wallet integration remains a separate step. The wallet must update its dependency to `digicoinlib_flutter: ^0.0.3` and complete Android/iOS signing, recovery, and upgrade testing before shipping the updated application.

Publishing these libraries does not certify that all real-device wallet tests are complete.
