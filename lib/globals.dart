import 'package:flutter/material.dart';

final List<Color> globalColors = [Colors.blue, Colors.red, Colors.yellow, Colors.green, Colors.purple];

final Map<Color, Color> globalColorsToAccent = {
  Colors.blue: Colors.blueAccent,
  Colors.red: Colors.redAccent,
  Colors.yellow: Colors.yellowAccent,
  Colors.green: Colors.greenAccent,
  Colors.purple: Colors.purpleAccent
};

class Line {
  /// The points on the line.
  List<Offset> points;

  /// The color of the line.
  Color color;

  Line(List<Offset> points, Color color) {
    this.points = points;
    this.color  = color;
  }
}

List<Line> globalLines = [];