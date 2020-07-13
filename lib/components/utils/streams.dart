import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:rxdart/rxdart.dart';

/// Wrapper for StreamBuilder that automatically supplies an initial value.
class RxStreamBuilder<T> extends StatelessWidget {
  /// The stream to use, including the initial value.
  final ValueStream<T> stream;

  /// The build strategy currently used by this builder.
  final AsyncWidgetBuilder<T> builder;

  const RxStreamBuilder({
    Key key,
    @required this.stream,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(initialData: stream.value, stream: stream, builder: builder);
  }
}

/// Wrapper for RxStreamBuilder that simplifies common usecases.
///
/// The stream provides the initial value and then listens to changes. The builder is guaranteed
/// to receive non-null data only.
///
/// Waiting, error, and null have default display widgets, but these are expected to be unusual
/// states.
class SimpleRxStreamBuilder<T> extends StatelessWidget {
  /// The stream to use, including the initial value.
  final ValueStream<T> stream;

  /// The build strategy currently used by this builder.
  final Widget Function(BuildContext context, T data) builder;

  final Widget whileWaiting;
  final Widget whileError;
  final Widget whileNull;

  SimpleRxStreamBuilder(
      {Key key,
      @required this.stream,
      @required this.builder,
      Widget whileWaiting,
      Widget whileError,
      Widget whileNull})
      : assert(builder != null),
        whileWaiting = whileWaiting ?? Center(child: CircularProgressIndicator()),
        whileError = whileError ?? Center(child: Icon(Icons.error_outline, color: Colors.red)),
        whileNull = whileNull ?? Center(child: Icon(Icons.error_outline, color: Colors.yellow)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return RxStreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return whileWaiting;
        } else if (snapshot.hasError) {
          var err = snapshot.error as Error;
          Fimber.e('Snapshot has error', ex: err, stacktrace: err.stackTrace);
          return whileError;
        } else if (snapshot.data == null) {
          Fimber.e('Data unexpectedly null');
          return whileNull;
        }

        final data = snapshot.data as T;
        return builder(context, data);
      },
    );
  }
}
