import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

final List<Color> globalColors = [Colors.blue, Colors.red, Colors.yellow, Colors.green, Colors.purple];

final Map<Color, Color> globalColorsToAccent = {
  Colors.blue: Colors.blueAccent,
  Colors.red: Colors.redAccent,
  Colors.yellow: Colors.yellowAccent,
  Colors.green: Colors.greenAccent,
  Colors.purple: Colors.purpleAccent
};

Map myThemesMap = {
  //'Government': ['Treason', 'Constitution', 'Spy', 'Hacking', 'Emails', 'Probe', 'Investigation', 'Prison'],
  //'Harassment': ['Harassment', 'Party', '80s', 'Producer', 'Couch', 'Grape', 'Consent', 'Workplace'],
  'Cryptocurrency': ['Coin', 'Block', 'Farm', 'Regulation', 'Payment', 'Mining', 'Hold', 'Chain'],
  //'March Madness': ['Ball', 'Hoop', 'Bracket', 'Seed', 'Division', 'College', 'Region', 'Round'],
  //'Immigration': ['Ethnic', 'Ice', 'Raid', 'Wall', 'Caravan', 'Nuclear', 'Family', 'Dream'],
  'Technology': ['Tech', 'Board', 'Battery', 'Facebook', 'Fortnite', 'Russia', 'Collision', 'Zuckerberg'],
  //'Rock Music': ['Rock', 'Platinum', 'Feedback', 'Guitar', 'Overdose', 'Bus', 'Poppers', 'Kayne'],
  //'RWBY': ['Anime', 'Rose', 'Grim', 'Dust', 'Juniper', 'Remnant', 'Cardinal', 'Haven'],
  //'Jurassic Park': ['Dinosaur', 'Life', 'Amber', 'DNA', 'Jeep', 'UNIX', 'Grant', 'Kingdom'],
  'Summer': ['Beach', 'Picnic', 'Camp', 'Sunshine', 'Hot', 'Jam', 'Sweat', 'BBQ'],
  //'Robin Williams': ['Robin', 'Popeye', 'Nanny', 'Genie', 'Alien', 'Android', 'Museum', 'AI'],
  //'Call Of Duty': ['Black', 'Tactics', 'Attachement', 'Confirmed', 'Ops', 'Dew', 'Scope', 'Killstreak'],
  //'Mark Wahlberg': ['Funky', 'Vibration', 'Boston', 'Happening', 'Star', 'Burgers', 'Transformers', 'Felony'],
  //'Skype': ['Call', 'Freemium', 'Ebay', 'Microsoft', 'Surveillance', 'Moji', 'Joel', 'Protocol'],
  'Biology': ['Foot', 'Hand', 'Leg', 'Arm', 'Body'],
  'Maths': ['Integrate', 'Range', 'Average', 'Maximum'],
  'Chemistry': ['Atom', 'Radioactive', 'Bond'],
  'Physics': ['Momentum', 'Gravity', 'Power'],
  'Languages': ['German', 'French', 'Spanish'],
  'Economics': ['Currency', 'Profit', 'Loss'],
  'Politics': ['Brexit', 'Prime Minister'],
  'Google': ['Search', 'Drive', 'News', 'Page', 'Alphabet', 'Plus', 'YouTube', 'Android'],
  'Star Wars': ['Saber', 'Force', 'Blaster', 'Jedi', 'Speeder', 'Space', 'Emperor', 'Projection'],
};

class Line {
  /// The points on the line.
  List<Offset> points;

  /// The color of the line.
  Color color;

  Line(List<Offset> points, Color color) {
    this.points = points;
    this.color  = color;
  }
}

FirebaseApp firebaseApp;
DatabaseReference firebaseDB;
FirebaseUser user;

List<Line> globalLines = [];

//The following are theme vals for achievement unlocking
bool isShowTheme = false;
bool isRandomTheme = false;
bool isCustomTheme = false;
String chosenThemeName = '';
int cpuDifficulty = 0; // 0 => Party Mode (NA), 4 => Impossible

//
int timerSetting = 0;

int termIndex = 0;
List<int> totals = [];

int maxTextLength = 50;

//GlobalValues so I can reset timer after queries loads
bool hasAnimationStarted;
AnimationController controller;

resetTimerAnimation() {
  hasAnimationStarted = false;
  controller.reset();
}
