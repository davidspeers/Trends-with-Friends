import 'dart:ui';
import 'dart:async';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

import 'functions.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'fontStyles.dart';

import 'package:flutter/cupertino.dart';

import 'animations.dart';
import 'globals.dart' as globals;

import 'routes.dart';

String txt = "If this is your first time playing Trends With Friends - welcome..."
    "or you've never used GT before we recommend you press the ? and read the How To Play section";

void main() => runApp(new MyApp());

//Adding this as a behaviour removes the default blue glow when overscrolling a ListView on android.
//Then I can add my own custom color without it mixing with the blue. Using GlowingOverscrollIndicator
class removeListGlowingOverscroll extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //This code gets the default flutter background code
    //ThemeData x = new ThemeData();
    //print(x.scaffoldBackgroundColor);
    return new MaterialApp(
      title: 'Google Trends Game',
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: removeListGlowingOverscroll(),
          child: child,
        );
      },
      theme: new ThemeData(
          primarySwatch: Colors.blue, primaryColor: new Color(0xffd05c6b)),
      home: new AnimatedHome(),
    );
  }
}

class AnimatedHome extends StatefulWidget {
  @override
  AnimatedHomeState createState() => new AnimatedHomeState();
}

//Global Variables - can instead put them in constructor of AnimatedPainter
double _screenWidth;
double _screenHeight;
List<Color> myColors = [
  Colors.blue,
  Colors.red,
  Colors.green,
  //Colors.yellow,
  Colors.purple[400],
];

class AnimatedHomeState extends State<AnimatedHome> with TickerProviderStateMixin, WidgetsBindingObserver{
  AnimationController _controller;

  //Tests Trendmaster Achievement unlock. Search for floatingactionbar to find function caller
  /*List<String> allAchievements = [
    //All Achievements, except final one
    "My First Achievement",
    "Trends Newbie",
    "Trends Novice",
    "Trends Pro",
    "Trends with Friends",
    "Peake Score",
    "Quintessential Gamer",
    "Trends Setter",
    "Pro Trends Setter",
    "Trends Getter",
    "Complete the Show",
    "Same Choice, Different Outcome",
    "Beat the Machine",
    "Beat the Harder Machine",
    "Beat the Hardest Machine",
  ];
  unlockAllAchievements() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    allAchievements.forEach((string) => prefs.setBool(string, true));
  }*/

  ///Main State Var Inits
  //You had to do this weird global thing because variables in stackButton seemed to being reset to initial values
  Map<String,int> modeToChoiceIndexMap = {
    'Party Mode': 0,
    'CPU Mode': 1
  };

  getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    modeToChoiceIndexMap['Party Mode'] = prefs.getInt('numPlayers') ?? 0;
    modeToChoiceIndexMap['CPU Mode'] = prefs.getInt('difficulty') ?? 1;
  }

  setSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('numPlayers',  modeToChoiceIndexMap['Party Mode']);
    prefs.setInt('difficulty', modeToChoiceIndexMap['CPU Mode']);
  }

  //Color scheme 1A
  //Color mainButtonColor = Colors.yellow[200];
  //Color secondaryButtonColor = Colors.green;
  //Color scheme 1B
  //Color mainButtonColor = Colors.green[200];
  //Color secondaryButtonColor = Colors.black87;
  //Color partyButtonBg = Colors.blue[400];
  //Color cpuButtonBg = Colors.red[400];
  //Color scheme 2
  //Color mainButtonColor = Colors.green[500];
  Color playButtonColor = Colors.blue[400];
  Color changeValButtonColor = Colors.blue[400];
  Color aboutButtonColor = Colors.red[400];
  Color bottomButtonsColor = Colors.green[400];
  Color cardColor = Color.fromRGBO(210, 210, 210, 0.9);
  Color secondaryButtonColor = Colors.black87;
  Color partyButtonBg = Colors.blue[300];
  Color cpuButtonBg = Colors.red[300];
  Widget customIconButton({
    @required IconData iconImage,
    @required double size,
    @required VoidCallback myOnPressed,
    @required Color mainColor}
      ) {
    Color splashColor;
    if (iconImage == Icons.help) {
      splashColor = Colors.redAccent[100];
    } else {
      splashColor = Colors.blueAccent[100];
    }

    return new Stack(
        children: <Widget>[
          new IconButton(
            icon: new Icon(Icons.brightness_1, color: secondaryButtonColor),
            iconSize: size,
            onPressed: myOnPressed,
            padding: EdgeInsets.only(top: 0.0),
          ),
          new IconButton(
            //icon: new Icon(iconImage, color: mainButtonColor),
            icon: new Icon(iconImage, color: mainColor),
            iconSize: size,
            onPressed: myOnPressed,
            padding: EdgeInsets.only(top: 0.0),
            splashColor: splashColor,
            highlightColor: splashColor,
          ),
        ]
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = new AnimationController(
      duration: Duration(seconds: 8),
      vsync: this,
    );
    //This code automatically starts the animation
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _startAnimation());
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  ///This code is flutters' onPause and onResume check.
  ///This override is obtained by adding the WidgetsBindingObserver
  ///I've done this so the animation stops upon app closure, thus not using
  ///up unnecessary cpu
  ///For more information look at:
  /// https://docs.flutter.io/flutter/widgets/WidgetsBindingObserver-class.html
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      //There is also paused and suspending but those states are transitioned to
      //from inactive to unnecessary to check
      _controller.stop();
    } else {
      _startAnimation();
    }
  }

  Future<void> _startAnimation() async {
    _controller.stop();
    ///This works really well - because Dart is single-threaded what's happening
    ///is the code below the await doesn't run until _controller.forward is finished.
    ///At this point I can change my values, reset the controller and the
    ///while loop continues creating another animation with the new values.
    ///Note: the importance of async and await
    print(_screenHeight);
    while (true) {
      _controller.reset();
      globals.globalLines = [];
      int numberOfPoints = randomRange(4, 6);
      double maximumChange = _screenHeight/4;
      double yMin;
      double yMax;
      List<Offset> points; // Is used to keep track on points in for loop
      myColors..shuffle();
      for (int i = 0; i<2; i++) {
        points = [];
        //Add initial point
        points.add(Offset(-10.0, randomDouble(_screenHeight)));
        for (int i = 1; i<numberOfPoints; i++) {
          ///This if-else statement means the line doesn't jump more than
          ///maximumChange from point to point and that the line doesn't
          ///move outside the widgets' bounds
          if (points[i-1].dy < maximumChange) {
            yMin = 0.0;
            yMax = points[i-1].dy + maximumChange;
          } else if (points[i-1].dy > _screenHeight-maximumChange) {
            yMin = points[i-1].dy - maximumChange;
            yMax = _screenHeight;
          } else {
            yMin = points[i-1].dy - maximumChange;
            yMax = points[i-1].dy + maximumChange;
          }
          //Last point needs a slight dx increase
          if (i == numberOfPoints-1) {
            points.add(
                Offset(_screenWidth+10.0, randomDoubleRange(yMin, yMax))
            );
          } else {
            points.add(
                Offset(i*_screenWidth/(numberOfPoints-1), randomDoubleRange(yMin, yMax))
            );
          }
        }
        globals.globalLines.add(new globals.Line(
            points,
            myColors[i]
        ));
      }
      //sleep(const Duration(milliseconds: 400));

      await _controller.forward();


    }
  }

  @override
  Widget build(BuildContext context) {
    double appBarHeight = 100.0;
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height - appBarHeight-50.0;
    return new Scaffold(
      //PreferredSize increases the appBar height which then allows me to use padding
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBarHeight),
          child: new Padding(
            padding: EdgeInsets.only(top: 30.0),
            child: new AppBar(
              //title: new Text(widget.title),
              title: new Image.asset('assets/images/TrendsWithFriendsLogo.png', height: 100.0),
              centerTitle: true,
              elevation: 0.0, //Removes shadow on bottom of appbar
              backgroundColor: Color(0xfffafafa),
              actions: <Widget>[
                customIconButton(
                    iconImage: Icons.help,
                    size: 45.0,
                    myOnPressed: () => Navigator.of(context).push(AboutPageRoute()),
                    mainColor: aboutButtonColor
                )
              ],
            ),
          )
      ),
      body: new CustomPaint(
        painter: new LinesPainter(_controller),
        child: _homePageUI(),
      ),
      /*Test Achievement Unlocking
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          unlockAllAchievements();
        },
        child: new Icon(Icons.title),
      )*/
    );
  }

  ///Main functions
  Widget stackedButton({@required String mode}) {
    String selectionTextHeading;
    List<String> listChoices;
    double choiceFontSize;
    Color myColor;

    switch (mode) {
      case "Party Mode": {
        selectionTextHeading = "Number of Players:";
        listChoices = ['2', '3', '4', '5'];
        choiceFontSize = 18.0;
        myColor = partyButtonBg;
        break;
      }
      case "CPU Mode": {
        selectionTextHeading = "Difficulty:";
        listChoices = ['Easy', 'Normal', 'Hard', 'Impossible'];
        choiceFontSize = 14.0;
        myColor = cpuButtonBg;
        break;
      }
      default: {
        print("Error - Mode doesn't match switch statement");
      }
    }

    return new Stack(
      children: <Widget>[
        //Can't use Container because it isn't a Material Widget and so
        //Any animations of button presses are obscured by the container
        new Card(
          //height: 150.0,
          //width: double.infinity,
          //color: myColor,
          //color: Colors.transparent,
          color: cardColor,
          elevation: 0.0,//when using translucent colors elevation border can make it look blurred. Also, color loses greyness when set to 0.0
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0))),
          //decoration: BoxDecoration(color: globalColors[0], borderRadius: BorderRadius.all(Radius.circular(30.0))),
          // alignment: FractionalOffset.center,
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Text(mode, style: customFont(color: Colors.black87, fontsize: 12.0)),
              new Text(selectionTextHeading, style: customFont(color: Colors.black87, fontsize: 8.0)),
              new Row(
                children: <Widget>[
                  new Padding(padding: EdgeInsets.only(left: 45.0)),
                  customIconButton(
                    iconImage: Icons.remove_circle,
                    size: 40.0,
                    myOnPressed: () {
                      if (modeToChoiceIndexMap[mode] > 0) {
                        setState(() {
                          modeToChoiceIndexMap[mode] = modeToChoiceIndexMap[mode]-1;
                        });
                      }
                    },
                    mainColor: changeValButtonColor
                  ),
                  new Expanded(
                      child: new Center(
                        child: Text(listChoices[modeToChoiceIndexMap[mode]], style: customFont(color: Colors.black, fontsize: choiceFontSize)),
                      )
                  ),
                  customIconButton(
                    iconImage: Icons.add_circle,
                    size: 40.0,
                    myOnPressed: () {
                      if (modeToChoiceIndexMap[mode] < 3) {
                        setState(() {
                          modeToChoiceIndexMap[mode] = modeToChoiceIndexMap[mode]+1;
                        });
                      }
                    },
                    mainColor: changeValButtonColor
                  ),
                  new Padding(padding: EdgeInsets.only(right: 45.0)),
                ],
              ),
              customIconButton(iconImage: Icons.play_circle_filled, size: 60.0, myOnPressed: () {
                _pushSelected(mode, alertChoice: listChoices[modeToChoiceIndexMap[mode]]);
              }, mainColor: playButtonColor)
            ],
          ),
        ),
      ],
    );


  }

  Widget _homePageUI() {

    final List<String> buttons = ["Themes Creator", "Achievements"];

    List<Widget> myButtons = [];

    for (int i=0; i<buttons.length; i++) {
      myButtons.add(customButton(buttons[i]));
    }

    List<Widget> myChildren = [
      /*new Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
        child: new Image.asset('assets/images/TrendsWithFriendsLogo.png', height: 50.0,),
      )*/
      new Expanded(child: Container()),
      new Padding(
          padding: EdgeInsets.all(8.0),
          child: stackedButton(mode: "Party Mode")
      ),
      new Padding(
          padding: EdgeInsets.all(8.0),
          child: stackedButton(mode: "CPU Mode")
      ),
      new Expanded(child: Container()),
      new Row(
        children: <Widget>[
          new Expanded(child: myButtons[0]),
          new Expanded(child: myButtons[1]),
        ],
      ),
    ];

    /*myChildren.add(
      new Padding(
        padding: const EdgeInsets.all(16.0),
        child: new Column(
          children: myButtons,
        ),
      )
    );*/

    return new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: myChildren
    );
  }

  Widget customButton(String text) {
    EdgeInsets myPadding;
    if (text == 'Themes Creator') {
      myPadding = EdgeInsets.fromLTRB(16.0, 0.0, 8.0, 16.0);
    } else if (text == 'Achievements') {
      myPadding = EdgeInsets.fromLTRB(8.0, 0.0, 16.0, 16.0);
    } else {
      print('Error customButton text doesn\'t match');
    }
    return new Padding(
        padding: myPadding,
        child: ButtonTheme(
          height: 60.0,
          child: RaisedButton(
              onPressed: () => _pushSelected(text),
              color: bottomButtonsColor,
              textColor: secondaryButtonColor,
              child: new Text(text, style: customFont(color: Colors.black87, fontsize: 7.0)),
              //splashColor: globalColorsToAccent[color], //hold button to see
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0)))
          ),
        )
    );

  }

  void _pushSelected(String choice, {var alertChoice}) {

    switch (choice) {
      case "Themes Creator":
        Navigator.of(context).push(new ThemesCreatorPageRoute());
        break;

      case "Achievements":
        Navigator.of(context).push(new AchievementsPageRoute());
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
        //Navigator.of(context).push(new SecondPageRoute(5));
        print("Alert Choice: $alertChoice");
        print('Mode: $choice');
        if (choice == "Party Mode") {
          //Convert teams as a string to an int
          int numTeams;
          switch (alertChoice) {
            case '2': {numTeams = 2; break;}
            case '3': {numTeams = 3; break;}
            case '4': {numTeams = 4; break;}
            case '5': {numTeams = 5; break;}
          }
          alertChoice = numTeams;
          globals.cpuDifficulty = 0;
        } else if (choice == "CPU Mode") {
          switch (alertChoice) {
            case 'Easy': {
              globals.cpuDifficulty = 1;
              break;
            }
            case 'Normal': {
              globals.cpuDifficulty = 2;
              break;
            }
            case 'Hard': {
              globals.cpuDifficulty = 3;
              break;
            }
            case 'Impossible': {
              globals.cpuDifficulty = 4;
              break;
            }
          }
        }
        Navigator.of(context).push(new ThemeSelectRoute(alertChoice, choice));
    }
  }
}

