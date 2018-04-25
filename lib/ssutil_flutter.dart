import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef Widget DataBuilder<T>(T data);
typedef Widget ErrBuilder(Object err);
typedef Widget WaitBuilder();

class FutBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final DataBuilder<T> builder;
  final ErrBuilder errBuilder;
  final WaitBuilder waitBuilder;

  const FutBuilder({Key key, this.future, this.builder, this.errBuilder, this.waitBuilder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<T>(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<T> snap) {
          final db = builder ?? defaultDataBuilder;
          final wb = waitBuilder ?? defaultWaitBuilder;
          final eb = errBuilder ?? defaultErrBuilder;
          if (snap.hasData) {
            T data = snap.data;
            return db(data);
          } else if (snap.hasError) {
            return eb(snap.error);
          }
          return wb();
        });
  }

  Widget defaultErrBuilder(Object err) {
    debugPrint("Problem compelting an http call $err");
    return new Text("Error: $err");
  }

  Widget defaultWaitBuilder() {
    return new CircularProgressIndicator();
  }

  Widget defaultDataBuilder(T data) {
    return new Text("$data");
  }
}
