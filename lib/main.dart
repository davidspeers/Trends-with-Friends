import 'package:flutter/material.dart';
import 'modeSelect.dart';
import 'addLevel.dart';
import 'achievements.dart';

import 'package:flutter/cupertino.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Google Trends Game',
      theme: new ThemeData(
          primarySwatch: Colors.blue, primaryColor: new Color(0xffd05c6b)),
      home: new HomePage(title: 'Trends Game Home Page'),
      routes: <String, WidgetBuilder>{
        '/mode': (BuildContext context) => new ModeSelectPage(title: "Mode Select"),
        '/addLevel': (BuildContext context) => new AddLevelPage(title: "Custom Levels"),
        '/achievements': (BuildContext context) => new AchievementsPage(title: "Custom Levels"),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: _homePageUI()
    );
  }

  Widget _homePageUI() {
    final List<Color> colors = [Colors.blue, Colors.red, Colors.yellow, Colors.green, Colors.purple];
    final List<String> buttons = ["Start", "Tutorial", "Add Level", "Achievements", "About"];

    List<Widget> myChildren = [
      new Image.asset('assets/images/TrendsWithFriendsLogo.png')
    ];

    for (int i=0; i<buttons.length; i++) {
      myChildren.add(customButton(buttons[i], colors[i]));
    }

    return new Center(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: myChildren
      ),
    );
  }

  Widget customButton(String text, Color color) {
    return new MaterialButton(
      onPressed: () => _pushSelected(text),
      height: 70.0,
      minWidth: double.infinity,
      color: color,
      textColor: Colors.black,
      child: new Text(text),
      splashColor: Colors.redAccent, //hold button to see
    );
  }

  void _pushSelected(String choice) {

    switch (choice) {
      case "Add Level":
        Navigator.of(context).pushNamed('/addLevel');
        break;

      case "Achievements":
        Navigator.of(context).pushNamed('/achievements');
        break;

      default:
        /*Navigator.of(context).push(
            new MaterialPageRoute(
                builder: (context) {
                  return new ModeSelectPage(title: "Hello");
                }
            )
        );*/
        /*Navigator.of(context).push(new PageRouteBuilder(
            opaque: true,
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (BuildContext context, _, __) {
              return new ModeSelectPage(title: "Hello");
            },
            transitionsBuilder: (_, Animation<double> animation, __, Widget child) {

              return new SlideTransition(
                child: child,
                position: new Tween<Offset>(
                  begin: const Offset(-1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
              );
            }
        ));*/
        //Navigator.of(context).push(new SecondPageRoute());
        Navigator.of(context, rootNavigator: true).push(
          new CupertinoPageRoute<bool>(
            //in ios a fullScreenDialog is a new page that comes in from the bottom and comes up and is designed
            //to be exited with an x in the top left. Setting fullscreendialog to true does a cupertino
            //bottom to top animation, else it does an ios-typical left to right transition
            fullscreenDialog: false,
            builder: (BuildContext context) => new ModeSelectPage(title: "hello"),
          )
        );
    }
  }

}

//This makes the android transition look like iOS double check and see which one you prefer
// Solution found here: https://stackoverflow.com/questions/50196913/how-to-change-navigation-animation-using-flutter/50208048#50208048
// The solution includes a bit about changing the animation
class SecondPageRoute extends CupertinoPageRoute {
  SecondPageRoute()
      : super(builder: (BuildContext context) => new ModeSelectPage(title: "hello"));

}

