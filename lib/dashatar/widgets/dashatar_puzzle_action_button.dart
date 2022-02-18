import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:unpuzzle_it_abhi/audio_control/audio_control.dart';
import 'package:unpuzzle_it_abhi/dashatar/dashatar.dart';
import 'package:unpuzzle_it_abhi/helpers/helpers.dart';
import 'package:unpuzzle_it_abhi/l10n/l10n.dart';
import 'package:unpuzzle_it_abhi/layout/responsive_layout_builder.dart';
import 'package:unpuzzle_it_abhi/puzzle/puzzle.dart';
import 'package:unpuzzle_it_abhi/theme/theme.dart';
import 'package:unpuzzle_it_abhi/timer/timer.dart';

import '../../custom/custom.dart';

/// {@template dashatar_puzzle_action_button}
/// Displays the action button to start or shuffle the puzzle
/// based on the current puzzle state.
/// {@endtemplate}
class DashatarPuzzleActionButton extends StatefulWidget {
  /// {@macro dashatar_puzzle_action_button}
  const DashatarPuzzleActionButton({Key? key, AudioPlayerFactory? audioPlayer})
      : _audioPlayerFactory = audioPlayer ?? getAudioPlayer,
        super(key: key);

  final AudioPlayerFactory _audioPlayerFactory;

  @override
  State<DashatarPuzzleActionButton> createState() =>
      _DashatarPuzzleActionButtonState();
}

