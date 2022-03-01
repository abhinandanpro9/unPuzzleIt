import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:just_audio/just_audio.dart';
import 'package:image/image.dart' as image;
import 'package:flutter/material.dart';
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

  getWiget(){
    return this._paintWidget;
  }

  getImage(){
    return this._imageMain;
  }
}

class AllUtils {
  static Image? _image;

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
