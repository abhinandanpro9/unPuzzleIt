import 'dart:async';
import 'dart:developer';

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

/// {@template splash}
/// Displays a splash screen as a menu
/// {@endtemplate}
class SplashScreen extends StatefulWidget {
  /// {@macro splash}
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
  late final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Timer _helpTimer;

  Future<void> help() async {
    // Obtain shared preferences.
    final SharedPreferences prefs = await _prefs;
    bool? helpSplash = false;
    try {
      helpSplash = prefs.getBool('helpSplash');
    } on Exception catch (ex) {
      log("Hello "+ex.toString());
    }

    if ((helpSplash==null || helpSplash==false)) {
      // Call help ssection
      _helpTimer = Timer(const Duration(milliseconds: 200), () async {
        await showAppDialogCustom<void>(
          barrierDismissible: true,
          context: context,
          bgColor: Colors.white,
          child: MultiBlocProvider(
            providers: [
              BlocProvider.value(
                value: context.read<DashatarThemeBloc>(),
              ),
            ],
            child: HelpInfo(
              text: context.l10n.mainTitleHelp,
              duration: 2000,
              color: Colors.blueAccent,
            ),
          ),
        );
      });
      await prefs.setBool('helpSplash', true);
    }
  }

  @override
  void initState() {
    super.initState();

    //Call Help section
    help();

    _successAudioPlayer = widget._audioPlayerFactory();

    _successAudioPlayer.setAsset('assets/audio/spinwheel_success.mp3');

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
    _successAudioPlayer.dispose();
    _controller.dispose();
    if(_helpTimer.isActive)_helpTimer.cancel();
    super.dispose();
  }

  void splashExit(BuildContext context) {
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
                                ? 150.0
                                : 100.0);

                        return Image(
                            height: widthImage,
                            image: new AssetImage(
                                "assets/images/splash/hello.gif"));
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
                                .copyWith(
                                    color: Colors.white,
                                    fontFamily: 'Courgette');

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
                                  ? 50.0
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
                                        unawaited(_successAudioPlayer.play());
                                        // Path Theme
                                        context.read<DashatarThemeBloc>().add(
                                            DashatarThemeChanged(
                                                themeIndex: 1));
                                        splashExit(context);
                                      },
                                      iconSize: widthImage,
                                      icon: Image(
                                          image: new AssetImage(
                                              "assets/images/splash/happy.gif")))),
                              Tooltip(
                                  key: const Key('smileyBored'),
                                  message: context.l10n.mainSmiley2,
                                  verticalOffset: 40,
                                  child: IconButton(
                                      onPressed: () {
                                        unawaited(_successAudioPlayer.play());
                                        // Custom Theme
                                        context.read<DashatarThemeBloc>().add(
                                            DashatarThemeChanged(
                                                themeIndex: 2));
                                        splashExit(context);
                                      },
                                      iconSize: widthImage,
                                      icon: Image(
                                          image: new AssetImage(
                                              "assets/images/splash/bored.gif")))),
                              Tooltip(
                                  key: const Key('smileyAngry'),
                                  message: context.l10n.mainSmiley3,
                                  verticalOffset: 40,
                                  child: IconButton(
                                      onPressed: () {
                                        unawaited(_successAudioPlayer.play());
                                        // Simple Theme
                                        context.read<DashatarThemeBloc>().add(
                                            DashatarThemeChanged(
                                                themeIndex: 0));
                                        splashExit(context);
                                      },
                                      iconSize: widthImage,
                                      icon: Image(
                                          image: new AssetImage(
                                              "assets/images/splash/angry.gif"))))
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
                        // final textStyle =
                        //     (currentSize == ResponsiveLayoutSize.large
                        //             ? PuzzleTextStyle.headline2
                        //             : PuzzleTextStyle.headline3)
                        //         .copyWith(color: Colors.white);

                        // final textAlign =
                        //     currentSize == ResponsiveLayoutSize.small
                        //         ? TextAlign.center
                        //         : TextAlign.left;

                        final widthImage =
                            (currentSize == ResponsiveLayoutSize.large
                                ? 250.0
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
                              splashExit(context);
                            } else if (selected.contains('Custom')) {
                              // Custom Theme
                              context
                                  .read<DashatarThemeBloc>()
                                  .add(DashatarThemeChanged(themeIndex: 2));
                              splashExit(context);
                            } else if (selected.contains('Path')) {
                              // Path Theme
                              context
                                  .read<DashatarThemeBloc>()
                                  .add(DashatarThemeChanged(themeIndex: 1));
                              splashExit(context);
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
                                .copyWith(
                                    color: Colors.white,
                                    fontFamily: 'Courgette');

                        final textAlign =
                            currentSize == ResponsiveLayoutSize.small
                                ? TextAlign.center
                                : TextAlign.left;

                        // final widthImage =
                        //     (currentSize == ResponsiveLayoutSize.large
                        //         ? 300.0
                        //         : 200.0);

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
