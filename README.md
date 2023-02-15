# Flip Panel Plus

A package for flip panel items like image, countdown or clock with built-in animation.
Since the developer of [flip_panel](https://pub.dev/packages/flip_panel) didn't respond.
So we updated the package, added some improvements and fixed some issues.

## Getting Started

To use this package, add `flip_panel_plus` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).


<p>
   <img src="https://raw.githubusercontent.com/omar-alshyokh/flutter_flip_panel_plus/master/screenshots/flip_clock.gif" width="200" 
       height="450" />
    <img src="https://raw.githubusercontent.com/omar-alshyokh/flutter_flip_panel_plus/master/screenshots/flip_countdown.gif" width="200" 
       height="450" />
</p>
<p>
   <img src="https://raw.githubusercontent.com/omar-alshyokh/flutter_flip_panel_plus/master/screenshots/flip_image.gif" width="200"
         height="450" />
    <img src="https://raw.githubusercontent.com/omar-alshyokh/flutter_flip_panel_plus/master/screenshots/reverse_countdown.gif" width="200"
         height="450" />
</p>

## Add dependency
```
dependencies:
  flip_panel_plus: ^1.0.0
```

## Import

````dart
import 'package:flip_panel_plus/flip_panel_plus.dart';
````
## Usage


Create a flip panel countdown:

````dart
FlipClockPlus.countdown(
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
## Output
![flip_countdown](https://raw.githubusercontent.com/omar-alshyokh/flutter_flip_panel_plus/master/screenshots/flip_countdown.gif)


Create flip clock:

````dart
FlipClockPlus.simple(
  startTime: DateTime.now(),
  digitColor: Colors.white,
  backgroundColor: Colors.black,
  digitSize: 30.0,
  centerGapSpace: 0.0,
  borderRadius: const BorderRadius.all(Radius.circular(3.0)),
)
````
## Output
![flip_clock](https://raw.githubusercontent.com/omar-alshyokh/flutter_flip_panel_plus/master/screenshots/flip_clock.gif)



Create flip reverse countdown:

````dart
FlipClockPlus.reverseCountdown(
  duration:const Duration(days: 10),
  digitColor: Colors.white,
  backgroundColor: Colors.black,
  digitSize: 30.0,
  centerGapSpace: 0.0,
  borderRadius: const BorderRadius.all(Radius.circular(3.0)),
  onDone: () {
    print('onDone');
   },
)
````
## Output
![reverse_countdown](https://raw.githubusercontent.com/omar-alshyokh/flutter_flip_panel_plus/master/screenshots/reverse_countdown.gif)





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
