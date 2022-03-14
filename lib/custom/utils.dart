import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gap/gap.dart';
import 'package:image/image.dart' as image;
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unpuzzle_it_abhi/layout/layout.dart';
import 'package:unpuzzle_it_abhi/theme/theme.dart';
import 'package:unpuzzle_it_abhi/typography/typography.dart';

class _TileSize {
  static double small = 75;
  static double medium = 100;
  static double large = 112;
}

class ParseFileClass {
  final Widget _paintWidget;
  final Image? _imageMain;

  ParseFileClass(this._paintWidget, this._imageMain);

  getWiget() {
    return this._paintWidget;
  }

  getImage() {
    return this._imageMain;
  }
}

class SettingsUtils {
  static SharedPreferences? preferences;

  static Future<void> settingInit() async {
    preferences = await SharedPreferences.getInstance();

    int? readHighscore;
    int? readXp;
    List<String>? items;

    try {
      readHighscore = preferences!.getInt('highscore');
      readXp = preferences!.getInt('xp');
      items = preferences!.getStringList('achievements');
    } on Exception catch (ex) {
      // log("Hello " + ex.toString());
    }

    if ((readHighscore == null)) {
      await preferences!.setInt('highscore', 0);
      readHighscore = 0;
    }
    if ((readXp == null)) {
      await preferences!.setInt('xp', 0);
      readXp = 0;
    }
    if ((items == null)) {
      await preferences!.setStringList('achievements', <String>[":"]);
      items = [":"];
    }
  }

  static int? getHighscore() {
    int? readHighscore;

    try {
      readHighscore = preferences!.getInt('highscore');
    } on Exception catch (ex) {
      // log("Hello " + ex.toString());
    }
    return readHighscore;
  }

  static int? getXp() {
    int? readXp;

    try {
      readXp = preferences!.getInt('xp');
    } on Exception catch (ex) {
      // log("Hello " + ex.toString());
    }
    return readXp;
  }

  static List<String>? getAchieve() {
    List<String>? items;

    try {
      items = preferences!.getStringList('achievements');
    } on Exception catch (ex) {
      // log("Hello " + ex.toString());
    }
    return items;
  }

  static bool? getAudio() {
    bool? audioControl = false;
    try {
      audioControl = preferences!.getBool('audioControl');
    } on Exception catch (ex) {
      // log("Hello " + ex.toString());
    }
    return audioControl;
  }

  static void setAchieve(List<String>? items) {
    try {
      preferences!.setStringList('achievements', items!);
    } on Exception catch (ex) {
      // log("Hello " + ex.toString());
    }
  }

  static void setHighscore(int score) {
    try {
      preferences!.setInt('highscore', score);
    } on Exception catch (ex) {
      // log("Hello " + ex.toString());
    }
  }

  static void setXp(int xp) {
    try {
      preferences!.setInt('xp', xp);
    } on Exception catch (ex) {
      // log("Hello " + ex.toString());
    }
  }

  static void setAudio(bool audioControl) {
    try {
      preferences!.setBool('audioControl', audioControl);
    } on Exception catch (ex) {
      // log("Hello " + ex.toString());
    }
  }
}

class AchievementList {
  final List<String> achieveItems = ['1st One', '4 in a Row!', 'GOLDen Man !'];
  final List<int> achieveItemsXP = [10, 40, 500];

  List<String>? getAchieveList() {
    return achieveItems;
  }

  List<int>? getAchieveXp() {
    return achieveItemsXP;
  }

  List<String> getString() {
    // this is where the mapping will be placed
    Map<String, int> stringMap = new Map();

    // and here the relationship between the dates and the meals is done
    for (var i = 0; i < achieveItems.length; i++)
      stringMap[achieveItems[i]] = achieveItemsXP[i];

    List<String> yourObjects = stringMap.keys.map((index) {
      return "$index: ${stringMap[index]} XP";
    }).toList();

    return yourObjects;
  }
}

class AllUtils {
  static Image? _image;

