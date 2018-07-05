import 'package:flutter/material.dart';

class StoryModePage extends StatefulWidget {
StoryModePage({Key key, this.title}) : super(key: key);

final String title;

@override
_StoryModePageState createState() => new _StoryModePageState();
}

class _StoryModePageState extends State<StoryModePage> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: _storyModePageUI()
    );
  }

  Widget _storyModePageUI() {
    return new Center(
      child: new Text("Hello")
    );
  }

}