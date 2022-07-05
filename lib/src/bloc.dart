import 'dart:async';

import 'package:flutter/material.dart';

/// BLoC 클래스를 구현하기 위한 인터페이스
abstract class Bloc<B, S> {
  /// 초기 상태와 함께 BLoC 객체를 생성한다.
  Bloc(this._state);

  final _controller = StreamController<S>.broadcast();

  /// 상태 컨트롤러가 닫혔는지 확인한다.
  bool get icClosed => _controller.isClosed;

  /// 상태 컨트롤러의 [Stream]을 반환한다.
  Stream<S> get stream => _controller.stream;

  /// 상태 컨트롤러의 [StreamSink]를 반환한다.
  StreamSink<S> get sink => _controller.sink;

  S _state;

  /// 현재 상태를 반환한다.
  S get state => _state;

  /// 현재 상태를 변경하고 업데이트한다.
  void setState(S state) {
    _state = state;
    _controller.add(_state);
  }

  /// [context]와 함께 BLoC 내부 리소스를 초기화한다.
  B initialize(BuildContext context);

  /// BLoC 내부 리소스를 정리한다.
  @mustCallSuper
  void dispose() => _controller.close();
}

/// 비동기 작업 처리를 목적으로 하는 BLoC 클래스를 구현하기 위한 인터페이스
abstract class FetchBloc<B, T> extends Bloc<B, FetchResult<T>> {
  /// FetchResult<T> 상태를 가진 BLoC 객체 생성한다.
  FetchBloc([T? initialData]) : super(FetchResult.none<T>(initialData));

  /// 로딩 이벤트를 추가한다.
  void addLoadingEvent([T? data]) => setState(FetchResult.loading<T>(data));

  /// 완료 이벤트를 추가한다.
  void addDoneEvent(T? data) => setState(FetchResult.done<T>(data));

  /// 오류 이벤트를 추가한다.
  void addErrorEvent(error, {stackTrace}) =>
      setState(FetchResult.error<T>(error, stackTrace: stackTrace));
}

/// Fetch 상태
enum FetchStatus {
  /// 초기 상태
  none,

  /// 로딩 상태
  loading,

  /// 완료 상태
  done,

  /// 오류 상태
  error,
}

/// Fetch 결과
class FetchResult<T> {
  /// Fetch 상태
  final FetchStatus status;

  /// 오류
  final dynamic err;

  /// 오류 경로
  final dynamic stackTrace;

  /// Fetch 데이터
  final T? data;

  const FetchResult(this.status, {this.err, this.stackTrace, this.data});

  static FetchResult<T> none<T>([T? data]) =>
      FetchResult<T>(FetchStatus.none, data: data);

  static FetchResult<T> loading<T>([T? data]) =>
      FetchResult<T>(FetchStatus.loading, data: data);

  static FetchResult<T> done<T>(T? data) =>
      FetchResult<T>(FetchStatus.done, data: data);

  static FetchResult<T> error<T>(error, {stackTrace}) =>
      FetchResult<T>(FetchStatus.error, err: error, stackTrace: stackTrace);
}
