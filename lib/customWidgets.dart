import 'package:flutter/material.dart';

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
      FocusScope.of(context).requestFocus(new FocusNode()); //Removes keyboard before going back
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
        barrierDismissible: false, // outside click dismisses alert
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text(message),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('Confirm'),
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

void createInteractiveSnackBar(String text, BuildContext context, SnackBarAction SBAction) {
  final snackBar = SnackBar(
    content: Text(
      text,
      textAlign: TextAlign.center,
    ),
    duration: const Duration(seconds: 6),
    action: SBAction,
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

