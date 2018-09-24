import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'finalScore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'customWidgets.dart';
import 'functions.dart';
import 'fontStyles.dart';
import 'routes.dart';
import 'globals.dart' as globals;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
    List<String> allDates = [];
    //Because returnedAvgs isEmpty when gibberish was the input/
    //This stops an error occuring and lets me put the contingency in snapshot.hasdata
    if (returnedAvgs.isNotEmpty) {
      json["values"].forEach((val) => weeklyVals.add(val["value"].cast<int>()));
      print(weeklyVals);
      json["values"].forEach((val) => allDates.add(val["formattedAxisTime"]));
      print(allDates);
    } else {
      weeklyVals = [json["values"].cast<int>()];
    }
    return new Post(
      avgs: returnedAvgs,
      weeklyVals: weeklyVals,
      allDates: allDates,
      cpuAnswer: json["cpuAnswer"]
    );
  }
}

bool isFetchingPost = false;
Future<Post> fetchPost(String mode, var alertChoice, String term, List<String> queries) async {
  isFetchingPost = true;
  final url = "https://trends-app-server.herokuapp.com/";
  final response =
  await http.post(url, body: json.encode({'secret_val': 'potato', 'mode': mode, 'difficulty': alertChoice, 'query': term, 'values': queries}));
  print(response.body);
  final responseJson = json.decode(response.body);
  print("Averages: ${responseJson["averages"]}");
  print("Weekly Values: ${responseJson["values"]}");
  print("CPU Answer: ${responseJson["cpuAnswer"] ?? "No CPU Answer"}");
  isFetchingPost = false;
  return new Post.fromJson(responseJson);
}

