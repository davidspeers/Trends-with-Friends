import 'package:flutter/material.dart';


import 'dart:async';
import 'dart:io';

import 'routes.dart';
import 'fontStyles.dart';
import 'globals.dart' as globals;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'onlineHelpers.dart';

class OnlineLoginPage extends StatefulWidget {
  OnlineLoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _OnlineLoginPageState createState() => new _OnlineLoginPageState();
}

///There are 3 important backend blocks here - search for onPressed to see them.
///onlineHelpers.dart contains most of the firebase contingency backend while the
///rest of the code inside onPressed handles the navigation.
///Note that all that auth is doing is let people to onlineMode, with their 'user' credentials.
///The other thing that is passed onto onlineMode is 'app' which contains the the Trends firebase details.
class _OnlineLoginPageState extends State<OnlineLoginPage> {

  Future<String> _message = Future<String>.value('');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Expanded(child: Container()),
          new Padding(
            padding: EdgeInsets.all(10.0),
            child: ButtonTheme(
              height: 60.0,
              child: RaisedButton(
                onPressed: () {
                  handleFirebaseConnection()
                    .then((FirebaseApp app) {
                    handleGoogleSignIn()
                        .then((FirebaseUser user) {
                      globals.user = user;
                      Navigator.of(context).push(
                          new OnlineModeRoute(
                            'Logged In',
                            user
                          )
                      );
                    }).catchError((e) => print(e));
                  }).catchError((e) => print(e));
                },
                color: Colors.blue[200],
                textColor: Colors.black,
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new Padding(padding: EdgeInsets.all(0.0)),
                    new Image.asset('assets/images/GoogleLogo.png', height: 40.0),
                    new Center(
                      child: new Text('Login with Google', style: customFont(color: Colors.black87, fontsize: 12.0)),
                    ),
                    new Padding(padding: EdgeInsets.all(0.0))
                  ]
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0)))
              ),
            )
          ),
          new Padding(
              padding: EdgeInsets.all(10.0),
              child: ButtonTheme(
                height: 60.0,
                child: RaisedButton(
                    onPressed: () {
                      handleFirebaseConnection()
                        .then((FirebaseApp app) {
                          final FirebaseAuth _auth = FirebaseAuth.fromApp(app);
                          Navigator.of(context).push(
                              new OnlineEmailLoginRoute('Login', _auth)
                          );
                      }).catchError((e) => print(e));
                    },
                    color: Colors.blue[200],
                    textColor: Colors.black,
                    child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Padding(padding: EdgeInsets.all(0.0)),
                          new Image.asset('assets/images/MailLogo.png', height: 60.0),
                          new Center(
                            child: new Text('Login with Email', style: customFont(color: Colors.black87, fontsize: 12.0)),
                          ),
                          new Padding(padding: EdgeInsets.all(0.0))
                        ]
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0)))
                ),
              )
          ),
          Expanded(child: Container()),
          Text('Don\'t have an account?'),
          MaterialButton(
            child: const Text('Sign Up'),
              onPressed: () {
                handleFirebaseConnection()
                    .then((FirebaseApp app) {
                  final FirebaseAuth _auth = FirebaseAuth.fromApp(app);
                  Navigator.of(context).push(
                    new OnlineEmailLoginRoute('Sign Up', _auth)
                  );
                }).catchError((e) => print(e));
              },
          ),
          /*FutureBuilder<String>(
              future: _message,
              builder: (_, AsyncSnapshot<String> snapshot) {
                return Text(snapshot.data ?? '',
                  style:
                  const TextStyle(color: Color.fromARGB(255, 0, 155, 0)));
              }
            ),*/
        ],
      ),
    );
  }
}