import 'package:flutter/material.dart';
import 'package:unpuzzle_it_abhi/typography/typography.dart';

class AchieveWidget extends StatefulWidget {
  AchieveWidget(this.s, {Key? key}) : super(key: key);

  String s;

  @override
  State<AchieveWidget> createState() => _AchieveWidgetState();
}

class _AchieveWidgetState extends State<AchieveWidget>
    with SingleTickerProviderStateMixin {
  // Animation Controller
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 4),
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
    final double pad = 25;
    final textStyle = (PuzzleTextStyle.headline4)
        .copyWith(color: Colors.yellowAccent, shadows: <Shadow>[
      Shadow(
        offset: Offset(5.0, 5.0),
        blurRadius: 3.0,
        color: Color.fromARGB(255, 0, 0, 0),
      ),
      Shadow(
        offset: Offset(5.0, 5.0),
        blurRadius: 8.0,
        color: Color.fromARGB(125, 0, 0, 255),
      ),
    ]);

    return Center(
      child: SlideTransition(
        position: _offsetAnimation,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding:
                  EdgeInsets.only(left: pad, right: pad, top: pad, bottom: pad),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 7,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                    BoxShadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 8.0,
                      spreadRadius: 5.0,
                      color: Color.fromARGB(124, 3, 103, 233),
                    ),
                  ],
                  color: Color.fromARGB(255, 53, 0, 122)),
              child: AnimatedDefaultTextStyle(
                style: textStyle,
                duration: Duration(seconds: 500),
                child: Text(
                  widget.s.split(':')[1],
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
