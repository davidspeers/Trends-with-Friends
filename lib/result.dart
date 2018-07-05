import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'finalScore.dart';
import 'functions.dart';
import 'fontStyles.dart';

import 'dart:async';
import 'dart:convert';

class Post {
  Post({this.vals, this.cpuAnswer});

  final List<int> vals;
  final String cpuAnswer;

  factory Post.fromJson(Map<String, dynamic> json) {
    //Needed to enforce List<int> not List<dynamic>
    List<int> returnedVals = [];
    json["values"].forEach((val) => returnedVals.add(val));
    return new Post(
      vals: returnedVals,
      cpuAnswer: json["cpuAnswer"]
    );
  }
}

Future<Post> fetchPost(String mode, var alertChoice, String term, List<String> queries) async {
  final url = "https://trends-app-server.herokuapp.com/";
  final response =
  await http.post(url, body: json.encode({'secret_val': 'potato', 'mode': mode, 'difficulty': alertChoice, 'query': term, 'values': queries}));
  print(response.body);
  final responseJson = json.decode(response.body);
  print("Logs:");
  print(responseJson);
  return new Post.fromJson(responseJson);
}

class ResultsPage extends StatefulWidget {
  //Note: the curly braces means the values are optional and that you have to do key:value when specifying
  ResultsPage({Key key, this.title, this.queries, this.lastQuery, this.previousResults, this.term, this.mode, this.alertChoice}) : super(key: key);

  final String title;
  final List<String> queries;
  final bool lastQuery;
  final List<int> previousResults;
  final String term;
  final String mode;
  final dynamic alertChoice;

  @override
  _ResultsPageState createState() => new _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  final List<Color> colors = [Colors.blue, Colors.red, Colors.yellow, Colors.green, Colors.purple];

  List<int> results;

  @override
  Widget build(BuildContext context) {
    return _resultsPageUI();
  }

  Widget _resultsPageUI() {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Fetch Data Example'),
      ),
      body: new Center(
        child: new FutureBuilder<Post>(
          future: fetchPost(widget.mode, widget.alertChoice, widget.term, widget.queries),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              results = snapshot.data.vals;
              return _buildList(snapshot.data);
            } else if (snapshot.hasError) {
              return new Text("${snapshot.error}");
            }
            // By default, show a loading spinner
            return new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  new Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: new Text(
                      "Calculating Trendiest Term",
                      style: blackTextSmall,
                    ),
                  ),
                  CircularProgressIndicator(),
                ]
            );
          },
        ),
      ),
      floatingActionButton: new FloatingActionButton(
          // When the user presses the button, show an alert dialog with the
          // text the user has typed into our text field.
          onPressed: () {
            //_pushQueries();
            //Makes sure user doesn't move to next screen before results displayed (stops bug)
            if (results!=null) {
              if (!widget.lastQuery) {
                Navigator.pop(context, results);
              } else {
                List<int> finalResults = addLists(results, widget.previousResults);
                _pushFinalScore(finalResults);
              }
            }
          },
          tooltip: 'Show me the value!',
          child: new Icon(Icons.send),
        )
      //backgroundColor: Colors.white,
    );
  }

  void _pushFinalScore(List<int> results) {
    Navigator.of(context).push(
        new MaterialPageRoute(
            builder: (context) {
              return new FinalScorePage(title: "Hello", scores: results, mode: widget.mode);
            }
        )
    );
  }

  Widget _buildList(Post jsonResponse) {
    switch (widget.mode) {
      case ("Party Mode"): {
        List<int> totals = addLists(widget.previousResults, jsonResponse.vals);
        return new ListView.builder(
          itemBuilder: (context, index) {
            return new Container(
              color: colors[index],
              child: ListTile(
                title: new Text("Team ${index+1}:", style: whiteText,),
                subtitle: new Text(
                  "${widget.queries[index]}: ${jsonResponse.vals[index].toString()}"
                    "\nTotal: ${totals[index]}",
                  style: whiteTextSmall
                ),
              )
            );
          },
          itemCount: totals.length,
        );
      }

      case ("CPU Mode"): {
        List<int> totals = addLists(widget.previousResults, jsonResponse.vals);
        List<String> messages = ["Your Answer:", "CPU Answer:"];
        List<String> allQueries = [widget.queries[0], toTitleCase(jsonResponse.cpuAnswer)];
        return new ListView.builder(
          itemBuilder: (context, index) {
            return new Container(
              color: colors[index],
              child: ListTile(
                title: new Text(messages[index], style: whiteText),
                subtitle: new Text(
                  "${allQueries[index]}: ${jsonResponse.vals[index].toString()}"
                      "\nTotal: ${totals[index]}",
                  style: whiteTextSmall
                ),
              )
            );
          },
          itemCount: totals.length,
        );
      }
    }

  }

}

