import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:unpuzzle_it_abhi/helpers/helpers.dart';
import 'package:unpuzzle_it_abhi/spinning_wheel/spin_wheel.dart';

// Handles Roulette Widget creation
class CustomRoulette extends StatelessWidget {
  final StreamController _dividerController = StreamController<int>();
  final StreamController _dividerControllerEnd = StreamController<int>();
  final double width;
  final double height;
  final Function(String)? callback;
  late final AudioPlayer? _audioPlayer;
  final AudioPlayerFactory _audioPlayerFactory = getAudioPlayer;
  late bool isCalled = false;
  late bool isCalledStart = false;

  CustomRoulette({required this.width, required this.height, this.callback});

  dispose() {
    _audioPlayer!.dispose();
    _dividerController.close();
    _audioPlayer!.dispose();
    _dividerControllerEnd.close();
  }

  Future<void> startOfSpinMusic(AsyncSnapshot<Object?> snapshot) async {
    await _audioPlayer!.setAsset('assets/audio/spinwheel.mp3');
    try {
      unawaited(_audioPlayer!.play());
    } on Exception catch (_) {
      // log('Waiting for chrome permission');
    }
  }

  Future<void> endOfSpinMusic(AsyncSnapshot<Object?> snapshot) async {
    unawaited(_audioPlayer!.stop());
    await _audioPlayer!.setAsset('assets/audio/spinwheel_success.mp3');
    try {
      unawaited(_audioPlayer!.play());
    } on Exception catch (_) {
      // log('Waiting for chrome permission');
    }
  }

  Widget startOfSpin(AsyncSnapshot<Object?> snapshot) {
    isCalledStart = !isCalledStart;
    if (!isCalledStart) startOfSpinMusic(snapshot);
    return Container();
  }

  Widget endOfSpin(AsyncSnapshot<Object?> snapshot) {
    isCalled = !isCalled;
    if (!isCalled) endOfSpinMusic(snapshot);
    return RouletteScore(
      selected: snapshot.data as int,
      callback: callback,
    );
  }

  @override
  Widget build(BuildContext context) {
    _audioPlayer = _audioPlayerFactory();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SpinningWheel(
          Image.asset('assets/images/splash/roulette.png'),
          width: width,
          height: height,
          initialSpinAngle: _generateRandomAngle(),
          spinResistance: 0.5,
          canInteractWhileSpinning: false,
          dividers: 8,
          onUpdate: _dividerController.add,
          onEnd: _dividerControllerEnd.add,
          secondaryImage:
              Image.asset('assets/images/splash/roulette-center.png'),
          secondaryImageHeight: 110,
          secondaryImageWidth: 110,
        ),
        SizedBox(height: 30),
        // StreamBuilder(
        //   stream: _dividerController.stream,
        //   builder: (context, snapshot) =>
        //       snapshot.hasData ? startOfSpin(snapshot) : Container(),
        // ),
        StreamBuilder(
          stream: _dividerControllerEnd.stream,
          builder: (context, snapshot) =>
              snapshot.hasData ? endOfSpin(snapshot) : Container(),
        ),
        Padding(padding: EdgeInsets.only(bottom: height / 10)),
      ],
    );
  }

  double _generateRandomAngle() => Random().nextDouble() * pi * 2;
}

// Handles Score Displaying
class RouletteScore extends StatefulWidget {
  final int selected;
  final Function(String)? callback;
  RouletteScore({required this.selected, required this.callback});

  @override
  State<StatefulWidget> createState() => _RouletteScore();
}

class _RouletteScore extends State<RouletteScore> {
  bool isCalled = false;

  final Map<int, String> labels = {
    1: 'Simple Game',
    2: 'Spin Again!!',
    3: 'Path Game',
    4: 'Simple Game',
    5: 'Custom Game',
    6: 'Spin Again!!',
    7: 'Path Game',
    8: 'Custom Game',
  };

  @override
  Widget build(BuildContext context) {
    if (!isCalled) {
      isCalled = true;
    } else {
      widget.callback!(labels[widget.selected]!);
    }

    return Text('${labels[widget.selected]}',
        style: TextStyle(
            fontStyle: FontStyle.italic, fontSize: 24.0, color: Colors.white));
  }
}
