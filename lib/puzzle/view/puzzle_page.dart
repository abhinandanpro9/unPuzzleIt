// ignore_for_file: unused_field

import 'dart:async' as async;
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:confetti/confetti.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image/image.dart' as image;
import 'package:just_audio/just_audio.dart';
import 'package:rainbow_color/rainbow_color.dart';
import 'package:unpuzzle_it_abhi/audio_control/audio_control.dart';
import 'package:unpuzzle_it_abhi/colors/colors.dart';
import 'package:unpuzzle_it_abhi/custom/custom.dart';
import 'package:unpuzzle_it_abhi/dashatar/dashatar.dart';
import 'package:unpuzzle_it_abhi/flames/flames.dart';
import 'package:unpuzzle_it_abhi/helpers/helpers.dart';
import 'package:unpuzzle_it_abhi/l10n/l10n.dart';
import 'package:unpuzzle_it_abhi/layout/layout.dart';
import 'package:unpuzzle_it_abhi/models/models.dart';
import 'package:unpuzzle_it_abhi/puzzle/puzzle.dart';
import 'package:unpuzzle_it_abhi/theme/theme.dart';
import 'package:unpuzzle_it_abhi/timer/timer.dart';
import 'package:unpuzzle_it_abhi/typography/typography.dart';

// import '../../simple/simple.dart';

/// {@template puzzle_page}
/// The root page of the puzzle UI.
///
/// Builds the puzzle based on the current [PuzzleTheme]
/// from [ThemeBloc].
/// {@endtemplate}
class PuzzlePage extends StatelessWidget {
  /// {@macro puzzle_page}
  const PuzzlePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => DashatarThemeBloc(
            themes: const [
              // todo: modified
              // flow: THEME handles theme changer as part of dashatar theme bloc
              BlueDashatarTheme(),
              // new const DashatarTheme(),
              PathDashatarTheme(),
              CustomDashatarTheme(),
            ],
          ),
        ),
        BlocProvider(
          create: (_) => DashatarPuzzleBloc(
            secondsToBegin: 3,
            ticker: const Ticker(),
          ),
        ),
        BlocProvider(
          create: (context) => ThemeBloc(
            initialThemes: [
              // todo: modified
              // flow: THEME controls the theme selecter tab at top
              // const SimpleTheme(),
              context.read<DashatarThemeBloc>().state.theme,
              // context.read<DashatarThemeBloc>().state.theme,
            ],
          ),
        ),
        BlocProvider(
          create: (_) => TimerBloc(
            ticker: const Ticker(),
          ),
        ),
        BlocProvider(
          create: (_) => AudioControlBloc(),
        ),
      ],
      child: Stack(children: [
        GameWidget(
          game: ParallaxBackground(),
        ),
        PuzzleView(),
        // Container(
        //   width: 100,
        //   height: 100,
        //   child: GameWidget(
        //     game: FlameCustomCharacter(),
        //   ),
        // )
      ]),
    );
  }
}

/// {@template puzzle_view}
/// Displays the content for the [PuzzlePage].
/// {@endtemplate}
class PuzzleView extends StatefulWidget {
  /// {@macro puzzle_view}
  PuzzleView({Key? key}) : super(key: key);

  final Rainbow blueRainbow =
      Rainbow(rangeStart: 0.0, rangeEnd: 10.0, spectrum: [
    PuzzleColors.customPrimary,
    Color.fromARGB(255, 0, 23, 100),
    Color.fromARGB(255, 27, 0, 100),
    PuzzleColors.pathPrimary,
    Color.fromARGB(255, 0, 77, 45),
    Color.fromARGB(255, 1, 51, 53),
    PuzzleColors.customPrimary,
  ]);

  @override
  _PuzzleView createState() => _PuzzleView();
}

