import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_list_drag_and_drop/drag_and_drop_list.dart';

class AddLevelPage extends StatefulWidget {
  AddLevelPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AddLevelPageState createState() => new _AddLevelPageState();
}

class _AddLevelPageState extends State<AddLevelPage> {
  final titleController = new TextEditingController();
  final queryController = new TextEditingController();
  List<String> items = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
  ];

  @override
  Widget build(BuildContext context) {
    return _addLevelPageUI();
  }

  @override
  void dispose() {
    // Clean up the controller when Widget is disposed
    titleController.dispose();
    queryController.dispose();
    super.dispose();
  }

  Widget _addLevelPageUI() {

    void changeFun() {
      print("In Function?");
    }

    var dragNDropList = new DragAndDropList<String>(
      items,
      itemBuilder: (BuildContext context, item) {
        return new SizedBox(
          child: new Card(
            child: new ListTile(
              title: new Text(item),
              trailing: new IconButton(
                  icon: new Icon(Icons.highlight_off),
                  tooltip: 'Action Tool Tip',
                  onPressed: () {
                    //The onPressed doesn't always seem to work. Thus the print statement.
                    //Stopping and Running the app seems to fix this.
                    print("Logging Working?");
                    changeFun();
                  }
              ),
            ),
          ),
        );
      },
      onDragFinish: (before, after) {
        String data = items[before];
        items.removeAt(before);
        items.insert(after, data);
      },
      canBeDraggedTo: (one, two) => true,
      dragElevation: 8.0,
    );

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
        actions: <Widget>[
          FlatButton(child: Text("Save"),)
        ],
      ),
      /*body: new Column(
          //shrinkWrap: true,
          //padding: const EdgeInsets.all(20.0),
          children: myChildren
      ),*/
      body: new Container(
        padding: const EdgeInsets.all(10.0),
        child: new Column(
          children: <Widget>[
            new TextField(
                controller: titleController,
                autofocus: true,
                decoration: new InputDecoration(
                    filled: true,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(12.0),
                    ),
                    hintText: 'Title Name'
                )
            ),
            new Text("What do you want your team name to be?"),
            new TextField(
                controller: queryController,
                autofocus: true,
                decoration: new InputDecoration(
                    filled: true,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(12.0),
                    ),
                    hintText: 'Query Name'
                )
            ),
            new Container(
              height: 8.0,
            ),
            new Expanded(
              child: dragNDropList
            )

          ]
        )
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          if (queryController.text.isNotEmpty) {
            _addQuery();
          } else {
            //true if keyboard is hidden. uses ternary operator for succinctness
            var toastPosition = (MediaQuery.of(context).viewInsets.bottom == 0) ? ToastGravity.BOTTOM : ToastGravity.CENTER;
            Fluttertoast.showToast(
                msg: "You can't add an empty query",
                toastLength: Toast.LENGTH_SHORT,
                gravity: toastPosition,
                timeInSecForIos: 1,
                bgcolor: "#e74c3c",
                textcolor: '#ffffff'
            );
          }
        },
        tooltip: 'Show me the value!',
        child: new Icon(Icons.add),
      ),
    );
  }

  void _addQuery() {
    //Add to ListView
    setState(() {
      //queries += [Text(queryController.text)];
    });
    queryController.clear();
  }
}