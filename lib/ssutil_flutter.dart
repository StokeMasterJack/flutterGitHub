import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:github/ssutil.dart' as ss;

typedef Widget DataBuilder<T>(BuildContext context, T data);
typedef Widget ErrBuilder(BuildContext context, Object err);
typedef Widget NoneBuilder(BuildContext context);

class Defaults {
  static Widget noneBuilder(BuildContext context) {
//    return new Text("ConnectionState.none");
    return new Text("");
  }

  static Widget activeBuilder(BuildContext context) {
    return new Text("ConnectionState.active");
  }

  static Widget waitBuilder(BuildContext context) {
    return new Center(child: new CircularProgressIndicator());
  }

  static Widget errBuilder(BuildContext context, Object err, {String title}) {
    ss.logError(err, title);
    final String effectiveTitle = title ?? "An error occurred";

    final List<Widget> rows = [
      new Text(effectiveTitle, style: Theme.of(context).textTheme.headline),
      new Text("Type: ${err.runtimeType}"),
      new Text("$err"),
    ];

    if (err is Error) {
      StackTrace trace = err.stackTrace;
      if (trace != null) {
        rows.add(new Text("Stacktrace:"));

        rows.add(new Text(
          trace.toString(),
          style: new TextStyle(fontFamily: 'monospace'),
        ));
      } else {
        rows.add(new Text("No stacktrace"));
      }
    }

    final col = new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );

    return new Padding(padding: const EdgeInsets.all(16.0), child: new SingleChildScrollView(child: col));
  }

  static Widget dataBuilder<T>(BuildContext context, T data) {
    return new Text("$data");
  }

  static Widget asyncBuilder<T>(
    BuildContext context,
    AsyncSnapshot<T> snap, {
    WidgetBuilder noneBuilder,
    WidgetBuilder waitBuilder,
    WidgetBuilder activeBuilder,
    DataBuilder<T> dataBuilder,
    ErrBuilder errBuilder,
  }) {
    if (noneBuilder == null) noneBuilder = Defaults.noneBuilder;
    if (waitBuilder == null) waitBuilder = Defaults.waitBuilder;
    if (activeBuilder == null) activeBuilder = Defaults.activeBuilder;
    if (errBuilder == null) errBuilder = Defaults.errBuilder;
    if (dataBuilder == null) dataBuilder = Defaults.dataBuilder;

    switch (snap.connectionState) {
      case ConnectionState.none:
        return noneBuilder(context);
      case ConnectionState.waiting:
        return waitBuilder(context);
      case ConnectionState.active:
        return activeBuilder(context);
      case ConnectionState.done:
        return snap.hasError ? errBuilder(context, snap.error) : dataBuilder(context, snap.data);
      default:
        return Text("Should nver get here");
    } //switch
  } //asyncBuilder

}

class FutBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final WidgetBuilder waitBuilder;
  final WidgetBuilder noneBuilder;
  final WidgetBuilder activeBuilder;
  final ErrBuilder errBuilder;
  final DataBuilder<T> dataBuilder;

  FutBuilder({@required this.future, dataBuilder, noneBuilder, waitBuilder, activeBuilder, errBuilder})
      : this.noneBuilder = noneBuilder != null ? noneBuilder : Defaults.noneBuilder,
        this.waitBuilder = waitBuilder != null ? waitBuilder : Defaults.waitBuilder,
        this.activeBuilder = activeBuilder != null ? activeBuilder : Defaults.activeBuilder,
        this.errBuilder = errBuilder != null ? errBuilder : Defaults.errBuilder,
        this.dataBuilder = dataBuilder != null ? dataBuilder : Defaults.dataBuilder;

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<T>(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<T> snap) {
//          if(snap.hasData) return dataBuilder(context,snap.data);
          switch (snap.connectionState) {
            case ConnectionState.none:
              return noneBuilder(context);
            case ConnectionState.waiting:
              return waitBuilder(context);
            case ConnectionState.active:
              return activeBuilder(context);
            case ConnectionState.done:
              return snap.hasError ? errBuilder(context, snap.error) : dataBuilder(context, snap.data);
            default:
              return Text("Should nver get here");
          }
        });
  }
}

class SnapBuilder<T> extends StatelessWidget {
  final AsyncSnapshot<T> snap;
  final WidgetBuilder waitBuilder;
  final WidgetBuilder noneBuilder;
  final WidgetBuilder activeBuilder;
  final ErrBuilder errBuilder;
  final DataBuilder<T> dataBuilder;

  SnapBuilder({@required this.snap, dataBuilder, noneBuilder, waitBuilder, activeBuilder, errBuilder})
      : this.noneBuilder = noneBuilder != null ? noneBuilder : Defaults.noneBuilder,
        this.waitBuilder = waitBuilder != null ? waitBuilder : Defaults.waitBuilder,
        this.activeBuilder = activeBuilder != null ? activeBuilder : Defaults.activeBuilder,
        this.errBuilder = errBuilder != null ? errBuilder : Defaults.errBuilder,
        this.dataBuilder = dataBuilder != null ? dataBuilder : Defaults.dataBuilder;

  @override
  Widget build(BuildContext context) {
    switch (snap.connectionState) {
      case ConnectionState.none:
        return noneBuilder(context);
      case ConnectionState.waiting:
        return waitBuilder(context);
      case ConnectionState.active:
        return activeBuilder(context);
      case ConnectionState.done:
        return snap.hasError ? errBuilder(context, snap.error) : dataBuilder(context, snap.data);
      default:
        return Text("Should nver get here");
    }
  }
}

void snack(BuildContext context, String msg) {
  Scaffold.of(context).showSnackBar(new SnackBar(content: new Text(msg)));
}


typedef OnSelected<T>(BuildContext context, T value);
typedef ContextCallback(BuildContext context);