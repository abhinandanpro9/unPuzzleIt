import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:unpuzzle_it_abhi/models/models.dart';

part 'dashatar_puzzle_event.dart';
part 'dashatar_puzzle_state.dart';

/// {@template dashatar_puzzle_bloc}
/// A bloc responsible for starting the Dashatar puzzle.
/// {@endtemplate}
class DashatarPuzzleBloc
    extends Bloc<DashatarPuzzleEvent, DashatarPuzzleState> {
  /// {@macro dashatar_puzzle_bloc}
  DashatarPuzzleBloc({
    required this.secondsToBegin,
    required Ticker ticker,
  })  : _ticker = ticker,
        super(DashatarPuzzleState(secondsToBegin: secondsToBegin)) {
    on<DashatarCountdownStarted>(_onCountdownStarted);
    on<DashatarCountdownTicked>(_onCountdownTicked);
    on<DashatarCountdownStopped>(_onCountdownStopped);
    on<DashatarCountdownReset>(_onCountdownReset);
    on<DashatarCountdownReverse>(_onCountdownReverse);
    on<DashatarCountdownReverseTicked>(_onCountdownReverseTicked);
    on<DashatarCountdownReverseStopped>(_onCountdownReverseStopped);
  }

  void _onCountdownReverseStopped(
    DashatarCountdownReverseStopped event,
    Emitter<DashatarPuzzleState> emit,
  ) {
    _tickerSubscriptionMs?.cancel();
    emit(
      state.copyWith(
        isCountdownRunning: false,
        isReqReverse: false,
      ),
    );
  }

  void _onCountdownReverseTicked(
    DashatarCountdownReverseTicked event,
    Emitter<DashatarPuzzleState> emit,
  ) {
    emit(state.copyWith(secondsToBegin: state.secondsToBegin + 1));
  }

  // create:
  void _onCountdownReverse(
    DashatarCountdownReverse event,
    Emitter<DashatarPuzzleState> emit,
  ) {
    _tickerSubscriptionMs?.cancel();
    _tickerSubscriptionMs = _tickerms
        .tick()
        .listen((_) => add(const DashatarCountdownReverseTicked()));
    emit(
      state.copyWith(
        isCountdownRunning: false,
        isReqReverse: true,
        secondsToBegin: state.secondsToBegin,
      ),
    );
  }

  /// The number of seconds before the puzzle is started.
  final int secondsToBegin;

  final Ticker _ticker;
  final TickerMs _tickerms = const TickerMs();

  StreamSubscription<int>? _tickerSubscription;
  StreamSubscription<int>? _tickerSubscriptionMs;

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  void _startTicker() {
    //flow: TICKER start the init shuffle countdown
    _tickerSubscription?.cancel();
    _tickerSubscription =
        _ticker.tick().listen((_) => add(const DashatarCountdownTicked()));
  }

  void _onCountdownStarted(
    DashatarCountdownStarted event,
    Emitter<DashatarPuzzleState> emit,
  ) {
    _startTicker();
    emit(
      state.copyWith(
        isCountdownRunning: true,
        isReqReverse: false,
        secondsToBegin: secondsToBegin,
      ),
    );
  }

  void _onCountdownTicked(
    DashatarCountdownTicked event,
    Emitter<DashatarPuzzleState> emit,
  ) {
    if (state.secondsToBegin == 0) {
      _tickerSubscription?.pause();
      emit(
        state.copyWith(
          isCountdownRunning: false,
          isReqReverse: false,
        ),
      );
    } else {
      emit(state.copyWith(secondsToBegin: state.secondsToBegin - 1));
    }
  }

  void _onCountdownStopped(
    DashatarCountdownStopped event,
    Emitter<DashatarPuzzleState> emit,
  ) {
    _tickerSubscription?.pause();
    emit(
      state.copyWith(
        isCountdownRunning: false,
        isReqReverse: false,
        secondsToBegin: secondsToBegin,
      ),
    );
  }

  void _onCountdownReset(
    DashatarCountdownReset event,
    Emitter<DashatarPuzzleState> emit,
  ) {
    //flow: TICKER call start ticker
    _startTicker();
    emit(
      state.copyWith(
        isCountdownRunning: true,
        isReqReverse: false,
        secondsToBegin: event.secondsToBegin ?? secondsToBegin,
      ),
    );
  }
}
