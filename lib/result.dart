import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'finalScore.dart';
import 'functions.dart';
import 'fontStyles.dart';

import 'dart:async';
import 'dart:convert';

class Post {
  Post({this.vals});

  final List<int> vals;

  factory Post.fromJson(Map<String, dynamic> json) {
    return new Post(
      vals: [json['val1'], json['val2']],
    );
  }
}

Future<Post> fetchPost(List<String> queries) async {
  final url = "https://trends-app-server.herokuapp.com/";
  final response =
  await http.post(url, body: json.encode({'secret_val': 'potato', 'val1': queries[0], 'val2': queries[1]}));
  final responseJson = json.decode(response.body);
  print("Logs:");
  print(responseJson);
  return new Post.fromJson(responseJson);
}

class ResultsPage extends StatefulWidget {
  //Note: the curly braces means the values are optional and that you have to do key:value when specifying
  ResultsPage({Key key, this.title, this.queries, this.lastQuery, this.previousResults}) : super(key: key);

  final String title;
  final List<String> queries;
  final bool lastQuery;
  final List<int> previousResults;

  @override
  _ResultsPageState createState() => new _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  final List<MaterialColor> colors = [Colors.blue, Colors.red, Colors.yellow, Colors.green, Colors.purple];

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
          future: fetchPost(widget.queries),
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
              return new FinalScorePage(title: "Hello", scores: results);
            }
        )
    );
  }

  Widget _buildList(Post jsonResponse) {
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
        itemCount: 2,
    );
  }

}

