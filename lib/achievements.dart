import 'package:flutter/material.dart';

import 'package:flutter_sticky_header/flutter_sticky_header.dart';

import 'customWidgets.dart';
import 'fontStyles.dart';

class AchievementsPage extends StatefulWidget {
  AchievementsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AchievementsPageState createState() => new _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {

  List<String> headings = ["Unlocked Achievements", "Locked Achievements",];

  List<List<String>> allAchievements = [
    [
      //Unlocked Achievements
      "My First Achievement - Complete the Tutorial"
    ],
    [
      //Locked Achievements
      "Trend Newbie - Play 1 Game",
      "Trend Novice - Play 10 Games",
      "Trend Pro - Play 100 Games",
      "Trend Master / Quintessential Gamer - Unlock all other achievements",
      "Trends With Friends - Play a game of party mode",
      "Peake / Current Trender - Get a score of 100 in a query",
      "I'm pretty sure you cheated - Beat CPU mode on Impossible Difficulty",
      "You did what?! - Beat CPU mode on Hard Difficulty or harder",
      "Placeholder - Beat CPU mode"
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.green,
      ),
      body: new Builder(builder: (BuildContext context) {
        return new CustomScrollView(slivers: _buildSlivers(context));
      }),
    );
  }

  List<Widget> _buildSlivers(BuildContext context) {
    List<Widget> slivers = new List<Widget>();

    int i = 0;
    slivers.addAll(_buildLists(context, i, i+=allAchievements.length, allAchievements));
    //slivers.addAll(_buildGrids(context, i, i += 3));
    return slivers;
  }

  List<Widget> _buildLists(BuildContext context, int firstIndex, int count, List<List<String>> lists) {
    return List.generate(count, (sliverIndex) {
      sliverIndex += firstIndex;
      return new SliverStickyHeader(
      //buildHeader found in customWidget.dart
      header: _buildHeader(sliverIndex, headings),
        sliver: new SliverList(
          delegate: new SliverChildBuilderDelegate(
            (context, i) {
              String dashedString = lists[sliverIndex][i];
              List<String> separatedString = dashedString.split(" - ");
              List<Widget> myChildren = [];
              try {
                myChildren = [
                  new Text(
                    separatedString[0],
                    style: blackTextSmall,
                  ),
                  new Text(
                    separatedString[1],
                    style: greyTextSmall,
                  )
                ];
              } catch (error) {
                print(error.toString());
              }
              return new ListTile(
                title: new Column(
                  children: myChildren,
                  crossAxisAlignment: CrossAxisAlignment.start,
                )
              );
            },
            childCount: lists[sliverIndex].length,
          ),
        ),
      );
    });
  }

  Widget _buildHeader(int index, List<String> headings) {
    int unlockedAchievements = allAchievements[0].length;
    int lockedAchievements = allAchievements[1].length;
    int totalAchievements = unlockedAchievements+lockedAchievements;
    List<String> achievementsFraction = [
      unlockedAchievements.toString() + '/' + totalAchievements.toString(),
      lockedAchievements.toString() + '/' + totalAchievements.toString()
    ];
    return new Container(
      height: 60.0,
      color: Colors.lightBlue,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.centerLeft,
      child: new Text(
        headings[index] + " " + achievementsFraction[index],
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

}