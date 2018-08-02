import 'package:flutter/material.dart';

class TutorialPage extends StatefulWidget {
  TutorialPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _TutorialPageState createState() => new _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  @override
  Widget build(BuildContext context) {
    return _tutorialPageUI();
  }

  Widget _tutorialPageUI() {

  }
}