class _DashatarPuzzleActionButtonState
    extends State<DashatarPuzzleActionButton> {
  late final AudioPlayer _audioPlayer;
  bool gameStarted = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = widget._audioPlayerFactory()
      ..setAsset('assets/audio/click.mp3');
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _sliderWidget(DashatarPuzzleStatus status, int sliderMin,
      int sliderMax, int tileSize, bool isLoading) {
    return Tooltip(
      key: ValueKey(status),
      message: context.l10n.puzzleSliderTooltip,
      verticalOffset: 40,
      child: SliderWidget(
        min: sliderMin,
        max: sliderMax,
        fullWidth: true,
        value: tileSize,
        onChanged: isLoading
            ? null
            : (newSize) async {
                // log(newSize.toString());
                context.read<TimerBloc>().add(const TimerReset());

                context.read<PuzzleBloc>().add(
                      PuzzleInitialized(
                        shufflePuzzle: false,
                        tileSize: (newSize == 0) ? 4 : newSize.toInt(),
                      ),
                    );
              },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.select((DashatarThemeBloc bloc) => bloc.state.theme);

    final status =
        context.select((DashatarPuzzleBloc bloc) => bloc.state.status);
    final isLoading = status == DashatarPuzzleStatus.loading;
    final isStarted = status == DashatarPuzzleStatus.started;
    final sliderMin = 2;
    final sliderMax = 6;
    // create:
    // final puzzle = context.watch<PuzzleBloc>().state.puzzle;

//flow: BTN Restart button click
    final text = isStarted
        ? context.l10n.dashatarRestart
        : (isLoading
            ? context.l10n.dashatarGetReady
            : context.l10n.dashatarStartGame);
    var tileSize = context.read<PuzzleBloc>().tileSize;
    final puzzleChange =
        context.select((PuzzleBloc bloc) => bloc.state.customPuzzleChange);
    // final puzzle = context.watch<PuzzleBloc>().state.puzzle;

    // Handle theme changes if size greater then 4
    if (!theme.isCustomTheme && tileSize != 4) {
      context.read<PuzzleBloc>().add(
            const PuzzleInitialized(
              shufflePuzzle: false,
              tileSize: 4,
            ),
          );
    }

    final Widget _startBtn = Tooltip(
      key: ValueKey(status),
      message: isStarted ? context.l10n.puzzleRestartTooltip : '',
      verticalOffset: 40,
      child: Column(
        children: <Widget>[
          PuzzleButton(
            onPressed: isLoading
                ? null
                : () async {
                    final hasStarted = status == DashatarPuzzleStatus.started;

                    // Reset the timer and the countdown.
                    context.read<TimerBloc>().add(const TimerReset());
                    context.read<DashatarPuzzleBloc>().add(
                          DashatarCountdownReset(
                            // flow: TIMER countdown time control
                            secondsToBegin: hasStarted ? 5 : 3,
                          ),
                        );

                    // Initialize the puzzle board to show the initial puzzle
                    // (unshuffled) before the countdown completes.
                    if (hasStarted) {
                      var tileSize = context.watch<PuzzleBloc>().tileSize;
                      context.read<PuzzleBloc>().add(
                            PuzzleInitialized(
                              shufflePuzzle: false,
                              tileSize: tileSize,
                            ),
                          );
                    }

                    setState(() {
                      gameStarted = true;
                    });

                    unawaited(_audioPlayer.replay());
                  },
            textColor: isLoading ? theme.defaultColor : null,
            child: Text(text),
          ),
        ],
      ),
    );

    Widget _autoSolveBtn = Tooltip(
      key: const Key('btn2'),
      message: isStarted ? context.l10n.puzzleSolveTooltip : '',
      verticalOffset: 40,
      child: PuzzleButton(
        onPressed: isLoading || !gameStarted
            ? null
            : () async {
                // create:
                // Reset the timer and the countdown.
                context.read<TimerBloc>().add(const TimerReset());
                context.read<DashatarPuzzleBloc>().add(
                      const DashatarCountdownReverse(),
                    );
                setState(() {
                  gameStarted = false;
                });

                unawaited(_audioPlayer.replay());
              },
        textColor: isLoading ? theme.defaultColor : null,
        child: Text(context.l10n.dashatarSolve),
      ),
    );

    Widget _addNew = Tooltip(
      key: const Key('btn3'),
      message: isLoading ? '':context.l10n.puzzleAddNew,
      verticalOffset: 40,
      child: PuzzleButtonCustom(
        onPressed: isLoading
            ? null
            : () async {
                // create:
                // Reset the timer and the countdown.
                // context.read<TimerBloc>().add(const TimerReset());
                // context.read<TimerBloc>().add(const TimerReset());
                context
                    .read<PuzzleBloc>()
                    .add(PuzzleTriggerCustom(puzzleChange));

                unawaited(_audioPlayer.replay());
              },
        textColor: isLoading ? theme.defaultColor : null,
        child: Text('+',style: TextStyle(fontSize: 30)),
      ),
    );

    // final Widget _sliderWidget =

    return ResponsiveLayoutBuilder(
      small: (_, child) => AudioControlListener(
        audioPlayer: _audioPlayer,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _startBtn,
                const Padding(padding: EdgeInsets.only(left: 10)),
                _autoSolveBtn,
              ],
            ),
            const Padding(padding: EdgeInsets.only(top: 10)),
            if (theme.isCustomTheme)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _sliderWidget(
                      status, sliderMin, sliderMax, tileSize, isLoading),
                  _addNew,
                ],
              ),
          ],
        ),
      ),
      medium: (_, child) => AudioControlListener(
        audioPlayer: _audioPlayer,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _startBtn,
                const Padding(padding: EdgeInsets.only(left: 10)),
                _autoSolveBtn,
              ],
            ),
            const Padding(padding: EdgeInsets.only(top: 10)),
            if (theme.isCustomTheme)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _sliderWidget(
                      status, sliderMin, sliderMax, tileSize, isLoading),
                  _addNew,
                ],
              ),
          ],
        ),
      ),
      large: (_, __) => AudioControlListener(
        audioPlayer: _audioPlayer,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: <Widget>[
                _startBtn,
                const Padding(padding: EdgeInsets.only(left: 10)),
                _autoSolveBtn,
              ],
            ),
            const Padding(padding: EdgeInsets.all(10)),
            if (theme.isCustomTheme)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _sliderWidget(
                      status, sliderMin, sliderMax, tileSize, isLoading),
                  _addNew,
                ],
              ),
          ],
        ),
      ),
    );
  }
}
