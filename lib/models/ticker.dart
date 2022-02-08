/// {@template ticker}
/// Object to increment time in seconds.
/// {@endtemplate}
class Ticker {
  /// {@macro ticker}
  const Ticker();

  /// Increments time by 1 second.
  Stream<int> tick() {
    return Stream.periodic(const Duration(seconds: 1), (x) => 1 + x++);
  }
}

/// {@template ticker}
/// Object to increment time in ms.
/// {@endtemplate}
class TickerMs {
  /// {@macro ticker}
  const TickerMs();

  /// Increments time by 0.25 second.
  Stream<int> tick() {
    return Stream.periodic(const Duration(milliseconds: 250), (x) => 250 + x);
  }
}
