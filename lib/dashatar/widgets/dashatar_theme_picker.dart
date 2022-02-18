import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:unpuzzle_it_abhi/audio_control/audio_control.dart';
import 'package:unpuzzle_it_abhi/dashatar/dashatar.dart';
import 'package:unpuzzle_it_abhi/helpers/helpers.dart';
import 'package:unpuzzle_it_abhi/layout/layout.dart';
import 'package:unpuzzle_it_abhi/puzzle/puzzle.dart';
import 'package:unpuzzle_it_abhi/timer/timer.dart';

/// {@template dashatar_theme_picker}
/// Displays the Dashatar theme picker to choose between
/// [DashatarThemeState.themes].
///
/// By default allows to choose between [BlueDashatarTheme],
/// [GreenDashatarTheme] or [YellowDashatarTheme].
/// {@endtemplate}
class DashatarThemePicker extends StatefulWidget {
  /// {@macro dashatar_theme_picker}
  const DashatarThemePicker({
    Key? key,
    AudioPlayerFactory? audioPlayer,
  })  : _audioPlayerFactory = audioPlayer ?? getAudioPlayer,
        super(key: key);

  static const _activeThemeNormalSize = 120.0;
  static const _activeThemeSmallSize = 65.0;
  static const _inactiveThemeNormalSize = 96.0;
  static const _inactiveThemeSmallSize = 50.0;

  final AudioPlayerFactory _audioPlayerFactory;

  @override
  State<DashatarThemePicker> createState() => _DashatarThemePickerState();
}

class _DashatarThemePickerState extends State<DashatarThemePicker> {
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = widget._audioPlayerFactory();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<DashatarThemeBloc>().state;
    final activeTheme = themeState.theme;
    final puzzle = context.select((PuzzleBloc bloc) => bloc.state.puzzle);

    return AudioControlListener(
      audioPlayer: _audioPlayer,
      child: ResponsiveLayoutBuilder(
        small: (_, child) => child!,
        medium: (_, child) => child!,
        large: (_, child) => child!,
        child: (currentSize) {
          final isSmallSize = currentSize == ResponsiveLayoutSize.small;
          final activeSize = isSmallSize
              ? DashatarThemePicker._activeThemeSmallSize
              : DashatarThemePicker._activeThemeNormalSize;
          final inactiveSize = isSmallSize
              ? DashatarThemePicker._inactiveThemeSmallSize
              : DashatarThemePicker._inactiveThemeNormalSize;

          return SizedBox(
            key: const Key('dashatar_theme_picker'),
            height: activeSize,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                themeState.themes.length,
                (index) {
                  final theme = themeState.themes[index];
                  final isActiveTheme = theme == activeTheme;
                  final padding = index > 0 ? (isSmallSize ? 4.0 : 8.0) : 0.0;
                  final size = isActiveTheme ? activeSize : inactiveSize;

                  return Padding(
                    padding: EdgeInsets.only(left: padding),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        key: Key('dashatar_theme_picker_$index'),
                        onTap: () async {
                          // flow: 11111
                          if (isActiveTheme) {
                            return;
                          }

                          if (activeTheme.isCustomTheme &&
                              puzzle.tiles.length > 16) {
                            // fix: For Timer reset after switch from custom theme
                            context.read<TimerBloc>().add(const TimerReset());
                            context.read<PuzzleBloc>().add(
                                  PuzzleInitialized(
                                    shufflePuzzle: false,
                                    tileSize: 4,
                                  ),
                                );
                          }

                          // Update the current Dashatar theme.
                          context
                              .read<DashatarThemeBloc>()
                              .add(DashatarThemeChanged(themeIndex: index));

                          // Play the audio of the current Dashatar theme.
                          await _audioPlayer.setAsset(theme.audioAsset);
                          unawaited(_audioPlayer.play());
                        },
                        child: AnimatedContainer(
                          width: size,
                          height: size,
                          curve: Curves.easeInOut,
                          duration: const Duration(milliseconds: 350),
                          child: Image.asset(
                            theme.themeAsset,
                            fit: BoxFit.fill,
                            semanticLabel: theme.semanticsLabel(context),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
