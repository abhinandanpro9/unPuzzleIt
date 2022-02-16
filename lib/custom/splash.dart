import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unpuzzle_it_abhi/custom/custom.dart';
import 'package:unpuzzle_it_abhi/dashatar/dashatar.dart';
import 'package:unpuzzle_it_abhi/helpers/helpers.dart';
import 'package:unpuzzle_it_abhi/l10n/l10n.dart';
import 'package:unpuzzle_it_abhi/layout/layout.dart';
import 'package:unpuzzle_it_abhi/theme/theme.dart';
import 'package:unpuzzle_it_abhi/typography/typography.dart';

/// {@template dashatar_share_dialog}
/// Displays a Dashatar share dialog with a score of the completed puzzle
/// and an option to share the score using Twitter or Facebook.
/// {@endtemplate}
class SplashScreen extends StatefulWidget {
  /// {@macro dashatar_share_dialog}
  const SplashScreen({
    Key? key,
    AudioPlayerFactory? audioPlayer,
  })  : _audioPlayerFactory = audioPlayer ?? getAudioPlayer,
        super(key: key);

  final AudioPlayerFactory _audioPlayerFactory;

  @override
  State<SplashScreen> createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AudioPlayer _successAudioPlayer;
  late final AudioPlayer _clickAudioPlayer;
  late Timer _startTutorialTimer;
  late final prefs;

  Future<void> help() async {
    // Obtain shared preferences.
    prefs = await SharedPreferences.getInstance();
    final bool? helpSplash = prefs.getBool('helpSplash');

    if (helpSplash != true) {
      // Call help ssection
      _startTutorialTimer = Timer(const Duration(milliseconds: 100), () async {
        await showAppDialogCustom<void>(
          barrierDismissible: true,
          context: context,
          child: MultiBlocProvider(
            providers: [
              BlocProvider.value(
                value: context.read<DashatarThemeBloc>(),
              ),
            ],
            child: const SplashScreenInfo(),
          ),
        );
      });
      await prefs.setBool('helpSplash', true);
    }
  }

  @override
  void initState() {
    //Call Help section
    help();

    super.initState();

    _successAudioPlayer = AudioPlayer()..setAsset('assets/audio/success.mp3');
    unawaited(_successAudioPlayer.play());

    _clickAudioPlayer = AudioPlayer()..setAsset('assets/audio/click.mp3');

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    Future.delayed(
      const Duration(milliseconds: 140),
      _controller.forward,
    );
  }

