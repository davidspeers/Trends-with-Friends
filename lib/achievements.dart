import 'package:flutter/material.dart';

import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'customWidgets.dart';
import 'fontStyles.dart';

class AchievementsPage extends StatefulWidget {
  AchievementsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AchievementsPageState createState() => new _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {

  List<String> headings = ["Unlocked Achievements", "Locked Achievements"];

  List<List<String>> allAchievements = [
    [
      //Unlocked Achievements

    ],
    [
      //Locked Achievements

    ],
    [
      //All Achievements
      "My First Achievement - Look at your achievements.",
      "Trends Newbie - Play 1 Game",
      "Trends Novice - Play 10 Games",
      "Trends Pro - Play 100 Games",
      "Trends with Friends - Play a game of party mode",
      "Peake Score - Get a score of 100 in a round",
      "Quintessential Gamer - Get a total score of 600 in a game",
      "Trends Setter - Create a Custom Theme",
      "Pro Trends Setter - Create 5 Custom Themes",
      "Trends Getter - Play a Custom Theme",
      "Complete the Show - Play Every Show Theme",
      "Same Choice, Different Outcome - Play a random theme twice.",
      "Beat the Machine  - Beat CPU mode",
      "Beat the Harder Machine - Beat CPU mode on Hard Difficulty or harder",
      "Beat the Hardest Machine - Beat CPU mode on Impossible Difficulty",
      "Trendmaster - Unlock all other achievements",
    ],
    /*[
      //Stats
      "Total Party Mode Games",
      "Total CPU Mode Games",
      "Games Won",
      "Games Lost"
    ]*/
  ];

  //Initialising here and instantiating in the builder allows you to call
  //the snackbar in code written outside the builder.
  //Also, note that snackbars need scaffolds followed by a builder
  BuildContext _scaffoldContext;

  final snackBar = SnackBar(
    content: Text(
      'Achievement Unlocked -\nMy First Achievement',
      textAlign: TextAlign.center,
    ),
    duration: const Duration(seconds: 3),
  );

  getSharedPrefs() async {

    //If first time on AchievementsPage unlock First Achievement
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String initialAchievement = "My First Achievement";
    bool isInitialised = prefs.getBool(initialAchievement) ?? false;
    if (!isInitialised) {
      prefs.setBool(initialAchievement, true);
      Scaffold.of(_scaffoldContext).showSnackBar(snackBar);
    }

    //Check which achievements have already been unlocked and add them to the correct list
    String achievementName;
    bool isAchievementUnlocked;
    setState(() {
      allAchievements[2].forEach((dashedString) {
        achievementName = dashedString.split(" - ")[0];
        isAchievementUnlocked = prefs.getBool(achievementName) ?? false;
        if (isAchievementUnlocked) {
          allAchievements[0].add(dashedString);
        } else {
          allAchievements[1].add(dashedString);
        }
      });
    });
  }

  @override
  void initState() {
    getSharedPrefs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.green,
        //actions: <Widget>[IconButton(icon: Icon(Icons.add), onPressed: () => Scaffold.of(_scaffoldContext).showSnackBar(snackBar))],
      ),
      body: new Builder(builder: (BuildContext context) {
        _scaffoldContext = context;
        return new CustomScrollView(slivers: _buildSlivers(context));
      }),
    );
  }

  List<Widget> _buildSlivers(BuildContext context) {
    List<Widget> slivers = new List<Widget>();

    int i = 0;
    slivers.addAll(_buildLists(context, i, i+=allAchievements.length-1, allAchievements));
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
                    style: greyTextSmaller,
                  ),
                ];
              } catch (error) {
                print(error.toString());
              }
              return new ListTile(
                title: new Padding(
                  padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
                  child: Column(
                    children: myChildren,
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                )
              );
            },
            childCount: lists[sliverIndex].length,
          )
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