import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unpuzzle_it_abhi/audio_control/audio_control.dart';
import 'package:unpuzzle_it_abhi/layout/layout.dart';
import 'package:unpuzzle_it_abhi/theme/theme.dart';

/// {@template audio_control}
/// Displays and allows to update the current audio status of the puzzle.
/// {@endtemplate}
class AudioControl extends StatelessWidget {
  /// {@macro audio_control}
  AudioControl({Key? key}) : super(key: key);

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> audioGlobal(BuildContext context) async {
    // Obtain shared preferences.
    final SharedPreferences prefs = await _prefs;
    bool? audioControl = false;
    try {
      audioControl = prefs.getBool('audioControl');
    } on Exception catch (ex) {
      // log("Hello " + ex.toString());
    }

    audioControl == null ? audioControl = true : audioControl = !audioControl;
    await prefs.setBool('audioControl', audioControl);

    context.read<AudioControlBloc>().add(AudioToggled());
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);
    final audioMuted =
        context.select((AudioControlBloc bloc) => bloc.state.muted);
    final audioAsset =
        audioMuted ? theme.audioControlOffAsset : theme.audioControlOnAsset;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => audioGlobal(context),
        child: AnimatedSwitcher(
          duration: PuzzleThemeAnimationDuration.backgroundColorChange,
          child: ResponsiveLayoutBuilder(
            key: Key(audioAsset),
            small: (_, __) => Image.asset(
              audioAsset,
              key: const Key('audio_control_small'),
              width: 24,
              height: 24,
            ),
            medium: (_, __) => Image.asset(
              audioAsset,
              key: const Key('audio_control_medium'),
              width: 33,
              height: 33,
            ),
            large: (_, __) => Image.asset(
              audioAsset,
              key: const Key('audio_control_large'),
              width: 33,
              height: 33,
            ),
          ),
        ),
      ),
    );
  }
}
