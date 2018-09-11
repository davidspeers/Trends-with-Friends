import 'package:flutter/material.dart';
import 'routes.dart';

import 'result.dart';
import 'customWidgets.dart';
import 'functions.dart';
import 'fontStyles.dart';


import 'dart:async';


class QueryPage extends StatefulWidget {
  QueryPage({Key key, this.title, this.terms, this.futureTerms, this.mode, this.alertChoice}) : super(key: key);

  final String title;
  final List<String> terms;
  final Future<List<String>> futureTerms;
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
  //Declare queries here so that they can be accessed by FAB and _pushResults()
  List<String> convertedTerms;

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

    Widget body;
    int queryInsertIndex = (widget.mode == "Party Mode") ? 1 : 0;

    if (widget.title == "Random Nouns") {
      print("Random");
      body = new FutureBuilder(
          future: widget.futureTerms,
          builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
            //The below line insures no error message and just an empty container shows while the data is loading
            //It can be replaced with a circular spinner or something else
            if (!snapshot.hasData) return new Container();
            convertedTerms = snapshot.data;
            print("content - $convertedTerms");
            children.insert(
                queryInsertIndex,
                new Text(
                  "Match 1 word with:\n${convertedTerms[termIndex]}",
                  style: whiteTextSmall,
                )
            );
            return new Padding(
                padding: const EdgeInsets.all(16.0),
                child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,//align left
                    children: children
                )
            );
            /*return new ListView.builder(
          scrollDirection: Axis.vertical,
          padding: new EdgeInsets.all(6.0),
          itemCount: content.length,
          itemBuilder: (BuildContext context, int index) {
            return new Container(
              alignment: FractionalOffset.center,
              margin: new EdgeInsets.only(bottom: 6.0),
              padding: new EdgeInsets.all(6.0),
              color: Colors.blueGrey,
              child: new Text('${content[index]}'),
            );
          },
        );*/
          }
      );
    } else {
      print("Not random");
      //Add term to children list
      convertedTerms = widget.terms;
      children.insert(
          queryInsertIndex,
          new Text(
            "Match 1 word with:\n${convertedTerms[termIndex]}",
            style: whiteTextSmall,
          )
      );
      body = new Padding(
          padding: const EdgeInsets.all(16.0),
          child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,//align left
              children: children
          )
      );
    }

    return Scaffold(
      appBar: new AppBar(
        leading: homeIcon(context),
        title: new Text('Retrieve Text Input ${widget.title}'),
      ),
      body: body,
      backgroundColor: bgColor,
      floatingActionButton: new FloatingActionButton(
        // When the user presses the button, show an alert dialog with the
        // text the user has typed into our text field.
        // The async and await stuff is there so that the widget doesn't update
        // until the widget is popped back. There may be a better way of doing this.
        onPressed: () async {
          switch (widget.mode) {
            case ("Party Mode"): {
              queries[teamNum] = myController.text + " " + convertedTerms[termIndex];
              if (teamNum < widget.alertChoice) {
                setState(() {
                  bgColor = bgColors[teamNum];
                  teamNum++;
                  myController.text = "";
                });
              } else {
                // List<int> scores returned from results.dart
                if (termIndex < convertedTerms.length-1) {
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
              queries["User Answer"] = myController.text + " " + convertedTerms[termIndex];
              if (termIndex < convertedTerms.length-1) {
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
      new ResultsPageRoute(
        queriesList,
        lastQuery,
        results,
        convertedTerms[termIndex],
        widget.mode,
        widget.alertChoice,
      )
    );
  }

}