class _PuzzleView extends State<PuzzleView>
    with SingleTickerProviderStateMixin {
  late AnimationController _blueController;
  late Animation<double> _blueAnim;
  async.Timer? _startPuzzleTimer;
  bool isStartCalled = false;

  // animate a double from 0 to 10
  Animatable<double> blueBgValue = Tween<double>(begin: 0.0, end: 10.0);

  @override
  void initState() {
    // create:
    if (!isStartCalled) {
      _startPuzzleTimer =
          async.Timer(const Duration(milliseconds: 100), () async {
        await showAppDialogCustom<void>(
          context: context,
          child: MultiBlocProvider(
            providers: [
              BlocProvider.value(
                value: context.read<DashatarThemeBloc>(),
              ),
            ],
            child: const SplashScreen(),
          ),
        );
      });

      isStartCalled = true;
    }

    super.initState();
    _blueController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )
      ..forward()
      ..repeat();
    setState(() {
      _blueAnim = blueBgValue.animate(_blueController);
    });
  }

  @override
  void dispose() {
    _blueController.dispose();
    _startPuzzleTimer!.cancel();
    super.dispose();
  }

  // Widget builder for simple, path and custom themes
  Widget puzzleViewChooser(PuzzleTheme theme, Widget _blocListener) {
    // custom theme build
    if (theme.isCustomTheme) {
      return AnimatedContainer(
          duration: PuzzleThemeAnimationDuration.backgroundColorChange,
          decoration: BoxDecoration(color: theme.backgroundColor),
          child: AnimatedBuilder(
              animation: _blueController,
              builder: (context, child) {
                return Container(
                  child: new Stack(
                    children: <Widget>[
                      _blocListener,
                    ],
                  ),
                );
              }));
    } else if (theme.isPathTheme) {
      return AnimatedContainer(
          duration: PuzzleThemeAnimationDuration.backgroundColorChange,
          decoration: BoxDecoration(color: Colors.transparent),
          child: _blocListener); // path theme build
    } else {
      return AnimatedContainer(
        duration: PuzzleThemeAnimationDuration.backgroundColorChange,
        decoration: BoxDecoration(color: theme.backgroundColor),
        child: AnimatedBuilder(
            animation: _blueController,
            builder: (context, child) {
              return Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                        widget.blueRainbow[_blueAnim.value],
                        widget.blueRainbow[(50.0 + _blueAnim.value) %
                            widget.blueRainbow.rangeEnd]
                      ])),
                  child: _blocListener);
            }),
      ); // simple theme
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);

    // context.read<DashatarThemeBloc>().add(DashatarThemeChanged(themeIndex: 0));
    // final themeState = context.watch<DashatarThemeBloc>().state;
    // final activeTheme = themeState.theme;

    /// Shuffle only if the current theme is Simple.
    // final shufflePuzzle = theme is SimpleTheme; //controls if shuffle by default

    //flow: PUZZ handles loading of puzzle theme view
    return Scaffold(
      body: AnimatedContainer(
          duration: PuzzleThemeAnimationDuration.backgroundColorChange,
          decoration: BoxDecoration(color: Colors.transparent),
          child: AnimatedBuilder(
              animation: _blueController,
              builder: (context, child) {
                return Container(
                  decoration: (theme.isPathTheme)
                      ? BoxDecoration(color: Colors.transparent)
                      : (!theme.isCustomTheme)
                          ? BoxDecoration(color: theme.backgroundColor)
                          : BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                  widget.blueRainbow[_blueAnim.value],
                                  widget.blueRainbow[(50.0 + _blueAnim.value) %
                                      widget.blueRainbow.rangeEnd]
                                ])),
                  child: new Stack(
                    children: <Widget>[
                      BlocListener<DashatarThemeBloc, DashatarThemeState>(
                        listener: (context, state) {
                          final dashatarTheme =
                              context.read<DashatarThemeBloc>().state.theme;
                          context
                              .read<ThemeBloc>()
                              .add(ThemeUpdated(theme: dashatarTheme));
                        },
                        child: MultiBlocProvider(
                          providers: [
                            BlocProvider(
                              create: (context) => TimerBloc(
                                ticker: const Ticker(),
                              ),
                            ),
                            BlocProvider(
                              create: (context) =>
                                  PuzzleBloc(4) // flow: PUZZ control grid size
                                    ..add(
                                      const PuzzleInitialized(
                                        shufflePuzzle:
                                            false, // todo: modified shufflePuzzle
                                        tileSize: 4,
                                      ),
                                    ),
                            ),
                          ],
                          child: const _Puzzle(
                            key: Key('puzzle_view_puzzle'),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              })),
      backgroundColor: Colors.transparent,
    );

    // return Scaffold(
    //   body: AnimatedCrossFade(
    //     duration: const Duration(seconds: 3),
    //     firstChild: _simpleTheme,
    //     secondChild: _pathTheme,
    //         // puzzleViewChooser(theme, _customTheme, _pathTheme, _simpleTheme),
    //     crossFadeState:
    //         !theme.isCustomTheme ? CrossFadeState.showFirst : CrossFadeState.showSecond,
    //   ),
    // );
  }
}

class _Puzzle extends StatefulWidget {
  const _Puzzle({Key? key}) : super(key: key);

  @override
  _PuzzleCreate createState() => _PuzzleCreate();
}

class _PuzzleCreate extends State<_Puzzle> {
  late final AudioPlayer _player;
  late Timer timer;
  late String activeThemeTemp = '';

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    // create: audio AudioControlListener can be used
    _init();
  }

  Future<void> _update(String assetPath) async {
    await _player.setAsset(assetPath);
  }

  Future<void> _init() async {
    await _player.setAsset('assets/audio/back_medium.mp3');
    async.unawaited(_player.setVolume(1));
    async.unawaited(_player.setLoopMode(LoopMode.one));
    try {
      // async.unawaited(_player.play());
    } on Exception catch (_) {
      // log('Waiting for chrome permission');
    }
    // timer = Timer.periodic(
    //   const Duration(seconds: 1),
    //   (Timer t) async => {_update(t)},
    // );
  }

  // Future<void> _unInit() async {
  //  if(timer.isActive){timer.cancel();}
  // }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // todo: unused modified
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);
    final state = context.select((PuzzleBloc bloc) => bloc.state);
    final themeState = context.watch<DashatarThemeBloc>().state;
    final activeThemeAsset = themeState.theme.audioAssetBack;
    final audioState = context.watch<AudioControlBloc>().state.muted;

    if (activeThemeTemp != activeThemeAsset) {
      activeThemeTemp = activeThemeAsset;
      _update(activeThemeAsset);
    }
    async.unawaited(_player.setVolume((audioState) ? 0 : 1));

    // final tileSize = context.select((PuzzleBloc bloc) => bloc.tileSize);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // todo: modified
            // flow: unknown
            // if (theme is SimpleTheme)
            theme.layoutDelegate.backgroundBuilder(state),
            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  children: const [
                    PuzzleHeader(),
                    PuzzleSections(),
                  ],
                ),
              ),
            ),
            // todo: modified
            // flow : THEME Dashatar Theme selector at bottom page
            theme.layoutDelegate.backgroundBuilder(state),
          ],
        );
      },
    );
  }
}

