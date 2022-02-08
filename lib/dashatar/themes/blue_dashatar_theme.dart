import 'package:flutter/material.dart';
import 'package:unpuzzle_it_abhi/colors/colors.dart';
import 'package:unpuzzle_it_abhi/dashatar/dashatar.dart';
import 'package:unpuzzle_it_abhi/l10n/l10n.dart';

/// {@template blue_dashatar_theme}
/// The blue dashatar puzzle theme.
/// {@endtemplate}
class BlueDashatarTheme extends DashatarTheme {
  /// {@macro blue_dashatar_theme}
  const BlueDashatarTheme() : super();

  @override
  String semanticsLabel(BuildContext context) =>
      context.l10n.dashatarBlueDashLabelText;

  @override
  bool get isCustomTheme => false;

  @override
  String get themeTitle => 'Simple Yet Complex!';

  @override
  Color get backgroundColor => PuzzleColors.bluePrimary;

  @override
  Color get defaultColor => PuzzleColors.blue90;

  @override
  Color get buttonColor => PuzzleColors.blue50;

  @override
  Color get menuInactiveColor => PuzzleColors.blue50;

  @override
  Color get countdownColor => PuzzleColors.blue50;

  @override
  String get themeAsset => 'assets/images/dashatar/gallery/blue.png';

  @override
  String get successThemeAsset => 'assets/images/dashatar/success/blue.png';

  @override
  String get audioControlOffAsset =>
      'assets/images/audio_control/blue_dashatar_off.png';

  @override
  String get audioAsset => 'assets/audio/blue.mp3';

  @override
  String get audioAssetBack => 'assets/audio/back_medium.mp3';

  @override
  // flow: TILE asset
  String get dashAssetsDirectory => 'assets/images/dashatar/blue/';
}
