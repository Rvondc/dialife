import 'package:flutter/material.dart';

Widget waitForFuture<T>(
    {Widget loading = const Placeholder(),
    required Future<T> future,
    required Widget Function(BuildContext context, T data) builder}) {
  return FutureBuilder(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return loading;
      }

      return builder(context, snapshot.data as T);
    },
  );
}
