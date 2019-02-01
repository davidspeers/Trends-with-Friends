import 'package:flutter/material.dart';
import 'fontStyles.dart';
import 'routes.dart';
import 'dart:async';
import 'globals.dart' as globals;
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

class OnlineModePage extends StatefulWidget {
  OnlineModePage({Key key, this.title, this.user}) : super(key: key);

  final String title;
  final FirebaseUser user;

  @override
  _OnlineModePageState createState() => new _OnlineModePageState();
}

class _OnlineModePageState extends State<OnlineModePage> {
  FirebaseDatabase database;
  DatabaseReference dbRef;
  final roomNameController = new TextEditingController();

  ///Helper Functions
  /*Widget customButton(String text, EdgeInsets padding) {
    return new Padding(
        padding: padding,
        child: ButtonTheme(
          height: 60.0,
          minWidth: double.infinity,
          child: RaisedButton(
              onPressed: () => joinOrHostAlert(text),
              color: Colors.blue[400],
              child: new Text(text, style: customFont(color: Colors.black87, fontsize: 7.0)),
              //splashColor: globalColorsToAccent[color], //hold button to see
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0)))
          ),
        )
    );
  }

  void joinOrHostAlert(String joinOrHost) {
    bool isJoin = (joinOrHost == 'Join Game') ? true : false;
    bool isHost = (joinOrHost == 'Host Game') ? true : false;
    if ((isJoin && isHost) == false) {
      new Exception("Custom Error - Neither Join or Host Game Matched");
    }
    showDialog<Null>(
      context: context,
      //barrierDismissible: false, // outside click dismisses alert
      builder: (BuildContext context) {
        return new AlertDialog(
          content: new TextField(
            controller: roomNameController,
            autofocus: true,
            decoration: new InputDecoration(
                filled: true,
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(12.0),
                ),
                hintText: "Enter Room Name"
            ),
            maxLength: 20,
            //onSubmitted: (text) => null,
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
              onPressed: () {
                if (isJoin) {

                } else {
                  createGameRoom(roomNameController.text.trimRight());
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    ThemeSelectRoute(
                      mode: 'Online Mode',
                      teamName: widget.user.displayName,
                      roomName: roomNameController.text.trimRight()
                    )
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }*/

  ///Creates a game room that other players can join.
  void createGameRoom(String roomName){
    dbRef.child(roomName).set({
      'Host': widget.user.displayName
    });
  }

  ///Call this when you press the category you want to join. Lookup the oldest in
  ///that categories wait list (if it exists) ensuring concurrency by doing it via a transaction.
  ///If it's empty add yourself to the wait list. If it fails try again.
  ///Problem is there's no waiting. If B,C,D join at the same time and A is already waiting.
  ///B will match with A, while B and C both join and will wait for another
  ///Solution - the concurrency ensures that if C and D fail, then we will add C concurrently and
  ///so when D tries to also add it will lookup.
  ///
  ///Call this when your waiting for someone to join. It is activated when there is a child added.
  ///Do a transaction to change the child to your partner.
  ///Problem is if A exists and B and C join what stops B asking C before A asks B
  void lookForRoom() {

  }

  List<Widget> _buildGrids(BuildContext context, List<String> items) {
      return [new SliverStickyHeader(
        header: _buildHeader('Show Themes'),
        sliver: new SliverGrid(
          gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 4.0, mainAxisSpacing: 4.0),
          delegate: new SliverChildBuilderDelegate(
                (context, i) => GestureDetector(
              onTap: () {
                //addToQueue(_getKeys(globals.myThemesMap)[i]);
                String category = _getKeys(globals.myThemesMap)[i];
                Navigator.of(context).push(
                    new OnlineGameRoute(category, globals.myThemesMap[category])
                );
              },
              child: new GridTile(
                child: new Container(
                  color: Colors.blue[100],
                  child: Center(
                    //padding: const EdgeInsets.all(8.0),
                    child: new Text(
                      items[i],
                      style: const TextStyle(color: Colors.black, fontSize: 16.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            childCount: items.length,
          ),
        ),
      )];
  }

  Widget _buildHeader(String heading) {
    return new Container(
      height: 60.0,
      color: Colors.lightBlue,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.centerLeft,
      child: new Text(
        heading,
        style: const TextStyle(color: Colors.white, fontSize: 18.0),
      ),
    );
  }

  List<String> _getKeys(Map map) {
    List<String> topics = [];
    map.forEach((k,v) => topics.add(k));
    return topics;
  }

  @override
  void initState() {
    database = FirebaseDatabase(app: globals.firebaseApp);
    dbRef = database.reference();
    globals.firebaseDB = dbRef;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text(widget.title),
      ),
      body: GlowingOverscrollIndicator(
          axisDirection: AxisDirection.down,
          color: Colors.blue,
          child: new CustomScrollView(slivers: _buildGrids(context, _getKeys(globals.myThemesMap))
          )
      ),
    );
  }
  /*List<Item> items = List();
  Item item;
  DatabaseReference itemRef;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    item = Item("", "");
    final FirebaseDatabase database = FirebaseDatabase.instance; //Rather then just writing FirebaseDatabase(), get the instance.
    itemRef = database.reference().child('items');
    itemRef.onChildAdded.listen(_onEntryAdded);
    itemRef.onChildChanged.listen(_onEntryChanged);
  }

  _onEntryAdded(Event event) {
    setState(() {
      items.add(Item.fromSnapshot(event.snapshot));
    });
  }

  _onEntryChanged(Event event) {
    var old = items.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      items[items.indexOf(old)] = Item.fromSnapshot(event.snapshot);
    });
  }

  void handleSubmit() {
    final FormState form = formKey.currentState;

    if (form.validate()) {
      form.save();
      form.reset();
      itemRef.push().set(item.toJson());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FB example'),
      ),
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
          Flexible(
            flex: 0,
            child: Center(
              child: Form(
                key: formKey,
                child: Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.info),
                      title: TextFormField(
                        initialValue: "",
                        onSaved: (val) => item.title = val,
                        validator: (val) => val == "" ? val : null,
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.info),
                      title: TextFormField(
                        initialValue: '',
                        onSaved: (val) => item.body = val,
                        validator: (val) => val == "" ? val : null,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        handleSubmit();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            child: FirebaseAnimatedList(
              query: itemRef,
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                return new ListTile(
                  leading: Icon(Icons.message),
                  title: Text(items[index].title),
                  subtitle: Text(items[index].body),
                );
              },
            ),
          ),
        ],
      ),
    );
  }*/
}