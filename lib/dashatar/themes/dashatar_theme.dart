import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:unpuzzle_it_abhi/colors/colors.dart';
import 'package:unpuzzle_it_abhi/dashatar/dashatar.dart';
import 'package:unpuzzle_it_abhi/layout/layout.dart';
import 'package:unpuzzle_it_abhi/models/models.dart';
import 'package:unpuzzle_it_abhi/theme/theme.dart';

/// {@template dashatar_theme}
/// The dashatar puzzle theme.
/// {@endtemplate}
abstract class DashatarTheme extends PuzzleTheme {
  /// {@macro dashatar_theme}
  const DashatarTheme() : super();

  String get themeTitle => 'Dashatar';

  @override
  String get name => 'Dashatar';

  @override
  String get audioControlOnAsset =>
      'assets/images/audio_control/dashatar_on.png';

  @override
  bool get hasTimer => true;

  @override
  Color get nameColor => PuzzleColors.white;

  @override
  Color get titleColor => PuzzleColors.white;

  @override
  Color get hoverColor => PuzzleColors.black2;

  @override
  Color get pressedColor => PuzzleColors.white2;

  @override
  bool get isLogoColored => false;

  @override
  bool get isCustomTheme => false;

  @override
  bool get isPathTheme => false;

  @override
  Color get menuActiveColor => PuzzleColors.white;

  @override
  Color get menuUnderlineColor => PuzzleColors.white;

  @override
  List<int> get pathMap => [];

  @override
  PuzzleLayoutDelegate get layoutDelegate =>
      const DashatarPuzzleLayoutDelegate();

  /// The semantics label of this theme.
  String semanticsLabel(BuildContext context);

  /// The text color of the countdown timer.
  Color get countdownColor;

  /// The path to the image asset of this theme.
  ///
  /// This asset is shown in the Dashatar theme picker.
  String get themeAsset;

  /// The path to the success image asset of this theme.
  ///
  /// This asset is shown in the success state of the Dashatar puzzle.
  String get successThemeAsset;

  /// The path to the audio asset of this theme.
  String get audioAsset;

  /// The path to the directory with dash assets for all puzzle tiles.
  String get dashAssetsDirectory;

  /// The path to the dash asset for the given [tile].
  ///
  /// The puzzle consists of 15 Dash tiles which correct board positions
  /// are as follows:
  ///
  ///  1   2   3   4
  ///  5   6   7   8
  ///  9  10  11  12
  /// 13  14  15
  ///
  /// The dash asset for the i-th tile may be found in the file i.png.
  /// flow: TILE 5. asset load
  String dashAssetForTile(Tile tile) =>
      p.join(dashAssetsDirectory, '${tile.value.toString()}.png');

  String get audioAssetBack;

  @override
  List<Object?> get props => [
        name,
        themeTitle,
        hasTimer,
        nameColor,
        titleColor,
        backgroundColor,
        defaultColor,
        shareColor,
        buttonColor,
        hoverColor,
        pressedColor,
        isLogoColored,
        menuActiveColor,
        menuUnderlineColor,
        menuInactiveColor,
        audioControlOnAsset,
        audioControlOffAsset,
        layoutDelegate,
        countdownColor,
        themeAsset,
        successThemeAsset,
        audioAsset,
        dashAssetsDirectory,
        audioAssetBack,
        pathMap
      ];
}
