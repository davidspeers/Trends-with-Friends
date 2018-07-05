import 'package:flutter/material.dart';
import 'themeSelect.dart';
import 'storyMode.dart';

import 'dart:async';

class ModeSelectPage extends StatefulWidget {
  ModeSelectPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ModeSelectPageState createState() => new _ModeSelectPageState();
}

class _ModeSelectPageState extends State<ModeSelectPage> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: _modeSelectPageUI()
    );
  }

  Widget _modeSelectPageUI() {
    return new Center(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          /*new Text(
            'You have pushed the button this many times:',
            style: Theme.of(context).textTheme.display1,
          ),*/
          modeSelectionButton("Party Mode"),
          modeSelectionButton("CPU Mode"),
          modeSelectionButton("Story Mode"),
          modeSelectionButton("Private Match Mode"),
          modeSelectionButton("Public Match Mode"),
        ],
      ),
    );
  }

  Widget modeSelectionButton(String text) {
    return new MaterialButton(
      onPressed: () {
        switch (text) {
          case "Party Mode": {
            //_teamsAlert("Party Mode");
            _choicesAlert("Party Mode", 'Select  Number of Teams', [2, 3, 4, 5]);
            //_askedToLead();
            //_pushThemeSelect();
            break;
          }

          case "CPU Mode": {
            _choicesAlert("CPU Mode", "Select Difficulty", ["Impossible", "Hard", "Normal", "Easy"]);
            break;
          }

          case "Story Mode": {
            print("Hello");
            _pushStorySelect();
            break;
          }

          default: {
            //_neverSatisfied();
            print("Nothing Happened - Check Mode Selection Button");
            //do Nothing
            break;
          }
        }
      },
      height: 70.0,
      minWidth: double.infinity,
      color: Theme
          .of(context)
          .primaryColor,
      textColor: Colors.white,
      child: new Text(text),
      splashColor: Colors.redAccent, //hold button to see
    );
  }

  Future<Null> _choicesAlert(String mode, String title , List<dynamic> choices) async {
    List<Widget> buttons = [];
    for (var choice in choices) {
      buttons.add(alertChoiceButton(choice, mode));
    }
    return showDialog<Null>(
      context: context,
      barrierDismissible: true, // outside click dismisses alert
      builder: (BuildContext context) {
        switch (mode) {
          case "Party Mode": {
            return new AlertDialog(
                title: new Text(title),
                actions: buttons
            );
          }

          case "CPU Mode": {
            return new AlertDialog(
                title: new Text(title),
                content: verticalLayout(buttons)
            );
          }

        }

      },
    );
  }

  Widget verticalLayout(List<Widget> widgets) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  Widget alertChoiceButton(var choice, String mode) {
    return new MaterialButton(
      onPressed: () => _pushThemeSelect(choice, mode),
      height: 60.0,
      minWidth: 60.0,
      color: Theme.of(context).primaryColor,
      textColor: Colors.white,
      child: new Text(choice.toString()),
      splashColor: Colors.redAccent, //hold button to see
    );
  }


  void _pushThemeSelect(var alertChoice, String mode) {
      Navigator.of(context).push(
          new MaterialPageRoute(
              builder: (context) {
                return new ThemeSelectPage(title: "Hello", alertChoice: alertChoice, mode: mode);
              }
          )
      );
  }

  void _pushStorySelect() {
    Navigator.of(context).push(
        new MaterialPageRoute(
            builder: (context) {
              return new StoryModePage(title: "Hello",);
            }
        )
    );
  }
}