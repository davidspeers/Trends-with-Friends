import 'package:flutter/material.dart';

//Note: the enums are located in this file
import 'levelEditor.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AddLevelPage extends StatefulWidget {
  AddLevelPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AddLevelPageState createState() => new _AddLevelPageState();
}

class _AddLevelPageState extends State<AddLevelPage> {
  List<String> items = [];

  getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      items = prefs.getStringList("CustomLevels") ?? [];
    });
  }

  setSharedPrefs(String chosenLevel, ListChoices listChoice) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("CustomLevels", items);
    if (listChoice == ListChoices.delete) {
      prefs.remove(chosenLevel);
    }
  }

  @override
  void initState() {
    super.initState();
    getSharedPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return _addLevelPageUI();
  }

  Widget _addLevelPageUI() {

    var levelsList = new ListView.builder(
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
                    child: const Text('Delete Level'),
                  ),
                  const PopupMenuItem<ListChoices>(
                    value: ListChoices.edit,
                    child: const Text('Edit Level'),
                  ),
                  const PopupMenuItem<ListChoices>(
                    value: ListChoices.moveToTop,
                    child: const Text('Move Level to top of List'),
                  ),
                  const PopupMenuItem<ListChoices>(
                    value: ListChoices.moveToBottom,
                    child: const Text('Move Level to bottom of List'),
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
        actions: <Widget>[
          FlatButton(
            child: Text("Add Level"),
            onPressed: () => _pushLevelEditor(levelEditType: LevelEditingTypes.add),
          )
        ],
      ),
      body: new Container(
          padding: const EdgeInsets.all(10.0),
          child: new Column(
              children: <Widget>[
                new Expanded(
                    child: levelsList
                )

              ]
          )
      ),
    );
  }

  void executeChoice(ListChoices choice, int itemNumber) {
    String chosenLevel = items[itemNumber];
    switch (choice) {
      case (ListChoices.delete): {
        //items.removeAt(itemNumber);
        setState(() {
          items.removeAt(itemNumber);
        });
        break;
      }

      case (ListChoices.edit): {
        _pushLevelEditor(levelEditType: LevelEditingTypes.edit, levelTitle: items[itemNumber]);
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
    setSharedPrefs(chosenLevel, choice);
  }

  void _pushLevelEditor({LevelEditingTypes levelEditType, String levelTitle}) {
    /*setState(() {
      for (int i = 0; i < 3; i++) {
        items.add(
          i.toString()
        );
      }
    });*/
    switch (levelEditType) {
      case (LevelEditingTypes.add): {
        Navigator.of(context).push(
          new MaterialPageRoute(
            builder: (context) {
              return new LevelEditorPage(
                title: "Hello", levelEditingType: levelEditType, existingLevels: items);
            }
          )
        );
        break;
      }
      case (LevelEditingTypes.edit): {
        Navigator.of(context).push(
          new MaterialPageRoute(
            builder: (context) {
              return new LevelEditorPage(
                title: "Hello", levelEditingType: levelEditType, existingLevels: items, levelTitle: levelTitle);
            }
          )
        );
        break;
      }
      default: {
        print("Error - LevelEditingType of wrong type (probably null)");
      }
    }
  }
}