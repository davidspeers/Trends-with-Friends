import 'package:flutter/material.dart';

import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:collection'; //Needed for LinkedHashMap (which is needed to maintain forEach order)
import 'fontStyles.dart';
import 'globals.dart';

List<String> userAnswers;

class TimeSeriesCallbackChart extends StatefulWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  TimeSeriesCallbackChart(this.seriesList, {this.animate});

  factory TimeSeriesCallbackChart.empty(List<String> usersAnswers) {
    userAnswers = usersAnswers;
    List<List<int>> weeklyVals = [[], []];
    for (int i=0; i<2; i++) {
      usersAnswers.forEach((string) => weeklyVals[i].add(0));
    }
    DateTime today = DateTime.now();
    return new TimeSeriesCallbackChart(_createWithData(
      weeklyVals: weeklyVals,
      allDateTimeDates: [DateTime.utc(today.year-1, today.month, today.day), today]
    ));
  }

  factory TimeSeriesCallbackChart.withTrendsValues(List<List<int>> weeklyVals, List<String> allDates, List<String> usersAnswers) {
    userAnswers = usersAnswers;
    return new TimeSeriesCallbackChart(_createWithData(
      weeklyVals: weeklyVals, allDates: allDates
    ));
  }

  //All functions need to be static because factorys are static.
  static List<charts.Series<TimeSeriesScore, DateTime>> _createWithData({
    List<List<int>> weeklyVals,
    List<String> allDates, //Use this one for withTrendsValues
    List<DateTime> allDateTimeDates //Use this one for empty
  }) {
    List<charts.Series<TimeSeriesScore, DateTime>> graphLinesList = [];
    List<TimeSeriesScore> data;
    List<DateTime> dateTimes;
    if (allDateTimeDates == null) {
      dateTimes = convertStringsToDateTimes(allDates);
    } else {
      dateTimes = allDateTimeDates;
    }

    //Instatiate data in the form [List<TimeSeriesScore> * number of teams]
    //For each team
    for (int i=0; i<weeklyVals[0].length; i++) {
      data = []; //reset data
      //For each week
      for (int j=0; j<weeklyVals.length; j++) {
        data.add(
          new TimeSeriesScore(
            dateTimes[j],
            weeklyVals[j][i]
          )
        );
      }
      graphLinesList.add(
          new charts.Series<TimeSeriesScore, DateTime>(
            id: 'Team ${i+1}',
            domainFn: (TimeSeriesScore score, _) => score.time,
            measureFn: (TimeSeriesScore score, _) => score.score,
            data: data,
          )
      );
    }
    return graphLinesList;
  }

  static List<DateTime> convertStringsToDateTimes(List<String> dates) {
    //Strings are in the form: MMM (D)D, YYYY
    //I want it in the forms: YYYY, MM, & DD
    List<DateTime> convertedList = [];
    List<String> tempSplitString;
    int year;
    int month;
    int day;
    dates.forEach((date) {
      //tempSplitString now ['MMM', '(D)D,', 'YYYY']
      tempSplitString = date.split(' ');
      //Convert Day
      day = int.parse(tempSplitString[1].replaceFirst(',', ''));
      //Convert Month
      switch (tempSplitString[0]) {
        case 'Jan': {month = 1; break;}
        case 'Feb': {month = 2; break;}
        case 'Mar': {month = 3; break;}
        case 'Apr': {month = 4; break;}
        case 'May': {month = 5; break;}
        case 'Jun': {month = 6; break;}
        case 'Jul': {month = 7; break;}
        case 'Aug': {month = 8; break;}
        case 'Sep': {month = 9; break;}
        case 'Oct': {month = 10; break;}
        case 'Nov': {month = 11; break;}
        case 'Dec': {month = 12; break;}
        default: {
          print("Error - no json months matched");
        }
      }
      //Convert Year
      year = int.parse(tempSplitString[2]);
      convertedList.add(DateTime(year, month, day));
    });
    return convertedList;
  }

  // We need a Stateful widget to build the selection details with the current
  // selection as the state.
  @override
  State<StatefulWidget> createState() => new _SelectionCallbackState();

}

class _SelectionCallbackState extends State<TimeSeriesCallbackChart> {
  DateTime _time;
  LinkedHashMap<String, num> _measures = new LinkedHashMap();

