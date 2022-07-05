import 'package:flutter/material.dart';
import 'package:flutter_bloc_provider/flutter_bloc_provider.dart';
import 'package:provider/single_child_widget.dart';

/// BLoC 제공자 유틸리티
class BlocProviderUtils {
  /// [bloc]을 가지는 [Provider]를 생성한다.
  static SingleChildWidget create<T extends Bloc>({
    Key? key,
    required T bloc,
    Widget? child,
  }) =>
      Provider<T>(
        key: key,
        create: (ctx) => bloc.initialize(ctx),
        dispose: (_, __) => bloc.dispose(),
        child: child,
      );

  /// [value]를 가지는 [Provider]를 생성한다.
  static SingleChildWidget value<T extends Bloc>({
    Key? key,
    required T value,
    Widget? child,
  }) =>
      Provider<T>.value(
        key: key,
        value: value,
        child: child,
      );
}
