import 'dart:async';
import 'dart:developer';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unpuzzle_it_abhi/audio_control/audio_control.dart';
import 'package:unpuzzle_it_abhi/custom/custom.dart';
import 'package:unpuzzle_it_abhi/custom/utils.dart';
import 'package:unpuzzle_it_abhi/dashatar/dashatar.dart';
import 'package:unpuzzle_it_abhi/flames/flames.dart';
import 'package:unpuzzle_it_abhi/helpers/helpers.dart';
import 'package:unpuzzle_it_abhi/l10n/l10n.dart';
import 'package:unpuzzle_it_abhi/layout/layout.dart';
import 'package:unpuzzle_it_abhi/models/models.dart';
import 'package:unpuzzle_it_abhi/puzzle/puzzle.dart';
import 'package:unpuzzle_it_abhi/theme/themes/themes.dart';

abstract class _TileSize {
  static double small = 75;
  static double medium = 100;
  static double large = 112;
}

/// {@template dashatar_puzzle_tile}
/// Displays the puzzle tile associated with [tile]
/// based on the puzzle [state].
/// {@endtemplate}
class DashatarPuzzleTile extends StatefulWidget {
  /// {@macro dashatar_puzzle_tile}
  const DashatarPuzzleTile({
    Key? key,
    required this.tile,
    required this.state,
    required this.tileImage,
    AudioPlayerFactory? audioPlayer,
  })  : _audioPlayerFactory = audioPlayer ?? getAudioPlayer,
        super(key: key);

  /// The tile to be displayed.
  final Tile tile;
  final Widget tileImage;

  /// The state of the puzzle.
  final PuzzleState state;

  final AudioPlayerFactory _audioPlayerFactory;

  @override
  State<DashatarPuzzleTile> createState() => DashatarPuzzleTileState();
}

