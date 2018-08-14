import 'package:flutter/material.dart';
import 'themeSelect.dart';

import 'dart:async';
import 'customWidgets.dart';

class ModeSelectPage extends StatefulWidget {
  ModeSelectPage({Key key, @required this.title}) : super(key: key);

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
            _choicesAlert("Party Mode", [2, 3, 4, 5], 'Select  Number of Teams');
            //_askedToLead();
            //_pushThemeSelect();
            break;
          }

          case "CPU Mode": {
            _choicesAlert("CPU Mode", ["Impossible", "Hard", "Normal", "Easy"], "Select Difficulty");
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

  Future<Null> _choicesAlert(String mode, List<dynamic> choices, [String title]) async {
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

          default: {
            if (title == null) {
              return new AlertDialog(
                //verticalAlertDialog is found in customWidgets
                content: verticalAlertLayout(buttons)
              );
            } else {
              return new AlertDialog(
                title: new Text(title),
                content: verticalAlertLayout(buttons)
              );
            }
          }

        }

      },
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
          return new ThemeSelectPage(
            title: "Hello", alertChoice: alertChoice, mode: mode
          );
        }
      )
    );
  }

}