# Android native artifact provenance — DigiCoinLib Flutter 0.0.3

Source of truth: authenticated pub.dev `digicoinlib_flutter` 0.0.2 archive,
compared with the original tracked GitHub baseline and local modified pub cache.
The local pub cache was NOT trusted as a copy of published 0.0.2.

The existing `src/CMakeLists.txt` pins bitcoin-core/secp256k1
commit `1ad5185cd42c0636104129fcc9f6a4bf9c67cc40` (v0.4.1).
The Android debug APK was checked for all four ABIs and required FFI exports.
A debug APK check does not replace real-device signing tests.

| ABI | APK bytes | APK SHA-256 | Provenance |
| --- | ---: | --- | --- |
| `armeabi-v7a` | 1,218,148 | `8c628392b7cb2e6e6df50fd8ec5e4c6dab1195a9fbd8c092c9963496211289b8` | Native build output; no binary in published 0.0.2 |
| `arm64-v8a` | 1,247,080 | `65b0afb4feb302447fb7eb4cec1c4406159830a7ada4d1012a180197fcf7864c` | Native build output; no binary in published 0.0.2 |
| `x86` | 1,304,056 | `3ae1c9e219037566bd9e8ba22cc28b9522287f2151c5848ec247817a1bb76197` | Native build output; no binary in published 0.0.2 |
| `x86_64` | 1,251,448 | `dd5673961e58f74f6e8ecfa4a745841d0b39296b2ab21d63ebf10ee24454adcd` | Native build output; no binary in published 0.0.2 |

The two `.bak` Android files from the modified local pub cache were not
included. Android namespace was reconciled against official 0.0.2.
Generated JNI artifacts are left gitignored if not present in the official archive.
Both packages were published on November 5, 2026. Real-device signing and native platform compatibility checks remain outstanding before production wallet integration.
