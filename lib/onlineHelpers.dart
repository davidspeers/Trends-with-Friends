import 'package:flutter/material.dart';
import 'globals.dart' as globals;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'routes.dart';

import 'package:google_sign_in/google_sign_in.dart';

Future<FirebaseApp> handleFirebaseConnection() async {
  //Original pub instance creation (requires gradle dependency maintenance.
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  //Different from pub example - try establishing Firebase instance using Firebase_core
  //Found by downloading the json config file from the firebase console
  final FirebaseApp app = await FirebaseApp.configure(
      name: 'Trends',
      options: const FirebaseOptions(
          googleAppID: '1:639028185553:android:d39396698da6d498',
          gcmSenderID: '639028185553',
          databaseURL: 'https://trends-82164.firebaseio.com',
          apiKey: 'AIzaSyDALhMwWfwoGth6Snzds7NvNZeGq8hrQZE'
      )
  );
  globals.firebaseApp = app;
  return app;
}

Future<FirebaseUser> handleGoogleSignIn() async {

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final FirebaseAuth _auth = FirebaseAuth.fromApp(globals.firebaseApp);

  GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  FirebaseUser user = await _auth.signInWithGoogle(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  return user;
}

Future<FirebaseUser> handleSignInEmail(FirebaseAuth _auth, BuildContext context, String email, String password) async {

  final FirebaseUser user = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password)
    .catchError((e) {
      if (e.toString() == 'PlatformException(exception, There is no user record corresponding to this identifier. The user may have been deleted., null)') {
        showDialog<Null>(
          context: context,
          builder: (BuildContext context) {
            return new AlertDialog(
              content: Text('No Account exists with this email.\n'
                  'Would you like to create an account with this email and password?'),
              contentPadding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
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
                      handleSignUp(_auth, email, password);
                      Navigator.of(context).pop();
                      Fluttertoast.showToast(
                        msg: "Account Created",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 1,
                      );
                    }
                ),
              ],
            );
          },
        );
      } else if (e.toString() == 'PlatformException(exception, The password is invalid or the user does not have a password., null)') {
        Fluttertoast.showToast(
          msg: "Incorrect Password",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
        );
      }
      else {
        print('@@@' + e.toString() + '@@@');
      }
  });

  assert(user != null);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);

  print('signInEmail succeeded: $user');

  return user;

}

Future<FirebaseUser> handleSignUp(FirebaseAuth _auth, email, password) async {

  //email.trim() as if you have whitespace in the email then it'll be in the wrong format
  final FirebaseUser user = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password)
      .catchError((e) {
    if (e.toString() == 'PlatformException(exception, The email address is already in use by another account., null)') {
      Fluttertoast.showToast(
        msg: "This email address is already in use.\nIf you own the email address try logging in instead.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
      );
    }
    print('@@@' + e.toString() + '@@@');
  });

  assert (user != null);
  assert (await user.getIdToken() != null);

  return user;

}

//Believe this isn't a needed function
/*Future<bool> isEmailRegistered(FirebaseAuth _auth, email) async {
  print('In here??');
  List<String> values = await _auth.fetchProvidersForEmail(email: email);
  print('Still here??');
  print(values);
  values.forEach((value) => print('@@@@@@@@@@@@' + value));
  print('Now??');
}*/

void resetPassword(FirebaseAuth _auth, String email) {
  _auth.sendPasswordResetEmail(email: email.trim())
      .then((success) {
    Fluttertoast.showToast(
      msg: "Password Reset Email Sent",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 1,
    );
  })
      .catchError((e) {
    Fluttertoast.showToast(
      msg: "Invalid Email",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 1,
    );
  });
}