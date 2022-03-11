import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:unpuzzle_it_abhi/helpers/helpers.dart';
import 'package:unpuzzle_it_abhi/layout/layout.dart';

/// {@template splash}
/// Displays a splash screen as a menu
/// {@endtemplate}
class Loading extends StatefulWidget {
  /// {@macro splash}
  const Loading({
    Key? key,
    AudioPlayerFactory? audioPlayer,
    this.callback,
    required this.lottie,
    required this.lottieDuration,
    required this.backColor,
  })  : _audioPlayerFactory = audioPlayer ?? getAudioPlayer,
        super(key: key);

  final AudioPlayerFactory _audioPlayerFactory;

  final String lottie;

  final int lottieDuration;

  final Color backColor;

  /// Called when this button is tapped.
  final Function(int)? callback;

  @override
  State<Loading> createState() => _Loading();
}

class _Loading extends State<Loading> with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: widget.lottieDuration),
        upperBound: 1)
      ..forward()
      ..repeat();

    Timer(const Duration(milliseconds: 2000), () async {
      Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backColor,
      body: Center(
          child: ResponsiveLayoutBuilder(
        small: (_, child) => child!,
        medium: (_, child) => child!,
        large: (_, child) => child!,
        //flow: TILE Stack
        child: (_) => SingleChildScrollView(
          child: LayoutBuilder(builder: (context, constraints) {
            return SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ResponsiveLayoutBuilder(
                    small: (context, child) => Center(
                      child: SizedBox(
                        child: Center(
                          child: child,
                        ),
                      ),
                    ),
                    medium: (context, child) => Center(
                      child: child,
                    ),
                    large: (context, child) => SizedBox(
                      child: child,
                    ),
                    child: (currentSize) {
                      final widthImage =
                          (currentSize == ResponsiveLayoutSize.large
                              ? 300.0
                              : 250.0);

                      return Lottie.asset(widget.lottie,
                          controller: _controller, height: widthImage);
                      // Image(
                      //     height: widthImage,
                      //     image: new AssetImage(
                      //         "assets/images/splash/hello.gif"));
                    },
                  ),
                ],
              ),
            );
          }),
        ),
      )),
    );
  }
}
