This package provides tools to easily implement the bloc pattern.

## Directory

``` bash
├── src
│   ├── bloc.dart
│   ├── bloc_provider_utils.dart
│   └── bloc_stream_builder.dart
└── flutter_bloc_provider.dart
```

## Getting started

To use this package, add `flutter_bloc_provider` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/). For example:

```yaml
dependencies:
  flutter_bloc_provider:
    git:
      url: https://github.com/Dev-hwang/flutter_bloc_provider.git
      ref: master
```

## Usage

이 패키지에는 일반 상태 관리를 위한 BLoC 구현 인터페이스 `Bloc`와 비동기 작업 처리를 목적으로 하는 BLoC 구현 인터페이스 `FetchBloc`를 제공합니다. 구현 방법은 아래와 같습니다.

```dart
// CounterBloc extends Bloc<BLoC 클래스명, 상태 타입>
class CounterBloc extends Bloc<CounterBloc, int> {
  // super 함수를 사용하여 상태를 초기화한다. 여기서는 상태 타입이 정수형이므로 0으로 초기화했다.
  CounterBloc() : super(0);

  // initialize 함수는 BLoC 내부 리소스를 초기화하기 위한 용도로 사용된다.
  @override
  CounterBloc initialize(BuildContext context) => this;

  // dispose 함수는 BLoC 내부 리소스를 정리하기 위한 용도로 사용된다.
  @override
  void dispose() => super.dispose();

  void increment() {
    // state 필드에 접근하여 현재 상태를 가져올 수 있다.
    if (state > 8) return;

    // setState 함수를 사용하여 현재 상태를 업데이트할 수 있다.
    setState(state + 1);
  }

  void decrement() {
    if (state < 1) return;

    setState(state - 1);
  }
}
```

```dart
// AsyncBloc extends FetchBloc<BLoC 클래스명, 데이터 타입>
class AsyncBloc extends FetchBloc<AsyncBloc, List<String>> {
  // 내부적으로 FetchResult<테이터 타입> 상태를 만들기 때문에 초기화가 필요없다.
  // AsyncBloc() : super();

  // initialize 함수는 BLoC 내부 리소스를 초기화하기 위한 용도로 사용된다.
  @override
  AsyncBloc initialize(BuildContext context) => this;

  // dispose 함수는 BLoC 내부 리소스를 정리하기 위한 용도로 사용된다.
  @override
  void dispose() => super.dispose();

  Future<void> fetchMenuList() async {
    // 로딩 이벤트를 추가한다. 검색 중일 때 프로그레스 위젯을 보여주고 싶은 경우 주로 사용한다.
    addLoadingEvent();

    _getMenuListFromApiServer().then((data) {
      // 완료 이벤트를 추가한다.
      addDoneEvent(data);

      // state.data 필드에 접근하여 데이터를 확인할 수 있다.
      print('data: ${state.data}');
    }).catchError((error, stackTrace) {
      // 오류 이벤트를 추가한다.
      addErrorEvent(error, stackTrace: stackTrace);

      // state.err 및 state.stackTrace 필드에 접근하여 오류 정보를 확인할 수 있다.
      print('error: ${state.err}');
      print('stackTrace: ${state.stackTrace}');
    });
  }

  // 이 함수는 API 서버에 있다고 가정한다.
  Future<List<String>> _getMenuListFromApiServer() async {
    await Future.delayed(const Duration(seconds: 5));

    if (Random().nextInt(2) == 0) {
      return ['hello', 'bloc', 'provider'];
    } else {
      throw Exception('메뉴 정보를 찾을 수 없습니다.');
    }
  }
}
```

다음으로 `BlocProviderUtils` 클래스를 이용하여 BLoC을 생성하고 초기화해야 합니다.

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProviderUtils.create(
        bloc: CounterBloc(),
        child: const BlocTestPage(),
      ),
    );
  }
}
```

2개 이상의 BLoC을 생성하려면 `MultiProvider` 위젯을 사용하세요.

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          BlocProviderUtils.create(bloc: CounterBloc()),
          BlocProviderUtils.create(bloc: AsyncBloc()),
        ],
        child: const BlocTestPage(),
      ),
    );
  }
}
```

`context.read<T>()` 함수를 사용하여 상위 위젯에서 생성된 BLoC 및 데이터에 접근할 수 있습니다.

```dart
class BlocTestPage extends StatefulWidget {
  const BlocTestPage({Key? key}) : super(key: key);

  @override
  _BlocTestPageState createState() => _BlocTestPageState();
}

class _BlocTestPageState extends State<BlocTestPage> {
  void _onIncrementActionButtonPressed() {
    context.read<CounterBloc>().increment();
  }

  void _onDecrementActionButtonPressed() {
    context.read<CounterBloc>().decrement();
  }

  void _onFetchMenuListActionButtonPressed() {
    context.read<AsyncBloc>().fetchMenuList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello, Bloc Provider'),
      ),
      body: _buildContentView(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: _onIncrementActionButtonPressed,
          ),
          const SizedBox(height: 8.0),
          FloatingActionButton(
            child: const Icon(Icons.remove),
            onPressed: _onDecrementActionButtonPressed,
          ),
          const SizedBox(height: 8.0),
          FloatingActionButton(
            child: const Icon(Icons.request_page),
            onPressed: _onFetchMenuListActionButtonPressed,
          ),
        ],
      ),
    );
  }
}
```

마지막으로 `BlocStreamBuilder<B, S>` 위젯을 사용하여 BLoC 상태 변화를 구독하고 UI를 업데이트하세요.

```dart
Widget _buildContentView() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // CounterBloc
        BlocStreamBuilder<CounterBloc, int>(
          listener: (context, state) {
            // BLoC 상태가 변경되거나 업데이트되면 호출됩니다.
            // 주로 상태에 따라 팝업이나 토스트 메시지를 출력할 때 사용됩니다.
            print('CounterBloc state: $state');
          },
          listenWhen: (widgetState, blocState) {
            // listener 호출 조건을 정의할 수 있습니다.
            return blocState != 5;
          },
          builder: (context, state) {
            return Text('count: $state');
          },
        ),

        // AsyncBloc
        BlocStreamBuilder<AsyncBloc, FetchResult<List<String>>>(
          buildWhen: (widgetState, blocState) {
            // builder 호출 조건을 정의할 수 있습니다.
            return widgetState.status != blocState.status;
          },
          builder: (context, state) {
            if (state.status == FetchStatus.error)
              return const Text('오류가 발생하여 메뉴 정보를 확인할 수 없습니다.');

            if (state.status == FetchStatus.loading)
              return const CircularProgressIndicator();

            return Text('menuList: ${state.data.toString()}');
          },
        ),
      ],
    ),
  );
}
```
