import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'globals.dart' as globals;
import 'routes.dart';

class TimerPage extends StatefulWidget {
  TimerPage({Key key, this.title, this.terms, this.futureTerms, this.mode, this.alertChoice}) : super(key: key);

  final String title;
  final List<String> terms;
  final Future<List<String>> futureTerms;
  final String mode;
  final dynamic alertChoice;

  @override
  TimerPageState createState() => TimerPageState();
}

class TimerPageState extends State<TimerPage> with TickerProviderStateMixin {
  AnimationController controller;

  List<int> timerTimes = [0, 15, 30, 45, 60];
  bool hasAnimationStarted = false;

  String get timerString {
    Duration duration = controller.duration * controller.value;
    return '${(duration.inSeconds+1).toString()}';//.padLeft(2, '0')}';
  }

  Future sleep1() {
    return new Future.delayed(const Duration(seconds: 1), () => controller.reset());
  }

  _pushQuery() {
    Navigator.of(context).push(new QueryPageRoute(
      title: widget.title,
      terms: widget.terms,
      futureTerms: widget.futureTerms,
      mode: widget.mode,
      alertChoice: widget.alertChoice
    ));

    //hasAnimationStarted = false;
  }

  resetAnimation() {
    hasAnimationStarted = false;
    controller.reset();
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: timerTimes[globals.timerSetting]),
    );
    controller.addStatusListener((status) {
      //I think the controller is operating in reverse,
      //therefore we use dismissed not completed
      if (status == AnimationStatus.dismissed) {
        _pushQuery();
      }
    });
    //Reset animation after QueryPage has been fully loaded
    WidgetsBinding.instance.addPostFrameCallback((_) => resetAnimation());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    List<Widget> myChildren = [];
    if (widget.title == "Random Nouns") {
      myChildren.add(
        new FutureBuilder(
          future: widget.futureTerms,
          builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
            //The below line insures no error message and just an empty container shows while the data is loading
            //It can be replaced with a circular spinner or something else
            if (!snapshot.hasData) return new Container();
            List<String> convertedTerms = snapshot.data;
            print("content - $convertedTerms");
            return Text(
              "Match 1 Word with:\n${convertedTerms[globals.termIndex]}",
              style: themeData.textTheme.display1,
              textAlign: TextAlign.center,
            );
          }
        )
      );
    } else {
      myChildren.add(
        Text(
          "Match 1 Word with:\n${widget.terms[globals.termIndex]}",
          style: themeData.textTheme.display1,
          textAlign: TextAlign.center,
        )
      );
    }

    myChildren.add(
      Expanded(
        child: Align(
          alignment: FractionalOffset.center,
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: controller,
                    builder: (BuildContext context, Widget child) {
                      return new CustomPaint(
                          painter: TimerPainter(
                            animation: controller,
                            backgroundColor: Colors.white,
                            color: themeData.indicatorColor,
                          ));
                    },
                  ),
                ),
                Align(
                  alignment: FractionalOffset.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                          animation: controller,
                          builder: (BuildContext context, Widget child) {
                            if (controller.status == AnimationStatus.dismissed && !hasAnimationStarted) {
                              return new Text(
                                timerTimes[globals.timerSetting].toString(),
                                style: themeData.textTheme.display4,
                              );
                            } else {
                              return new Text(
                                timerString,
                                style: themeData.textTheme.display4,
                              );
                            }
                          }
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    myChildren.add(
        Container(
          margin: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FloatingActionButton(
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (BuildContext context, Widget child) {
                    return new Icon(controller.isAnimating
                        ? Icons.pause
                        : Icons.play_arrow);
                  },
                ),
                onPressed: () {
                  hasAnimationStarted = true;
                  if (controller.isAnimating)
                    controller.stop();
                  else {
                    controller.reverse(
                        from: controller.value == 0.0
                            ? 1.0
                            : controller.value);
                  }
                },
                heroTag: null,
              ),
              FloatingActionButton(
                child: Icon(Icons.skip_next),
                onPressed: () => _pushQuery(),
                heroTag: null,
              )
            ],
          ),
        )
    );

    return Scaffold(
      appBar: new AppBar(
        title: new Text('Timer'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: myChildren
        ),
      ),
    );
  }
}

class TimerPainter extends CustomPainter {
  TimerPainter({
    this.animation,
    this.backgroundColor,
    this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(TimerPainter old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}