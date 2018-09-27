import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart' as globals;

Widget homeIcon(BuildContext context) {
  var backIcon;
  switch(Theme.of(context).platform) {
    case TargetPlatform.iOS:
      {
        backIcon = new Icon(
          Icons.arrow_back_ios,
          color: Colors.white
        );
        break;
      }
    default:
      {
        backIcon = new Icon(
          Icons.arrow_back,
          color: Colors.white
        );
        break;
      }
  }

  return new IconButton(
    icon: backIcon,
    onPressed: () {
      //FocusScope.of(context).requestFocus(new FocusNode()); //Removes keyboard before going back
      Navigator.popUntil(context, ModalRoute.withName('/'));
    }
  );

}

Widget alertBackIcon(BuildContext context, String message, String modalRouteName) {
  var backIcon;
  switch(Theme.of(context).platform) {
    case TargetPlatform.iOS:
      {
        backIcon = new Icon(
          Icons.arrow_back_ios,
          color: Colors.white
        );
        break;
      }
    default:
      {
        backIcon = new Icon(
          Icons.arrow_back,
          color: Colors.white
        );
        break;
      }
  }

  return new IconButton(
    icon: backIcon,
    onPressed: () {
      showDialog<Null>(
        context: context,
        //barrierDismissible: false, // outside click dismisses alert
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text(message),
            titlePadding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
            actions: <Widget>[
              new FlatButton(
                child: new Text(
                  'Cancel',
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text(
                  'Confirm',
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0
                  ),
                ),
                onPressed: () {
                  //Look at main.dart to see how I routes to name the desired ModalRoute
                  Navigator.popUntil(context, ModalRoute.withName(modalRouteName));
                },
              ),
            ],
          );
        },
      );
    }
  );
}

Widget customBackIcon(BuildContext context, VoidCallback customOnPressed) {
  var backIcon;
  switch(Theme.of(context).platform) {
    case TargetPlatform.iOS:
      {
        backIcon = new Icon(
            Icons.arrow_back_ios,
            color: Colors.white
        );
        break;
      }
    default:
      {
        backIcon = new Icon(
            Icons.arrow_back,
            color: Colors.white
        );
        break;
      }
  }

  return new IconButton(
      icon: backIcon,
      onPressed: customOnPressed
  );
}

Widget saveBackIcon(BuildContext context, String modalRouteName) {
  var backIcon;
  switch(Theme.of(context).platform) {
    case TargetPlatform.iOS:
      {
        backIcon = new Icon(
            Icons.arrow_back_ios,
            color: Colors.white
        );
        break;
      }
    default:
      {
        backIcon = new Icon(
            Icons.arrow_back,
            color: Colors.white
        );
        break;
      }
  }

  return new IconButton(
    icon: backIcon,
    onPressed: () {
      Navigator.popUntil(context, ModalRoute.withName(modalRouteName));
    }
  );
}

Widget verticalAlertLayout(List<Widget> widgets) {
  return new Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: widgets,
  );
}

void createSnackBar(String text, BuildContext context) {
  final snackBar = SnackBar(
    content: Text(
      text,
      textAlign: TextAlign.center,
    ),
    duration: const Duration(seconds: 3),
  );

  Scaffold.of(context).showSnackBar(snackBar);
}

void createInteractiveSnackBar(String text, BuildContext context, SnackBarAction sbAction) {
  final snackBar = SnackBar(
    content: Text(
      text,
      textAlign: TextAlign.center,
    ),
    duration: const Duration(seconds: 6),
    action: sbAction,
  );

  Scaffold.of(context).showSnackBar(snackBar);
}

class SimpleScaffold extends StatelessWidget {
  const SimpleScaffold({
    Key key,
    this.title,
    this.child,
  }) : super(key: key);

  final String title;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(title),
      ),
      body: child,
    );
  }
}

///Normal AlertDialogs can't change once displayed.
///Therefore this custom alert content one is needed so the radio tiles change
class RadioAlertDialog extends StatefulWidget {
  RadioAlertDialog({
    Key key,
    this.buttonNames,
  }): super(key: key);

  final List<String> buttonNames;

  @override
  _RadioAlertDialogState createState() => new _RadioAlertDialogState();
}

class _RadioAlertDialogState extends State<RadioAlertDialog> {

  int _selectedIndex;

  @override
  void initState() {
    _selectedIndex = globals.timerSetting;
    super.initState();
  }

  setSharedPrefs() async {
    globals.timerSetting = _selectedIndex;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('timerChoice', _selectedIndex);
  }

  _getContent(){
    if (widget.buttonNames.length == 0){
      return new Container();
    }

    return new Column (
        children: <Widget>[
          Material(
            child: new Column(
                children: new List<RadioListTile<int>>.generate(
                    widget.buttonNames.length,
                        (int index){
                      return new RadioListTile<int>(
                        value: index,
                        groupValue: _selectedIndex,
                        title: new Text(widget.buttonNames[index]),
                        onChanged: (int value) {
                          setState((){
                            _selectedIndex = value;
                          });
                        },
                      );
                    }
                )
            )
          ),
          new Container(
            color: Colors.grey[50],
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                new FlatButton(
                  child: new Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  padding: EdgeInsets.all(0.0),
                ),
                new FlatButton(
                  child: new Text(
                    'Confirm',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0
                    ),
                  ),
                  onPressed: () {
                    setSharedPrefs();
                    Navigator.of(context).pop();
                  },
                  padding: EdgeInsets.all(0.0),
                ),
              ],
            ),
          )
          /*SizedBox(
            height: 5.0,
            child: Container(
              color: Colors.grey[50],
            ),
          ),
          ButtonTheme(
            minWidth: double.infinity,
            height: 50.0,
            padding: EdgeInsets.all(0.0),
            child: RaisedButton(
              child: Text('Confirm', style: blackTextSmaller,),
              color: Colors.blue[400],
              onPressed: () async {
                setSharedPrefs();
                Navigator.of(context).pop();
              },
              //elevation: 0.0,
              //highlightElevation: 0.0,
            ),
          ),*/
        ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return _getContent();
  }
}

