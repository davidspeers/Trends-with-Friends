import 'package:flutter/material.dart';
import 'main.dart';
import 'result.dart';

import 'customWidgets.dart';
import 'functions.dart';
import 'fontStyles.dart';

import 'dart:async';


class QueryPage extends StatefulWidget {
  QueryPage({Key key, this.title, this.terms}) : super(key: key);

  final String title;
  final List<String> terms;

  @override
  _QueryPageState createState() => new _QueryPageState();
}

class _QueryPageState extends State<QueryPage> {
  //Text Controller Retrieves the current value
  final myController = new TextEditingController();
  var bgColor = Colors.blueAccent[200];
  var teamNum = 1;
  var queries = {}; // This is a Map
  var termIndex = 0;
  var score = 0;
  List<int> results = [];

  @override
  void dispose() {
    // Clean up the controller when Widget is disposed
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _queryPageUI();
  }

  Widget _queryPageUI() {
    return Scaffold(
      appBar: new AppBar(
        leading: homeIcon(context),
        title: new Text('Retrieve Text Input ${widget.title}'),
      ),
      body: new Padding(
          padding: const EdgeInsets.all(16.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,//align left
            children: <Widget>[
              new Text(
                  "Team $teamNum",
                  style: whiteText
              ),
              new Text(
                "Match 1 word with:\n${widget.terms[termIndex]}",
                style: whiteTextSmall,
              ),
              new TextField(
                controller: myController,
                autofocus: true,
                decoration: new InputDecoration(
                  fillColor: Colors.yellow,
                  filled: true,
                  contentPadding: new EdgeInsets.fromLTRB(
                      10.0, 30.0, 10.0, 10.0
                  ),
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(12.0),
                  ),
                  hintText: 'Please Enter Term'
                ),
              ),
            ],
          )
      ),
      backgroundColor: bgColor,
      floatingActionButton: new FloatingActionButton(
        // When the user presses the button, show an alert dialog with the
        // text the user has typed into our text field.
        // The async and await stuff is there so that the widget doesn't update
        // until the widget is popped back. There may be a better way of doing this.
        onPressed: () async {
          queries[teamNum] = myController.text + " " + widget.terms[termIndex];
          if (teamNum < 2) {
            setState(() {
              bgColor = Colors.redAccent[200];
              teamNum++;
              myController.text = "";
            });
          } else {
            // List<int> scores returned from results.dart
            if (termIndex < widget.terms.length-1) {
              List<int> scores = await _pushResults(false);
              setState(() {
                bgColor = Colors.blueAccent[200];
                teamNum--;
                myController.text = "";
                termIndex++;
              });
              results = addLists(results, scores);
            } else {
              _pushResults(true);
            }
          }
        },
        tooltip: 'Show me the value!',
        child: new Icon(Icons.send),
      ),
    );
  }

  Future _pushResults(bool lastQuery) {
    return Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return new ResultsPage(
            title: "Hello", queries: [queries[1], queries[2]], lastQuery: lastQuery, previousResults: results);
        }
      )
    );
  }

}

