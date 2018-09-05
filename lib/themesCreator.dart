import 'package:flutter/material.dart';

//Note: the enums are located in this file
import 'themesEditor.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'routes.dart';

class AddThemePage extends StatefulWidget {
  AddThemePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AddThemePageState createState() => new _AddThemePageState();
}

class _AddThemePageState extends State<AddThemePage> {
  List<String> items = [];

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
            onPressed: () => _pushThemeEditor(themeEditType: ThemeEditingTypes.add),
          )
        ],
      ),
      body: new Container(
          padding: const EdgeInsets.all(10.0),
          child: new Column(
              children: <Widget>[
                new Expanded(
                    child: themesList
                )

              ]
          )
      ),
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

  void _pushThemeEditor({ThemeEditingTypes themeEditType, String themeTitle}) {
    /*setState(() {
      for (int i = 0; i < 3; i++) {
        items.add(
          i.toString()
        );
      }
    });*/
    switch (themeEditType) {
      case (ThemeEditingTypes.add): {
        Navigator.of(context).push(ThemesEditorPageRoute(themeEditingType: themeEditType, existingThemes: items));
        break;
      }
      case (ThemeEditingTypes.edit): {
        Navigator.of(context).push(ThemesEditorPageRoute(themeEditingType: themeEditType, existingThemes: items, themeTitle: themeTitle));
        break;
      }
      default: {
        print("Error - ThemeEditingType of wrong type (probably null)");
      }
    }
  }
}