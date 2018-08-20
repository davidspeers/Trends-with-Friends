import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'finalScore.dart';
import 'functions.dart';
import 'fontStyles.dart';

import 'dart:async';
import 'dart:convert';

import 'barChart.dart';
import 'timeGraph.dart';

class Post {
  Post({this.weeklyVals, this.allDates, this.avgs, this.cpuAnswer});

  final List<List<int>> weeklyVals;
  final List<String> allDates;
  final List<int> avgs;
  final String cpuAnswer;

  //This factory constructor returns a Post object which contains the:
  //averages, weekly values, and cpuAnswer (null if not playing cpu mode).
  factory Post.fromJson(Map<String, dynamic> json) {
    //Need to enforce List<int> not List<dynamic>
    //The following is the less efficient way of enforcing this:
    /*List<int> returnedAvgs = [];
    json["averages"].forEach((val) => returnedAvgs.add(val));
    Again I need to enforce List<int> not List<dynamic>, but I believe the way
    dart work is that it sees [x,y] as a List<dynamic> and not until I look at x and y
    does it see that x and y are in fact ints.
    json["values"].forEach((val) => weeklyVals.add([val["value"][0], val["value"][1]]));*/
    //Here is the better version:
    List<int> returnedAvgs = json["averages"].cast<int>();
    List<List<int>> weeklyVals = [];
    json["values"].forEach((val) => weeklyVals.add(val["value"].cast<int>()));
    print(weeklyVals);
    List<String> allDates = [];
    json["values"].forEach((val) => allDates.add(val["formattedAxisTime"]));
    print(allDates);
    return new Post(
      avgs: returnedAvgs,
      weeklyVals: weeklyVals,
      allDates: allDates,
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
  print("Averages: ${responseJson["averages"]}");
  print("Weekly Values: ${responseJson["values"]}");
  print("CPU Answer: ${responseJson["cpuAnswer"] ?? "No CPU Answer"}");
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
  final List<dynamic> colors = [Colors.blue, Colors.red, Colors.yellow, Colors.green, Colors.purple];

  List<int> results;

  @override
  Widget build(BuildContext context) {
    return _resultsPageUI();
  }

  Widget _resultsPageUI() {
    
    List<String> tabs = ["Scores", "Past Scores", "Average"];

    List<Widget> myTabs = [];
    tabs.forEach((tabName) => myTabs.add(Tab(text: tabName))); //Tab widget can contain an Icon or a child not just text

    List<Widget> myTabContents = [];
    tabs.forEach((tabName) => myTabContents.add(_buildFuturePostWidget(tabName))); //Tab widget can contain an Icon or a child not just text

    return new DefaultTabController(
        length: tabs.length,
        child: new Scaffold(
            appBar: new AppBar(
              bottom: TabBar(
                tabs: myTabs
              ),
              title: Text('Fetch Data Example'),
            ),
            body: TabBarView(
              children: myTabContents,
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
        )
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

  Widget _buildFuturePostWidget(String tabName) {
    return new Center(
      child: new FutureBuilder<Post>(
        future: fetchPost(widget.mode, widget.alertChoice, widget.term, widget.queries),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            results = snapshot.data.avgs;
            switch (tabName) {
              case ("Scores"): {
                return _buildScoresTab(snapshot.data);
              }
              case ("Past Scores"):{
                return new TimeSeriesCallbackChart.withTrendsValues(
                  snapshot.data.weeklyVals,
                  snapshot.data.allDates,
                  widget.queries
                );
              }
              case ("Average"): {
                return new SimpleBarChart.withGivenData(results);
              }
              default: {
                print("Error - 'tabName' doesn't match with any of the 'tabs' items");
                return Text("Check Error Logs");
              }
            }
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
    );
  }

  Widget _buildScoresTab(Post jsonResponse) {
    switch (widget.mode) {
      case ("Party Mode"): {
        List<int> totals = addLists(widget.previousResults, jsonResponse.avgs);
        return new ListView.builder(
          itemBuilder: (context, index) {
            return new Container(
              color: colors[index],
              child: ListTile(
                title: new Text("Team ${index+1}:", style: whiteText,),
                subtitle: new Text(
                  "${widget.queries[index]}: ${jsonResponse.avgs[index].toString()}"
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
        List<int> totals = addLists(widget.previousResults, jsonResponse.avgs);
        List<String> messages = ["Your Answer:", "CPU Answer:"];
        List<String> allQueries = [widget.queries[0], toTitleCase(jsonResponse.cpuAnswer)];
        return new ListView.builder(
          itemBuilder: (context, index) {
            return new Container(
              color: colors[index],
              child: ListTile(
                title: new Text(messages[index], style: whiteText),
                subtitle: new Text(
                  "${allQueries[index]}: ${jsonResponse.avgs[index].toString()}"
                      "\nTotal: ${totals[index]}",
                  style: whiteTextSmall
                ),
              )
            );
          },
          itemCount: totals.length,
        );
      }

      default: {
        return new Text("Error - mode not of expected type");
      }
    }

  }

}

