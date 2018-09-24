import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'globals.dart' as globals;

import 'themeSelect.dart';
import 'query.dart';
import 'timer.dart';
import 'result.dart';
import 'finalScore.dart';
import 'about.dart';
import 'achievements.dart';
import 'themesCreator.dart';
import 'themesEditor.dart';

class ThemeSelectRoute extends CupertinoPageRoute {
  final alertChoice;
  final String mode;

  ThemeSelectRoute(this.alertChoice, this.mode)
      : super(
    builder: (BuildContext context) => new ThemeSelectPage(title: 'Theme Select', alertChoice: alertChoice, mode: mode),
  );
}

class QueryOrTimerPageRoute extends CupertinoPageRoute {
  final String title;
  final List<String> terms;
  final Future<List<String>> futureTerms;
  final String mode;
  final dynamic alertChoice;

  QueryOrTimerPageRoute({@required this.title, this.terms, this.futureTerms, @required this.mode, @required this.alertChoice})
      : super(
    //WillPopScope stops the swipe left to go back feature
    builder: (BuildContext context) {
      if (globals.timerSetting == 0) {
        return new WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: new QueryPage(
            title: title,
            terms: terms,
            futureTerms: futureTerms,
            mode: mode,
            alertChoice: alertChoice,
          ),
        );
      } else {
        return new TimerPage(
          title: title,
          terms: terms,
          futureTerms: futureTerms,
          mode: mode,
          alertChoice: alertChoice
        );
      }
    },
    settings: RouteSettings(name: "/QueryOrTimer")
  );
}

class QueryPageRoute extends CupertinoPageRoute {
  final String title;
  final List<String> terms;
  final Future<List<String>> futureTerms;
  final String mode;
  final dynamic alertChoice;

  QueryPageRoute({@required this.title, this.terms, this.futureTerms, @required this.mode, @required this.alertChoice})
      : super(
    //WillPopScope stops the swipe left to go back feature
      builder: (BuildContext context) {
        return new WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: new QueryPage(
            title: title,
            terms: terms,
            futureTerms: futureTerms,
            mode: mode,
            alertChoice: alertChoice,
          ),
        );
      }
  );
}

class ResultsPageRoute extends CupertinoPageRoute {
  final List<String> queries;
  final bool lastQuery;
  final List<int> previousResults;
  final String term;
  final String mode;
  final dynamic alertChoice;

  ResultsPageRoute(
      this.queries,
      this.lastQuery,
      this.previousResults,
      this.term,
      this.mode,
      this.alertChoice,
  ) : super(
    builder: (BuildContext context) => new ResultsPage(
        title: 'Results',
        queries: queries,
        lastQuery: lastQuery,
        previousResults: previousResults,
        term: term,
        mode: mode,
        alertChoice: alertChoice,
    ),
    //fullscreenDialog: true
  );
}

class FinalScorePageRoute extends CupertinoPageRoute {
  final String title;
  final List<int> scores;
  final String mode;

  FinalScorePageRoute({
    @required this.title,
    @required this.scores,
    @required this.mode,
  }) : super(
    builder: (BuildContext context) => new FinalScorePage(
      title: title,
      scores: scores,
      mode: mode,
    ),
  );
}

class AboutPageRoute extends CupertinoPageRoute {
  AboutPageRoute()
      : super(
    builder: (BuildContext context) => new AboutPage(title: 'About'),
  );
}

class AchievementsPageRoute extends CupertinoPageRoute {
  AchievementsPageRoute()
      : super(
      builder: (BuildContext context) => new AchievementsPage(title: 'Achievements'),
  );
}

class ThemesCreatorPageRoute extends CupertinoPageRoute {
  ThemesCreatorPageRoute()
    : super(
      builder: (BuildContext context) => new AddThemePage(title: "Custom Themes"),
      settings: RouteSettings(name: "/ThemesCreator")
);
}

class ThemesEditorPageRoute extends CupertinoPageRoute {

  final ThemeEditingTypes themeEditingType;
  final List<String> existingThemes;
  final String themeTitle;

  ThemesEditorPageRoute({this.themeEditingType, this.themeTitle, this.existingThemes})
      : super(
      builder: (BuildContext context) => new ThemeEditorPage(
        title: 'Theme Editor',
        themeEditingType: themeEditingType,
        themeTitle: themeTitle,
        existingThemes: existingThemes,
      )//needs params
  );
}