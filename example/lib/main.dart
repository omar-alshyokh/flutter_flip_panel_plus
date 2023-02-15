import 'package:flip_panel_plus/flip_panel_plus.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
      ),
      title: 'FlipPanel',
      routes: {
        'flip_image': (_) => const AnimatedImagePage(),
        'flip_clock': (_) => const FlipClockPage(),
        'countdown_clock': (_) => const CountdownClockPage(),
        'reverse_countdown': (_) => const ReverseCountdown(),
      },
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlipPanelPlus'),
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text('Flip Image'),
            onTap: () => Navigator.of(context).pushNamed('flip_image'),
          ),
          ListTile(
            title: const Text('Flip Clock'),
            onTap: () => Navigator.of(context).pushNamed('flip_clock'),
          ),

          ListTile(
            title: const Text('Countdown Clock'),
            onTap: () => Navigator.of(context).pushNamed('countdown_clock'),
          ),
          ListTile(
            title: const Text('Days To Go'),
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
    const imageWidth = 320.0;
    const imageHeight = 171.0;
    const toleranceFactor = 0.033;
    const widthFactor = 0.125;
    const heightFactor = 0.5;

    final random = Random();

    return Scaffold(
      appBar: AppBar(
        title: const Text('FlipImage'),
      ),
      body: Center(
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
        child: FlipClockPlus.simple(
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flip Countdown'),
      ),
      body: Center(
        child: FlipClockPlus.countdown(
          duration: const Duration(hours:1),
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
        child: FlipClockPlus.reverseCountdown(
          duration:const Duration(days: 10),
          digitColor: Colors.white,
          backgroundColor: Colors.black,
          digitSize: 30.0,
          centerGapSpace: 0.0,
          borderRadius: const BorderRadius.all(Radius.circular(3.0)),
          onDone: () {
            print('onDone');
          },
        ),
      ),
    );
  }
}
