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