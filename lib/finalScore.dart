import 'package:flutter/material.dart';

import 'customWidgets.dart';
import 'fontStyles.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FinalScorePage extends StatefulWidget {
  FinalScorePage({Key key, this.title, this.scores, this.mode, this.isRandomTheme}) : super(key: key);

  final String title;
  final List<int> scores;
  final String mode;
  final String isRandomTheme;

  @override
  _FinalScorePageState createState() => new _FinalScorePageState();
}

class _FinalScorePageState extends State<FinalScorePage> {

  BuildContext _scaffoldContext;

  updateAchievements() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Games Played Achievements
    bool isTrendsNewbie = prefs.getBool('Trends Newbie') ?? false;
    bool isTrendsNovice = prefs.getBool('Trends Novice') ?? false;
    bool isTrendsPro = prefs.getBool('Trends Pro') ?? false;
    if (!(isTrendsNewbie && isTrendsNovice && isTrendsPro)) {
      int numGamesPlayed = prefs.getInt("Number of Games Played") ?? 0;
      numGamesPlayed++;
      if (numGamesPlayed == 1 && !isTrendsNewbie) {
        prefs.setBool('Trends Newbie', true);
        createSnackBar('Achievement Unlocked -\nTrends Newbie', _scaffoldContext);
      } else if (numGamesPlayed == 10 && !isTrendsNovice) {
        prefs.setBool('Trends Novice', true);
        createSnackBar('Achievement Unlocked -\nTrends Novice', _scaffoldContext);
      } else if (numGamesPlayed == 100 && !isTrendsPro) {
        prefs.setBool('Trends Pro', true);
        createSnackBar('Achievement Unlocked -\nTrends Pro', _scaffoldContext);
      }
      prefs.setInt("Number of Games Played", numGamesPlayed);
    }

    //If Party Mode Achievements
    bool isTrendsFriends = prefs.getBool('Trends with Friends') ?? false;
    if (!isTrendsFriends) {
      if (widget.mode == 'Party Mode') {
        prefs.setBool('Trends with Friends', true);
        createSnackBar('Achievement Unlocked -\nTrends with Friends', _scaffoldContext);
      }
    }

    //Playing Custom Theme Achievements

    //If Random Theme Achievements
    print('Is Random Theme: ${widget.isRandomTheme}');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => updateAchievements());
  }

  @override
  Widget build(BuildContext context) {
    return _scorePageUI();
  }

  Widget _scorePageUI() {
    return new Scaffold(
      appBar: new AppBar(
        leading: homeIcon(context),
        title: new Text('Retrieve Text Input ${widget.title}'),
      ),
      body: new Builder(builder: (BuildContext context) {
        _scaffoldContext = context;
        return new Center(
          child: new Container(
              child: new Text(
                  getWinners(widget.scores),
                  textAlign: TextAlign.center,
                  style: blackTextBold
              ),
              width: double.infinity,
              color: Colors.amber
          ),
        );
      }),
      backgroundColor: getWinningColor(widget.scores),
    );
  }

  Color getWinningColor(List<int> scores) {
    final List<Color> colors = [Colors.blue, Colors.red, Colors.yellow, Colors.green, Colors.purple];
    List<int> winningIndex = getWinnersIndex(scores);
    if (winningIndex.length>1) return Colors.black;
    else return colors[winningIndex[0]];
  }

  String getWinners(List<int> scores) {
    List<int> winningIndex = getWinnersIndex(scores);
    String winners = "";
    switch (widget.mode) {
      case ("Party Mode"): {
        if (winningIndex.length>1) winners = "Winners:";
        else winners = "Winner:";
        for (int index in winningIndex) {
          winners = winners + "\nTeam ${index+1}";
        }
        break;
      }

      case ("CPU Mode"): {
        if (winningIndex.length>1) winners = "You Drew The Computer";
        else {
          if (winningIndex[0]==0) winners = "Congratulations, You Beat The Goog";
          else winners = "You Lost To The Goog\nTry Again";
        }
        break;
      }
    }
    return winners;
  }

  //Return all the indexes of the highest scores
  List<int> getWinnersIndex(List<int> scores) {
    int highestScore = 0;
    List<int> highestScoreIndex = [];
    for (int i=0; i<scores.length; i++) {
      if (scores[i]==highestScore) {
        highestScoreIndex.add(i);
      } else if (scores[i]>highestScore) {
        highestScore = scores[i];
        highestScoreIndex.clear();
        highestScoreIndex.add(i);
      }
    }
    return highestScoreIndex;
  }
}