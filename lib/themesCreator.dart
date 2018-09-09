import 'package:flutter/material.dart';

//Note: the enums are located in this file
import 'themesEditor.dart';

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'customWidgets.dart';
import 'routes.dart';

class AddThemePage extends StatefulWidget {
  AddThemePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AddThemePageState createState() => new _AddThemePageState();
}

class _AddThemePageState extends State<AddThemePage> {
  List<String> items = [];
  BuildContext _scaffoldContext;

  updateAchievements() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isTrendSetter = prefs.getBool('Trends Setter') ?? false;
    bool isProTrendSetter = prefs.getBool('Pro Trends Setter') ?? false;
    if (!(isTrendSetter && isProTrendSetter)) {
      int numCreatedThemes = prefs.getInt("Number of Created Themes") ?? 0;
      numCreatedThemes++;
      if (numCreatedThemes == 1 && !isTrendSetter) {
        prefs.setBool('Trends Setter', true);
        createSnackBar('Achievement Unlocked -\nTrends Setter', _scaffoldContext);
      } else if (numCreatedThemes == 5 && !isProTrendSetter) {
        prefs.setBool('Pro Trends Setter', true);
        createSnackBar('Achievement Unlocked -\nPro Trends Setter', _scaffoldContext);
      } else {
        Fluttertoast.showToast(
            msg: "Theme Saved",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            bgcolor: "#e74c3c",
            textcolor: '#ffffff'
        );
      }
      prefs.setInt("Number of Created Themes", numCreatedThemes);
    }
  }

  getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      items = prefs.getStringList("CustomThemes") ?? [];
    });
  }

  //"CustomThemes" contains the title of each custom theme
  //"$title" will give you a list of strings of that themes queries
  setSharedPrefs(String chosenTheme, ListChoices listChoice) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("CustomThemes", items);
    if (listChoice == ListChoices.delete) {
      prefs.remove(chosenTheme);
    }
  }

  @override
  void initState() {
    getSharedPrefs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _addThemePageUI();
  }

  Widget _addThemePageUI() {

    var themesList = new ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, item) {
        return new SizedBox(
          child: new Card(
            child: new ListTile(
              title: new Text(items[item]),
              trailing: new PopupMenuButton<ListChoices>(
                onSelected: (ListChoices result) { executeChoice(result, item); },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<ListChoices>>[
                  const PopupMenuItem<ListChoices>(
                    value: ListChoices.delete,
                    child: const Text('Delete Theme'),
                  ),
                  const PopupMenuItem<ListChoices>(
                    value: ListChoices.edit,
                    child: const Text('Edit Theme'),
                  ),
                  const PopupMenuItem<ListChoices>(
                    value: ListChoices.moveToTop,
                    child: const Text('Move Theme to top of List'),
                  ),
                  const PopupMenuItem<ListChoices>(
                    value: ListChoices.moveToBottom,
                    child: const Text('Move Theme to bottom of List'),
                  ),
                ],
              )
            ),
          ),
        );
      },
    );

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
        backgroundColor: Colors.green[400],
        actions: <Widget>[
          FlatButton(
            child: Text("Add Theme"),
            onPressed: () async {
              bool isNewThemeAdded = await _pushThemeEditor(themeEditType: ThemeEditingTypes.add) ?? false; //null unless Save Theme was pressed
              if (isNewThemeAdded) {
                await getSharedPrefs();
                updateAchievements();
              }
            }
          )
        ],
      ),
      body: new Builder(builder: (BuildContext context) {
        _scaffoldContext = context;
        return new Container(
            padding: const EdgeInsets.all(10.0),
            child: new Column(
                children: <Widget>[
                  new Expanded(
                      child: themesList
                  )

                ]
            )
        );
      })
    );
  }

  void executeChoice(ListChoices choice, int itemNumber) {
    String chosenTheme = items[itemNumber];
    switch (choice) {
      case (ListChoices.delete): {
        //items.removeAt(itemNumber);
        setState(() {
          items.removeAt(itemNumber);
        });
        break;
      }

      case (ListChoices.edit): {
        _pushThemeEditor(themeEditType: ThemeEditingTypes.edit, themeTitle: items[itemNumber]);
        break;
      }

      case (ListChoices.moveToTop): {
        String item = items.removeAt(itemNumber);
        setState(() {
          items.insert(
            0,
            item
          );
        });
        break;
      }

      case (ListChoices.moveToBottom): {
        String item = items.removeAt(itemNumber);
        setState(() {
          items.insert(
              items.length,
              item
          );
        });
        break;
      }

      default: {
        print("Error - ListChoices not of expected enum");
      }
    }
    setSharedPrefs(chosenTheme, choice);
  }

  Future _pushThemeEditor({ThemeEditingTypes themeEditType, String themeTitle}) {
    /*setState(() {
      for (int i = 0; i < 3; i++) {
        items.add(
          i.toString()
        );
      }
    });*/
    //Making this a future and returning is here to check if we've added a new Theme
    //and so need to update the list
    //Returns either true, false, or null. We only do anything if adding a theme.
    //And even then only if they pressed Save Theme.
    switch (themeEditType) {
      case (ThemeEditingTypes.add): {
        return Navigator.of(context).push(
            ThemesEditorPageRoute(themeEditingType: themeEditType, existingThemes: items)
        );
      }
      case (ThemeEditingTypes.edit): {
        return Navigator.of(context).push(
            ThemesEditorPageRoute(themeEditingType: themeEditType, existingThemes: items, themeTitle: themeTitle)
        );
      }
      default: {
        print("Error - ThemeEditingType of wrong type (probably null)");
      }
    }
  }
}