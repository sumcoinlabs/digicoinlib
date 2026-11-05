# DigiCoinLib release history

## v0.0.3 — release candidate (not published)

The Dart core package corrects DigiByte testnet Bech32, adds signet/regtest, fixes an optional BIP32 derivation argument, and introduces regression tests and independently recalculated DigiByte address and message-signature test fixtures. The Flutter wrapper fixes AGP 8's required Android namespace. Both READMEs and CI are updated.

**Compatibility:** DigiByte mainnet prefixes and default BIP32 seed derivation are unchanged. Testnet `tdgb` → `dgbt` is a breaking correction for applications that used the old testnet HRP. Explicit custom BIP32 `key:` calls now derive the requested key; default calls are unaffected.

**Verification:** See [VALIDATION.md](VALIDATION.md) and [MIGRATION.md](MIGRATION.md). Publishing is intentionally not automated.

## v0.0.2

Previous published Dart core and Flutter wrapper releases. Detailed history remains in the individual package changelogs.
