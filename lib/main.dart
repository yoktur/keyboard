import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:keyboard/MyKey.dart';
import 'package:vibration/vibration.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: KeyboardPage(),
    );
  }
}

class KeyboardPage extends StatefulWidget {
  @override
  KeyboardPageState createState() => KeyboardPageState();
}

class KeyboardPageState extends State<KeyboardPage> {
  TextEditingController controller = TextEditingController();
  bool smallLetters = true;
  Point<double> leftCenter;
  Point<double> rightCenter;
  Point<double> leftCurrent;
  Point<double> rightCurrent;
  String resultText, leftDirection, rightDirection;
  int leftAmount, rightAmount;
  Iterable<MyKey> iterableKeys;
  FlutterTts flutterTts = FlutterTts();
  @override
  void initState() {
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(1.0);
    flutterTts.setVolume(1.0);
    flutterTts.setPitch(1.0);

    DefaultAssetBundle.of(context).loadString("assets/keys.json").then((value) {
      Iterable jsonKeys = json.decode(value);
      List<MyKey> listKeys = [];
      for (var key in jsonKeys) {
        listKeys.add(myKeyFromJson(key));
      }
      setState(() {
        iterableKeys = listKeys;
      });
    });
    super.initState();
  }

  Widget build(BuildContext context) => Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          resultText == null ? '' : resultText,
                          style: TextStyle(fontSize: 30),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: TextFormField(
                            maxLines: 10,
                            minLines: 8,
                            showCursor: true,
                            controller: controller,
                            decoration: new InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.greenAccent, width: 5.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.red, width: 5.0),
                              ),
                            ),
                            readOnly: true,
                          ),
                        )
                      ],
                    )),
                    flex: 3,
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Center(
                              child: Text(
                            leftCurrent == null
                                ? ''
                                : '${leftAmount}X $leftDirection',
                            style: TextStyle(fontSize: 50),
                          )),
                        ),
                        Expanded(
                          child: Center(
                              child: Text(
                            rightCurrent == null
                                ? ''
                                : '${rightAmount}X $rightDirection',
                            style: TextStyle(fontSize: 50),
                          )),
                        )
                      ],
                    ),
                    flex: 1,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        if (controller.text.length > 0)
                          controller
                            ..text = controller.text
                                .substring(0, controller.text.length - 1)
                            ..selection = TextSelection.collapsed(
                                offset: controller.text.length);
                      }),
                      onDoubleTap: () =>
                          setState(() => smallLetters = !smallLetters),
                      onVerticalDragStart: (details) {
                        handleDragStart(true, details);
                      },
                      onVerticalDragUpdate: (details) {
                        handleDragUpdate(true, details);
                      },
                      onVerticalDragEnd: (details) {
                        handleDragEnd(true);
                      },
                      onHorizontalDragStart: (details) {
                        handleDragStart(true, details);
                      },
                      onHorizontalDragUpdate: (details) {
                        handleDragUpdate(true, details);
                      },
                      onHorizontalDragEnd: (details) {
                        handleDragEnd(true);
                      },
                      child: CustomPaint(
                        painter: KeyboardPainter(
                          leftCenter,
                          leftCurrent,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            border: Border.all(
                              color: Colors.blueGrey,
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => controller
                        ..text += '\n'
                        ..selection = TextSelection.collapsed(
                            offset: controller.text.length)),
                      onDoubleTap: () async {
                        setState(() => controller
                          ..text += ' '
                          ..selection = TextSelection.collapsed(
                              offset: controller.text.length));
                        if (controller.text.trimRight().split(' ').length > 0)
                          flutterTts.speak(
                              controller.text.trimRight().split(' ').last);
                      },
                      onVerticalDragStart: (details) {
                        handleDragStart(false, details);
                      },
                      onVerticalDragUpdate: (details) {
                        handleDragUpdate(false, details);
                      },
                      onVerticalDragEnd: (details) {
                        handleDragEnd(false);
                      },
                      onHorizontalDragStart: (details) {
                        handleDragStart(false, details);
                      },
                      onHorizontalDragUpdate: (details) {
                        handleDragUpdate(false, details);
                      },
                      onHorizontalDragEnd: (details) {
                        handleDragEnd(false);
                      },
                      child: CustomPaint(
                        painter: KeyboardPainter(rightCenter, rightCurrent),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            border: Border.all(
                              color: Colors.blueGrey,
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    flex: 1,
                  ),
                ],
              ),
              flex: 1,
            ),
          ],
        ),
      );
  handleDragStart(bool isLeft, DragStartDetails details) {
    setState(() {
      if (isLeft ? leftCenter == null : rightCenter == null)
        isLeft
            ? leftCenter = Point<double>(
                details.localPosition.dx, details.localPosition.dy)
            : rightCenter = Point<double>(
                details.localPosition.dx, details.localPosition.dy);
    });
  }

  handleDragEnd(bool isLeft) {
    setState(() {
      if (isLeft ? rightCurrent != null : leftCurrent != null) {
        resultText =
            '${leftAmount}X $leftDirection  ${rightAmount}X $rightDirection';
        if (iterableKeys
                .where((element) =>
                    element.leftAmount == leftAmount &&
                    element.leftDirection == leftDirection &&
                    element.rightAmount == rightAmount &&
                    element.rightDirection == rightDirection)
                .length >
            0) {
          controller
            ..text += smallLetters
                ? iterableKeys
                    .firstWhere((element) =>
                        element.leftAmount == leftAmount &&
                        element.leftDirection == leftDirection &&
                        element.rightAmount == rightAmount &&
                        element.rightDirection == rightDirection)
                    .key
                    .toLowerCase()
                : iterableKeys
                    .firstWhere((element) =>
                        element.leftAmount == leftAmount &&
                        element.leftDirection == leftDirection &&
                        element.rightAmount == rightAmount &&
                        element.rightDirection == rightDirection)
                    .key
            ..selection =
                TextSelection.collapsed(offset: controller.text.length);
          flutterTts
              .speak(controller.text.substring(controller.text.length - 1));
        }
      }
      if (isLeft)
        leftCenter = leftCurrent = leftAmount = leftDirection = null;
      else
        rightCenter = rightCurrent = rightAmount = rightDirection = null;
    });
  }

  handleDragUpdate(bool isLeft, DragUpdateDetails details) {
    setState(() {
      double x = details.localPosition.dx;
      double y = details.localPosition.dy;
      if (!isLeft && x < 0) x = 0;
      if (isLeft && x > MediaQuery.of(context).size.width / 2)
        x = MediaQuery.of(context).size.width / 2;
      if (y < 0) y = 0;
      isLeft
          ? leftCurrent = Point<double>(x, y)
          : rightCurrent = Point<double>(x, y);
      if (isLeft) {
        if (leftAmount != (leftCurrent.distanceTo(leftCenter) > 70 ? 2 : 1))
          Vibration.vibrate(
              duration: 120 * (leftCurrent.distanceTo(leftCenter) > 70 ? 2 : 1),
              amplitude:
                  125 * (leftCurrent.distanceTo(leftCenter) > 70 ? 2 : 1));
        leftAmount = leftCurrent.distanceTo(leftCenter) > 70 ? 2 : 1;
        double finalY = leftCenter.y - leftCurrent.y;
        double finalX = leftCenter.x - leftCurrent.x;
        if (finalY > 0 && finalY > finalX.abs()) leftDirection = 'UP';
        if (finalY < 0 && finalY.abs() > finalX.abs()) leftDirection = 'DOWN';
        if (finalX < 0 && finalY.abs() < finalX.abs()) leftDirection = 'RIGHT';
        if (finalX > 0 && finalY.abs() < finalX.abs()) leftDirection = 'LEFT';
      } else {
        if (rightAmount != (rightCurrent.distanceTo(rightCenter) > 70 ? 2 : 1))
          Vibration.vibrate(
              duration:
                  120 * (rightCurrent.distanceTo(rightCenter) > 70 ? 2 : 1),
              amplitude:
                  125 * (rightCurrent.distanceTo(rightCenter) > 70 ? 2 : 1));
        rightAmount = rightCurrent.distanceTo(rightCenter) > 70 ? 2 : 1;
        double finalY = rightCenter.y - rightCurrent.y;
        double finalX = rightCenter.x - rightCurrent.x;
        if (finalY > 0 && finalY > finalX.abs()) rightDirection = 'UP';
        if (finalY < 0 && finalY.abs() > finalX.abs()) rightDirection = 'DOWN';
        if (finalX < 0 && finalY.abs() < finalX.abs()) rightDirection = 'RIGHT';
        if (finalX > 0 && finalY.abs() < finalX.abs()) rightDirection = 'LEFT';
      }
    });
  }
}

class KeyboardPainter extends CustomPainter {
  Point<double> center;
  Point<double> current;

  KeyboardPainter(this.center, this.current);

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = new ui.Gradient.linear(
      Offset(0.0, 0.0),
      Offset(0.0, size.height),
      [
        Color(0xffff0000),
        Color(0xffffff00),
        Color(0xff00ff00),
        Color(0xff00ffff),
        Color(0xff0000ff),
        Color(0xffff00ff),
        Color(0xffff0000)
      ],
      [0 / 6, 1 / 6, 2 / 6, 3 / 6, 4 / 6, 5 / 6, 6 / 6],
    );
    final gradientPaint = new Paint()..shader = gradient;
    Paint paint = Paint();
    paint.strokeWidth = 10;
    paint.color = Colors.red;
    if (center != null) {
      canvas.drawCircle(Offset(center.x, center.y), 70.0, gradientPaint);
      if (current != null) {
        paint.color = Colors.purple;
        canvas.drawLine(
            Offset(center.x, center.y), Offset(current.x, current.y), paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
