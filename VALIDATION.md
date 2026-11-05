# DigiCoinLib 0.0.3 verification status

## Compatibility claims

- Core mainnet WIF/address/BIP32/Bech32 constants are preserved.
- The default BIP32 `Bitcoin seed` derivation is preserved.
- Testnet Bech32 intentionally changes from `tdgb` to `dgbt`.
- Signet and regtest are added.
- An explicit custom BIP32 `key:` argument now affects derivation as documented.
- No transaction serializer or secp256k1 implementation change is intended.

## Verification gates

- [ ] Compare GitHub runtime/native sources against both published 0.0.2 packages.
- [ ] Pass new network/BIP32 regression test.
- [ ] Run complete Dart/Chrome suite and evaluate inherited fixtures.
- [ ] Run Dart analyzer, Flutter plugin and Flutter example analyzer.
- [ ] Build Flutter plugin on Android API 36 and test it inside DigiByte Wallet.
- [ ] Test native secp256k1 on iOS/macOS and actual device upgrades.
- [ ] Verify release package contents with `dart pub publish --dry-run`.
- [ ] Publish Dart core, then Flutter wrapper, with explicit authorization.

This document intentionally does not state that unchecked validation gates have passed. Run results appear in GitHub Actions and local terminal output.

Network source: [DigiByte Core src/kernel/chainparams.cpp](https://github.com/DigiByte-Core/digibyte/blob/develop/src/kernel/chainparams.cpp). Do not infer DigiByte consensus activation of arbitrary script types from library API support.
