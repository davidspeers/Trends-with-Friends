import 'package:flutter/material.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

import 'query.dart';
import 'routes.dart';
import 'customWidgets.dart';
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
  List<String> headings = ["Themed Levels", "Random Levels", "Custom Levels"];

  Map myThemesMap = {
    'Star Wars': ["Saber", "Force", "Blaster", "Jedi", "Speeder"],//, "Space", "Emperor", "Projection"]
    'Star War': ["Saber", "Force", "Blaster", "Jedi", "Speeder"],//, "Space", "Emperor", "Projection"]
    'Star Was': ["Saber", "Force", "Blaster", "Jedi", "Speeder"],//, "Space", "Emperor", "Projection"]
    'Star Wrs': ["Saber", "Force", "Blaster", "Jedi", "Speeder"],//, "Space", "Emperor", "Projection"]
  };

  //The following code instantiates my customThemesMap
  Map customThemesMap = {};
  List<String> customThemeTitles;
  getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    customThemeTitles = prefs.getStringList("CustomThemes") ?? [];
    customThemeTitles.forEach((title) {
      customThemesMap[title] = prefs.getStringList(title);
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
    _getKeys(myThemesMap),
    ["Random Nouns", "Random Show Theme", "Random Words From Show Themes", "Random Custom Theme", "Random Words From Custom Themes"],
    _getKeys(customThemesMap)
    ];

    return new Scaffold(
      appBar: new AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blue,
      ),
      body: new Builder(builder: (BuildContext context) {
        return new CustomScrollView(slivers: _buildSlivers(context));
      }),
    );
  }

  List<Widget> _buildSlivers(BuildContext context) {
    List<Widget> slivers = new List<Widget>();

    int i = 0;
    slivers.addAll(_buildLists(context, i, i+=myLists.length, myLists));
    //slivers.addAll(_buildGrids(context, i, i += 3));
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

  /*List<Widget> _buildGrids(BuildContext context, int firstIndex, int count) {
    return List.generate(count, (sliverIndex) {
      sliverIndex += firstIndex;
      return new SliverStickyHeader(
        header: _buildHeader(sliverIndex),
        sliver: new SliverGrid(
          gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 4.0, mainAxisSpacing: 4.0),
          delegate: new SliverChildBuilderDelegate(
                (context, i) => GestureDetector(
              onTap: () => Scaffold.of(context).showSnackBar(
                  new SnackBar(content: Text('Grid tile #$i'))),
              child: new GridTile(
                child: Card(
                  child: new Container(
                    color: Colors.green,
                  ),
                ),
                footer: new Container(
                  color: Colors.white.withOpacity(0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: new Text(
                      'Grid tile #$i',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
            childCount: 9,
          ),
        ),
      );
    });
  }*/

  Widget _buildHeader(int index, List<String> headings) {
    return new Container(
      height: 60.0,
      color: Colors.lightBlue,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.centerLeft,
      child: new Text(
        headings[index],
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  List<String> _getKeys(Map map) {
    List<String> topics = [];
    map.forEach((k,v) => topics.add(k));
    return topics;
  }

  void _pushGame(int headingIndex, int index, String mode, var alertChoice) {
    switch (headings[headingIndex]) {
      case "Themed Levels": {
        globals.isShowTheme = true;
        globals.isRandomTheme = false;
        globals.isCustomTheme = false;
        globals.chosenThemeName = myLists[headingIndex][index];
        Navigator.of(context).push(
          new QueryPageRoute(
            title: myLists[headingIndex][index],
            terms: myThemesMap[myLists[headingIndex][index]],
            mode: mode,
            alertChoice: alertChoice
          )
        );
        break;
      }
      case "Random Levels": {
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
            Navigator.of(context).push(
              new QueryPageRoute(
                title: myLists[headingIndex][index],
                futureTerms: randomWords,
                mode: mode, alertChoice:
                alertChoice,
              )
            );
            break;
          }
          case 'Random Show Theme': {
            String randomTheme = randomKey(myThemesMap);
            Navigator.of(context).push(
              new QueryPageRoute(
                title: randomTheme,
                terms: myThemesMap[randomTheme],
                mode: mode,
                alertChoice: alertChoice,
              )
            );
            break;
          }
          case 'Random Words From Show Themes': {
            List<String> randomWords = [];
            for (int i=0; i<8; i++) {
              List<String> randomValues = randomValFromMap(myThemesMap);
              randomWords.add(randomValFromList(randomValues));
            }
            Navigator.of(context).push(
                new QueryPageRoute(
                    title: 'Random Show Words',
                    terms: randomWords,
                    mode: mode,
                    alertChoice: alertChoice,
                )
            );
            break;
          }
          case 'Random Custom Theme': {
            String randomTheme = randomKey(customThemesMap);
            Navigator.of(context).push(
                new QueryPageRoute(
                    title: randomTheme,
                    terms: customThemesMap[randomTheme],
                    mode: mode,
                    alertChoice: alertChoice,
                )
            );
            break;
          }
          case 'Random Words From Custom Themes': {
            List<String> randomWords = [];
            for (int i=0; i<8; i++) {
              List<String> randomValues = randomValFromMap(customThemesMap);
              randomWords.add(randomValFromList(randomValues));
            }
            Navigator.of(context).push(
                new QueryPageRoute(
                    title: 'Random Custom Words',
                    terms: randomWords,
                    mode: mode,
                    alertChoice: alertChoice,
                )
            );
            break;
          }
        }
        break;
      }
      case "Custom Levels": {
        globals.isShowTheme = false;
        globals.isRandomTheme = false;
        globals.isCustomTheme = true;
        globals.chosenThemeName = myLists[headingIndex][index];
        Navigator.of(context).push(
          new QueryPageRoute(
            title: myLists[headingIndex][index],
            terms: customThemesMap[myLists[headingIndex][index]],
            mode: mode,
            alertChoice: alertChoice
          )
        );
        break;
      }
      default: {
        print("Heading Error - the heading was incorrect (${headings[headingIndex]}) ");
      }
    }
  }

  Future<List<String>> getRandomWords() async {
    String data = await getFileData('assets/csv/word-freq-top4999.csv');
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