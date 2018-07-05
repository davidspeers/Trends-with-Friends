import 'package:flutter/material.dart';
import 'modeSelect.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Google Trends Game',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new HomePage(title: 'Trends Game Home Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: _homePageUI()
    );
  }

  Widget _homePageUI() {
    return new Center(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          /*new Text(
            'You have pushed the button this many times:',
            style: Theme.of(context).textTheme.display1,
          ),*/
          customButton("Continue Game"),
          customButton("Start"),
          customButton("Tutorial"),
          customButton("Add Level")
        ],
      ),
    );
  }

  Widget customButton(String text) {
    return new MaterialButton(
      onPressed: _pushModeSelect,
      height: 70.0,
      minWidth: double.infinity,
      color: Theme.of(context).primaryColor,
      textColor: Colors.white,
      child: new Text(text),
      splashColor: Colors.redAccent, //hold button to see
    );
  }

  void _pushModeSelect() {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return new ModeSelectPage(title: "Hello");
        }
      )
    );
  }

}


