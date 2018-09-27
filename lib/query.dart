import 'package:flutter/material.dart';
import 'routes.dart';

import 'customWidgets.dart';
import 'functions.dart';
import 'fontStyles.dart';
import 'globals.dart' as globals;


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
  //final List<Color> bgColors = [Colors.blueAccent[200], Colors.redAccent[200], Colors.yellowAccent[200], Colors.greenAccent[200], Colors.purpleAccent[200]];
  //var bgColor = Colors.blueAccent[200];
  final List<Color> bgColors = [Colors.blue[400], Colors.red[400], Colors.yellow[400], Colors.green[400], Colors.purple[300]];
  var bgColor = Colors.blue[400];
  var fabIconColor = Colors.black12;
  var fabBgColor = Colors.white30;
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


    void submitWord() async {
      print("INDEX:" + globals.termIndex.toString());
      print("LENGTH:" + (convertedTerms.length-1).toString());
      if (myController.text.isNotEmpty) {
        switch (widget.mode) {
          case ("Party Mode"): {
            queries[teamNum] = myController.text + " " + convertedTerms[globals.termIndex];
            if (teamNum < widget.alertChoice) {
              setState(() {
                bgColor = bgColors[teamNum];
                teamNum++;
                myController.text = "";
                fabIconColor = Colors.black12;
                fabBgColor = Colors.white30;
              });
            } else {
              // List<int> scores returned from results.dart
              if (globals.termIndex < convertedTerms.length-1) {
                List<int> scores = await _pushResults(false);
                setState(() {
                  bgColor = bgColors[0];
                  teamNum = 1;
                  myController.text = "";
                  //globals.globals.termIndex++;
                  fabIconColor = Colors.black12;
                  fabBgColor = Colors.white30;
                });
                results = addLists(results, scores);
              } else {
                _pushResults(true);
              }
            }
            break;
          }

          case ("CPU Mode"): {
            queries["User Answer"] = myController.text + " " + convertedTerms[globals.termIndex];
            if (globals.termIndex < convertedTerms.length-1) {
              List<int> scores = await _pushResults(false);
              myController.text = "";
              //termIndex++;
              results = addLists(results, scores);
            } else {
              _pushResults(true);
            }
            break;
          }
        }
      }
    }

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
            hintText: 'Enter Term'
        ),
        maxLength: globals.maxTextLength,
        onChanged: (text) {
          if (text.isEmpty) {
            setState(() {
              fabIconColor = Colors.black12;
              fabBgColor = Colors.white30;
            });
          } else {
            setState(() {
              fabIconColor = Colors.black87;
              fabBgColor = Colors.white70;
            });
          }
        },
        onSubmitted: (text) => submitWord(),
      )
    ];
    if (widget.mode == "Party Mode") {
      children.insert(
        0,
        new Text(
          "Team $teamNum",
          style: whiteTextBlack
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
                  "Match 1 word with:\n${convertedTerms[globals.termIndex]}",
                  style: whiteTextSmallBlack,
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
            "Match 1 word with:\n${convertedTerms[globals.termIndex]}",
            style: whiteTextSmallBlack,
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

    String message = 'Are you sure you want to go back?\nAll progress will be lost.';
    String modalRouteName = '/SelectTheme';
    Widget backButton = alertBackIcon(
        context,
        message,
        modalRouteName
    );


    return new WillPopScope(
        onWillPop: () {
          showDialog<Null>(
            context: context,
            //barrierDismissible: false, // outside click dismisses alert
            builder: (BuildContext context) {
              return new AlertDialog(
                title: new Text(message),
                titlePadding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
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
                      //Look at main.dart to see how I routes to name the desired ModalRoute
                      Navigator.popUntil(context, ModalRoute.withName(modalRouteName));
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Scaffold(
        appBar: new AppBar(
          leading: backButton,
          title: new Text(widget.title),
          backgroundColor: Colors.blue,
        ),
        body: body,
        backgroundColor: bgColor,
        floatingActionButton: new FloatingActionButton(
          // When the user presses the button, show an alert dialog with the
          // text the user has typed into our text field.
          // The async and await stuff is there so that the widget doesn't update
          // until the widget is popped back. There may be a better way of doing this.
          onPressed: () => submitWord(),
          child: new Icon(Icons.send, color: fabIconColor,),
          backgroundColor: fabBgColor,
        ),
      )
    );

  }

  Future _pushResults(bool lastQuery) {
    //Converts map to List
    List<String> queriesList = new List<String>.from(queries.values.toList());
    print("IS LAST QUERY? $lastQuery");
    return Navigator.of(context).push(
      new ResultsPageRoute(
        queriesList,
        lastQuery,
        results,
        convertedTerms[globals.termIndex],
        widget.mode,
        widget.alertChoice,
      )
    );
  }

}

