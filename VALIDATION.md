# DigiCoinLib 0.0.3 verification status

## Compatibility claims

- Core mainnet WIF/address/BIP32/Bech32 constants are preserved.
- The default BIP32 `Bitcoin seed` derivation is preserved.
- Testnet Bech32 intentionally changes from `tdgb` to `dgbt`.
- Signet and regtest are added.
- An explicit custom BIP32 `key:` argument now affects derivation as documented.
- No transaction serializer or secp256k1 implementation change is intended.

## Verification gates

- [x] Compared source and native components against official 0.0.2 archives.
- [x] Passed DigiByte network and BIP32 regression tests.
- [x] Passed all 285 Dart/Chrome core tests.
- [x] Passed Dart and Flutter static analysis.
- [x] Built the Android debug example APK.
- [x] Verified native secp256k1 exports for four Android architectures.
- [x] Completed pub.dev package validation.
- [x] Published both DigiCoinLib 0.0.3 packages on November 5, 2026.
- [ ] Complete DigiByte Wallet real-device Android signing and upgrade testing.
- [ ] Complete iOS/macOS native signing and wallet upgrade testing.

**Release status:** Both packages are published and available on pub.dev. Remaining device and wallet-compatibility testing is explicitly tracked separately. Successful publication does not constitute a full security audit or certify production wallet upgrades.

Network source: [DigiByte Core src/kernel/chainparams.cpp](https://github.com/DigiByte-Core/digibyte/blob/develop/src/kernel/chainparams.cpp). Do not infer DigiByte consensus activation of arbitrary script types from library API support.
