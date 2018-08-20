import 'package:flutter/material.dart';

import 'package:charts_flutter/flutter.dart' as charts;

class SimpleBarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SimpleBarChart(this.seriesList, {this.animate});

  factory SimpleBarChart.withGivenData(List<int> averages) {
    return new SimpleBarChart(_createWithData(averages));
  }

  static List<charts.Series<AverageScore, String>> _createWithData(List<int> averages) {

    List<int> teamNames = [1, 2, 3, 4, 5];

    List<dynamic> teamColors = [
      charts.MaterialPalette.blue.shadeDefault,
      charts.MaterialPalette.red.shadeDefault,
      charts.MaterialPalette.yellow.shadeDefault,
      charts.MaterialPalette.green.shadeDefault,
      charts.MaterialPalette.purple.shadeDefault,
    ];

    List<AverageScore> data = [];

    for (int i=0; i<averages.length; i++) {
      data.add(new AverageScore(teamNames[i], averages[i]));
    }

    return [
      new charts.Series<AverageScore, String>(
        id: 'Score',
        colorFn: (AverageScore score, __) => teamColors[score.teamNum-1],
        domainFn: (AverageScore score, _) => "Team ${score.teamNum.toString()}",
        measureFn: (AverageScore score, _) => score.score,
        data: data,
      )
    ];
  }


  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
    );
  }

}

class AverageScore {
  final int teamNum;
  final int score;

  AverageScore(this.teamNum, this.score);
}