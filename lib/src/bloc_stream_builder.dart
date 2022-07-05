import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_provider/src/bloc.dart';
import 'package:provider/provider.dart';

/// [BlocStreamBuilder] 위젯 빌더입니다.
typedef WidgetBuilder<S> = Widget Function(BuildContext context, S state);

/// [BlocStreamBuilder] 상태 리스너입니다.
typedef StateListener<S> = void Function(BuildContext context, S state);

/// [WidgetBuilder] 호출 조건입니다.
typedef WidgetBuilderCondition<S> = bool Function(S widgetState, S blocState);

/// [StateListener] 호출 조건입니다.
typedef StateListenerCondition<S> = bool Function(S widgetState, S blocState);

/// [BlocStreamBuilder] 구현 인터페이스입니다.
abstract class BlocStreamBuilderBase<B extends Bloc<B, S>, S>
    extends StatefulWidget {
  const BlocStreamBuilderBase({
    Key? key,
    this.bloc,
    this.buildWhen,
    this.listener,
    this.listenWhen,
  }) : super(key: key);

  /// BLoC 객체입니다. 입력되면 상위 객체보다 먼저 호출됩니다.
  final B? bloc;

  /// 위젯 빌드 조건입니다.
  ///
  /// 조건 결과가 참이면 업데이트된 상태와 함께 위젯이 빌드됩니다.
  final WidgetBuilderCondition<S>? buildWhen;

  /// BLoC 상태가 변경되었을 때 호출되는 리스너입니다.
  final StateListener<S>? listener;

  /// 상태 듣기 조건입니다.
  ///
  /// 조건 결과가 참이면 업데이트된 상태를 들을 수 있습니다.
  final StateListenerCondition<S>? listenWhen;

  /// [state]와 함께 위젯을 빌드합니다.
  Widget build(BuildContext context, S state);

  @override
  _BlocStreamBuilderBaseState<B, S> createState() =>
      _BlocStreamBuilderBaseState<B, S>();
}

class _BlocStreamBuilderBaseState<B extends Bloc<B, S>, S>
    extends State<BlocStreamBuilderBase<B, S>> {
  StreamSubscription<S>? _subscription;
  late B _bloc;
  late S _state;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? context.read<B>();
    _state = _bloc.state;
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant BlocStreamBuilderBase<B, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final prevBloc = oldWidget.bloc ?? context.read<B>();
    final currBloc = widget.bloc ?? prevBloc;
    if (prevBloc != currBloc) {
      if (_subscription != null) {
        _unsubscribe();
        _bloc = currBloc;
        _state = _bloc.state;
      }

      _subscribe();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = widget.bloc ?? context.read<B>();
    if (_bloc != bloc) {
      if (_subscription != null) {
        _unsubscribe();
        _bloc = bloc;
        _state = _bloc.state;
      }

      _subscribe();
    }
  }

  @override
  Widget build(BuildContext context) => widget.build(context, _state);

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    _subscription = _bloc.stream.listen((state) {
      if (widget.listenWhen?.call(_state, state) ?? true) {
        widget.listener?.call(context, state);
      }

      if (widget.buildWhen?.call(_state, state) ?? true) {
        setState(() {
          _state = state;
        });
      }
    });
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }
}

/// [StreamBuilder]를 보다 쉽게 구현할 수 있도록 해주는 위젯입니다.
class BlocStreamBuilder<B extends Bloc<B, S>, S>
    extends BlocStreamBuilderBase<B, S> {
  const BlocStreamBuilder({
    Key? key,
    required this.builder,
    WidgetBuilderCondition<S>? buildWhen,
    StateListener<S>? listener,
    StateListenerCondition<S>? listenWhen,
    B? bloc,
  }) : super(
          key: key,
          bloc: bloc,
          buildWhen: buildWhen,
          listener: listener,
          listenWhen: listenWhen,
        );

  /// BLoC 상태가 변경되었을 때 호출되는 위젯 빌더입니다.
  final WidgetBuilder<S> builder;

  @override
  Widget build(BuildContext context, S state) => builder(context, state);
}
