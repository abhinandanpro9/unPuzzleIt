import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unpuzzle_it_abhi/custom/custom.dart';
import 'package:unpuzzle_it_abhi/layout/layout.dart';
import 'package:unpuzzle_it_abhi/theme/theme.dart';

/// {@template audio_control}
/// Displays and allows to update the current audio status of the puzzle.
/// {@endtemplate}
class BackControl extends StatefulWidget {
  /// {@macro audio_control}
  BackControl({Key? key, required this.callback}) : super(key: key);

  final Function()? callback;

  @override
  _BackControl createState() => _BackControl();
}

class _BackControl extends State<BackControl> {
  Future<void> call() async {
    if (await AllUtils.onWillPop(context)) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // final theme = context.select((ThemeBloc bloc) => bloc.state.theme);
    final audioAsset = "assets/images/back.png";

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => {call()},
        child: AnimatedSwitcher(
          duration: PuzzleThemeAnimationDuration.backgroundColorChange,
          child: ResponsiveLayoutBuilder(
            key: Key(audioAsset),
            small: (_, __) => Image.asset(
              audioAsset,
              width: 24,
              height: 24,
            ),
            medium: (_, __) => Image.asset(
              audioAsset,
              width: 33,
              height: 33,
            ),
            large: (_, __) => Image.asset(
              audioAsset,
              width: 33,
              height: 33,
            ),
          ),
        ),
      ),
    );
  }
}