/// The state of [DashatarPuzzleTile].
@visibleForTesting
class DashatarPuzzleTileState extends State<DashatarPuzzleTile>
    with SingleTickerProviderStateMixin {
  AudioPlayer? _audioPlayer;
  late final Timer _timer;

  /// The controller that drives [_scale] animation.
  late AnimationController _controller;
  late Animation<double> _scale;

  int? highscore = 0;
  int? xp = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: PuzzleThemeAnimationDuration.puzzleTileScale,
    );

    _scale = Tween<double>(begin: 1, end: 0.94).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 1, curve: Curves.easeInOut),
      ),
    );

    // Delay the initialization of the audio player for performance reasons,
    // to avoid dropping frames when the theme is changed.
    _timer = Timer(const Duration(seconds: 1), () {
      _audioPlayer = widget._audioPlayerFactory()
        ..setAsset('assets/audio/tile_move.mp3');
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> scoringUpdate(int spriteTile) async {
    try {
      highscore = SettingsUtils.getHighscore();
      xp = SettingsUtils.getXp();
    } on Exception catch (ex) {
      log("Scoring " + ex.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.state.puzzle.getDimension();
    final puzzle = widget.state.puzzle;
    final zuppSize = 1.5;

    final theme = context.select((DashatarThemeBloc bloc) => bloc.state.theme);
    final status =
        context.select((DashatarPuzzleBloc bloc) => bloc.state.status);
    final hasStarted = status == DashatarPuzzleStatus.started;
    final puzzleState =
        context.select((PuzzleBloc bloc) => bloc.state.puzzleStatus);
    final puzzleIncomplete =
        context.select((PuzzleBloc bloc) => bloc.state.puzzleStatus) !=
            PuzzleStatus.complete;

    final movementDuration = status == DashatarPuzzleStatus.loading
        ? const Duration(milliseconds: 800)
        : const Duration(milliseconds: 370);

    final canPress = hasStarted && puzzleIncomplete;

    int spriteTile = 1;

    if (theme.isPathTheme) {
      spriteTile = puzzle.getNumberOfCorrectTiles() == 15
          ? puzzleState == PuzzleStatus.complete ||
                  puzzleState == PuzzleStatus.reversed
              ? puzzle.getCorrectSeq(theme.pathMap)
              : 1
          : puzzle.getCorrectSeq(theme.pathMap);
    }

    return Stack(
      children: [
        AudioControlListener(
          audioPlayer: _audioPlayer,
          child: AnimatedAlign(
            alignment: FractionalOffset(
              (widget.tile.currentPosition.x - 1) / (size - 1),
              (widget.tile.currentPosition.y - 1) / (size - 1),
            ),
            duration: movementDuration,
            curve: Curves.easeInOut,
            child: ResponsiveLayoutBuilder(
              small: (_, child) => SizedBox.square(
                key: Key('dashatar_puzzle_tile_small_${widget.tile.value}'),
                dimension: _TileSize.small,
                child: child,
              ),
              medium: (_, child) => SizedBox.square(
                key: Key('dashatar_puzzle_tile_medium_${widget.tile.value}'),
                dimension: _TileSize.medium,
                child: child,
              ),
              large: (_, child) => SizedBox.square(
                key: Key('dashatar_puzzle_tile_large_${widget.tile.value}'),
                dimension: _TileSize.large,
                child: child,
              ),
              child: (_) => MouseRegion(
                onEnter: (_) {
                  if (canPress) {
                    _controller.forward();
                  }
                },
                onExit: (_) {
                  if (canPress) {
                    _controller.reverse();
                  }
                },
                //flow: TILE click handling
                child: ScaleTransition(
                  key: Key('dashatar_puzzle_tile_scale_${widget.tile.value}'),
                  scale: _scale,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: canPress
                        ? () {
                            context
                                .read<PuzzleBloc>()
                                .add(TileTapped(widget.tile));
                            unawaited(_audioPlayer?.replay());
                          }
                        : null,
                    //flow: TILE 4. icon created here by loop
                    icon: (theme.isCustomTheme)
                        ? widget.tileImage
                        : Image.asset(
                            theme.dashAssetForTile(widget.tile),
                            semanticLabel: context.l10n.puzzleTileLabelText(
                              widget.tile.value.toString(),
                              widget.tile.currentPosition.x.toString(),
                              widget.tile.currentPosition.y.toString(),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (!theme.isCustomTheme &&
            theme.isPathTheme &&
            widget.tile.value == spriteTile)
          AudioControlListener(
            audioPlayer: _audioPlayer,
            child: AnimatedAlign(
              alignment: FractionalOffset(
                (widget.tile.currentPosition.x - 1) / (size - 0.5),
                (widget.tile.currentPosition.y - 1) / (size - 0.5),
              ),
              duration: movementDuration,
              curve: Curves.easeInOut,
              child: ResponsiveLayoutBuilder(
                small: (_, child) => SizedBox.square(
                  key: Key('dashatar_puzzle_tile_small_${widget.tile.value}'),
                  dimension: _TileSize.small / 2,
                  child: MouseRegion(
                    //flow: TILE click handling
                    child: ScaleTransition(
                      key: Key(
                          'dashatar_puzzle_tile_scale_${widget.tile.value}'),
                      scale: _scale,
                      child: GameWidget(
                        game: FlameCustomCharacter(
                            width: _TileSize.small / zuppSize,
                            height: _TileSize.small / zuppSize),
                      ),
                    ),
                  ),
                ),
                medium: (_, child) => SizedBox.square(
                  key: Key('dashatar_puzzle_tile_medium_${widget.tile.value}'),
                  dimension: _TileSize.medium / 2,
                  child: MouseRegion(
                    //flow: TILE click handling
                    child: ScaleTransition(
                      key: Key(
                          'dashatar_puzzle_tile_scale_${widget.tile.value}'),
                      scale: _scale,
                      child: GameWidget(
                        game: FlameCustomCharacter(
                            width: _TileSize.medium / zuppSize,
                            height: _TileSize.medium / zuppSize),
                      ),
                    ),
                  ),
                ),
                large: (_, child) => SizedBox.square(
                  key: Key('dashatar_puzzle_tile_large_${widget.tile.value}'),
                  dimension: _TileSize.large / 2,
                  child: MouseRegion(
                    //flow: TILE click handling
                    child: ScaleTransition(
                      key: Key(
                          'dashatar_puzzle_tile_scale_${widget.tile.value}'),
                      scale: _scale,
                      child: GameWidget(
                        game: FlameCustomCharacter(
                            width: _TileSize.large / zuppSize,
                            height: _TileSize.large / zuppSize),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }
}
