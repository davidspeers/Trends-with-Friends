import 'package:flutter/material.dart';

class OnlineModePage extends StatefulWidget {
  OnlineModePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _OnlineModePageState createState() => new _OnlineModePageState();
}

class _OnlineModePageState extends State<OnlineModePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text(widget.title),
      ),
      body: Container()
    );
  }
}