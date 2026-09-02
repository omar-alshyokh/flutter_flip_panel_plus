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
      title: 'FlipPanelPlus',
      routes: {
        'flip_countdown': (_) => const FlipCountdownPage(),
        'flip_styles': (_) => const FlipStylesPage(),
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
            title: const Text('Flip Countdown'),
            subtitle: const Text('Controller: pause, resume, reset, add time'),
            onTap: () => Navigator.of(context).pushNamed('flip_countdown'),
          ),
          ListTile(
            title: const Text('Styles'),
            subtitle: const Text('Presets, gradients, labels, custom digits'),
            onTap: () => Navigator.of(context).pushNamed('flip_styles'),
          ),
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
          duration: const Duration(hours: 1),
          digitColor: Colors.white,
          backgroundColor: Colors.black,
          digitSize: 48.0,
          borderRadius: const BorderRadius.all(Radius.circular(3.0)),
          onDone: () {
            debugPrint('OnDone');
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
          duration: const Duration(days: 10),
          digitColor: Colors.white,
          backgroundColor: Colors.black,
          digitSize: 30.0,
          centerGapSpace: 0.0,
          borderRadius: const BorderRadius.all(Radius.circular(3.0)),
          onDone: () {
            debugPrint('onDone');
          },
        ),
      ),
    );
  }
}


/// Demonstrates [FlipCountdown] driven by a [FlipCountdownController].
class FlipCountdownPage extends StatefulWidget {
  const FlipCountdownPage({super.key});

  @override
  State<FlipCountdownPage> createState() => _FlipCountdownPageState();
}

class _FlipCountdownPageState extends State<FlipCountdownPage> {
  late final FlipCountdownController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FlipCountdownController(
      duration: const Duration(minutes: 2),
    )..addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flip Countdown')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlipCountdown(
              controller: _controller,
              showLabels: true,
              digitColor: Colors.white,
              backgroundColor: Colors.black,
              digitSize: 28.0,
              width: 38.0,
              height: 52.0,
              borderRadius: const BorderRadius.all(Radius.circular(4.0)),
              onDone: () => debugPrint('done'),
            ),
            const SizedBox(height: 24),
            Text('status: ${_controller.status.name}'),
            Text('remaining: ${_controller.remaining}'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _controller.start,
                  child: const Text('Start'),
                ),
                ElevatedButton(
                  onPressed: _controller.pause,
                  child: const Text('Pause'),
                ),
                ElevatedButton(
                  onPressed: _controller.resume,
                  child: const Text('Resume'),
                ),
                ElevatedButton(
                  onPressed: () => _controller.reset(autoStart: true),
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _controller.addTime(const Duration(seconds: 30)),
                  child: const Text('+30s'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


/// Shows the styling options: presets, gradients, labels and custom digits.
class FlipStylesPage extends StatelessWidget {
  const FlipStylesPage({super.key});

  static const _d = Duration(minutes: 12, seconds: 34);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F5),
      appBar: AppBar(title: const Text('Styles')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        children: [
          _row(
            'dark: the classic board',
            const FlipCountdown(
              duration: _d,
              style: FlipDigitStyle.dark(fontSize: 26, width: 36, height: 50),
            ),
          ),
          _row(
            'light: inverted with a hairline border',
            const FlipCountdown(
              duration: _d,
              style: FlipDigitStyle.light(fontSize: 26, width: 36, height: 50),
            ),
          ),
          _row(
            'card: tinted and raised',
            FlipCountdown(
              duration: _d,
              style: FlipDigitStyle.card(
                seed: const Color(0xFF4C4CE0),
                fontSize: 26,
                width: 38,
                height: 52,
              ),
            ),
          ),
          _row(
            'gradient + labels above',
            const FlipCountdown(
              duration: _d,
              showLabels: true,
              labelPosition: FlipLabelPosition.above,
              labels: FlipCountdownLabels.short(),
              labelStyle: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              style: FlipDigitStyle(
                fontSize: 26,
                width: 36,
                height: 50,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF7A18), Color(0xFFE1231C)],
                ),
              ),
            ),
          ),
          _row(
            'seamless (panelSpacing: 0)',
            const FlipCountdown(
              duration: _d,
              panelSpacing: 0,
              style: FlipDigitStyle.dark(fontSize: 26, width: 36, height: 50),
            ),
          ),
          _row(
            'seamless gradient',
            const FlipCountdown(
              duration: _d,
              panelSpacing: 0,
              style: FlipDigitStyle(
                fontSize: 26,
                width: 36,
                height: 50,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                ),
              ),
            ),
          ),
          _row(
            'Arabic labels + Eastern Arabic numerals',
            Directionality(
              textDirection: TextDirection.rtl,
              child: FlipCountdown(
                duration: _d,
                showLabels: true,
                labels: const FlipCountdownLabels(
                  days: 'أيام',
                  hours: 'ساعات',
                  minutes: 'دقائق',
                  seconds: 'ثوانٍ',
                ),
                labelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                style: const FlipDigitStyle.dark(
                  fontSize: 26,
                  width: 36,
                  height: 50,
                ).copyWith(
                  digitFormatter: FlipDigitStyle.easternArabicNumerals,
                ),
              ),
            ),
          ),
          _row(
            'minimal: no boxes, no separator',
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: const Color(0xFF14141A),
              child: const Center(
                child: FlipCountdown(
                  duration: _d,
                  separator: SizedBox(width: 10),
                  flipDuration: Duration(milliseconds: 260),
                  style: FlipDigitStyle.minimal(fontSize: 30),
                ),
              ),
            ),
          ),
          _row(
            'ruled: rules above and below, no boxes',
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              color: const Color(0xFF14141A),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(height: 1.5, color: Colors.white24),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: FlipCountdown(
                        duration: _d,
                        panelSpacing: 0,
                        separator: SizedBox(width: 8),
                        flipDuration: Duration(milliseconds: 260),
                        style: FlipDigitStyle.minimal(fontSize: 30),
                      ),
                    ),
                  ),
                  Container(height: 1.5, color: Colors.white24),
                ],
              ),
            ),
          ),
          _row(
            'compact strip: icon, label and time inline',
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1F6F4A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_outlined, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'ENDS IN',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 12),
                  FlipCountdown(
                    duration: _d,
                    panelSpacing: 0,
                    flipDuration: Duration(milliseconds: 240),
                    separator: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 1),
                      child: Text(
                        ':',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          height: 1.0,
                        ),
                      ),
                    ),
                    style: FlipDigitStyle.minimal(
                      fontSize: 18,
                      width: 15,
                      height: 26,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _row(
            'custom digitBuilder: full control',
            FlipCountdown(
              duration: _d,
              showSeconds: false,
              separator: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text('·', style: TextStyle(fontSize: 26)),
              ),
              digitBuilder: (context, digit) => Container(
                width: 38,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF4C4CE0), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$digit',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF4C4CE0),
                  ),
                ),
              ),
            ),
          ),
          _row(
            'completedBuilder: 3s, then a message',
            FlipCountdown(
              duration: const Duration(seconds: 3),
              style: const FlipDigitStyle.dark(
                  fontSize: 26, width: 36, height: 50),
              completedBuilder: (context) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1231C),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'EXPIRED',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
          _row(
            'headless builder: any UI you like',
            FlipCountdownBuilder(
              duration: _d,
              builder: (context, remaining, status) => Text(
                '${remaining.inMinutes}m ${remaining.inSeconds.remainder(60)}s left',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, Widget child) => Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7A7A85),
                ),
              ),
            ),
            child,
          ],
        ),
      );
}
