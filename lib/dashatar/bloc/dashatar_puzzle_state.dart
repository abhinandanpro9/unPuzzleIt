// ignore_for_file: public_member_api_docs

part of 'dashatar_puzzle_bloc.dart';

/// The status of [DashatarPuzzleState].
enum DashatarPuzzleStatus {
  /// The puzzle is not started yet.
  notStarted,

  /// The puzzle is loading.
  loading,

  /// The puzzle is started.
  started,

  /// The puzzle is being reversed.
  reversed
}

class DashatarPuzzleState extends Equatable {
  const DashatarPuzzleState({
    required this.secondsToBegin,
    this.isCountdownRunning = false,
    this.isReqReverse = false,
  });

  /// Whether the countdown of this puzzle is currently running.
  final bool isCountdownRunning;

  /// Whether the request is for reverse.
  final bool isReqReverse;

  /// The number of seconds before the puzzle is started.
  final int secondsToBegin;

  /// The status of the current puzzle.
  DashatarPuzzleStatus get status =>
      (isCountdownRunning && secondsToBegin > 0) || isReqReverse
          ? isReqReverse
              ? DashatarPuzzleStatus.reversed
              : DashatarPuzzleStatus.loading
          : (secondsToBegin == 0
              ? DashatarPuzzleStatus.started
              : DashatarPuzzleStatus.notStarted);

  @override
  List<Object> get props => [isReqReverse, isCountdownRunning, secondsToBegin];

  DashatarPuzzleState copyWith({
    bool? isCountdownRunning,
    bool? isReqReverse,
    int? secondsToBegin,
  }) {
    return DashatarPuzzleState(
      isCountdownRunning: isCountdownRunning ?? this.isCountdownRunning,
      isReqReverse: isReqReverse ?? this.isReqReverse,
      secondsToBegin: secondsToBegin ?? this.secondsToBegin,
    );
  }
}
