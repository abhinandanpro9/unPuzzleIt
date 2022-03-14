import 'dart:async' as async;
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unpuzzle_it_abhi/app/app.dart';
import 'package:unpuzzle_it_abhi/custom/custom.dart';
import 'package:unpuzzle_it_abhi/helpers/helpers.dart';
import 'package:unpuzzle_it_abhi/l10n/l10n.dart';
import 'package:unpuzzle_it_abhi/layout/layout.dart';
import 'package:unpuzzle_it_abhi/puzzle/puzzle.dart';
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
    this.callback,
  })  : _audioPlayerFactory = audioPlayer ?? getAudioPlayer,
        super(key: key);

  final AudioPlayerFactory _audioPlayerFactory;

  /// Called when this button is tapped.
  final Function(int)? callback;

  @override
  State<SplashScreen> createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AudioPlayer _successAudioPlayer;
  late final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  // late Timer? _helpTimer;

  Future<void> help() async {
    // Obtain shared preferences.
    final SharedPreferences prefs = await _prefs;
    bool? helpSplash = false;
    try {
      helpSplash = prefs.getBool('helpSplash');
    } on Exception catch (ex) {
      log("Hello " + ex.toString());
    }

    if ((helpSplash == null || helpSplash == false)) {
      // Call help ssection
      async.Timer(const Duration(milliseconds: 200), () async {
        await showAppDialogCustom<void>(
          barrierDismissible: true,
          context: context,
          bgColor: Colors.white,
          child: HelpInfo(
            text: context.l10n.mainTitleHelp,
            duration: 2000,
            color: Colors.blueAccent,
          ),
        );
      });
      await prefs.setBool('helpSplash', true);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      //Call Help section
      help();
      Future.delayed(
        const Duration(milliseconds: 200),
        _controller.forward,
      );
    });

    _successAudioPlayer = widget._audioPlayerFactory();

    _successAudioPlayer.stop();

    _successAudioPlayer.setAsset('assets/audio/spinwheel_success.mp3');

    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 3000),
        upperBound: 0.5);
  }

  @override
  void dispose() {
    _successAudioPlayer.dispose();
    _controller.dispose();
    // if(_helpTimer!=null && _helpTimer!.isActive)_helpTimer!.cancel();
    super.dispose();
  }

  void splashExit(BuildContext context, {required int themeIndex}) {
    // widget.callback!(themeIndex);
    final mainGameApp = App(themeIndex);
    final mainLoading = Loading(
        lottie: 'assets/images/splash/loading_custom.json',
        lottieDuration: 1000,
        backColor: Color.fromARGB(255, 0, 25, 63));

    var refresh;

    async.Timer(const Duration(milliseconds: 1000), () async {
      refresh = Navigator.push(
          context, MaterialPageRoute(builder: (context) => mainGameApp));

      showAppDialogCustomSplash<void>(
        context: context,
        barrierDismissible: false,
        child: mainLoading,
      );
      refresh == null ? refresh : refresh;
    });
  }

  int? highscore = 0;
  int? xp = 0;
  List<String>? achieve = [":"];

  Future<void> getHighscore() async {
    SettingsUtils.settingInit();

    async.Timer(const Duration(milliseconds: 100), () async {
      int? readHighscore;
      int? readXp;
      List<String>? items;

      try {
        readHighscore = SettingsUtils.getHighscore();
        readXp = SettingsUtils.getXp();
        items = SettingsUtils.getAchieve();
      } on Exception catch (ex) {
        // log("Hello " + ex.toString());
      }

      if (readXp != xp ||
          readHighscore != highscore ||
          achieve!.length != items!.length ||
          xp == null) {
        setState(() {
          highscore = readHighscore;
          xp = readXp;
          achieve = items;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    getHighscore();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ResponsiveLayoutBuilder(
        small: (_, child) => child!,
        medium: (_, child) => child!,
        large: (_, child) => child!,
        //flow: TILE Stack
        child: (_) => Stack(children: [
          SingleChildScrollView(
            child: LayoutBuilder(builder: (context, constraints) {
              return SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const ResponsiveGap(small: 23, medium: 32, large: 50),
                      SplashHead(),
                      emojiSection(context, _controller, _successAudioPlayer,
                          splashExit),
                      const ResponsiveGap(small: 23, medium: 32, large: 50),
                      // CustomRoulette(),
                      rouletteSection(context, splashExit),
                      const ResponsiveGap(small: 23, medium: 0, large: 0),
                      smallScoreBuilder(context, highscore, xp, achieve),
                    ],
                  ));
            }),
          ),
          scoreBuilderBox(context, highscore, xp),
          achieveBuilderBox(context, achieve),
        ]),
      ),
    );
  }
}

