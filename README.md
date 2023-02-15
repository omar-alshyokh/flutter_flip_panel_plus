# Flip Panel Plus

A package for flip panel with built-in animation. Since the developer of 'https://pub.dev/packages/flip_panel' didn't respond. So we updated the package and added some improvements.

<p>
	<img src="https://github.com/hnvn/flutter_flip_panel/blob/master/screenshots/flip_image.gif?raw=true" width="250" height="443"  />
	<img src="https://github.com/hnvn/flutter_flip_panel/blob/master/screenshots/flip_clock.gif?raw=true" width="250" height="443" />
</p>

## How to use

````dart
import 'package:flip_panel/flip_panel.dart';
````

Create a flip panel from iterable source:

````dart
final digits = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

FlipPanel.builder(
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
FlipPanel<int>.stream(
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