/// {@template puzzle_header}
/// Displays the header of the puzzle.
/// {@endtemplate}
@visibleForTesting
class PuzzleHeader extends StatelessWidget {
  /// {@macro puzzle_header}
  const PuzzleHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ResponsiveLayoutBuilder(
        small: (context, child) => Stack(
          children: [
            const Align(
              child: PuzzleLogo(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 34),
                child: AudioControl(key: audioControlKey),
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
              PuzzleLogo(),
              PuzzleMenu(),
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
              PuzzleLogo(),
              PuzzleMenu(),
            ],
          ),
        ),
      ),
    );
  }
}

/// {@template puzzle_logo}
/// Displays the logo of the puzzle.
/// {@endtemplate}
@visibleForTesting
class PuzzleLogo extends StatefulWidget {
  /// {@macro puzzle_logo}
  const PuzzleLogo({Key? key}) : super(key: key);
  @override
  _PuzzleLogo createState() => _PuzzleLogo();
}

class _PuzzleLogo extends State<PuzzleLogo> {
  late final async.Timer _startTutorialTimer;

  Future<void> callHelp(String textHelp) async {
    _startTutorialTimer =
        async.Timer(const Duration(milliseconds: 500), () async {
      await showAppDialogCustom<void>(
        barrierDismissible: true,
        context: context,
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
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);
    final themeState = context.watch<DashatarThemeBloc>().state;
    final activeTheme = themeState.theme;

    // Call help
    if (activeTheme.isCustomTheme) {
      callHelp(context.l10n.customHelp);
    } else if (activeTheme.isPathTheme) {
      callHelp(context.l10n.pathHelp);
    }

    return AppFlutterLogo(
      key: puzzleLogoKey,
      isColored: theme.isLogoColored,
    );
  }
}

/// {@template puzzle_sections}
/// Displays start and end sections of the puzzle.
/// {@endtemplate}
class PuzzleSections extends StatefulWidget {
  /// {@macro puzzle_sections}
  const PuzzleSections({Key? key}) : super(key: key);

  @override
  _PuzzleSections createState() => _PuzzleSections();
}

// Used to draw star confetti
Path drawStar(Size size) {
  // Method to convert degree to radians
  double degToRad(double deg) => deg * (pi / 180.0);

  const numberOfPoints = 5;
  final halfWidth = size.width / 2;
  final externalRadius = halfWidth;
  final internalRadius = halfWidth / 2.5;
  final degreesPerStep = degToRad(360 / numberOfPoints);
  final halfDegreesPerStep = degreesPerStep / 2;
  final path = Path();
  final fullAngle = degToRad(360);
  path.moveTo(size.width, halfWidth);

  for (double step = 0; step < fullAngle; step += degreesPerStep) {
    path.lineTo(halfWidth + externalRadius * cos(step),
        halfWidth + externalRadius * sin(step));
    path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * sin(step + halfDegreesPerStep));
  }
  path.close();
  return path;
}

class _PuzzleSections extends State<PuzzleSections> {
  // Animation controller
  late ConfettiController _controllerCenter;
  late ConfettiWidget _starBlast = ConfettiWidget(
    confettiController: _controllerCenter,
    maxBlastForce: 100,
    minBlastForce: 75,
    gravity: 0.1,
    blastDirectionality: BlastDirectionality
        .explosive, // don't specify a direction, blast randomly
    shouldLoop: true, // start again as soon as the animation is finished
    colors: const [
      Colors.green,
      Colors.blue,
      Colors.pink,
      Colors.orange,
      Colors.purple
    ], // manually specify the colors to be used
    createParticlePath: drawStar, // define a custom shape/path.
  );

