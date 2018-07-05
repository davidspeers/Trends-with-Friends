import 'package:flutter/material.dart';

Widget homeIcon(BuildContext context) {
  switch(Theme.of(context).platform) {
    case TargetPlatform.iOS: {
      return new IconButton(
          icon: new Icon(
              Icons.arrow_back_ios,
              color: Colors.white
          ),
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/'));
          }
      );
    }

    default: {
      return new IconButton(
          icon: new Icon(
              Icons.arrow_back,
              color: Colors.white
          ),
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/'));
          }
      );
    }
  }

}