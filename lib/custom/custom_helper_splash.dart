import 'package:flutter/material.dart';
import 'package:unpuzzle_it_abhi/layout/responsive_layout_builder.dart';
import 'package:unpuzzle_it_abhi/theme/theme.dart';

/// Displays the [AppDialog] above the current contents of the app.
/// Exclusively for Splash Screen 
Future<T?> showAppDialogCustomSplash<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = false,
  String barrierLabel = '',
}) =>
    showGeneralDialog<T>(
      transitionBuilder: (context, animation, secondaryAnimation, widget) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.decelerate,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: widget,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      barrierColor: const Color(0x66000000),
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => AppDialogCustomSplash(
        child: child,
      ),
    );


/// Displays the [AppDialog] above the current contents of the app.
class AppDialogCustomSplash extends StatelessWidget {
  /// {@macro app_dialog}
  const AppDialogCustomSplash({
    Key? key,
    required this.child,
  }) : super(key: key);

  /// The content of this dialog.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayoutBuilder(
      small: (_, __) => Material(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: child,
        ),
      ),
      medium: (_, child) => child!,
      large: (_, child) => child!,
      child: (currentSize) {
        // final dialogWidth =
        //     currentSize == ResponsiveLayoutSize.large ? 740.0 : 700.0;

        return Dialog(
          clipBehavior: Clip.hardEdge,
          backgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: child,
          ),
        );
      },
    );
  }
}
