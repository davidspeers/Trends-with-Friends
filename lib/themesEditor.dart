import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'fontStyles.dart';
import 'globals.dart' as globals;

class ThemeEditorPage extends StatefulWidget {
  ThemeEditorPage({Key key, this.title, this.themeEditingType, this.themeTitle, this.existingThemes}) : super(key: key);

  final String title;
  final ThemeEditingTypes themeEditingType;
  final List<String> existingThemes;
  final String themeTitle;

  @override
  _ThemeEditorPageState createState() => new _ThemeEditorPageState();
}

enum ListChoices { edit, delete, moveToTop, moveToBottom }
enum QueryEditingTypes { add, edit }
enum ThemeEditingTypes { add, edit }


class _ThemeEditorPageState extends State<ThemeEditorPage> {
  //final titleController = new TextEditingController(text: widget.themeTitle ?? "");
  final titleController = new TextEditingController();
  List<String> items = [];

  @override
  Widget build(BuildContext context) {
    return _addThemePageUI();
  }

  getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> queries = prefs.getStringList('Escape ${widget.themeTitle}');
    setState(() {
      items = queries ?? []; //Because queries could be null
    });
  }

  @override
  void initState() {
    getSharedPrefs();
    //This code is needed as if in build it is recalled upon keyboard pop or push
    //Can't simply set titleController.text to widget.themeTitle because cursor points to beginning of Text Editor
    //This workaround and others can be found on https://github.com/flutter/flutter/issues/11416
    var cursorPos = titleController.selection;
    titleController.text = widget.themeTitle ?? '';
    if (cursorPos.start > titleController.text.length) {
      cursorPos = new TextSelection.fromPosition(
          new TextPosition(offset: titleController.text.length));
    }
    titleController.selection = cursorPos;
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when Widget is disposed
    titleController.dispose();
    super.dispose();
  }

  Widget _addThemePageUI() {
    bool textFieldAutoFocus;

    switch (widget.themeEditingType) {
      case (ThemeEditingTypes.add): {
        textFieldAutoFocus = true;
        break;
      }
      case (ThemeEditingTypes.edit): {
        textFieldAutoFocus = false;
        break;
      }
      default: {
        print("Error - ListChoices not of expected enum");
      }
    }

    var queriesList;
    if (items.isEmpty) {
      queriesList = Center(
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: Text(
              "To add a word to the theme press the '+' symbol in the top-right corner",
              textAlign: TextAlign.center,
              style: blackTextSmall,
            ),
          )
      );
    } else {
      queriesList = new GlowingOverscrollIndicator(
        axisDirection: AxisDirection.down,
        color: Colors.green,
        child: new ListView.builder(
          itemCount: items.length,
          itemBuilder: (BuildContext context, item) {
            return new Padding(
              padding: EdgeInsets.only(left: 5.0, right: 5.0),
              child: new Card(
                child: new ListTile(
                  title: new Text(items[item]),
                  trailing: new PopupMenuButton<ListChoices>(
                    onSelected: (ListChoices result) { executeChoice(result, item); },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<ListChoices>>[
                      const PopupMenuItem<ListChoices>(
                        value: ListChoices.delete,
                        child: const Text('Delete Query'),
                      ),
                      const PopupMenuItem<ListChoices>(
                        value: ListChoices.edit,
                        child: const Text('Edit Query'),
                      ),
                      const PopupMenuItem<ListChoices>(
                        value: ListChoices.moveToTop,
                        child: const Text('Move Query to top of List'),
                      ),
                      const PopupMenuItem<ListChoices>(
                        value: ListChoices.moveToBottom,
                        child: const Text('Move Query to bottom of List'),
                      ),
                    ],
                  )
                )
              )
            );
          },
        )
      );
    }

    exitDialog() {
      String message = "Can't save theme because:";
      bool displayMessage = false;
      if (titleController.text.isEmpty) {
        message += "\n• Title is empty";
        displayMessage = true;
      }
      if (items.isEmpty) {
        message += "\n• No words have been added";
        displayMessage = true;
      }
      if (
      widget.existingThemes.contains(titleController.text.trim()) &&
          (titleController.text.trim() != (widget.themeTitle ?? "").trim() || widget.themeEditingType == ThemeEditingTypes.add)
      ) {
        message +="\n• A theme with this title already exists";
        displayMessage = true;
      }
      if (!displayMessage) {
        setSharedPrefs(titleController.text, items);
        //Popping true tells creator a new theme was created
        Navigator.of(context).pop(true);
      } else {
        message += "\n\nDo you wish to leave without saving?";

        showDialog<Null>(
          context: context,
          //barrierDismissible: false, // outside click dismisses alert
          builder: (BuildContext context) {
            return new AlertDialog(
              content: new Text(message, style: blackTextSmaller),
              contentPadding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
              actions: <Widget>[
                new FlatButton(
                  child: new Text(
                    'Cancel',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                new FlatButton(
                  child: new Text(
                    'Confirm',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0
                    ),
                  ),
                  onPressed: () {
                    //Look at main.dart to see how I routes to name the desired ModalRoute
                    Navigator.popUntil(context, ModalRoute.withName('/ThemesCreator'));
                  },
                ),
              ],
            );
          },
        );
      }
    }

    return new WillPopScope(
      onWillPop: exitDialog,
      child: Scaffold(
        appBar: new AppBar(
          leading: IconButton(
            icon: Icon(Icons.check),
            onPressed: exitDialog
          ),
          title: new Text(widget.title),
          backgroundColor: Colors.green[400],
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => queryAlert(QueryEditingTypes.add, items.length),
            )
          ],
        ),
        body: new Column(
                children: <Widget>[
                  new Padding(
                    padding: EdgeInsets.all(10.0),
                    child: new TextField(
                      controller: titleController,
                      autofocus: textFieldAutoFocus,
                      decoration: new InputDecoration(
                          filled: true,
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(12.0),
                          ),
                          hintText: 'Theme Name'
                      ),
                      maxLength: globals.maxTextLength,
                    ),
                  ),
                  new Container(
                    height: 6.0,
                  ),
                  new Expanded(
                      child: queriesList
                  )

                ]
            )
      )
    );
  }

  void executeChoice(ListChoices choice, int itemNumber) {
    switch (choice) {
      case (ListChoices.delete): {
        //items.removeAt(itemNumber);
        setState(() {
          items.removeAt(itemNumber);
        });
        break;
      }

      case (ListChoices.edit): {
        queryAlert(QueryEditingTypes.edit, itemNumber);
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
  }

  void queryAlert(QueryEditingTypes type, int itemNumber) {
    String myHintText;
    switch (type) {
      case(QueryEditingTypes.add): {
        myHintText = "Enter Query Name";
        break;
      }
      case(QueryEditingTypes.edit): {
        myHintText = items[itemNumber];
        break;
      }
      default: {
        print("Error - QueryEditingTypes not of expected enum");
      }
    }
    final queryController = new TextEditingController();

    addQuery() {
      setState(() {
        if (queryController.text.isEmpty) {
          var toastPosition = (MediaQuery.of(context).viewInsets.bottom == 0) ? ToastGravity.BOTTOM : ToastGravity.CENTER;
          Fluttertoast.showToast(
              msg: "Query Name can't be empty",
              toastLength: Toast.LENGTH_SHORT,
              gravity: toastPosition,
              timeInSecForIos: 1
          );
        } else {
          if (type == QueryEditingTypes.add) {
            items.add(queryController.text);
          } else if (type == QueryEditingTypes.edit) {
            items[itemNumber] = queryController.text;
          } else {
            print("Error - QueryEditingTypes not of expected enum");
          }
          Navigator.of(context).pop();
        }
      });
    }

    if (items.length < 25) {
      showDialog<Null>(
        context: context,
        //barrierDismissible: false, // outside click dismisses alert
        builder: (BuildContext context) {
          return new AlertDialog(
            content: new TextField(
              controller: queryController,
              autofocus: true,
              decoration: new InputDecoration(
                  filled: true,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(12.0),
                  ),
                  hintText: myHintText
              ),
              maxLength: globals.maxTextLength,
              onSubmitted: (text) => addQuery(),
            ),
            contentPadding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
            actions: <Widget>[
              new FlatButton(
                child: new Text(
                  'Cancel',
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text(
                  'Confirm',
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0
                  ),
                ),
                onPressed: () => addQuery(),
              ),
            ],
          );
        },
      );
    } else {
      Fluttertoast.showToast(
        msg: "Queries Limit Reached",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1
      );
    }
  }

  setSharedPrefs(String title, List<String> queries) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    title = title.trim(); //removes leading and trailing whitespace
    var customThemes = prefs.getStringList("CustomThemes") ?? [];
    if (widget.themeEditingType == ThemeEditingTypes.add) {
      customThemes.add(title);
    } else if (widget.themeEditingType == ThemeEditingTypes.edit) {
      int themeIndex = customThemes.indexOf(widget.themeTitle);

      //Remove Previous Theme Key and Values to free up space
      String previousThemeName = customThemes[themeIndex];
      prefs.remove(previousThemeName);

      //Set location of edited name to location of previous name
      customThemes[themeIndex] = title;
    }
    prefs.setStringList("CustomThemes", customThemes);
    prefs.setStringList('Escape $title', queries);
  }
}