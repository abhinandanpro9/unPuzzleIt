import 'package:flutter/material.dart';
import 'dart:async' as async;

class AchieveWidget extends StatefulWidget {
  const AchieveWidget({Key? key}) : super(key: key);

  @override
  State<AchieveWidget> createState() => _AchieveWidgetState();
}

class _AchieveWidgetState extends State<AchieveWidget>
    with SingleTickerProviderStateMixin {
  // Animation Controller
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  );
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: const Offset(1.5, 0.0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.elasticInOut,
  ));

  @override
  void initState() {
    super.initState();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SlideTransition(
        position: _offsetAnimation,
        child: Container(
          width: double.infinity,
          child: FlutterLogo(size: 150.0),
        ),
      ),
    );
  }
}
