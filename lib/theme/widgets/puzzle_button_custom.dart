import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unpuzzle_it_abhi/colors/colors.dart';
import 'package:unpuzzle_it_abhi/theme/theme.dart';
import 'package:unpuzzle_it_abhi/typography/typography.dart';

/// {@template puzzle_button}
/// Displays the puzzle action button.
/// {@endtemplate}
class PuzzleButtonCustom extends StatelessWidget {
  /// {@macro puzzle_button}
  const PuzzleButtonCustom({
    Key? key,
    required this.child,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    // required this.width,
  }) : super(key: key);

  /// The background color of this button.
  /// Defaults to [PuzzleTheme.buttonColor].
  final Color? backgroundColor;

  /// The text color of this button.
  /// Defaults to [PuzzleColors.white].
  final Color? textColor;

  /// Called when this button is tapped.
  final VoidCallback? onPressed;

  /// The label of this button.
  final Widget child;

  // final double width;

  // final double height;

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);
    final buttonTextColor = textColor ?? PuzzleColors.white;
    final buttonBackgroundColor = backgroundColor ?? theme.buttonColor;

    return SizedBox(
      // width: width,
      // height: height,
      child: AnimatedTextButton(
        duration: PuzzleThemeAnimationDuration.textStyle,
        style: TextButton.styleFrom(
          alignment: Alignment.center,
          textStyle: PuzzleTextStyle.headline5,
          shape: CircleBorder(),
        ).copyWith(
          backgroundColor: MaterialStateProperty.all(buttonBackgroundColor),
          foregroundColor: MaterialStateProperty.all(buttonTextColor),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