  @override
  void dispose() {
    _startTutorialTimer.cancel();
    _successAudioPlayer.dispose();
    _clickAudioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  void Exit(BuildContext context) {
    Timer(const Duration(milliseconds: 500), () async {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ResponsiveLayoutBuilder(
        small: (_, child) => child!,
        medium: (_, child) => child!,
        large: (_, child) => child!,
        //flow: TILE Stack
        child: (_) => SingleChildScrollView(
          child: LayoutBuilder(builder: (context, constraints) {
            return SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ResponsiveLayoutBuilder(
                      small: (context, child) => Center(
                        child: SizedBox(
                          child: Center(
                            child: child,
                          ),
                        ),
                      ),
                      medium: (context, child) => Center(
                        child: child,
                      ),
                      large: (context, child) => SizedBox(
                        child: child,
                      ),
                      child: (currentSize) {
                        final widthImage =
                            (currentSize == ResponsiveLayoutSize.large
                                ? 200.0
                                : 100.0);

                        return Image(
                            height: widthImage,
                            image: new AssetImage("assets/images/hello.gif"));
                      },
                    ),

                    ResponsiveLayoutBuilder(
                      small: (context, child) => Center(
                        child: SizedBox(
                          child: Center(
                            child: child,
                          ),
                        ),
                      ),
                      medium: (context, child) => Center(
                        child: child,
                      ),
                      large: (context, child) => SizedBox(
                        child: child,
                      ),
                      child: (currentSize) {
                        final textStyle =
                            (currentSize == ResponsiveLayoutSize.large
                                    ? PuzzleTextStyle.headline2
                                    : PuzzleTextStyle.headline3)
                                .copyWith(color: Colors.white);

                        final textAlign =
                            currentSize == ResponsiveLayoutSize.small
                                ? TextAlign.center
                                : TextAlign.left;

                        return AnimatedDefaultTextStyle(
                          style: textStyle,
                          duration: PuzzleThemeAnimationDuration.textStyle,
                          child: Text(
                            context.l10n.mainTitle,
                            textAlign: textAlign,
                          ),
                        );
                      },
                    ),
                    ResponsiveLayoutBuilder(
                        small: (context, child) => Center(
                              child: SizedBox(
                                child: Center(
                                  child: child,
                                ),
                              ),
                            ),
                        medium: (context, child) => Center(
                              child: child,
                            ),
                        large: (context, child) => SizedBox(
                              child: child,
                            ),
                        child: (currentSize) {
                          final widthImage =
                              (currentSize == ResponsiveLayoutSize.large
                                  ? 75.0
                                  : 50.0);
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Tooltip(
                                  key: const Key('smileyGreat'),
                                  message: context.l10n.mainSmiley1,
                                  verticalOffset: 40,
                                  child: IconButton(
                                      onPressed: () {
                                        // Path Theme
                                        context.read<DashatarThemeBloc>().add(
                                            DashatarThemeChanged(
                                                themeIndex: 1));
                                        Exit(context);
                                      },
                                      iconSize: widthImage,
                                      icon: Image(
                                          image: new AssetImage(
                                              "assets/images/happy.gif")))),
                              Tooltip(
                                  key: const Key('smileyBored'),
                                  message: context.l10n.mainSmiley2,
                                  verticalOffset: 40,
                                  child: IconButton(
                                      onPressed: () {
                                        // Custom Theme
                                        context.read<DashatarThemeBloc>().add(
                                            DashatarThemeChanged(
                                                themeIndex: 2));
                                        Exit(context);
                                      },
                                      iconSize: widthImage,
                                      icon: Image(
                                          image: new AssetImage(
                                              "assets/images/bored.gif")))),
                              Tooltip(
                                  key: const Key('smileyAngry'),
                                  message: context.l10n.mainSmiley3,
                                  verticalOffset: 40,
                                  child: IconButton(
                                      onPressed: () {
                                        // Simple Theme
                                        context.read<DashatarThemeBloc>().add(
                                            DashatarThemeChanged(
                                                themeIndex: 0));
                                        Exit(context);
                                      },
                                      iconSize: widthImage,
                                      icon: Image(
                                          image: new AssetImage(
                                              "assets/images/angry.gif"))))
                            ],
                          );
                        }),
                    const ResponsiveGap(small: 23, medium: 32, large: 50),
                    // CustomRoulette(),
                    ResponsiveLayoutBuilder(
                      small: (context, child) => Center(
                        child: SizedBox(
                          child: Center(
                            child: child,
                          ),
                        ),
                      ),
                      medium: (context, child) => Center(
                        child: child,
                      ),
                      large: (context, child) => SizedBox(
                        child: child,
                      ),
                      child: (currentSize) {
                        final textStyle =
                            (currentSize == ResponsiveLayoutSize.large
                                    ? PuzzleTextStyle.headline2
                                    : PuzzleTextStyle.headline3)
                                .copyWith(color: Colors.white);

                        final textAlign =
                            currentSize == ResponsiveLayoutSize.small
                                ? TextAlign.center
                                : TextAlign.left;

                        final widthImage =
                            (currentSize == ResponsiveLayoutSize.large
                                ? 300.0
                                : 200.0);

                        return CustomRoulette(
                          height: widthImage,
                          width: widthImage,
                          callback: (selected) {
                            if (selected.contains('Simple')) {
                              // Simple Theme
                              context
                                  .read<DashatarThemeBloc>()
                                  .add(DashatarThemeChanged(themeIndex: 0));
                              Exit(context);
                            } else if (selected.contains('Custom')) {
                              // Custom Theme
                              context
                                  .read<DashatarThemeBloc>()
                                  .add(DashatarThemeChanged(themeIndex: 2));
                              Exit(context);
                            } else if (selected.contains('Path')) {
                              // Path Theme
                              context
                                  .read<DashatarThemeBloc>()
                                  .add(DashatarThemeChanged(themeIndex: 1));
                              Exit(context);
                            }
                          },
                        );
                      },
                    ),
                    ResponsiveLayoutBuilder(
                      small: (context, child) => Center(
                        child: SizedBox(
                          child: Center(
                            child: child,
                          ),
                        ),
                      ),
                      medium: (context, child) => Center(
                        child: child,
                      ),
                      large: (context, child) => SizedBox(
                        child: child,
                      ),
                      child: (currentSize) {
                        final textStyle =
                            (currentSize == ResponsiveLayoutSize.large
                                    ? PuzzleTextStyle.headline2
                                    : PuzzleTextStyle.headline3)
                                .copyWith(color: Colors.white);

                        final textAlign =
                            currentSize == ResponsiveLayoutSize.small
                                ? TextAlign.center
                                : TextAlign.left;

                        final widthImage =
                            (currentSize == ResponsiveLayoutSize.large
                                ? 300.0
                                : 200.0);

                        return AnimatedDefaultTextStyle(
                          style: textStyle,
                          duration: PuzzleThemeAnimationDuration.textStyle,
                          child: Center(
                            child: Text(
                              context.l10n.mainWheelHelp,
                              textAlign: textAlign,
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ));
          }),
        ),
      ),
    );
  }
}

class SplashScreenInfo extends StatefulWidget {
  /// {@macro dashatar_share_dialog}
  const SplashScreenInfo({
    Key? key,
  }) : super(key: key);

  @override
  State<SplashScreenInfo> createState() => _SplashScreenInfo();
}

class _SplashScreenInfo extends State<SplashScreenInfo>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void Exit(BuildContext context) {
    Timer(const Duration(milliseconds: 3000), () async {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final geog = context.read<DashatarThemeBloc>();

    Exit(context);

    return Center(
      child: Wrap(
        children: [
          ResponsiveLayoutBuilder(
              small: (_, child) => child!,
              medium: (_, child) => child!,
              large: (_, child) => child!,
              child: (currentSize) {
                final textStyle = (currentSize == ResponsiveLayoutSize.large
                        ? PuzzleTextStyle.headline2
                        : PuzzleTextStyle.headline3)
                    .copyWith(
                        color: (currentSize == ResponsiveLayoutSize.small)
                            ? Colors.black
                            : Colors.white);

                final textAlign = currentSize == ResponsiveLayoutSize.small
                    ? TextAlign.center
                    : TextAlign.left;

                return AnimatedDefaultTextStyle(
                  style: textStyle,
                  duration: PuzzleThemeAnimationDuration.textStyle,
                  child: Center(
                    child: Text(
                      context.l10n.mainTitleHelp,
                      textAlign: textAlign,
                    ),
                  ),
                );
              })
        ],
      ),
    );
  }
}
