import 'package:flutter/material.dart';
import 'package:unpuzzle_it_abhi/colors/colors.dart';
import 'package:unpuzzle_it_abhi/dashatar/dashatar.dart';
import 'package:unpuzzle_it_abhi/l10n/l10n.dart';

/// {@template green_dashatar_theme}
/// The green dashatar puzzle theme.
/// {@endtemplate}
class PathDashatarTheme extends DashatarTheme {
  /// {@macro green_dashatar_theme}
  const PathDashatarTheme() : super();

  @override
  String semanticsLabel(BuildContext context) =>
      context.l10n.dashatarGreenDashLabelText;

  @override
  bool get isCustomTheme => false;

  @override
  bool get isPathTheme => true;

  @override
  String get themeTitle => 'Lost of Track!';

  @override
  Color get backgroundColor => PuzzleColors.pathPrimary;

  @override
  Color get defaultColor => PuzzleColors.path90;

  @override
  Color get buttonColor => PuzzleColors.path50;

  @override
  Color get menuInactiveColor => PuzzleColors.path50;

  @override
  Color get countdownColor => PuzzleColors.path50;

  @override
  String get themeAsset => 'assets/images/dashatar/gallery/path.png';

  @override
  String get successThemeAsset => 'assets/images/dashatar/success/path.png';

  @override
  String get audioControlOffAsset =>
      'assets/images/audio_control/yellow_dashatar_off.png';

  @override
  String get audioAsset => 'assets/audio/path.mp3';

  @override
  String get audioAssetBack => 'assets/audio/back_path.mp3';

  @override
  String get dashAssetsDirectory => 'assets/images/dashatar/path/';
}
