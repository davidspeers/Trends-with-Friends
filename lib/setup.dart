import 'package:flutter/material.dart';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';

import 'query.dart';

class SetupPage extends StatefulWidget {
  SetupPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SetupPageState createState() => new _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
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
    return _setupPageUI();
  }

  Widget _setupPageUI() {
    final title = 'Grid List';
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
                _pushGame(index);
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
    List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(data);
    List<List<dynamic>> randomWords = (rowsAsListOfValues..shuffle()).sublist(0,4);
    List<String> rndWords = convertCSV(randomWords);
    print(rndWords);
    themesMap['Random'] = rndWords;
  }

  List<String> convertCSV(List<List<dynamic>> csvList) {
    List<String> stringList = [];
    for (var csv in csvList) {
      String s = capitalize(csv[0].toString());
      stringList.add(s);
    }
    return stringList;
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  Future<String> getFileData(String path) async {
    return await rootBundle.loadString(path);
  }

  void _pushGame(int index) {
    Navigator.of(context).push(
        new MaterialPageRoute(
            builder: (context) {
              return new QueryPage(title: topics[index], terms: themesMap[topics[index]]);
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