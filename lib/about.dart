import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  AboutPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AboutPageState createState() => new _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return _aboutPageUI();
  }

  Widget _aboutPageUI() {
    return new Scaffold(
      appBar: new AppBar(title: new Text(widget.title)),
      body: new Container(),
    );
  }
}