@override
Widget smallScoreBuilder(
    BuildContext context, int? highscore, int? xp, List<String>? achieveItems) {
  return Column(
    children: [
      ResponsiveLayoutBuilder(
        small: (context, child) => Center(
          child: SizedBox(
            child: Center(
              child: child,
            ),
          ),
        ),
        medium: (context, child) => SizedBox(),
        large: (context, child) => SizedBox(),
        child: (currentSize) {
          final textStyle = (PuzzleTextStyle.headline4)
              .copyWith(color: Colors.white, shadows: <Shadow>[
            Shadow(
              offset: Offset(5.0, 5.0),
              blurRadius: 3.0,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            Shadow(
              offset: Offset(5.0, 5.0),
              blurRadius: 8.0,
              color: Color.fromARGB(125, 0, 0, 255),
            ),
          ]);
          final textStyleScore = (PuzzleTextStyle.headline4Soft)
              .copyWith(color: Colors.yellow, shadows: <Shadow>[
            Shadow(
              offset: Offset(3.0, 3.0),
              blurRadius: 3.0,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            Shadow(
              offset: Offset(3.0, 3.0),
              blurRadius: 8.0,
              color: Color.fromARGB(125, 0, 0, 255),
            ),
          ]);

          final textAlign = TextAlign.center;

          final double pad =
              currentSize == ResponsiveLayoutSize.large ? 50 : 20;
          final double gap =
              currentSize == ResponsiveLayoutSize.large ? 25 : 20;

          return Row(
            mainAxisAlignment:
                MainAxisAlignment.center, //Center Row contents horizontally,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  padding: EdgeInsets.only(
                      left: pad, right: pad, top: pad, bottom: pad),
                  decoration: BoxDecoration(
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          offset: Offset(5.0, 5.0),
                          blurRadius: 3.0,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        BoxShadow(
                          offset: Offset(5.0, 5.0),
                          blurRadius: 8.0,
                          spreadRadius: 5.0,
                          color: Color.fromARGB(124, 3, 103, 233),
                        ),
                      ],
                      color: Color.fromARGB(255, 24, 149, 207),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, //Center Row contents horizontally,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedDefaultTextStyle(
                        style: textStyle,
                        duration: Duration(seconds: 500),
                        child: Text(
                          'HighScore',
                          textAlign: textAlign,
                        ),
                      ),
                      // const ResponsiveGap(small: 23, medium: 32, large: 50),
                      Gap(gap),
                      AnimatedDefaultTextStyle(
                        style: textStyleScore,
                        duration: Duration(seconds: 500),
                        child: Text(
                          highscore.toString(),
                          textAlign: textAlign,
                        ),
                      ),
                      Gap(pad),
                      AnimatedDefaultTextStyle(
                        style: textStyle,
                        duration: Duration(seconds: 500),
                        child: Text(
                          'XP',
                          textAlign: textAlign,
                        ),
                      ),
                      // const ResponsiveGap(small: 23, medium: 32, large: 50),
                      Gap(gap),
                      AnimatedDefaultTextStyle(
                        style: textStyleScore,
                        duration: Duration(seconds: 500),
                        child: Text(
                          xp.toString(),
                          textAlign: textAlign,
                        ),
                      ),
                    ],
                  )),
            ],
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
        medium: (context, child) => SizedBox(),
        large: (context, child) => SizedBox(),
        child: (currentSize) {
          return Row(
            mainAxisAlignment:
                MainAxisAlignment.center, //Center Row contents horizontally,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .center, //Center Row contents horizontally,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Achievements(achieveItems),
                ],
              ),
            ],
          );
        },
      ),
    ],
  );
}

