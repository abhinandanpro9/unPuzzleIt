import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:unpuzzle_it_abhi/typography/typography.dart';

import 'custom_hero.dart';

class Achievements extends StatelessWidget {
  Achievements(this.achieveItems, {Key? key}) : super(key: key);

  List<String>? achieveItems;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(HeroDialogRoute(builder: (context) {
            return _AchieveCard(achieveItems);
          }));
        },
        child: Hero(
          tag: _heroAchieve,
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin!, end: end!);
          },
          child: Material(
              color: Colors.transparent,
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32)),
              child: Image(
                image: AssetImage('assets/images/medal.png'),
                width: 56,
              )
              // const Icon(
              //   Icons.add_rounded,
              //   size: 56,
              // ),
              ),
        ),
      ),
    );
  }
}

/// Tag-value.
const String _heroAchieve = 'achieve-card';

/// {@template achievements}
/// Popup card to add a new [achievements]. Should be used in conjuction with
/// [HeroDialogRoute] to achieve the popup effect.
///
/// Uses a [Hero] with tag [_heroAchieve].
/// {@endtemplate}
class _AchieveCard extends StatelessWidget {
  /// {@macro achievements}
  _AchieveCard(this.achieveItems, {Key? key}) : super(key: key);

  List<String>? achieveItems;

  @override
  Widget build(BuildContext context) {
    final textStyle = (PuzzleTextStyle.headline3)
        .copyWith(color: Colors.white, shadows: <Shadow>[
      Shadow(
        offset: Offset(3.0, 3.0),
        blurRadius: 3.0,
        color: Color.fromARGB(255, 0, 0, 0),
      ),
      Shadow(
        offset: Offset(5.0, 5.0),
        blurRadius: 8.0,
        color: Color.fromARGB(125, 0, 0, 255),
      ),
    ]);
    final textStyleList = (PuzzleTextStyle.headline4Soft)
        .copyWith(color: Colors.white, shadows: <Shadow>[
      Shadow(
        offset: Offset(2.0, 2.0),
        blurRadius: 3.0,
        color: Color.fromARGB(255, 0, 0, 0),
      ),
      Shadow(
        offset: Offset(2.0, 2.0),
        blurRadius: 8.0,
        color: Color.fromARGB(125, 0, 0, 255),
      ),
    ]);
    final textStyleListRight = (PuzzleTextStyle.headline4Soft)
        .copyWith(color: Color.fromARGB(255, 68, 243, 255), shadows: <Shadow>[
      Shadow(
        offset: Offset(2.0, 2.0),
        blurRadius: 3.0,
        color: Color.fromARGB(255, 0, 0, 0),
      ),
      Shadow(
        offset: Offset(2.0, 2.0),
        blurRadius: 8.0,
        color: Color.fromARGB(125, 0, 0, 255),
      ),
    ]);

    final textAlign = TextAlign.left;

    final double gap = 20;
    final double widthList = 300;
    final double heightList = 250;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: _heroAchieve,
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin!, end: end!);
          },
          child: Material(
            color: Color.fromARGB(255, 63, 153, 153),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                                  achieveItems![index].split(':')[1],
                                  textAlign: textAlign,
                                ),
                              ),
                              title: AnimatedDefaultTextStyle(
                                style: textStyleList,
                                duration: Duration(milliseconds: 500),
                                child: Text(
                                  achieveItems![index].split(':')[0],
                                  textAlign: textAlign,
                                ),
                              ),
                            );
                          }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// {@template custom_rect_tween}
/// Linear RectTween with a [Curves.easeOut] curve.
///
/// Less dramatic that the regular [RectTween] used in [Hero] animations.
/// {@endtemplate}
class CustomRectTween extends RectTween {
  /// {@macro custom_rect_tween}
  CustomRectTween({
    required Rect begin,
    required Rect end,
  }) : super(begin: begin, end: end);

  @override
  Rect lerp(double t) {
    final elasticCurveValue = Curves.easeOut.transform(t);
    return Rect.fromLTRB(
      lerpDouble(begin!.left, end!.left, elasticCurveValue)!,
      lerpDouble(begin!.top, end!.top, elasticCurveValue)!,
      lerpDouble(begin!.right, end!.right, elasticCurveValue)!,
      lerpDouble(begin!.bottom, end!.bottom, elasticCurveValue)!,
    );
  }
}
