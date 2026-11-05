<p align="center">
  <a href="https://digibyte.org/"><img src="https://raw.githubusercontent.com/DigiByte-Core/digibyte-logos/master/Symbol%20Icons/512x512.png" width="110" alt="DigiByte logo"></a>
</p>
<p align="center">
  <a href="https://pub.dev/packages/digicoinlib/versions/0.0.3"><img src="https://img.shields.io/badge/Dart-0.0.3%20published-0175C2" alt="DigiCoinLib Dart 0.0.3 published"></a>
  <a href="https://pub.dev/packages/digicoinlib_flutter/versions/0.0.3"><img src="https://img.shields.io/badge/Flutter-0.0.3%20published-02569B" alt="DigiCoinLib Flutter 0.0.3 published"></a>
  <a href="https://github.com/sumcoinlabs/digicoinlib/blob/master/LICENSE"><img src="https://img.shields.io/badge/license-BSD--3--Clause-blue" alt="BSD-3-Clause"></a>
  <a href="https://github.com/sumcoinlabs/digicoinlib/tree/master/digicoinlib"><img src="https://img.shields.io/badge/Dart-library-0175C2?logo=dart" alt="Dart library"></a>
  <a href="https://github.com/sumcoinlabs/digicoinlib/tree/master/digicoinlib_flutter"><img src="https://img.shields.io/badge/Flutter-plugin-02569B?logo=flutter" alt="Flutter plugin"></a>
  <a href="https://github.com/sumcoinlabs/digicoinlib/actions/workflows/dart-test-analyze.yml"><img src="https://github.com/sumcoinlabs/digicoinlib/actions/workflows/dart-test-analyze.yml/badge.svg?branch=master" alt="CI status"></a>
</p>

# DigiCoinLib Flutter — 0.0.3

Flutter platform wrapper for [`digicoinlib`](../digicoinlib/README.md), including native secp256k1 integration and the `DigiCoinlibLoader` widget for asynchronous initialization.

Install the published package:

```sh
flutter pub add digicoinlib_flutter
```

```dart
import 'package:flutter/widgets.dart';
import 'package:digicoinlib_flutter/digicoinlib_flutter.dart';

class DigiByteLoaderExample extends StatelessWidget {
  const DigiByteLoaderExample({super.key});

  @override
  Widget build(BuildContext context) => DigiCoinlibLoader(
    loadChild: const Text('Loading DigiCoinLib'),
    errorBuilder: (context, error) => Text('Error: $error'),
    builder: (context) => const Text('DigiCoinLib ready'),
  );
}
```

Supports Android, iOS, Linux, macOS, Windows and web with platform-specific setup. Android uses the explicit `com.example.digicoinlib_flutter` Gradle namespace required by AGP 8+. The example application at [`example/`](example/) uses a local path reference to the wrapper, not a nonexistent hosted 2.0.0 version.

The published Flutter wrapper depends on the published DigiCoinLib 0.0.3 core. Local development overrides are only necessary when testing unpublished changes. See [MIGRATION.md](../MIGRATION.md) and [VALIDATION.md](../VALIDATION.md). No cryptographic primitives were changed in this wrapper release.
