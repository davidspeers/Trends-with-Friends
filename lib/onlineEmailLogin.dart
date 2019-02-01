import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; //Needed for LengthLimitingTextInputFormatter

import 'dart:async';
import 'dart:io';

import 'routes.dart';
import 'fontStyles.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'onlineHelpers.dart';

class OnlineEmailLoginPage extends StatefulWidget {
  OnlineEmailLoginPage({Key key, this.title, this.auth}) : super(key: key);

  final String title;
  final FirebaseAuth auth;

  @override
  _OnlineEmailLoginPageState createState() => new _OnlineEmailLoginPageState();
}

class _OnlineEmailLoginPageState extends State<OnlineEmailLoginPage> {

  final emailController = new TextEditingController();
  final passwordController = new TextEditingController();

  bool isUserSigningUp = false;

  Future<String> _message = Future<String>.value('');

  @override
  Widget build(BuildContext context) {

    if (widget.title == 'Sign Up') {
      isUserSigningUp = true;
    }

    List<Widget> myChildren = <Widget>[
      new Padding(
        padding: EdgeInsets.all(10.0),
        child: new TextField(
          controller: emailController,
          autofocus: true,
          decoration: new InputDecoration(
              filled: true,
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(12.0),
              ),
              hintText: 'email@example.com'
          ),
          inputFormatters:[
            //Limits length of textfield without showing length
            LengthLimitingTextInputFormatter(254), //254 is max number of email chars
          ],
        ),
      ),
      new Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: new TextField(
          controller: passwordController,
          autofocus: false,
          decoration: new InputDecoration(
              filled: true,
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(12.0),
              ),
              hintText: 'Password'
          ),
          maxLength: 20,
        ),
      ),
      new Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: ButtonTheme(
            height: 60.0,
            child: RaisedButton(
                onPressed: () {
                  if (emailController == null || emailController.text.isEmpty) {
                    Fluttertoast.showToast(
                      msg: "Please Enter Your Email",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIos: 1,
                    );
                  } else if (passwordController == null || passwordController.text.length < 6) {
                    Fluttertoast.showToast(
                      msg: "Please Enter A Password\n(Minimum 6 characters)",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIos: 1,
                    );
                  } else {
                    if (isUserSigningUp) {
                      handleSignUp(widget.auth, emailController.text, passwordController.text)
                        .then((FirebaseUser user) {
                        Fluttertoast.showToast(
                          msg: "Account Created",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIos: 1,
                        );
                        Navigator.of(context).push(
                            new OnlineModeRoute(
                                'Logged In',
                                user,
                            )
                        );
                      });
                    } else {
                      handleSignInEmail(widget.auth, context, emailController.text, passwordController.text)
                          .then((FirebaseUser user) {
                        Navigator.of(context).push(
                            new OnlineModeRoute(
                                'Logged In',
                                user,
                            )
                        );
                      });
                    }
                  }
                },
                color: Colors.blue[200],
                textColor: Colors.black,
                child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Center(
                        child: new Text(widget.title, style: customFont(color: Colors.black87, fontsize: 12.0)),
                      ),
                    ]
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0)))
            ),
          )
      ),
    ];

    if (isUserSigningUp) {
      //Insert Name Field

    } else {
      //Add Forgot PW Button
      TextEditingController passwordResetController = new TextEditingController();
      myChildren.insert(2,
        Align(
          alignment: Alignment.centerRight,
          child: MaterialButton(
            child: const Text('Forgot Password?'),
            onPressed: () {
              showDialog<Null>(
                context: context,
                builder: (BuildContext context) {
                  return new AlertDialog(
                    title: Center(child: Text('Reset Password')),
                    titlePadding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
                    content: new TextField(
                      controller: passwordResetController,
                      autofocus: true,
                      decoration: new InputDecoration(
                          filled: true,
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(12.0),
                          ),
                          hintText: 'email@example.com'
                      ),
                      inputFormatters:[
                        //Limits length of textfield without showing length
                        LengthLimitingTextInputFormatter(254), //254 is max number of email chars
                      ],
                      onSubmitted: (text) {
                        resetPassword(widget.auth, passwordResetController.text);
                        Navigator.of(context).pop();
                      },
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
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
                        onPressed: () => Navigator.of(context).pop(),
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
                          resetPassword(widget.auth, passwordResetController.text);
                          Navigator.of(context).pop();
                        }
                      ),
                    ],
                  );
                },
              );
            },
          ),
        )
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: myChildren
      ),
    );
  }
}