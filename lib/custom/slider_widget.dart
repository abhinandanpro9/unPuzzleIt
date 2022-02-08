// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:unpuzzle_it_abhi/custom/slider_component.dart';

class SliderWidget extends StatefulWidget {
  /// Slider Widger for selecting the puzzle grid size
  const SliderWidget({Key? key, 
    required this.onChanged,
    this.sliderHeight = 48,
    this.max = 10,
    this.min = 0,
    this.fullWidth = false,
    this.onPressed,
    required this.value,
  }) : super(key: key);

  final double sliderHeight;
  final int min;
  final int max;
  final int value;
  final bool fullWidth;

  /// Called when this button is tapped.
  final VoidCallback? onPressed;

  final ValueChanged<double>? onChanged;

  @override
  SliderWidgetState createState() => SliderWidgetState();
}

class SliderWidgetState extends State<SliderWidget> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    var paddingFactor = .2;

    // if (widget.fullWidth == null) paddingFactor = .3;

    return Container(
      width: (widget.sliderHeight) * 5.5,
      height: widget.sliderHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(widget.sliderHeight * .3),
        ),
        gradient: LinearGradient(
            colors: const [
              Color(0xFF00c6ff),
              Color(0xFF0072ff),
            ],
            begin: const FractionalOffset(0, 0),
            end: const FractionalOffset(1.0, 1.00),
            stops: [widget.min.toDouble(), widget.max.toDouble()]),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(widget.sliderHeight * paddingFactor, 2,
            widget.sliderHeight * paddingFactor, 2,),
        child: Row(
          children: <Widget>[
            Text(
              '${widget.min}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: widget.sliderHeight * .3,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(
              width: widget.sliderHeight * .1,
            ),
            Expanded(
              child: Center(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.white.withOpacity(1),
                    inactiveTrackColor: Colors.white.withOpacity(.5),
                    trackHeight: 4,
                    thumbShape: SliderCircleThumbPainter(
                      thumbRadius: widget.sliderHeight * .4,
                      min: widget.min,
                      max: widget.max,
                    ),
                    overlayColor: Colors.white.withOpacity(.4),
                    valueIndicatorColor: Colors.white,
                    activeTickMarkColor: Colors.white,
                    inactiveTickMarkColor: Colors.red.withOpacity(.7),
                  ),
                  child: Slider(
                    value: _value,
                    divisions: widget.max-widget.min,
                    min: widget.min.toDouble(),
                    max: widget.max.toDouble(),
                    onChanged: (value) {
                      setState(() {
                        _value = value;
                      });
                      widget.onChanged!(value);
                    },
                  ),
                ),
              ),
            ),
            SizedBox(
              width: widget.sliderHeight * .1,
            ),
            Text(
              '${widget.max}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: widget.sliderHeight * .3,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
