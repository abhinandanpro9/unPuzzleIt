import 'dart:async';
import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unpuzzle_it_abhi/audio_control/audio_control.dart';
import 'package:unpuzzle_it_abhi/dashatar/dashatar.dart';
import 'package:unpuzzle_it_abhi/flames/flames.dart';
import 'package:unpuzzle_it_abhi/helpers/helpers.dart';
import 'package:unpuzzle_it_abhi/layout/layout.dart';
import 'package:unpuzzle_it_abhi/puzzle/puzzle.dart';
import 'package:unpuzzle_it_abhi/timer/timer.dart';

abstract class _BoardSize {
  static double small = 312;
  static double medium = 424;
  static double large = 472;
}

/// {@template dashatar_puzzle_board}
/// Displays the board of the puzzle in a [Stack] filled with [tiles].
/// {@endtemplate}
class DashatarPuzzleBoard extends StatefulWidget {
  /// {@macro dashatar_puzzle_board}
  const DashatarPuzzleBoard({
    Key? key,
    required this.tiles,
  }) : super(key: key);

  /// flow: TILE The tiles to be displayed on the board.
  final List<Widget> tiles;

  @override
  State<DashatarPuzzleBoard> createState() => _DashatarPuzzleBoardState();
}

class _DashatarPuzzleBoardState extends State<DashatarPuzzleBoard> {
  Timer? _completePuzzleTimer;

  @override
  void dispose() {
    _completePuzzleTimer?.cancel();
    super.dispose();
  }

  void _showOverlay(BuildContext context) async {
    // Declaring and Initializing OverlayState
    // and OverlayEntry objects
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(builder: (context) {
      // You can return any widget you like
      // here to be displayed on the Overlay
      return Positioned(
        left: MediaQuery.of(context).size.width * 0.2,
        top: MediaQuery.of(context).size.height * 0.3,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Stack(
            children: [
              Image.asset(
                'images/shuffle_icon.png',
                colorBlendMode: BlendMode.multiply,
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.13,
                left: MediaQuery.of(context).size.width * 0.13,
                child: Material(
                  color: Colors.black,
                  child: Text(
                    'I will disappear in 3 seconds.',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.025,
                        color: Colors.green),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });

    // Inserting the OverlayEntry into the Overlay
    overlayState!.insert(overlayEntry);

    // Awaiting for 3 seconds
    await Future.delayed(Duration(seconds: 3));

    // Removing the OverlayEntry from the Overlay
    overlayEntry.remove();
  }

  @override
  Widget build(BuildContext context) {
    // flow: PUZZ listener for PuzzleBloc
    return Stack(
      children: [
        // LayoutBuilder(builder: (context, constraints){
        //   WidgetsBinding.instance!.addPostFrameCallback((_) => _showOverlay(context));
        //   return Navigator(
        //       key: new Key("value"),
        //     );
        // }),

        BlocListener<PuzzleBloc, PuzzleState>(
          listener: (context, state) async {
            if (state.puzzleStatus == PuzzleStatus.complete) {
              _completePuzzleTimer =
                  Timer(const Duration(milliseconds: 370), () async {
                await showAppDialog<void>(
                  context: context,
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider.value(
                        value: context.read<DashatarThemeBloc>(),
                      ),
                      BlocProvider.value(
                        value: context.read<PuzzleBloc>(),
                      ),
                      BlocProvider.value(
                        value: context.read<TimerBloc>(),
                      ),
                      BlocProvider.value(
                        value: context.read<AudioControlBloc>(),
                      ),
                    ],
                    child: const DashatarShareDialog(),
                  ),
                );
              });
            }
          },
          child: ResponsiveLayoutBuilder(
            small: (_, child) => SizedBox.square(
              key: const Key('dashatar_puzzle_board_small'),
              dimension: (_BoardSize.small / 4) * (sqrt(widget.tiles.length)),
              child: child,
            ),
            medium: (_, child) => SizedBox.square(
              key: const Key('dashatar_puzzle_board_medium'),
              dimension: (_BoardSize.medium / 4) * (sqrt(widget.tiles.length)),
              child: child,
            ),
            large: (_, child) => SizedBox.square(
              key: const Key('dashatar_puzzle_board_large'),
              dimension: (_BoardSize.large / 4) * (sqrt(widget.tiles.length)),
              child: child,
            ),
            //flow: TILE Stack
            child: (_) => Stack(children: widget.tiles),
          ),
        ),
        ResponsiveLayoutBuilder(
          small: (_, child) => SizedBox.square(
            key: const Key('dashatar_puzzle_board_small_sprite'),
            dimension: (_BoardSize.small / 4) * (sqrt(widget.tiles.length)),
            child: child,
          ),
          medium: (_, child) => SizedBox.square(
            key: const Key('dashatar_puzzle_board_medium_sprite'),
            dimension: (_BoardSize.medium / 4) * (sqrt(widget.tiles.length)),
            child: child,
          ),
          large: (_, child) => SizedBox.square(
            key: const Key('dashatar_puzzle_board_large_sprite'),
            dimension: (_BoardSize.large / 4) * (sqrt(widget.tiles.length)),
            child: child,
          ),
          //flow: TILE Stack
          // child: (_) => Container(
          //   alignment: Alignment.center,
          //   width: 100,
          //   height: 100,
          //   child: GameWidget(
          //     game: FlameCustomCharacter(),
          //   ),
          // ),
        ),
      ],
    );
  }
}
