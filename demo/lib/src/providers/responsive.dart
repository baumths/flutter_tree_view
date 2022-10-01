import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<double> screenWidthProvider = Provider(
  (ref) => throw UnimplementedError(),
);

final StateProvider<Screen> screenProvider = StateProvider((ref) {
  final width = ref.watch(screenWidthProvider);

  if (width >= 900) {
    return Screen.large;
  }
  return Screen.small;
}, dependencies: [screenWidthProvider]);

typedef ScreenCallback<T> = T Function();

abstract class Screen {
  const Screen();

  static const Screen small = _Small();
  static const Screen large = _Large();

  T when<T>({
    required ScreenCallback<T> small,
    required ScreenCallback<T> large,
  });
}

class _Small extends Screen {
  const _Small();
  @override
  T when<T>({
    required ScreenCallback<T> small,
    required ScreenCallback<T> large,
  }) {
    return small();
  }
}

class _Large extends Screen {
  const _Large();
  @override
  T when<T>({
    required ScreenCallback<T> small,
    required ScreenCallback<T> large,
  }) {
    return large();
  }
}