/*Future<Post> fetchPost() async {
  final response =
  await http.get('https://jsonplaceholder.typicode.com/posts/1');

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    return Post.fromJson(json.decode(response.body));
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

class Post {
  final int userId;
  final int id;
  final String title;
  final String body;

  Post({this.userId, this.id, this.title, this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}*/

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

  BuildContext _scaffoldContext;

  updateAchievements(Post postData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool hasPeakeScore = prefs.getBool('Peake Score') ?? false;
    if (!hasPeakeScore) {
      List<int> scores = postData.weeklyVals.last;
      if (widget.mode == "CPU Mode") {
        //Check First Only (Not CPU Answer)
        if (scores[0] == 100) {
          prefs.setBool('Peake Score', true);
          createSnackBar('Achievement Unlocked -\nPeake Score', _scaffoldContext);
        }
      } else {
        for (final score in scores) {
          if (score == 100) {
            prefs.setBool('Peake Score', true);
            createSnackBar('Achievement Unlocked -\nPeake Score', _scaffoldContext);
            break;
          }
        }
      }
    }

    bool isQuintessential = prefs.getBool('Quintessential Gamer') ?? false;
    if (!isQuintessential) {
      List<int> totalScores = addLists(postData.weeklyVals.last, widget.previousResults);
      if (widget.mode == "CPU Mode") {
        //Check First Only (Not CPU Answer)
        if (totalScores[0] >= 600) {
          prefs.setBool('Quintessential Gamer', true);
          createSnackBar('Achievement Unlocked -\nQuintessential Gamer', _scaffoldContext);
        }
      } else {
        for (final score in totalScores) {
          if (score >= 600) {
            prefs.setBool('Quintessential Gamer', true);
            createSnackBar('Achievement Unlocked -\nQuintessential Gamer', _scaffoldContext);
            break;
          }
        }
      }
    }
  }

  Future<Post> fetchedPost;

  @override
  void initState() {
    fetchedPost = fetchPost(widget.mode, widget.alertChoice, widget.term, widget.queries); // only create the future once.
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    List<String> tabs = ["Scores", "Past Scores", "Average"];
    List<Widget> myTabContents = [];

    List<Widget> myTabs = [];
    tabs.forEach((tabName) => myTabs.add(Tab(text: tabName))); //Tab widget can contain an Icon or a child not just text

    //Need to get the future here because or else you'll call 3 post requests
    //this.fetchedPost = fetchPost(widget.mode, widget.alertChoice, widget.term, widget.queries);
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
            body: new Builder(builder: (BuildContext context) {
              _scaffoldContext = context;
              return new TabBarView(
                children: myTabContents,
              );
            }),
            floatingActionButton: new FloatingActionButton(
              // When the user presses the button, show an alert dialog with the
              // text the user has typed into our text field.
              onPressed: () {
                //_pushQueries();
                //Makes sure user doesn't move to next screen before results displayed (stops bug)
                if (results!=null) {
                  globals.termIndex++;
                  if (!widget.lastQuery) {
                    if (globals.timerSetting == 0) {
                      Navigator.pop(context, results);
                    } else {
                      Navigator.popUntil(context, ModalRoute.withName('/QueryOrTimer'));
                    }
                  } else {
                    List<int> finalResults = addLists(results, widget.previousResults);
                    _pushFinalScore(finalResults);
                  }
                }
              },
              child: new Icon(Icons.send, color: Colors.black87,),
              backgroundColor: Colors.white70,
            )
        )
    );
  }

  void _pushFinalScore(List<int> results) {
    Navigator.of(context).push(
        new FinalScorePageRoute(
          title: "Hello",
          scores: results,
          mode: widget.mode,
        )
    );
  }

  Widget _buildFuturePostWidget(String tabName) {
    return new Center(
      child: new FutureBuilder<Post>(
        future: fetchedPost,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasData) {
            if (snapshot.data.avgs.isEmpty) {
              results = snapshot.data.weeklyVals.last;
              switch (tabName) {
                case ("Scores"): {
                  return _buildScoresTab(snapshot.data);
                }
                case ("Past Scores"): {
                  //return Text('No data available for either term.');
                  if (widget.mode == "Party Mode") {
                    return TimeSeriesCallbackChart.empty(
                      widget.queries
                    );
                  } else if (widget.mode == "CPU Mode") {
                    return TimeSeriesCallbackChart.empty(
                      widget.queries + [(toTitleCase(snapshot.data.cpuAnswer))]
                    );
                  }
                  break;
                }
                case ("Average"): {
                  //return Text('No data available for either term.');
                  List<int> averages = [];
                  widget.queries.forEach((string) => averages.add(0));
                  if (widget.mode == "CPU Mode") {
                    averages.add(0);
                  }
                  return new SimpleBarChart.withGivenData(averages);
                }
                default: {
                  print("Error - 'tabName' doesn't match with any of the 'tabs' items");
                  return Text("Check Error Logs");
                }
              }
            }
            updateAchievements(snapshot.data);
            results = snapshot.data.weeklyVals.last; //DO NOT REMOVE - This variable is used elsewhere
            switch (tabName) {
              case ("Scores"): {
                return _buildScoresTab(snapshot.data);
              }
              case ("Past Scores"): {
                if (widget.mode == "Party Mode") {
                  return new TimeSeriesCallbackChart.withTrendsValues(
                      snapshot.data.weeklyVals,
                      snapshot.data.allDates,
                      widget.queries
                  );
                } else if (widget.mode == "CPU Mode") {
                  return new TimeSeriesCallbackChart.withTrendsValues(
                      snapshot.data.weeklyVals,
                      snapshot.data.allDates,
                      widget.queries + [(toTitleCase(snapshot.data.cpuAnswer))]
                  );
                }
                break;
              }
              case ("Average"): {
                return new SimpleBarChart.withGivenData(snapshot.data.avgs);
              }
              default: {
                print("Error - 'tabName' doesn't match with any of the 'tabs' items");
                return Text("Check Error Logs");
              }
            }
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "Connection failed.\nCheck your internet connection and try again.",
                    style: blackTextSmaller,
                    textAlign: TextAlign.center,
                  ),
                ),
                RaisedButton(
                  child: Text('Try Again'),
                  onPressed: () {
                    if (isFetchingPost) {
                      setState(() {
                        fetchedPost = fetchPost(widget.mode, widget.alertChoice, widget.term, widget.queries);
                      });
                    }
                  }
                  //tabs[0] = 'hello';
                  //myTabContents[0] = Text('hello');
                  //build(_scaffoldContext);

                  //fetchedPost = fetchPost(widget.mode, widget.alertChoice, widget.term, widget.queries);
                  //print(fetchedPost.toString());
                  //tabs.forEach((tabName) => myTabContents.add(_buildFuturePostWidget(tabName, fetchedPost)));
                  ,
                )
              ],
            );
          }
          // By default, show a loading spinner
          // (although I think if connectionstate covers this already)
          return CircularProgressIndicator();
        },
      ),
    );
  }

  Widget _buildScoresTab(Post jsonResponse) {
    globals.totals = addLists(results, globals.totals);
    switch (widget.mode) {
      case ("Party Mode"): {
        return new ListView.builder(
          itemBuilder: (context, index) {
            return new Container(
                color: colors[index],
                child: ListTile(
                  title: new Text("Team ${index+1}:", style: whiteText,),
                  subtitle: new Text(
                      "${widget.queries[index]}: ${jsonResponse.weeklyVals.last[index].toString()}"
                          "\nTotal: ${globals.totals[index]}",
                      style: whiteTextSmall
                  ),
                )
            );
          },
          itemCount: globals.totals.length,
        );
      }

      case ("CPU Mode"): {
        List<String> messages = ["Your Answer:", "CPU Answer:"];
        List<String> allQueries = [widget.queries[0], toTitleCase(jsonResponse.cpuAnswer)];
        return new ListView.builder(
          itemBuilder: (context, index) {
            return new Container(
                color: colors[index],
                child: ListTile(
                  title: new Text(messages[index], style: whiteText),
                  subtitle: new Text(
                      "${allQueries[index]}: ${jsonResponse.weeklyVals.last[index].toString()}"
                          "\nTotal: ${globals.totals[index]}",
                      style: whiteTextSmall
                  ),
                )
            );
          },
          itemCount: globals.totals.length,
        );
      }

      default: {
        return new Text("Error - mode not of expected type");
      }
    }

  }
}