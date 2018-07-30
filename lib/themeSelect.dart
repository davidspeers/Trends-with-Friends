import 'package:flutter/material.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';

import 'query.dart';

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
  List<String> modes = ["Random", "TV", "Movies", "Politics", "Harry Potter", "Future", "Muppets", "Animals"];
  //add const to the map if you find out a way to take random out of the map
  var themesMap = {
    'Random': [""],
    'Star Wars': ["Saber", "Force", "Blaster", "Jedi", "Speeder"]//, "Space", "Emperor", "Projection"]
  };
  //var topics = _allTopics(themesMap);
  List<String> topics;

  @override
  Widget build(BuildContext context) {
    return _themeSelectPageUI();
  }

  Widget _themeSelectPageUI() {
    final title = widget.mode;
    topics = _allTopics(themesMap);

    return new Scaffold(
        appBar: new AppBar(
          title: new Text(title),
        ),
        body: new GridView.count(
          // Create a grid with 2 columns. If you change the scrollDirection to
          // horizontal, this would produce 2 rows.
          crossAxisCount: 2,
          // Generate 100 Widgets that display their index in the List
          children: new List.generate(topics.length, (index) {
            return new RaisedButton(
              onPressed: () {
                if (index == 0) {
                  getRandomWords();
                }
                _pushGame(index, widget.mode, widget.alertChoice);
              },
              child: new Text(
                '${topics[index]}',
                style: Theme.of(context).textTheme.headline,
              ),
            );
          }),
        ),
    );
  }

  void getRandomWords() async {
    String data = await getFileData('csv/word-freq-top4999.csv');
    List<String> rowsAsList = data.split("\n");
    List<String> randomWords = capitaliseList((rowsAsList..shuffle()).sublist(0, 4));
    themesMap['Random'] = randomWords;
  }

  List<String> capitaliseList(List<String> strings) {
    for (var i = 0; i < strings.length; i++) {
      strings[i] = capitalise(strings[i]);
    }
    return strings;
  }

  String capitalise(String s) => s[0].toUpperCase() + s.substring(1);

  Future<String> getFileData(String path) async {
    return await rootBundle.loadString(path);
  }

  void _pushGame(int index, String mode, var alertChoice) {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return new QueryPage(title: topics[index], terms: themesMap[topics[index]], mode: mode, alertChoice: alertChoice,);
        }
      )
    );
  }

  List<String> _allTopics(Map map) {
    List<String> topics = [];
    map.forEach((k,v) => topics.add(k));
    return topics;
  }

}