  // Listens to the underlying selection changes, and updates the information
  // relevant to building the primitive legend like information under the
  // chart.
  _onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;
    //print('[[[[[[' +model.selectedSeries[0].id);

    DateTime time;
    final LinkedHashMap<String, num> measures = new LinkedHashMap();

    // We get the model that updated with a list of [SeriesDatum] which is
    // simply a pair of series & datum.
    //
    // Walk the selection updating the measures map, storing off the score and
    // series name for each selection point.
    if (selectedDatum.isNotEmpty) {
      time = selectedDatum.first.datum.time;
      //print('------------' + selectedDatum.toString());
      //print(';;;;;;;' + selectedDatum[0].datum.score.toString());
      //print(';;;;;;;' + selectedDatum[0].series.toString());
      //print(';;;;;;;' + selectedDatum[0].hashCode.toString());
      //print(';;;;;;;' + selectedDatum[0].datum.toString());
      selectedDatum.forEach((charts.SeriesDatum datumPair) {
        measures[datumPair.series.displayName] = datumPair.datum.score;
      });
    }

    // Request a build.
    setState(() {
      _time = time;
      _measures = measures;
    });
  }

  @override
  Widget build(BuildContext context) {
    // The children consist of a Chart and Text widgets below to hold the info.
    List<charts.SeriesLegend> legend;
    if (userAnswers.length == 5) {
      legend = [new charts.SeriesLegend(
        position: charts.BehaviorPosition.start,
        horizontalFirst: false
      )];
    } else {
      legend = [new charts.SeriesLegend()];
    }
    final children = <Widget>[
      new SizedBox(
          height: 250.0,
          child: new charts.TimeSeriesChart(
            widget.seriesList,
            animate: widget.animate,
            selectionModels: [
              new charts.SelectionModelConfig(
                type: charts.SelectionModelType.info,
                listener: _onSelectionChanged,
              )
            ],
            behaviors: legend,
          )
      ),
    ];

    // If there is a selection, then include the details.
    if (_time != null) {
      String month;
      int day = _time.day;
      int monthInt = _time.month;
      int year = _time.year;
      switch (monthInt) {
        case 1: {month = 'Jan'; break;}
        case 2: {month = 'Feb'; break;}
        case 3: {month = 'Mar'; break;}
        case 4: {month = 'Apr'; break;}
        case 5: {month = 'May'; break;}
        case 6: {month = 'Jun'; break;}
        case 7: {month = 'Jul'; break;}
        case 8: {month = 'Aug'; break;}
        case 9: {month = 'Sep'; break;}
        case 10: {month = 'Oct'; break;}
        case 11: {month = 'Nov'; break;}
        case 12: {month = 'Dec'; break;}
        default: {print('Error - no monthInts matched');}
      }
      children.add(new Padding(
          padding: new EdgeInsets.only(top: 5.0),
          child: new Text("Week Beginning: $month $day, $year", style: blackTextSmall)));
    }
    children.add(new Padding(padding: new EdgeInsets.all(5.0)));
    /*int i = 0;
    _measures?.forEach((String series, num value) {
      children.add(
        new Container(
          color: globalColors[i],
          width: double.infinity,
          alignment: Alignment.center,
          child: new Text(
            '$series: $value',
            style: whiteTextSmall,
          ),
        )
      );
      i++;
    });*/
    final List<dynamic> colors = [Colors.blue[400], Colors.red[400], Colors.yellow[400], Colors.green[400], Colors.purple[300]];

    int i = 0;
    while (i < _measures.length) {
      String teamName = 'Team ${i+1}';
      num value = _measures[teamName];
      children.add(
        new Expanded(
          child: Container(
            color: colors[i],
            width: double.infinity,
            alignment: Alignment.center,
            child: new Text(
              '${userAnswers[i]}: $value',
              style: whiteTextSmallBlack,
              textAlign: TextAlign.center,
            ),
          ),
        )
      );
      i++;
    }

    return new Column(children: children);
  }
}

/// Sample time series data type.
class TimeSeriesScore {
  final DateTime time;
  final int score;

  TimeSeriesScore(this.time, this.score);
}