# Flip Panel Plus

A package for flip panel with built-in animation. Since the developer of 'https://pub.dev/packages/flip_panel' didn't respond. So we updated the package and added some improvements.

<p>

    <img src="https://raw.githubusercontent.com/omar-alshyokh/flutter_flip_panel_plus/master/screenshots/flip_clock.gif" width="300" 
        height="600" />
   <img src="https://raw.githubusercontent.com/omar-alshyokh/flutter_flip_panel_plus/master/screenshots/flip_countdown.gif" width="300" 
       height="600" />
    <img src="https://raw.githubusercontent.com/omar-alshyokh/flutter_flip_panel_plus/master/screenshots/flip_image.gif" width="300"
         height="600" />
    <img src="https://raw.githubusercontent.com/omar-alshyokh/flutter_flip_panel_plus/master/screenshots/reverse_countdown.gif" width="300"
         height="600" />
</p>


## How to use

````dart
import 'package:flip_panel_plus/flip_panel_plus.dart';
````

Create a flip panel from iterable source:

````dart
final digits = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

FlipPanelPlus.builder(
    itemBuilder: (context, index) => Container(
       color: Colors.black,
       padding: const EdgeInsets.symmetric(horizontal: 6.0),
       child: Text(
         '${digits[index]}',
         style: TextStyle(
             fontWeight: FontWeight.bold,
             fontSize: 50.0,
             color: Colors.white),
       ),
     ),
    itemsCount: digits.length,
    period: const Duration(milliseconds: 1000),
    loop: 1,
)
````

Create a flip panel from stream source:

````dart
FlipPanelPlus<int>.stream(
      itemStream: Stream.periodic(Duration(milliseconds: 1000), (count) => count % 10),
      itemBuilder: (context, value) => Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: Text(
          '$value',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 50.0,
            color: Colors.white
          ),
        ),
      ),
      initValue: 0,
  );

````

Create a flip panel countdown:

````dart
FlipClock.countdown(
  duration: const Duration(hours:1),
  digitColor: Colors.white,
  backgroundColor: Colors.black,
  digitSize: 48.0,
  borderRadius: const BorderRadius.all(Radius.circular(3.0)),
  onDone: () {
    print('OnDone');
   },
)
````
