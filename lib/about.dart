import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class AboutPage extends StatefulWidget {
  AboutPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AboutPageState createState() => new _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return _aboutPageUI();
  }

  Widget _aboutPageUI() {

    List<Entry> myChildren = [];
    List<String> myHeadings = [
      'How to Play',
      'How the Score is Calculated',
      'Contact the Developer'
    ];

    Map<String,String> headingsToContent = {
      'How to Play':
        "• Trends With Friends is a game inspired by the Google Trends Show web series.\n"
        "• Each game consists of multiple rounds.\n"
        "• In each round you will be given a word, you will then need to think of a word that people google with the given word.\n"
        "• Your word and the given word will then be combined to become your query.\n"
        "• Google Trends will then calculate a score for all the queries in that round.\n"
        "• At the end of the last round all the scores are tallied and whoever has the highest score wins.",
      'How the Score is Calculated':
        "• Please Note: Understanding the following isn't necessary to enjoy the game, but it is here for those who want to become a true Trendmaster.\n"
        "• Google Trends scores are calculated by comparing the search traffic of each query in the last week with the search traffic over the past 12 months."
        "\nThis means that not only are you trying to think of a query that is popular and thus googled often, but also a query that"
        " is popular in the last week."
        "\nFor example, if you're playing in June and you need to match a word with 'Super' you may be tempted to answer with 'Bowl',"
        " however, because google search traffic for the query 'Super Bowl' is about 1% of the search traffic in the lead-up to the Super Bowl,"
        "you will likely only score 1 point out of a possible 100."
        "\nGranted, Super Bowl even in June is often searched more than other popular 'Super' queries like "
        "'Super Food', 'Super Man', or 'Super Mario' and so you will likely still win the round, but only by 1 point.\n"
        "• Additional Tips:\n"
        "1 - You can enter more than one word that will be combined with the given word to make up your query."
        " However, this can only worsen your score. For example, 'Super Bowl Football' will never have a higher score than 'Super Bowl'.\n"
        "2 - Word order and capitalisation don't matter. The phrase 'Super Bowl' and 'bowl super' will both return the same scores.",
      'Contact the Developer':
        "If you have any other questions, have found any bugs, or have any suggestions feel free to email us at trendswithfriends@outlook.com",
    };

    myHeadings.forEach((heading) {
      myChildren.add(
        Entry(
          heading,
          <Entry>[
            Entry(headingsToContent[heading]),
          ],
        ),
      );
    });

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
        backgroundColor: Colors.red[400],
      ),
      /*body: new ListView(
        children: myChildren
      ),*/
      body: SafeArea(
        child: GlowingOverscrollIndicator(axisDirection: AxisDirection.down, color: Colors.red,
          child: new ListView.builder(
            itemBuilder: (BuildContext context, int index) =>
                CustomExpansionTile(myChildren[index]),
            itemCount: myChildren.length,
          ),),
      )
    );
  }
}

// One entry in the multilevel list displayed by this app.
class Entry {
  Entry(this.title, [this.children = const <Entry>[]]);

  final String title;
  final List<Entry> children;
}

class CustomExpansionTile extends StatefulWidget {
  const CustomExpansionTile(this.entry);
  final Entry entry;

  @override
  State createState() => CustomExpansionTileState();
}

class CustomExpansionTileState extends State<CustomExpansionTile> {
  bool isExpanded = false; //use this bool for initially unexpanded tiles
  bool isExpandedAgain = true; //use this bool for initially expanded tiles

  bool _isInitiallyExpanded(String title) {
    bool returnedVal;
    (title == 'How to Play') ? returnedVal = true : returnedVal = false;
    return returnedVal;
  }

  Future<Null> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      throw 'Could not launch $url';
    }
  }

  /*Future<Null> _launchInWebViewOrVC(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: true, forceWebView: true);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _launchStatus(BuildContext context, AsyncSnapshot<Null> snapshot) {
    if (snapshot.hasError) {
      return new Text('Error: ${snapshot.error}');
    } else {
      return const Text('');
    }
  }*/

  Widget _buildTiles(Entry root) {
    if (root.children.isEmpty) {
      if (root.title.contains('Google Trends Show')) {
        List<String> strings = root.title.split('Google Trends Show');
        List<TextSpan> textspans = [];
        for (int i=0; i<strings.length; i++) {
          textspans.add(
            new TextSpan(
              text: strings[i],
              style: new TextStyle(
                color: Colors.black,
                fontSize: 16.0, fontWeight:
                FontWeight.w400
              ),
            )
          );
          if (i < strings.length-1) {
            textspans.add(
              new TextSpan(
                text: 'Google Trends Show',
                style: new TextStyle(
                    color: Colors.blue,
                    fontSize: 16.0, fontWeight:
                FontWeight.w400,
                    decoration: TextDecoration.underline
                ),
                recognizer: new TapGestureRecognizer()
                  ..onTap = () => setState(() {
                    _launchInBrowser('https://www.youtube.com/watch?v=n9bqcK-nVRk&t=120s');
                  }),
              ),
            );
          }
        }
        return new ListTile(
          title: RichText(
            text: new TextSpan(
                children: textspans
            ),
          ),
        );
      } else {
        return ListTile(
            title: Text(root.title,
            style: new TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontWeight: FontWeight.w400
            ),
          )
        );
      }
    }
    bool isInitiallyExpanded = _isInitiallyExpanded(root.title);
    return ExpansionTile(
      key: PageStorageKey<Entry>(root),
      title: Text(
        root.title,
        style: TextStyle(
          //If root.title is Quick Start use isExpandedAgain, else use isExpanded
          color: isInitiallyExpanded ? (isExpandedAgain ? Colors.red : Colors.black87) : (isExpanded ? Colors.red : Colors.black87),
          fontSize: 19.0
        ),
      ),
      children: root.children.map(_buildTiles).toList(),
      /*children: [
        Text(root.children[0].title),
        new RichText(
          text: new TextSpan(
            children: [
              new TextSpan(
                text: 'This is no Link, ',
                style: new TextStyle(color: Colors.black),
              ),
              new TextSpan(
                text: 'but this is',
                style: new TextStyle(color: Colors.blue),
                recognizer: new TapGestureRecognizer()
                  ..onTap = () => setState(() {
                    _launched = _launchInWebViewOrVC('https://www.youtube.com/watch?v=n9bqcK-nVRk&t=120s');
                  }),
              ),
            ],
          ),
        ),
        new FutureBuilder<Null>(future: _launched, builder: _launchStatus),
      ],*/
      onExpansionChanged: (bool expanding) => setState(() {
        isInitiallyExpanded ? isExpandedAgain = expanding : isExpanded = expanding;
      }),
      initiallyExpanded: isInitiallyExpanded
    );
  }

  @override
  Widget build(BuildContext context) {

    return _buildTiles(widget.entry);
  }
}