@override
Widget scoreBuilderBox(BuildContext context, int? highscore, int? xp) {
  return Positioned(
    bottom: 74,
    right: 25,
    child: ResponsiveLayoutBuilder(
      small: (context, child) => SizedBox(),
      medium: (context, child) => SizedBox(
        child: child,
      ),
      large: (context, child) => SizedBox(
        child: child,
      ),
      child: (currentSize) {
        final textStyle = (currentSize == ResponsiveLayoutSize.large
                ? headline2
                : PuzzleTextStyle.headline4)
            .copyWith(color: Colors.white, shadows: <Shadow>[
          Shadow(
            offset: Offset(5.0, 5.0),
            blurRadius: 3.0,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          Shadow(
            offset: Offset(5.0, 5.0),
            blurRadius: 8.0,
            color: Color.fromARGB(125, 0, 0, 255),
          ),
        ]);
        final textStyleScore = (currentSize == ResponsiveLayoutSize.large
                ? PuzzleTextStyle.headline3Soft
                : PuzzleTextStyle.headline4Soft)
            .copyWith(color: Colors.yellow, shadows: <Shadow>[
          Shadow(
            offset: Offset(5.0, 5.0),
            blurRadius: 3.0,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          Shadow(
            offset: Offset(5.0, 5.0),
            blurRadius: 8.0,
            color: Color.fromARGB(125, 0, 0, 255),
          ),
        ]);

        final textAlign = currentSize == ResponsiveLayoutSize.small
            ? TextAlign.center
            : TextAlign.left;

        final double pad = currentSize == ResponsiveLayoutSize.large ? 50 : 20;
        final double gap = currentSize == ResponsiveLayoutSize.large ? 25 : 20;

        return Container(
            padding: EdgeInsets.all(pad),
            decoration: BoxDecoration(
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    offset: Offset(10.0, 10.0),
                    blurRadius: 3.0,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                  BoxShadow(
                    offset: Offset(10.0, 10.0),
                    blurRadius: 8.0,
                    spreadRadius: 5.0,
                    color: Color.fromARGB(124, 3, 103, 233),
                  ),
                ],
                color: Color.fromARGB(255, 24, 149, 207),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Column(
              children: [
                AnimatedDefaultTextStyle(
                  style: textStyle,
                  duration: Duration(seconds: 500),
                  child: Text(
                    'HighScore',
                    textAlign: textAlign,
                  ),
                ),
                // const ResponsiveGap(small: 23, medium: 32, large: 50),
                Gap(gap),
                AnimatedDefaultTextStyle(
                  style: textStyleScore,
                  duration: Duration(seconds: 500),
                  child: Text(
                    highscore.toString(),
                    textAlign: textAlign,
                  ),
                ),
                Gap(pad),
                AnimatedDefaultTextStyle(
                  style: textStyle,
                  duration: Duration(seconds: 500),
                  child: Text(
                    'XP',
                    textAlign: textAlign,
                  ),
                ),
                // const ResponsiveGap(small: 23, medium: 32, large: 50),
                Gap(gap),
                AnimatedDefaultTextStyle(
                  style: textStyleScore,
                  duration: Duration(seconds: 500),
                  child: Text(
                    xp.toString(),
                    textAlign: textAlign,
                  ),
                ),
              ],
            ));
      },
    ),
  );
}

@override
Widget achieveBuilderBox(BuildContext context, List<String>? achieveItems) {
  return Positioned(
    bottom: 74,
    left: 25,
    child: ResponsiveLayoutBuilder(
      small: (context, child) => SizedBox(),
      medium: (context, child) => SizedBox(
        child: child,
      ),
      large: (context, child) => SizedBox(
        child: child,
      ),
      child: (currentSize) {
        final textStyle = (currentSize == ResponsiveLayoutSize.large
                ? PuzzleTextStyle.headline3
                : PuzzleTextStyle.headline4)
            .copyWith(color: Colors.white, shadows: <Shadow>[
          Shadow(
            offset: Offset(7.0, 7.0),
            blurRadius: 3.0,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          Shadow(
            offset: Offset(7.0, 7.0),
            blurRadius: 8.0,
            color: Color.fromARGB(125, 0, 0, 255),
          ),
        ]);
        final textStyleList = (currentSize == ResponsiveLayoutSize.large
                ? PuzzleTextStyle.headline4Soft
                : PuzzleTextStyle.headline4Soft)
            .copyWith(color: Colors.white, shadows: <Shadow>[
          Shadow(
            offset: Offset(3.0, 3.0),
            blurRadius: 3.0,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          Shadow(
            offset: Offset(3.0, 3.0),
            blurRadius: 8.0,
            color: Color.fromARGB(125, 0, 0, 255),
          ),
        ]);
        final textStyleListRight = (currentSize == ResponsiveLayoutSize.large
                ? PuzzleTextStyle.headline4Soft
                : PuzzleTextStyle.headline4Soft)
            .copyWith(color: Color.fromARGB(255, 68, 243, 255), shadows: <Shadow>[
          Shadow(
            offset: Offset(3.0, 3.0),
            blurRadius: 3.0,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          Shadow(
            offset: Offset(3.0, 3.0),
            blurRadius: 8.0,
            color: Color.fromARGB(125, 0, 0, 255),
          ),
        ]);

        final textAlign = currentSize == ResponsiveLayoutSize.small
            ? TextAlign.center
            : TextAlign.left;

        final double pad = currentSize == ResponsiveLayoutSize.large ? 50 : 20;
        final double gap = currentSize == ResponsiveLayoutSize.large ? 25 : 20;
        final double widthList = currentSize == ResponsiveLayoutSize.large ? 300 : 150;
        final double heightList = currentSize == ResponsiveLayoutSize.large ? 200 : 150;

        return Container(
          padding: EdgeInsets.all(pad),
          decoration: BoxDecoration(
              boxShadow: <BoxShadow>[
                BoxShadow(
                  offset: Offset(5.0, 5.0),
                  blurRadius: 3.0,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                BoxShadow(
                  offset: Offset(5.0, 5.0),
                  blurRadius: 8.0,
                  spreadRadius: 5.0,
                  color: Color.fromARGB(255, 122, 39, 0),
                ),
              ],
              color: Color.fromARGB(255, 207, 82, 24),
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedDefaultTextStyle(
                style: textStyle,
                duration: Duration(seconds: 500),
                child: Text(
                  'Achievements',
                  textAlign: textAlign,
                ),
              ),
              Gap(gap),
              Container(
                height: heightList,
                width: widthList,
                child: ListView.builder(
                    itemCount: achieveItems!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        trailing: AnimatedDefaultTextStyle(
                          style: textStyleListRight,
                          duration: Duration(milliseconds: 500),
                          child: Text(
                            achieveItems[index].split(':')[1],
                            textAlign: textAlign,
                          ),
                        ),
                        title: AnimatedDefaultTextStyle(
                          style: textStyleList,
                          duration: Duration(milliseconds: 500),
                          child: Text(
                            achieveItems[index].split(':')[0],
                            textAlign: textAlign,
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),
        );
      },
    ),
  );
}

@override
Widget emojiSection(BuildContext context, _controller, _successAudioPlayer,
    void Function(BuildContext, {required int themeIndex}) splashExit) {
  return Column(
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
              (currentSize == ResponsiveLayoutSize.large ? 150.0 : 100.0);

          return currentSize == ResponsiveLayoutSize.small
              ? Gap(50)
              : Lottie.asset('assets/images/splash/hello.json',
                  controller: _controller, height: widthImage);
          // Image(
          //     height: widthImage,
          //     image: new AssetImage(
          //         "assets/images/splash/hello.gif"));
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
          final textStyle = (currentSize == ResponsiveLayoutSize.large
                  ? PuzzleTextStyle.headline2
                  : PuzzleTextStyle.headline3)
              .copyWith(color: Colors.white, fontFamily: 'Courgette');

          final textAlign = currentSize == ResponsiveLayoutSize.small
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
                (currentSize == ResponsiveLayoutSize.large ? 50.0 : 50.0);
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Tooltip(
                    key: const Key('smileyGreat'),
                    message: context.l10n.mainSmiley1,
                    verticalOffset: 40,
                    child: IconButton(
                        onPressed: () {
                          async.unawaited(_successAudioPlayer.play());

                          // // Path Theme
                          // context.read<DashatarThemeBloc>().add(
                          //     DashatarThemeChanged(
                          //         themeIndex: 1));
                          splashExit(context, themeIndex: 1);
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
                          async.unawaited(_successAudioPlayer.play());
                          // // Custom Theme
                          // context.read<DashatarThemeBloc>().add(
                          //     DashatarThemeChanged(
                          //         themeIndex: 2));
                          splashExit(context, themeIndex: 2);
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
                          async.unawaited(_successAudioPlayer.play());
                          // // Simple Theme
                          // context.read<DashatarThemeBloc>().add(
                          //     DashatarThemeChanged(
                          //         themeIndex: 0));
                          splashExit(context, themeIndex: 0);
                        },
                        iconSize: widthImage,
                        icon: Image(
                            image: new AssetImage(
                                "assets/images/splash/angry.gif"))))
              ],
            );
          }),
    ],
  );
}

@override
Widget rouletteSection(BuildContext context,
    void Function(BuildContext, {required int themeIndex}) splashExit) {
  return Column(
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
              (currentSize == ResponsiveLayoutSize.large ? 250.0 : 200.0);

          return CustomRoulette(
            height: widthImage,
            width: widthImage,
            callback: (selected) {
              if (selected.contains('Simple')) {
                // Simple Theme
                // context
                //     .read<DashatarThemeBloc>()
                //     .add(DashatarThemeChanged(themeIndex: 0));
                splashExit(context, themeIndex: 0);
              } else if (selected.contains('Custom')) {
                // Custom Theme
                // context
                //     .read<DashatarThemeBloc>()
                //     .add(DashatarThemeChanged(themeIndex: 2));
                splashExit(context, themeIndex: 2);
              } else if (selected.contains('Path')) {
                // // Path Theme
                // context
                //     .read<DashatarThemeBloc>()
                //     .add(DashatarThemeChanged(themeIndex: 1));
                splashExit(context, themeIndex: 1);
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
          final textStyle = (currentSize == ResponsiveLayoutSize.large
                  ? PuzzleTextStyle.headline2
                  : PuzzleTextStyle.headline3)
              .copyWith(
                  color: Colors.white,
                  fontFamily: 'Courgette',
                  shadows: <Shadow>[
                Shadow(
                  offset: Offset(10.0, 10.0),
                  blurRadius: 3.0,
                  color: Color.fromARGB(255, 212, 44, 114),
                ),
              ]);

          final textAlign = currentSize == ResponsiveLayoutSize.small
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
      ),
    ],
  );
}

final audioControlKey1 = GlobalKey(debugLabel: 'audio_control1');
final helpControlKey1 = GlobalKey(debugLabel: 'ahelp_control1');

@visibleForTesting
class SplashHead extends StatelessWidget {
  /// {@macro puzzle_header}
  const SplashHead({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: SizedBox(
      height: 30,
      child: ResponsiveLayoutBuilder(
        small: (context, child) => Stack(
          children: [
            const Align(
              child: SplashLogo(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 34 * 2),
                child: SplashHelpControl(
                  key: helpControlKey1,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 34),
                child: SplashAudioControl(key: audioControlKey1),
              ),
            ),
          ],
        ),
        medium: (context, child) => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 50,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SplashLogo(),
              SplashMenu(),
            ],
          ),
        ),
        large: (context, child) => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 50,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SplashLogo(),
              SplashMenu(),
            ],
          ),
        ),
      ),
    ));
  }
}