  @override
  void initState() {
    super.initState();
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 10));
  }

  @override
  void dispose() {
    super.dispose();
  }

  // int playConfetti() {
  //   _controllerCenter.play();

  //   return 100;
  // }

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);
    final state = context.select((PuzzleBloc bloc) => bloc.state);
    final numberOfilesLeft =
        state.puzzle.tiles.length - state.numberOfCorrectTiles - 1;
    final tileState = state.puzzleStatus.name;

    if (numberOfilesLeft == 0 &&
        (tileState == PuzzleStatus.reversing.name ||
            tileState == PuzzleStatus.reversed.name ||
            tileState == PuzzleStatus.complete.name)) {
      _controllerCenter.play();
    } else {
      if (_controllerCenter.state == ConfettiControllerState.playing) {
        _controllerCenter.stop();
      }
    }

    return ResponsiveLayoutBuilder(
      small: (context, child) => Column(
        children: [
          _starBlast,
          theme.layoutDelegate.startSectionBuilder(state),
          const PuzzleMenu(),
          const PuzzleBoard(),
          theme.layoutDelegate.endSectionBuilder(state),
          _starBlast,
        ],
      ),
      medium: (context, child) => Column(
        children: [
          _starBlast,
          theme.layoutDelegate.startSectionBuilder(state),
          const PuzzleBoard(),
          theme.layoutDelegate.endSectionBuilder(state),
          _starBlast,
        ],
      ),
      large: (context, child) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _starBlast,
          Expanded(
            child: theme.layoutDelegate.startSectionBuilder(state),
          ),
          const PuzzleBoard(),
          Expanded(
            child: theme.layoutDelegate.endSectionBuilder(state),
          ),
          _starBlast,
        ],
      ),
    );
  }
}

abstract class _TileSize {
  static double small = 75;
  static double medium = 100;
  static double large = 112;
}

