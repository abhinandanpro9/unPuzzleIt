// ignore_for_file: public_member_api_docs, cascade_invocations

import 'package:flutter/material.dart';

/// Custom Circular thumb painter
class SliderCircleThumbPainter extends SliderComponentShape {
  /// To create Circle for slider
  const SliderCircleThumbPainter({
    required this.thumbRadius,
    this.min = 0,
    this.max = 10,
  });

  /// [thumbRadius] [min] [max]
  final double thumbRadius;
  final int min;
  final int max;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double>? activationAnimation,
    Animation<double>? enableAnimation,
    bool? isDiscrete,
    TextPainter? labelPainter,
    RenderBox? parentBox,
    SliderThemeData? sliderTheme,
    TextDirection? textDirection,
    double? value,
    double? textScaleFactor,
    Size? sizeWithOverflow,
  }) {
    final textCanvas = context.canvas;

    //Thumb Style Color
    final textPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    //Text Span and style
    final textSpan = TextSpan(
      style: TextStyle(
        fontSize: thumbRadius * .8,
        fontWeight: FontWeight.w700,
        color: sliderTheme!.thumbColor,
      ),
      text: getValue(value!),
    );
    final span = textSpan;

    final textCirlePainter = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    // To Paint the thumb
    textCirlePainter.layout();
    final textCenter = Offset(
      center.dx - (textCirlePainter.width / 2),
      center.dy - (textCirlePainter.height / 2),
    );

    // Draw circle and paint with text
    textCanvas.drawCircle(center, thumbRadius * .9, textPaint);
    textCirlePainter.paint(textCanvas, textCenter);
  }

  String getValue(double value) {
    return (min + (max - min) * value).round().toString();
  }
}
