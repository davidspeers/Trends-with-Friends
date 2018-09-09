import 'package:flutter/animation.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'globals.dart';

class LinesPainter extends CustomPainter {
  final Animation<double> _animation;

  LinesPainter(this._animation) : super(repaint: _animation);

  void animateXLines(Canvas canvas, Color lineColor, List<Offset> points) {
    var paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill
      ..strokeWidth = 4.0;
    //The distances between all points
    List<double> difsX = [];
    List<double> difsY = [];
    for (int i = 0; i<points.length-1; i++) {
      difsX.add(points[i+1].dx-points[i].dx);
      difsY.add(points[i+1].dy-points[i].dy);
    }
    int numOfLineChanges = 2*(points.length-1);
    int numOfLineChangesOver2 = points.length-1; //Needed as dividing ints converts them to doubles
    double timeBetweenLineChanges = 1/numOfLineChanges;

    ///For loop loops for half the number of line changes because
    ///half the line changes are creating, the other half is deleting
    for (int i = 0; i<numOfLineChangesOver2; i++) {
      ///Line Creation
      if (_animation.value < timeBetweenLineChanges*(i+1) && _animation.value > timeBetweenLineChanges*i) {
        ///Draw Previously Created Lines
        for (int j = i; j>=1; j--) {
          canvas.drawLine(points[j-1], points[j], paint);
          canvas.drawCircle(points[j], 2.0, paint);
        }
        ///Line currently being created
        canvas.drawLine(
            points[i], //First Point
            Offset(
              points[i].dx+(difsX[i]*(_animation.value-timeBetweenLineChanges*i)*numOfLineChanges),
              points[i].dy+(difsY[i]*(_animation.value-timeBetweenLineChanges*i)*numOfLineChanges),
            ), //Second Point
            paint //Color
        );
      }

      ///Line deletion
      if (_animation.value < timeBetweenLineChanges*(i+1+numOfLineChangesOver2) && _animation.value > timeBetweenLineChanges*(i+numOfLineChangesOver2)) {
        ///Draw Lines not deleted yet
        for (int j = i+1; j<numOfLineChangesOver2; j++) {
          canvas.drawLine(points[j], points[j+1], paint);
          canvas.drawCircle(points[j], 2.0, paint); //width was 5.0
        }
        ///Line currently being deleted
        canvas.drawLine(
            Offset(
                points[i].dx+(difsX[i]*(_animation.value-timeBetweenLineChanges*(i+numOfLineChangesOver2))*numOfLineChanges),
                points[i].dy+(difsY[i]*(_animation.value-timeBetweenLineChanges*(i+numOfLineChangesOver2))*numOfLineChanges)
            ),
            points[i+1],
            paint
        );
      }
    }

  }

  @override
  void paint(Canvas canvas, Size size) {
    // _animation.value has a value between 0.0 and 1.0
    // use this to draw the first X% of the path
    globalLines.forEach((line) => animateXLines(canvas, line.color, line.points));
  }

  @override
  bool shouldRepaint(LinesPainter oldDelegate) {
    return true;
  }
}