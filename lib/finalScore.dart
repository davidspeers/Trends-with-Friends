import 'package:flutter/material.dart';

import 'customWidgets.dart';
import 'fontStyles.dart';

class FinalScorePage extends StatefulWidget {
  FinalScorePage({Key key, this.title, this.scores, this.mode}) : super(key: key);

  final String title;
  final List<int> scores;
  final String mode;

  @override
  _FinalScorePageState createState() => new _FinalScorePageState();
}

class _FinalScorePageState extends State<FinalScorePage> {

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
      body: new Center(
        child: new Container(
          child: new Text(
            getWinners(widget.scores),
            textAlign: TextAlign.center,
            style: blackTextBold
          ),
          width: double.infinity,
          color: Colors.amber
        ),
      ),
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