/// {@template puzzle_board}
/// Displays the board of the puzzle.
/// {@endtemplate}
@visibleForTesting
// flow: MAIN PUZZ TILE puzzle board
class PuzzleBoard extends StatefulWidget {
  /// {@macro puzzle_board}
  const PuzzleBoard({Key? key}) : super(key: key);

  @override
  _PuzzleBoard createState() => _PuzzleBoard();
}

class _PuzzleBoard extends State<PuzzleBoard> {
  final double _offset = 20; // Controls the tile offset
  final GlobalKey _globalKey = GlobalKey();
  FilePickerResult? filePath;
  bool _isLoading = true;
  bool _userAborted = false;
  bool _customPuzzleChange = false;
  Image? _imageMain;
  late Uint8List tempBytes;
  late Widget _paintWidget = RepaintBoundary(
    key: _globalKey,
    child: Container(
      // color: Colors.red,
      padding: const EdgeInsets.all(10),
      height: _TileSize.large,
      width: _TileSize.large,
      child: Image(
        image: new AssetImage('assets/images/dashatar/custom/13.png'),
      ),
    ),
  );
  bool _isImageLoaded = false;
  bool _isAllSuccess = false;
  List<Widget> _tileImageList = [];
  late Widget widgetDummy = RepaintBoundary(
    key: _globalKey,
    child: Container(
      // color: Colors.red,
      padding: const EdgeInsets.all(10),
      height: _TileSize.large,
      width: _TileSize.large,
      child: Image(
        image: new AssetImage('assets/images/dashatar/custom/13.png'),
      ),
    ),
  );
  Image _tileDummy =
      Image(image: new AssetImage('assets/images/dashatar/custom/13.png'));

  @override
  void initState() {
    super.initState();
  }

  // Function to pick file
  Future<void> _pickFiles(int size, bool customPuzzleChange) async {
    filePath = null;

    // File picker
    try {
      filePath = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        onFileLoading: (FilePickerStatus status) => print(status),
        allowedExtensions: ['jpg', 'png'],
      );
    } on PlatformException catch (e) {
      dev.log('Unsupported operation' + e.toString());
    } catch (e) {
      dev.log(e.toString());
    }

    if (filePath != null)
      // Parse file
      _parseFile(size.toDouble(), customPuzzleChange);

