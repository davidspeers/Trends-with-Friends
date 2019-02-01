import 'package:flutter/material.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'routes.dart';
import 'customWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'functions.dart';
import 'globals.dart' as globals;

class ThemeSelectPage extends StatefulWidget {
  ThemeSelectPage({Key key, this.title, this.alertChoice, this.mode, this.teamName, this.roomName}) : super(key: key);

  final String title;
  final dynamic alertChoice;
  final String mode;
  final String teamName;
  final String roomName;

  @override
  _ThemeSelectPageState createState() => new _ThemeSelectPageState();
}

class _ThemeSelectPageState extends State<ThemeSelectPage> {
  //List<String> themes = ["TV", "Movies", "Politics", "Harry Potter", "Future", "Muppets", "Animals"];
  List<String> headings = ["Show Themes", "Random Themes", "Custom Themes"];

  //The following code instantiates my customThemesMap & Timer Settings
  Map customThemesMap = {};
  List<String> customThemeTitles;

  getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    globals.timerSetting = prefs.getInt('timerChoice') ?? 0;
    customThemeTitles = prefs.getStringList("CustomThemes") ?? [];
    customThemeTitles.forEach((title) {
      customThemesMap[title] = prefs.getStringList('Escape $title');
    });
    setState(() {
      customThemesMap;
    });
  }
  @override
  void initState() {
    getSharedPrefs();
    super.initState();
  }

  List<String> randomWordsList;

  var myLists;

  @override
  Widget build(BuildContext context) {

    //Non-static initialisation
    myLists = [
    _getKeys(globals.myThemesMap),
    ["Random Nouns", "Random Show Theme", "Random Words From Show Themes", "Random Custom Theme", "Random Words From Custom Themes"],
    _getKeys(customThemesMap)
    ];

    return new Scaffold(
      appBar: new AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blue,
        actions: (widget.mode != 'Online Mode') ? <Widget>[
          IconButton(
            icon: Icon(Icons.timer),
            onPressed: () {
              List<String> timerChoices = [
                'No Timer',
                '15 Seconds',
                '30 Seconds',
                '45 Seconds',
                '60 Seconds'
              ];
              showDialog<Null>(
                context: context,
                //barrierDismissible: true, // outside click dismisses alert
                builder: (BuildContext context) {
                  getSharedPrefs();
                  return SimpleDialog(
                    title: Container(
                      color: Colors.grey[50],
                      padding: EdgeInsets.all(5.0),
                      child: Text(
                        'Timer Settings',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    titlePadding: EdgeInsets.all(0.0),
                    contentPadding: EdgeInsets.all(0.0),
                    children: <Widget>[
                      RadioAlertDialog(buttonNames: timerChoices)
                    ],
                  );
                }
              );
            },
          )
        ] : null,
      ),
      body: new Builder(builder: (BuildContext context) {
        return new GlowingOverscrollIndicator(
            axisDirection: AxisDirection.down,
            color: Colors.blue,
            child: new CustomScrollView(slivers: _buildSlivers(context)
            )
        );
      }),
    );
  }

  List<Widget> _buildSlivers(BuildContext context) {
    List<Widget> slivers = new List<Widget>();

    slivers.addAll(_buildGrids(context, 0, 1, myLists)); //1 list starting at index 0
    if (widget.mode != 'Online Mode') {
      slivers.addAll(_buildLists(context, 1, 2, myLists)); //2 lists starting at index 1
    }
    return slivers;
  }

  List<Widget> _buildLists(BuildContext context, int firstIndex, int count, List<List<String>> lists) {
    return List.generate(count, (sliverIndex) {
      sliverIndex += firstIndex;
      return new SliverStickyHeader(
        //buildHeader found in customWidget.dart
        header: _buildHeader(sliverIndex, headings),
        sliver: new SliverList(
          delegate: new SliverChildBuilderDelegate(
                (context, i) => new ListTile(
              //leading: new CircleAvatar(child: new Text('$sliverIndex')),
              title: new Text(lists[sliverIndex][i]),
              onTap: () => _pushGame(sliverIndex ,i, widget.mode, widget.alertChoice)
            ),
            childCount: lists[sliverIndex].length,
          ),
        ),
      );
    });
  }

  List<Widget> _buildGrids(BuildContext context, int firstIndex, int count, List<List<String>> lists) {
    return List.generate(count, (sliverIndex) {
      sliverIndex += firstIndex;
      return new SliverStickyHeader(
        header: _buildHeader(sliverIndex, headings),
        sliver: new SliverGrid(
          gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 4.0, mainAxisSpacing: 4.0),
          delegate: new SliverChildBuilderDelegate(
                (context, i) => GestureDetector(
              onTap: () => _pushGame(sliverIndex ,i, widget.mode, widget.alertChoice),
              child: new GridTile(
                child: new Container(
                  color: Colors.blue[100],
                  child: Center(
                    //padding: const EdgeInsets.all(8.0),
                    child: new Text(
                      lists[sliverIndex][i],
                      style: const TextStyle(color: Colors.black, fontSize: 16.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            childCount: lists[sliverIndex].length,
          ),
        ),
      );
    });
  }

  Widget _buildHeader(int index, List<String> headings) {
    return new Container(
      height: 60.0,
      color: Colors.lightBlue,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.centerLeft,
      child: new Text(
        headings[index],
        style: const TextStyle(color: Colors.white, fontSize: 18.0),
      ),
    );
  }

  List<String> _getKeys(Map map) {
    List<String> topics = [];
    map.forEach((k,v) => topics.add(k));
    return topics;
  }

  void _pushGame([int headingIndex, int index, String mode, var alertChoice]) {
    if (mode == 'Online Mode') {
      //Just need to send the values to Firebase and have it handle things.
      globals.firebaseDB.child(widget.roomName).update({
        myLists[headingIndex][index] : globals.myThemesMap[myLists[headingIndex][index]]
      });
      /*Navigator.of(context).push(
          new OnlineGameRoute(widget.teamName, widget.roomName)
      );*/
    } else {
      //Reset Globals
      globals.termIndex = 0;
      if (mode == "Party Mode") {
        switch (alertChoice) {
          case 2: globals.totals = [0, 0]; break;
          case 3: globals.totals = [0, 0, 0]; break;
          case 4: globals.totals = [0, 0, 0, 0]; break;
          case 5: globals.totals = [0, 0, 0, 0, 0]; break;
        }
      } else {
        globals.totals = [0, 0];
      }
      switch (headings[headingIndex]) {
        case "Show Themes": {
          globals.isShowTheme = true;
          globals.isRandomTheme = false;
          globals.isCustomTheme = false;
          globals.chosenThemeName = myLists[headingIndex][index];
          if (globals.timerSetting == 0) {
            Navigator.of(context).push(
                new QueryPageRoute(
                    title: myLists[headingIndex][index],
                    terms: globals.myThemesMap[myLists[headingIndex][index]],
                    mode: mode,
                    alertChoice: alertChoice
                )
            );
          } else {
            Navigator.of(context).push(
                new TimerPageRoute(
                    title: myLists[headingIndex][index],
                    terms: globals.myThemesMap[myLists[headingIndex][index]],
                    mode: mode,
                    alertChoice: alertChoice
                )
            );
          }
          break;
        }
        case "Random Themes": {
          globals.isShowTheme = false;
          globals.isRandomTheme = true;
          globals.isCustomTheme = false;
          globals.chosenThemeName = myLists[headingIndex][index];
          //Note the importance of not calling the getRandomWords function inside
          //the Navigator.of because it is called every time the keyboard appears and disappears
          //(or device orientation etc.)
          switch (myLists[headingIndex][index]) {
            case 'Random Nouns': {
              Future<List<String>> randomWords = getRandomWords();
              if (globals.timerSetting == 0) {
                Navigator.of(context).push(
                    new QueryPageRoute(
                      title: myLists[headingIndex][index],
                      futureTerms: randomWords,
                      mode: mode, alertChoice:
                    alertChoice,
                    )
                );
              } else {
                Navigator.of(context).push(
                    new TimerPageRoute(
                      title: myLists[headingIndex][index],
                      futureTerms: randomWords,
                      mode: mode, alertChoice:
                    alertChoice,
                    )
                );
              }
              break;
            }
            case 'Random Show Theme': {
              String randomTheme = randomKey(globals.myThemesMap);
              if (globals.timerSetting == 0) {
                Navigator.of(context).push(
                    new QueryPageRoute(
                      title: randomTheme,
                      terms: globals.myThemesMap[randomTheme],
                      mode: mode,
                      alertChoice: alertChoice,
                    )
                );
              } else {
                Navigator.of(context).push(
                    new TimerPageRoute(
                      title: randomTheme,
                      terms: globals.myThemesMap[randomTheme],
                      mode: mode,
                      alertChoice: alertChoice,
                    )
                );
              }
              break;
            }
            case 'Random Words From Show Themes': {
              List<String> randomWords = [];
              for (int i=0; i<8; i++) {
                List<String> randomValues = randomValFromMap(globals.myThemesMap);
                randomWords.add(randomValFromList(randomValues));
              }
              if (globals.timerSetting == 0) {
                Navigator.of(context).push(
                    new QueryPageRoute(
                      title: 'Random Show Words',
                      terms: randomWords,
                      mode: mode,
                      alertChoice: alertChoice,
                    )
                );
              } else {
                Navigator.of(context).push(
                    new TimerPageRoute(
                      title: 'Random Show Words',
                      terms: randomWords,
                      mode: mode,
                      alertChoice: alertChoice,
                    )
                );
              }
              break;
            }
            case 'Random Custom Theme': {
              if (customThemesMap.isNotEmpty) {
                String randomTheme = randomKey(customThemesMap);
                if (globals.timerSetting == 0) {
                  Navigator.of(context).push(
                      new QueryPageRoute(
                        title: randomTheme,
                        terms: customThemesMap[randomTheme],
                        mode: mode,
                        alertChoice: alertChoice,
                      )
                  );
                } else {
                  Navigator.of(context).push(
                      new TimerPageRoute(
                        title: randomTheme,
                        terms: customThemesMap[randomTheme],
                        mode: mode,
                        alertChoice: alertChoice,
                      )
                  );
                }
              } else {
                Fluttertoast.showToast(
                  msg: "No Custom Themes Available",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIos: 1,
                );
              }
              break;
            }
            case 'Random Words From Custom Themes': {
              if (customThemesMap.isNotEmpty) {
                List<String> randomWords = [];
                for (int i = 0; i < 8; i++) {
                  List<String> randomValues = randomValFromMap(customThemesMap);
                  randomWords.add(randomValFromList(randomValues));
                }
                if (globals.timerSetting == 0) {
                  Navigator.of(context).push(
                      new QueryPageRoute(
                        title: 'Random Custom Words',
                        terms: randomWords,
                        mode: mode,
                        alertChoice: alertChoice,
                      )
                  );
                } else {
                  Navigator.of(context).push(
                      new TimerPageRoute(
                        title: 'Random Custom Words',
                        terms: randomWords,
                        mode: mode,
                        alertChoice: alertChoice,
                      )
                  );
                }
              } else {
                Fluttertoast.showToast(
                  msg: "No Custom Themes Available",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIos: 1,
                );
              }
              break;
            }
          }
          break;
        }
        case "Custom Themes": {
          globals.isShowTheme = false;
          globals.isRandomTheme = false;
          globals.isCustomTheme = true;
          globals.chosenThemeName = myLists[headingIndex][index];
          if (globals.timerSetting == 0) {
            Navigator.of(context).push(
                new QueryPageRoute(
                    title: myLists[headingIndex][index],
                    terms: customThemesMap[myLists[headingIndex][index]],
                    mode: mode,
                    alertChoice: alertChoice
                )
            );
          } else {
            Navigator.of(context).push(
                new TimerPageRoute(
                    title: myLists[headingIndex][index],
                    terms: customThemesMap[myLists[headingIndex][index]],
                    mode: mode,
                    alertChoice: alertChoice
                )
            );
          }
          break;
        }
        default: {
          print("Heading Error - the heading was incorrect (${headings[headingIndex]}) ");
        }
      }
    }
  }

  Future<List<String>> getRandomWords() async {
    String data = await getFileData('assets/csv/most-common-nouns-english.csv');
    List<String> rowsAsList = data.split("\n");
    List<String> randomWords = capitaliseList((rowsAsList..shuffle()).sublist(0, 10));
    print("randomWords - $randomWords");
    return randomWords;
  }

  Future<String> getFileData(String path) async {
    return await rootBundle.loadString(path);
  }

  List<String> capitaliseList(List<String> strings) {
    for (var i = 0; i < strings.length; i++) {
      strings[i] = capitalise(strings[i]);
    }
    return strings;
  }

  String capitalise(String s) => s[0].toUpperCase() + s.substring(1);

}