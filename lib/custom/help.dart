import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unpuzzle_it_abhi/custom/custom.dart';
import 'package:unpuzzle_it_abhi/l10n/l10n.dart';
import 'package:unpuzzle_it_abhi/layout/layout.dart';
import 'package:unpuzzle_it_abhi/theme/theme.dart';

import '../dashatar/bloc/bloc.dart';

/// {@template audio_control}
/// Displays and allows to update the current audio status of the puzzle.
/// {@endtemplate}
class HelpControl extends StatefulWidget {
  /// {@macro audio_control}
  const HelpControl({Key? key}) : super(key: key);

  @override
  _HelpControl createState() => _HelpControl();
}

class _HelpControl extends State<HelpControl> {
  Future<void> callHelp(String textHelp, Color bgColor) async {
    Timer(const Duration(milliseconds: 500), () async {
      await showAppDialogCustom<void>(
        barrierDismissible: true,
        context: context,
        bgColor: bgColor,
        child: MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: context.read<DashatarThemeBloc>(),
            ),
          ],
          child: HelpInfo(
            text: textHelp,
            duration: 3000,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // final theme = context.select((ThemeBloc bloc) => bloc.state.theme);
    final themeState = context.watch<DashatarThemeBloc>().state;
    final activeTheme = themeState.theme;
    final audioAsset = "assets/images/help.png";

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => {
          if (activeTheme.isCustomTheme)
            {callHelp(context.l10n.customHelp, Colors.orangeAccent)}
          else if (activeTheme.isPathTheme)
            {callHelp(context.l10n.pathHelp, Colors.orangeAccent)}
          else
            {callHelp(context.l10n.defHelp, Colors.orangeAccent)}
        },
        child: AnimatedSwitcher(
          duration: PuzzleThemeAnimationDuration.backgroundColorChange,
          child: ResponsiveLayoutBuilder(
            key: Key(audioAsset),
            small: (_, __) => Image.asset(
              audioAsset,
              key: const Key('help_control_small'),
              width: 24,
              height: 24,
            ),
            medium: (_, __) => Image.asset(
              audioAsset,
              key: const Key('help_control_medium'),
              width: 33,
              height: 33,
            ),
            large: (_, __) => Image.asset(
              audioAsset,
              key: const Key('help_control_large'),
              width: 33,
              height: 33,
            ),
          ),
        ),
      ),
    );
  }
}
