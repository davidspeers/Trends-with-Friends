import 'package:flutter/material.dart';

final whiteText = new TextStyle(
    color: Colors.white,
    fontSize: 30.0
).apply(fontSizeFactor: 2.0);

final whiteTextSmall = new TextStyle(
    color: Colors.white,
    fontSize: 15.0
).apply(fontSizeFactor: 2.0);

final blackHeading = new TextStyle(
  color: Colors.black,
  fontSize: 14.0,
).apply(fontSizeFactor: 2.0);

final blackParagraph = new TextStyle(
  color: Colors.black,
  fontSize: 7.0,
).apply(fontSizeFactor: 2.0);

final blackTextBold = new TextStyle(
  color: Colors.black,
  fontSize: 30.0,
  fontWeight: FontWeight.bold
).apply(fontSizeFactor: 2.0);

final blackTextSmall = new TextStyle(
    color: Colors.black87,
    fontSize: 10.0
).apply(fontSizeFactor: 2.0);

final greyTextSmall = new TextStyle(
    color: Colors.grey,
    fontSize: 10.0
).apply(fontSizeFactor: 2.0);

TextStyle customFont({@required Color color, @required double fontsize}) {
  return new TextStyle(
    color: color,
    fontSize: fontsize,
  ).apply(fontSizeFactor: 2.0);
}