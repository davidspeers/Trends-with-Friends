import 'package:flutter/material.dart';
import 'result.dart';

import 'customWidgets.dart';
import 'functions.dart';
import 'fontStyles.dart';

import 'dart:async';


class QueryPage extends StatefulWidget {
  QueryPage({Key key, this.title, this.terms, this.mode, this.alertChoice}) : super(key: key);

  final String title;
  final List<String> terms;
  final String mode;
  final dynamic alertChoice;

  @override
  _QueryPageState createState() => new _QueryPageState();
}

class _QueryPageState extends State<QueryPage> {
  //Text Controller Retrieves the current value
  final myController = new TextEditingController();
  final List<Color> bgColors = [Colors.blueAccent[200], Colors.redAccent[200], Colors.yellowAccent[200], Colors.greenAccent[200], Colors.purpleAccent[200]];
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
    List<Widget> children = [
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
        )
      )
    ];
    if (widget.mode == "Party Mode") {
      children.insert(
        0,
        new Text(
          "Team $teamNum",
          style: whiteText
        )
      );
    }

    return Scaffold(
      appBar: new AppBar(
        leading: homeIcon(context),
        title: new Text('Retrieve Text Input ${widget.title}'),
      ),
      body: new Padding(
          padding: const EdgeInsets.all(16.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,//align left
            children: children
          )
      ),
      backgroundColor: bgColor,
      floatingActionButton: new FloatingActionButton(
        // When the user presses the button, show an alert dialog with the
        // text the user has typed into our text field.
        // The async and await stuff is there so that the widget doesn't update
        // until the widget is popped back. There may be a better way of doing this.
        onPressed: () async {
          switch (widget.mode) {
            case ("Party Mode"): {
              queries[teamNum] = myController.text + " " + widget.terms[termIndex];
              if (teamNum < widget.alertChoice) {
                setState(() {
                  bgColor = bgColors[teamNum];
                  teamNum++;
                  myController.text = "";
                });
              } else {
                // List<int> scores returned from results.dart
                if (termIndex < widget.terms.length-1) {
                  List<int> scores = await _pushResults(false);
                  setState(() {
                    bgColor = bgColors[0];
                    teamNum = 1;
                    myController.text = "";
                    termIndex++;
                  });
                  results = addLists(results, scores);
                } else {
                  _pushResults(true);
                }
              }
              break;
            }

            case ("CPU Mode"): {
              queries["User Answer"] = myController.text + " " + widget.terms[termIndex];
              if (termIndex < widget.terms.length-1) {
                List<int> scores = await _pushResults(false);
                myController.text = "";
                termIndex++;
                results = addLists(results, scores);
              } else {
                _pushResults(true);
              }
              break;
            }
          }

        },
        tooltip: 'Show me the value!',
        child: new Icon(Icons.send),
      ),
    );
  }

  Future _pushResults(bool lastQuery) {
    //Converts map to List
    List<String> queriesList = new List<String>.from(queries.values.toList());
    return Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return new ResultsPage(
            title: "Hello", queries: queriesList, lastQuery: lastQuery, previousResults: results, term: widget.terms[termIndex], mode: widget.mode, alertChoice: widget.alertChoice
          );
        }
      )
    );
  }

}