    // Set state and return
    if (!mounted) return;
  }

  // Function to parse image from the widget
  Future<image.Image?>? _getImageFromWidget() async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    // Size size = boundary.size;
    var img = await boundary.toImage();
    var byteData = await img.toByteData(format: ImageByteFormat.png);
    var pngBytes = byteData!.buffer.asUint8List();

    return image.decodeImage(pngBytes);
  }

  // Function to parse image from the widget and split to tiles
  Future<void> _parseWidget(int size) async {
    if (_imageMain == null) return;
    // Make null before access; Useful for reloading
    _tileImageList = [];

    // Get painted image
    image.Image? _image = await _getImageFromWidget();

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

      setState(() {
        dev.log('crop success');
        _isImageLoaded = false;
        _isAllSuccess = true;
      });
    }
  }

  // Function to parse the file and paint on canvas
  Future<void> _parseFile(double size, bool customPuzzleChange) async {
    if (filePath == null) return;

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

    if (_imageMain == null) return;

    // Make sure width is not greater than screen width
    // fix: For size exceeding max display width
    final screenWidth = MediaQuery.of(context).size.width - _offset;

    // First show the image in order to get get the image and crop
    const textStyle = TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 34,
      fontWeight: PuzzleFontWeight.bold,
    );
    _paintWidget = Column(
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

    // Wait for some time and then post update
    async.Timer(const Duration(seconds: 2), () async {
      setState(() {
        _isImageLoaded = true;
      });
    });

    setState(() {
      dev.log('image fetch success');
      _customPuzzleChange = customPuzzleChange;
      // _isImageLoaded = true;
    });

    // _imageMain = Image.file(File(filePath!.files.single.path as String));
    // final file = await File('$documentPath/images/foo.jpg').create(recursive: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);
    final puzzle = context.select((PuzzleBloc bloc) => bloc.state.puzzle);
    final customPuzzleChange =
        context.select((PuzzleBloc bloc) => bloc.state.customPuzzleChange);
    var _checkForIndex = puzzle.tiles.length != _tileImageList.length;
    final size = puzzle.getDimension();

    if (size == 0) return const CircularProgressIndicator();

    if (_isImageLoaded == true) {
      _parseWidget(size);
    } else if ((_checkForIndex && _isAllSuccess && theme.isCustomTheme)) {
      _isAllSuccess = false;
      _parseFile(size.toDouble(), customPuzzleChange);
    } else if (theme.isCustomTheme &&
        (_customPuzzleChange != customPuzzleChange)) {
      _isAllSuccess = false;
      _pickFiles(size, customPuzzleChange);
    }

    // if (false == theme.isCustomTheme) {
    //   _isAllSuccess=false;
    //   _tileImageList = [];
    //   filePath = null;
    // }

    if (true == theme.isCustomTheme &&
        filePath == null &&
        _isImageLoaded == false &&
        _tileImageList.length == 0) {
      // _pickFiles(size, customPuzzleChange);
    } else {
      // _imageMain = null;
      _isImageLoaded = false;
      _isLoading = false;
      _userAborted = filePath == null;
    }

    return PuzzleKeyboardHandler(
      child: BlocListener<PuzzleBloc, PuzzleState>(
        listener: (context, state) {
          if ((theme.hasTimer && state.puzzleStatus == PuzzleStatus.complete) ||
              (theme.hasTimer && state.puzzleStatus == PuzzleStatus.reversed)) {
            // create:
            context.read<TimerBloc>().add(const TimerStopped());
            context.read<DashatarPuzzleBloc>().add(
                  const DashatarCountdownReverseStopped(),
                );
          } else if (theme.hasTimer &&
              state.puzzleStatus == PuzzleStatus.spam) {
            context.read<TimerBloc>().add(const TimerStopped());
            context.read<DashatarPuzzleBloc>().add(
                  const DashatarCountdownReverseStopped(),
                );
          }
        },
        // flow: TILE 1. map tiles to key.
        // Calls exactly times of size.
        // Each calls create a new tile
        child: (false == theme.isCustomTheme ||
                (true == _isAllSuccess && true == theme.isCustomTheme))
            ? theme.layoutDelegate.boardBuilder(
                size,
                puzzle.tiles
                    .map(
                      (tile) => _PuzzleTile(
                        key: Key('puzzle_tile_${tile.value.toString()}'),
                        tile: tile,
                        tileImage: (_tileImageList.isEmpty ||
                                theme.isCustomTheme == false)
                            ? _tileDummy
                            : _checkForIndex
                                ? widgetDummy
                                : _tileImageList[tile.value - 1],
                      ),
                    )
                    .toList(),
              )
            : _paintWidget,
      ),
    );
  }
}

class _PuzzleTile extends StatelessWidget {
  const _PuzzleTile({
    Key? key,
    required this.tile,
    required this.tileImage,
  }) : super(key: key);

  /// The tile to be displayed.
  final Tile tile;

  //For Custom Theme
  final Widget tileImage;

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);
    final state = context.select((PuzzleBloc bloc) => bloc.state);

    // flow: TILE 2.
    return tile.isWhitespace
        ? (theme.isPathTheme)
            ? theme.layoutDelegate.tileBuilder(
                tile,
                state,
                tileImage,
              )
            : theme.layoutDelegate.whitespaceTileBuilder()
        : theme.layoutDelegate.tileBuilder(
            tile,
            state,
            tileImage,
          );
  }
}

/// {@template puzzle_menu}
/// Displays the menu of the puzzle.
/// {@endtemplate}
@visibleForTesting
class PuzzleMenu extends StatelessWidget {
  /// {@macro puzzle_menu}
  const PuzzleMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final themes = context.select((ThemeBloc bloc) => bloc.state.themes);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // flow: MENU at top
        // ...List.generate(
        //   themes.length,
        //   (index) => PuzzleMenuItem(
        //     theme: themes[index],
        //     themeIndex: index,
        //   ),
        // ),
        ResponsiveLayoutBuilder(
          small: (_, child) => const SizedBox(),
          medium: (_, child) => child!,
          large: (_, child) => child!,
          child: (currentSize) {
            return Row(
              children: [
                const Gap(44),
                AudioControl(
                  key: audioControlKey,
                )
              ],
            );
          },
        ),
      ],
    );
  }
}

