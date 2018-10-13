import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:io';

import 'routes.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

class OnlineLoginPage extends StatefulWidget {
  OnlineLoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _OnlineLoginPageState createState() => new _OnlineLoginPageState();
}

class _OnlineLoginPageState extends State<OnlineLoginPage> {
  Future<String> _handleGoogleSignIn() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    FirebaseUser user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return user.displayName;
  }

  Future<String> _message = Future<String>.value('');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MaterialButton(
            child: const Text('Test signInWithGoogle'),
            onPressed: () {
              setState(() {
                _message = _handleGoogleSignIn()
                    .then((String user) {
                      Navigator.of(context).push(
                        new OnlineModeRoute(
                          'Logged In'
                        )
                      );
                    })
                    .catchError((e) => print(e));
              });
            }
          ),
          FutureBuilder<String>(
              future: _message,
              builder: (_, AsyncSnapshot<String> snapshot) {
                return Text(snapshot.data ?? '',
                    style:
                    const TextStyle(color: Color.fromARGB(255, 0, 155, 0)));
              }),
        ],
      ),
    );
  }
}