  static Future<bool> onWillPop(BuildContext context) async {
    // final dialogWidth =
    //     currentSize == ResponsiveLayoutSize.large ? 740.0 : 700.0;
    return (await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => Dialog(
                backgroundColor: Color.fromARGB(255, 214, 73, 73),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                child: SizedBox(
                  width: 700.0,
                  child: ResponsiveLayoutBuilder(
                      small: (_, child) => child!,
                      medium: (_, child) => child!,
                      large: (_, child) => child!,
                      child: (currentSize) {
                        final padding = currentSize ==
                                ResponsiveLayoutSize.large
                            ? const EdgeInsets.fromLTRB(48, 53, 48, 53)
                            : (currentSize == ResponsiveLayoutSize.medium
                                ? const EdgeInsets.fromLTRB(48, 54, 48, 53)
                                : const EdgeInsets.fromLTRB(20, 40, 20, 40));

                        final textStyle = (currentSize ==
                                    ResponsiveLayoutSize.large
                                ? PuzzleTextStyle.headline2
                                : (currentSize == ResponsiveLayoutSize.medium)
                                    ? PuzzleTextStyle.headline3
                                    : PuzzleTextStyle.headline3Soft)
                            .copyWith(
                                color: Colors.white,
                                fontFamily: 'GoogleSans',
                                fontStyle: FontStyle.normal);

                        final textStylebtn = (currentSize ==
                                    ResponsiveLayoutSize.large
                                ? PuzzleTextStyle.headline3Soft
                                : (currentSize == ResponsiveLayoutSize.medium)
                                    ? PuzzleTextStyle.headline4Soft
                                    : PuzzleTextStyle.headline4Soft)
                            .copyWith(
                                color: Colors.white,
                                fontFamily: 'GoogleSans',
                                fontStyle: FontStyle.normal);

                        final btnStyle = ButtonStyle(
                            padding: MaterialStateProperty.all(EdgeInsets.only(
                                left: 20.0, right: 20.0, bottom: 10, top: 10)),
                            textStyle: MaterialStateProperty.all(textStylebtn),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)))),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white),
                            shadowColor: MaterialStateProperty.all(
                                Color.fromARGB(255, 88, 6, 0)));

                        final btnStyleYes = btnStyle.copyWith(
                          backgroundColor: MaterialStateProperty.all(
                              Color.fromARGB(255, 155, 59, 59)),
                        );

                        final btnStyleNo = btnStyle.copyWith(
                          backgroundColor: MaterialStateProperty.all(
                              Color.fromARGB(255, 39, 161, 100)),
                        );

                        final textAlign = TextAlign.center;
                        final double gap =
                            currentSize == ResponsiveLayoutSize.large ? 25 : 20;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: padding,
                              child: AnimatedDefaultTextStyle(
                                style: textStyle,
                                duration:
                                    PuzzleThemeAnimationDuration.textStyle,
                                child: Center(
                                  child: Text(
                                    'This will destroy\nall your progress!',
                                    textAlign: textAlign,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TextButton(
                                  style: btnStyleNo,
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: new Text('No'),
                                ),
                                Gap(gap),
                                TextButton(
                                  style: btnStyleYes,
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: new Text('Yes'),
                                ),
                              ],
                            ),
                            Gap(gap),
                          ],
                        );
                      }),
                )))) ??
        false;
  }

  static Future<void> audioInit(_audioPlayer) async {
    // await _audioPlayer.setAsset('assets/audio/back_medium.mp3');
    unawaited(_audioPlayer!.setVolume(1.0));
    unawaited(_audioPlayer!.setLoopMode(LoopMode.one));
    try {
      unawaited(_audioPlayer!.play());
    } on Exception catch (_) {
      // log('Waiting for chrome permission');
    }
  }

  static Future<void> audioUpdate(
      _audioPlayer, String assetPath, bool loop) async {
    // if (Platform.isWindows) {
    //   _audioPlayer!.dispose();
    //   _audioPlayer = null;
    //   _audioPlayer = _audioPlayerFactory();
    //   async.unawaited(_audioPlayer!.setVolume(1));
    //   async.unawaited(_audioPlayer!.setLoopMode(LoopMode.one));
    //   try {
    //     async.unawaited(_audioPlayer!.play());
    //   } on Exception catch (_) {
    //     // log('Waiting for chrome permission');
    //   }
    // }

    await _audioPlayer!.setAsset(assetPath);
    loop
        ? unawaited(_audioPlayer!.setLoopMode(LoopMode.one))
        : unawaited(_audioPlayer!.setLoopMode(LoopMode.off));
  }

  // Function to parse image from the widget
  static Future<image.Image?>? getImageFromWidget(_globalKey) async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    // Size size = boundary.size;
    var img = await boundary.toImage();
    var byteData = await img.toByteData(format: ImageByteFormat.png);
    var pngBytes = byteData!.buffer.asUint8List();

    return image.decodeImage(pngBytes);
  }

  static Future<List<Widget>> parseWidget(
      size, _globalKey, _offset, tempBytes, _imageMain, context) async {
    // Make null before access; Useful for reloading
    List<Widget> _tileImageList = [];

    // Get painted image
    image.Image? _image = await getImageFromWidget(_globalKey);

    image.Image? tempCropTiles;

    double sizeTile = _TileSize.large;

    if (kIsWeb) {
    } else if (Platform.isAndroid || Platform.isIOS) {
      sizeTile = _TileSize.small;
    }

    // fix: For size exceeding max display width
    final screenWidth = MediaQuery.of(context).size.width;

    // fix: For size exceeding max display width
    if (screenWidth <= PuzzleBreakpoints.small) {
      sizeTile = min(_TileSize.small, (screenWidth - _offset) / size);
    } else if (screenWidth <= PuzzleBreakpoints.medium) {
      sizeTile = min(_TileSize.medium, (screenWidth - _offset) / size);
    } else if (screenWidth <= PuzzleBreakpoints.large) {
      sizeTile = min(_TileSize.large, (screenWidth - _offset) / size);
    } else {
      sizeTile = min(_TileSize.large, (screenWidth - _offset) / size);
    }

    var index = 0;

    // Crop image to cube and store as widget
    for (; index < size * size; index++) {
      Size sizeBox = Size(sizeTile, sizeTile);

      var offsetTemp = Offset(
        index % size * sizeBox.width,
        index ~/ size * sizeBox.height,
      );

      if (_imageMain != null) {
        tempCropTiles = image.copyCrop(
          _image!,
          offsetTemp.dx.round(),
          offsetTemp.dy.round(),
          sizeTile.toInt(),
          sizeTile.toInt(),
        );
        tempBytes = Uint8List.fromList(image.encodePng(tempCropTiles));

        _imageMain = Image.memory(
          tempBytes,
        );

        _tileImageList.add(ClipRRect(
          borderRadius: BorderRadius.circular(10), // Image border
          child: SizedBox.fromSize(
            size: const Size.fromRadius(100), // Image radius
            child: _imageMain,
          ),
        ));
      }
    }

    return _tileImageList;
  }

  static Future<ParseFileClass> parseFile(
      size, filePath, context, _offset, _globalKey) async {
    Image? _imageMain;

    if (kIsWeb) {
      var _bytes = Uint8List.fromList(filePath!.files[0].bytes as Uint8List);

      // image.Image _image = image.decodePng(File(filePath!.files[0].path as String).readAsBytesSync())!;
      _imageMain = Image.memory(_bytes);
    } else if (Platform.isAndroid || Platform.isIOS || Platform.isWindows) {
      // Android-specific code
      // iOS-specific code
      _imageMain = Image.file(File(filePath!.files[0].path!));
    } else {
      var _bytes = Uint8List.fromList(filePath!.files[0].bytes as Uint8List);

      // image.Image _image = image.decodePng(File(filePath!.files[0].path as String).readAsBytesSync())!;
      _imageMain = Image.memory(_bytes);
    }

    if (_imageMain == null) return ParseFileClass(Container(), _imageMain);

    // Make sure width is not greater than screen width
    // fix: For size exceeding max display width
    final screenWidth = MediaQuery.of(context).size.width - _offset;

    // First show the image in order to get get the image and crop
    const textStyle = TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 34,
      fontWeight: PuzzleFontWeight.bold,
    );
    Widget _paintWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            Padding(padding: EdgeInsets.all(10)),
            AnimatedDefaultTextStyle(
              style: textStyle,
              duration: PuzzleThemeAnimationDuration.textStyle,
              child: Text('Loading...'),
            ),
          ],
        ),
        RepaintBoundary(
          key: _globalKey,
          child: ResponsiveLayoutBuilder(
            large: (_, child) => Container(
              // color: Colors.red,
              padding: const EdgeInsets.all(10),
              height: min(_TileSize.large * size, screenWidth),
              width: min(_TileSize.large * size, screenWidth),
              child: _imageMain as Widget,
            ),
            medium: (_, child) => Container(
              // color: Colors.red,
              padding: const EdgeInsets.all(10),
              height: min(_TileSize.medium * size, screenWidth),
              width: min(_TileSize.medium * size, screenWidth),
              child: _imageMain as Widget,
            ),
            small: (_, child) => Container(
              // color: Colors.red,
              padding: const EdgeInsets.all(10),
              height: min(_TileSize.small * size, screenWidth),
              width: min(_TileSize.small * size, screenWidth),
              child: _imageMain as Widget,
            ),
          ),
        ),
      ],
    );

    return ParseFileClass(_paintWidget, _imageMain);
  }

  static Image? getImage() {
    return _image;
  }
}
