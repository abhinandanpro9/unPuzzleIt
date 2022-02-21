import 'package:flutter/material.dart';
import 'package:unpuzzle_it_abhi/colors/colors.dart';
import 'package:unpuzzle_it_abhi/dashatar/dashatar.dart';
import 'package:unpuzzle_it_abhi/l10n/l10n.dart';

/// {@template green_dashatar_theme}
/// The green dashatar puzzle theme.
/// {@endtemplate}
class CustomDashatarTheme extends DashatarTheme {
  /// {@macro green_dashatar_theme}
  const CustomDashatarTheme() : super();

  @override
  String semanticsLabel(BuildContext context) =>
      context.l10n.dashatarGreenDashLabelText;

  @override
  String get themeTitle => 'Go Custom! Go Crazy!';

  @override
  bool get isCustomTheme => true;

  @override
  Color get backgroundColor => PuzzleColors.customPrimary;

  @override
  Color get defaultColor => PuzzleColors.custom90;

  @override
  Color get shareColor => PuzzleColors.custom90;

  @override
  Color get buttonColor => PuzzleColors.custom50;

  @override
  Color get menuInactiveColor => PuzzleColors.custom50;

  @override
  Color get countdownColor => PuzzleColors.custom50;

  @override
  String get themeAsset => 'assets/images/dashatar/gallery/custom.png';

  @override
  String get successThemeAsset => 'assets/images/dashatar/success/custom.png';

  @override
  String get audioControlOffAsset =>
      'assets/images/audio_control/green_dashatar_off.png';

  @override
  String get audioAsset => 'assets/audio/custom.mp3';

  @override
  String get audioAssetBack => 'assets/audio/back_custom.mp3';

  @override
  String get dashAssetsDirectory => 'assets/images/dashatar/custom/';
}
