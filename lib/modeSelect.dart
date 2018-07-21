import 'package:flutter/material.dart';
import 'themeSelect.dart';
import 'multiplayerMode.dart';
import 'multiplayerSetup.dart';
import 'package:web_socket_channel/io.dart';

import 'dart:async';

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
          modeSelectionButton("Online Multiplayer"),
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

          case "Online Multiplayer": {
            _choicesAlert("Multiplayer Mode", ["Host Game", "Join Game"]);
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
                content: verticalLayout(buttons)
              );
            } else {
              return new AlertDialog(
                title: new Text(title),
                content: verticalLayout(buttons)
              );
            }
          }

        }

      },
    );
  }

  Future<Null> _enterRoomAlert() async {
    final myController = new TextEditingController();
    return showDialog<Null>(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Enter Room Name'),
          content: new TextField(
              controller: myController,
              autofocus: true,
              decoration: new InputDecoration(
                  filled: true,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(12.0),
                  ),
                  hintText: 'Please Enter Room Name'
              )
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text('Enter Room'),
              onPressed: () {
                _pushThemeSelect(myController.text, "Multiplayer Mode");
              },
            )
          ],
        );
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
    if (mode == "Multiplayer Mode") {
       Navigator.of(context).push(
           new MaterialPageRoute(
               builder: (context) {
                 return new MultiplayerPage(
                     title: "Hello", alertChoice: alertChoice, mode: mode);
               }
           )
       );
    } else {
      Navigator.of(context).push(
          new MaterialPageRoute(
              builder: (context) {
                return new ThemeSelectPage(
                    title: "Hello", alertChoice: alertChoice, mode: mode);
              }
          )
      );
    }
  }

}