/// {@template puzzle_menu_item}
/// Displays the menu item of the [PuzzleMenu].
/// {@endtemplate}
@visibleForTesting
class PuzzleMenuItem extends StatelessWidget {
  /// {@macro puzzle_menu_item}
  const PuzzleMenuItem({
    Key? key,
    required this.theme,
    required this.themeIndex,
  }) : super(key: key);

  /// The theme corresponding to this menu item.
  final PuzzleTheme theme;

  /// The index of [theme] in [ThemeState.themes].
  final int themeIndex;

  @override
  Widget build(BuildContext context) {
    final currentTheme = context.select((ThemeBloc bloc) => bloc.state.theme);
    final isCurrentTheme = theme == currentTheme;

    return ResponsiveLayoutBuilder(
      small: (_, child) => Column(
        children: [
          Container(
            width: 100,
            height: 40,
            decoration: isCurrentTheme
                ? BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 2,
                        color: currentTheme.menuUnderlineColor,
                      ),
                    ),
                  )
                : null,
            child: child,
          ),
        ],
      ),
      medium: (_, child) => child!,
      large: (_, child) => child!,
      child: (currentSize) {
        final leftPadding =
            themeIndex > 0 && currentSize != ResponsiveLayoutSize.small
                ? 40.0
                : 0.0;

        return Padding(
          padding: EdgeInsets.only(left: leftPadding),
          child: Tooltip(
            message:
                theme != currentTheme ? context.l10n.puzzleChangeTooltip : '',
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
              ).copyWith(
                overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
              onPressed: () {
                // Ignore if this theme is already selected.
                if (theme == currentTheme) {
                  return;
                }

                // Update the currently selected theme.
                context
                    .read<ThemeBloc>()
                    .add(ThemeChanged(themeIndex: themeIndex));

                // Reset the timer of the currently running puzzle.
                context.read<TimerBloc>().add(const TimerReset());

                // Stop the Dashatar countdown if it has been started.
                context.read<DashatarPuzzleBloc>().add(
                      const DashatarCountdownStopped(),
                    );
                var tileSize =
                    context.watch<PuzzleBloc>().tileSize; // doesnt work
                // Initialize the puzzle board for the newly selected theme.
                context.read<PuzzleBloc>().add(
                      PuzzleInitialized(
                        // todo: modified
                        // flow: PUZZ default puzzle shuffle or not
                        shufflePuzzle: false,
                        tileSize:
                            (tileSize == 0) ? 4 : tileSize, // create: tileSize
                      ),
                    );
              },
              child: AnimatedDefaultTextStyle(
                duration: PuzzleThemeAnimationDuration.textStyle,
                style: PuzzleTextStyle.headline5.copyWith(
                  color: isCurrentTheme
                      ? currentTheme.menuActiveColor
                      : currentTheme.menuInactiveColor,
                ),
                child: Text(theme.name),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The global key of [PuzzleLogo].
///
/// Used to animate the transition of [PuzzleLogo] when changing a theme.
final puzzleLogoKey = GlobalKey(debugLabel: 'puzzle_logo');

/// The global key of [PuzzleName].
///
/// Used to animate the transition of [PuzzleName] when changing a theme.
final puzzleNameKey = GlobalKey(debugLabel: 'puzzle_name');

/// The global key of [PuzzleTitle].
///
/// Used to animate the transition of [PuzzleTitle] when changing a theme.
final puzzleTitleKey = GlobalKey(debugLabel: 'puzzle_title');

/// The global key of [NumberOfMovesAndTilesLeft].
///
/// Used to animate the transition of [NumberOfMovesAndTilesLeft]
/// when changing a theme.
final numberOfMovesAndTilesLeftKey =
    GlobalKey(debugLabel: 'number_of_moves_and_tiles_left');

/// The global key of [AudioControl].
///
/// Used to animate the transition of [AudioControl]
/// when changing a theme.
final audioControlKey = GlobalKey(debugLabel: 'audio_control');