class SplashHelpControl extends StatelessWidget {
  /// {@macro audio_control}
  const SplashHelpControl({Key? key}) : super(key: key);

  Future<void> callHelp(context, String textHelp, Color bgColor) async {
    Timer(const Duration(milliseconds: 500), () async {
      await showAppDialogCustom<void>(
        barrierDismissible: true,
        context: context,
        bgColor: bgColor,
        child: HelpInfo(
          text: textHelp,
          duration: 3000,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // final theme = context.select((ThemeBloc bloc) => bloc.state.theme);
    final audioAsset = "assets/images/help.png";

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => {
          {callHelp(context, context.l10n.mainTitleHelp, Colors.orangeAccent)}
        },
        child: AnimatedSwitcher(
          duration: PuzzleThemeAnimationDuration.backgroundColorChange,
          child: ResponsiveLayoutBuilder(
            key: Key(audioAsset),
            small: (_, __) => Image.asset(
              audioAsset,
              key: const Key('g_help_control_small'),
              width: 24,
              height: 24,
            ),
            medium: (_, __) => Image.asset(
              audioAsset,
              key: const Key('g_help_control_medium'),
              width: 33,
              height: 33,
            ),
            large: (_, __) => Image.asset(
              audioAsset,
              key: const Key('g_help_control_large'),
              width: 33,
              height: 33,
            ),
          ),
        ),
      ),
    );
  }
}

class SplashAudioControl extends StatefulWidget {
  /// {@macro audio_control}
  SplashAudioControl({Key? key}) : super(key: key);

  @override
  _SplashAudioControl createState() => _SplashAudioControl();
}

class _SplashAudioControl extends State<SplashAudioControl>
    with SingleTickerProviderStateMixin {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String audioAsset = "assets/images/audio_control/dashatar_on.png";

  Future<void> audioinitGlobal() async {
    // Obtain shared preferences.
    final SharedPreferences prefs = await _prefs;
    bool? audioControl = false;
    try {
      audioControl = prefs.getBool('audioControl');
    } on Exception catch (ex) {
      log("Hello " + ex.toString());
    }

    if (audioControl == null) {
      audioControl = true;
    } else {
      if (audioControl != null && !audioControl) {
        setState(() {
          audioAsset = "assets/images/audio_control/simple_off.png";
        });
      }
      return;
    }
    await prefs.setBool('audioControl', audioControl);

    setState(() {
      audioControl != null
          ? audioControl
              ? audioAsset = "assets/images/audio_control/dashatar_on.png"
              : audioAsset = "assets/images/audio_control/simple_off.png"
          : null;
    });
  }

  Future<void> audioGlobal() async {
    // Obtain shared preferences.
    final SharedPreferences prefs = await _prefs;
    bool? audioControl = false;
    try {
      audioControl = prefs.getBool('audioControl');
    } on Exception catch (ex) {
      log("Hello " + ex.toString());
    }

    audioControl == null ? audioControl = true : audioControl = !audioControl;
    await prefs.setBool('audioControl', audioControl);

    setState(() {
      audioControl != null
          ? audioControl
              ? audioAsset = "assets/images/audio_control/dashatar_on.png"
              : audioAsset = "assets/images/audio_control/simple_off.png"
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    audioinitGlobal();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: audioGlobal,
        child: AnimatedSwitcher(
          duration: PuzzleThemeAnimationDuration.backgroundColorChange,
          child: ResponsiveLayoutBuilder(
            key: Key(audioAsset),
            small: (_, __) => Image.asset(
              audioAsset,
              key: const Key('g_audio_control_small'),
              width: 24,
              height: 24,
            ),
            medium: (_, __) => Image.asset(
              audioAsset,
              key: const Key('g_audio_control_medium'),
              width: 33,
              height: 33,
            ),
            large: (_, __) => Image.asset(
              audioAsset,
              key: const Key('g_audio_control_large'),
              width: 33,
              height: 33,
            ),
          ),
        ),
      ),
    );
  }
}

/// {@template puzzle_menu}
/// Displays the menu of the puzzle.
/// {@endtemplate}
@visibleForTesting
class SplashMenu extends StatelessWidget {
  /// {@macro puzzle_menu}
  const SplashMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final themes = context.select((ThemeBloc bloc) => bloc.state.themes);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ResponsiveLayoutBuilder(
          small: (_, child) => const SizedBox(),
          medium: (_, child) => child!,
          large: (_, child) => child!,
          child: (currentSize) {
            return Row(
              children: [
                const Gap(44),
                SplashHelpControl(
                  key: helpControlKey1,
                ),
                const Gap(24),
                SplashAudioControl(
                  key: audioControlKey1,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// {@template puzzle_logo}
/// Displays the logo of the puzzle.
/// {@endtemplate}
@visibleForTesting
class SplashLogo extends StatelessWidget {
  /// {@macro puzzle_logo}
  const SplashLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppFlutterLogo(
      key: puzzleLogoKey,
      isColored: false,
    );
  }
}

const _baseTextStyle = TextStyle(
  fontFamily: 'GoogleSans',
  color: Colors.black,
  fontWeight: PuzzleFontWeight.regular,
);
TextStyle get headline2 {
  return _baseTextStyle.copyWith(
    fontSize: 45,
    height: 1.1,
    fontWeight: PuzzleFontWeight.bold,
  );
}
