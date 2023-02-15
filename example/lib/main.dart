import 'package:flip_panel_plus/flip_panel_plus.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
      ),
      title: 'FlipPanel',
      routes: {
        'flip_image': (_) => AnimatedImagePage(),
        'flip_clock': (_) => FlipClockPage(),
        'countdown_clock': (_) => CountdownClockPage(),
        'reverse_countdown': (_) => ReverseCountdown(),
      },
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FlipPanel'),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('Flip Image'),
            onTap: () => Navigator.of(context).pushNamed('flip_image'),
          ),
          ListTile(
            title: Text('Flip Clock'),
            onTap: () => Navigator.of(context).pushNamed('flip_clock'),
          ),

          ListTile(
            title: Text('Countdown Clock'),
            onTap: () => Navigator.of(context).pushNamed('countdown_clock'),
          ),
          ListTile(
            title: Text('Days To Go'),
            onTap: () => Navigator.of(context).pushNamed('reverse_countdown'),
          ),
        ],
      ),
    );
  }
}

class AnimatedImagePage extends StatelessWidget {
  const AnimatedImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final imageWidth = 320.0;
    final imageHeight = 171.0;
    final toleranceFactor = 0.033;
    final widthFactor = 0.125;
    final heightFactor = 0.5;

    final random = Random();

    return Scaffold(
      appBar: AppBar(
        title: Text('FlipImage'),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  0,
                  1,
                  2,
                  3,
                  4,
                  5,
                  6,
                  7,
                ]
                    .map((count) => FlipPanelPlus.stream(
                  itemStream: Stream.fromFuture(Future.delayed(
                      Duration(milliseconds: random.nextInt(20) * 100),
                          () => 1)),
                  itemBuilder: (_, value) => value <= 0
                      ? Container(
                    color: Colors.white,
                    width: widthFactor * imageWidth,
                    height: heightFactor * imageHeight,
                  )
                      : ClipRect(
                      child: Align(
                          alignment: Alignment(
                              -1.0 +
                                  count * 2 * 0.125 +
                                  count * toleranceFactor,
                              -1.0),
                          widthFactor: widthFactor,
                          heightFactor: heightFactor,
                          child: Image.asset(
                            'assets/flutter_cover.png',
                            width: imageWidth,
                            height: imageHeight,
                          ))),
                  initValue: 0,
                  spacing: 0.0,
                  direction: FlipDirection.up,
                ))
                    .toList(),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  0,
                  1,
                  2,
                  3,
                  4,
                  5,
                  6,
                  7,
                ]
                    .map((count) => FlipPanelPlus.stream(
                  itemStream: Stream.fromFuture(Future.delayed(
                      Duration(milliseconds: random.nextInt(20) * 100),
                          () => 1)),
                  itemBuilder: (_, value) => value <= 0
                      ? Container(
                    color: Colors.white,
                    width: widthFactor * imageWidth,
                    height: heightFactor * imageHeight,
                  )
                      : ClipRect(
                      child: Align(
                          alignment: Alignment(
                              -1.0 +
                                  count * 2 * 0.125 +
                                  count * toleranceFactor,
                              1.0),
                          widthFactor: widthFactor,
                          heightFactor: heightFactor,
                          child: Image.asset(
                            'assets/flutter_cover.png',
                            width: imageWidth,
                            height: imageHeight,
                          ))),
                  initValue: 0,
                  spacing: 0.0,
                  direction: FlipDirection.down,
                ))
                    .toList(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class FlipClockPage extends StatelessWidget {
  const FlipClockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flip Clock'),
      ),
      body: Center(
        child: FlipClock.simple(
          startTime: DateTime.now(),
          digitColor: Colors.white,
          backgroundColor: Colors.black,
          digitSize: 30.0,
          centerGapSpace: 0.0,
          borderRadius: const BorderRadius.all(Radius.circular(3.0)),
        ),
      ),
    );
  }
}


class CountdownClockPage extends StatelessWidget {
  const CountdownClockPage({super.key});

  @override
  Widget build(BuildContext context) {
    print('hey');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flip Countdown'),
      ),
      body: Center(
        child: FlipClock.countdown(
          duration: const Duration(seconds:10),
          digitColor: Colors.white,
          backgroundColor: Colors.black,
          digitSize: 48.0,
          borderRadius: const BorderRadius.all(Radius.circular(3.0)),
          onDone: () {
            print('OnDone');
          },
        ),
      ),
    );
  }
}

class ReverseCountdown extends StatelessWidget {
  const ReverseCountdown({super.key});


  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: AppBar(
        title: const Text('Reverse Countdown'),
      ),
      body: Center(
        child: FlipClock.reverseCountdown(
          duration:const Duration(seconds: 10),
          digitColor: Colors.white,
          backgroundColor: Colors.black,
          digitSize: 30.0,
          centerGapSpace: 1,
          borderRadius: const BorderRadius.all(Radius.circular(3.0)),
          onDone: () {
            print('onDone');
          },
        ),
      ),
    );
  }
}
