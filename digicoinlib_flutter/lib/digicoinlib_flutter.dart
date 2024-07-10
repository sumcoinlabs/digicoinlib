import 'package:flutter/widgets.dart';
import 'package:digicoinlib/digicoinlib.dart';
export 'package:digicoinlib/digicoinlib.dart';

/// A widget that ensures the coinlib library is loaded before use. This is
/// currently only necessary on web but it is good practice to use in any case.
class DigiCoinlibLoader extends StatefulWidget {

  /// The widget to show whilst digicoinlib is loading
  final Widget loadChild;
  /// The builder for a library load error
  final Widget Function(BuildContext context, Object? error) errorBuilder;
  /// The builder called once the library has loaded
  final WidgetBuilder builder;

  /// Whilst the library is loading, the [loadChild] widget will be displayed.
  /// If there is an error, the [errorBuilder] will be called with the error to
  /// obtain a widget to display. If the library loads successfully, [builder]
  /// will be called instead.
  const DigiCoinlibLoader({
    super.key,
    required this.loadChild,
    required this.errorBuilder,
    required this.builder,
  });

  @override
  State<DigiCoinlibLoader> createState() => _DigiCoinlibLoaderState();

}

class _DigiCoinlibLoaderState extends State<DigiCoinlibLoader> {

  late Future<void> loadResult;

  @override
  void initState() {
    super.initState();
    loadResult = loadDigiCoinlib();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
    builder: (context, snapshot) {

      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError) {
          return widget.errorBuilder(context, snapshot.error);
        }
        return widget.builder(context);
      }

      return widget.loadChild;

    },
    future: loadResult,
  );

}
