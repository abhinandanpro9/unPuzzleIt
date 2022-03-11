import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unpuzzle_it_abhi/dashatar/dashatar.dart';
import 'package:unpuzzle_it_abhi/layout/layout.dart';
import 'package:unpuzzle_it_abhi/puzzle/puzzle.dart';
import 'package:unpuzzle_it_abhi/theme/theme.dart';

/// {@template dashatar_start_section}
/// Displays the start section of the puzzle based on [state].
/// {@endtemplate}
class DashatarStartSection extends StatefulWidget {
  /// {@macro dashatar_start_section}
  DashatarStartSection({
    Key? key,
    required this.state,
  }) : super(key: key);

  /// The state of the puzzle.
  final PuzzleState state;

  @override
  _DashatarStartSection createState() => _DashatarStartSection();
}

class _DashatarStartSection extends State<DashatarStartSection> {
  @override
  Widget build(BuildContext context) {
    final status =
        context.select((DashatarPuzzleBloc bloc) => bloc.state.status);
    final theme = context.select((DashatarThemeBloc bloc) => bloc.state.theme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ResponsiveGap(
          small: 0,
          medium: 83,
          large: 151,
        ),
        // todo: PUZZLE name modified
        // PuzzleName(
        //   key: puzzleNameKey,
        // ),
        const ResponsiveGap(large: 16),
        PuzzleTitle(
          key: puzzleTitleKey,
          title: theme.themeTitle,
          // color: (theme.isPathTheme) ? PuzzleColors.pathPrimary : null,
        ),
        const ResponsiveGap(
          small: 5,
          medium: 16,
          large: 32,
        ),
        NumberOfMovesAndTilesLeft(
          key: numberOfMovesAndTilesLeftKey,
          numberOfMoves: widget.state.numberOfMoves,
          numberOfTilesLeft: status == DashatarPuzzleStatus.started ||
                  status == DashatarPuzzleStatus.reversed
              ? widget.state.numberOfTilesLeft
              : (widget.state.puzzle.tiles.length == 0)
                  ? widget.state.puzzle.tiles.length
                  : widget.state.puzzle.tiles.length - 1,
        ),
        const ResponsiveGap(
          small: 8,
          medium: 18,
          large: 32,
        ),
        ResponsiveLayoutBuilder(
          small: (_, __) => const SizedBox(),
          medium: (_, __) => const SizedBox(),
          large: (_, __) => const DashatarPuzzleActionButton(),
        ),
        ResponsiveLayoutBuilder(
          small: (_, __) => const DashatarTimer(),
          medium: (_, __) => const DashatarTimer(),
          large: (_, __) => const SizedBox(),
        ),
        const ResponsiveGap(small: 12),
      ],
    );
  }
}
