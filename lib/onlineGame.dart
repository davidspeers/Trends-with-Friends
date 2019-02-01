//Should be the same for both host and joiner
//Requires teamName and roomName
import 'package:flutter/material.dart';
import 'fontStyles.dart';
import 'routes.dart';
import 'result.dart';
import 'dart:async';
import 'globals.dart' as globals;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

String userid;

class OnlineGamePage extends StatefulWidget {
  OnlineGamePage({Key key, this.category, this.queries}) : super(key: key);

  final String category;
  final List<String> queries;

  @override
  _OnlineGamePageState createState() => new _OnlineGamePageState();
}

class _OnlineGamePageState extends State<OnlineGamePage> {
  int queryNum = 0;
  String myTerm;
  bool isHost;
  bool hasPartner = false;
  bool isWaitingForResults = false;
  List<WaitRoom> items = List();
  WaitRoom item;
  String waitCategory;
  String myKey; //Instantiated upon wait list join or successful partnering.
  DatabaseReference waitRoomRef; //The path to your waitRoom (including unique key)
  DatabaseReference waitListRef; //The Path to all the waitRooms
  DatabaseReference gameRoomRef; //the path to your gameroom
  DatabaseReference gamesListRef;//The path to all gameRooms
  List<Widget> myBody = [];
  Widget resultsWidget = Container();
  List<int> totals = [0, 0];
  StreamSubscription<Event> listenerToCancel;
  StreamSubscription<Event> listenerForLeaving;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    widget.queries.add('');
    item = WaitRoom("", "", "");
    waitCategory = 'Wait List/' + widget.category;
    waitListRef = globals.firebaseDB.child(waitCategory);

    ///Transactions
    /*var success = globals.firebaseDB.runTransaction((transaction) async {
      await transaction.set(userReference, userMap);
    }).then((_) {
      return globals.firebaseDB.collection(CollectionName.user).where(FirebaseUserField.uid, isEqualTo: userMap["uid"]).getDocuments();
    }).then((querySnapshot) {
      if (querySnapshot.documents.length == 0) {
        return false;
      }
      return true;
    }).catchError((e) {
      print(e);
      return false;
    });*/

    //waitListRef = globals.firebaseDB.child('items');
    //waitListRef.onChildAdded.listen((_) => print('Happened'));

    _findPartner();
    //waitListRef.onChildChanged.listen(_onEntryChanged);
    //DatabaseReference getAllWaiting2 = waitListRef.child(waitCategory).orderByKey().limitToFirst(1).reference();
    //print('@@@@@@@' + getAllWaiting);
    //print('@@@@@@@' + getAllWaiting2.toString());

  }

  ///First find the oldest entry in the chosen category.
  ///If none exists add yourself to the list.
  ///Else do a transaction join the oldest entry (make sure no other already joined).
  ///If that fails look if an oldest entry still exists and try again.
  ///Keep repeating that until the list is empty. At that point add yourself as part of a transaction
  ///
  /// Changing it - find all entries (or first 10) in the chosen category ordered by key.
  /// If empty add yourself to list
  /// Else loop through every entry trying to add yourself via a transaction
  /// If Successful break while loop
  /// If End of Loop reached join wait list
  _findPartner() {
    ///Return the oldest entry in the category
    isHost = false;
    int limitNum = 10;
    waitListRef.orderByKey().limitToFirst(limitNum).once().then((DataSnapshot snapshot) {
      print('Data : ${snapshot.value}');
      Map keys2vals = new Map<String, dynamic>.from(snapshot.value);
      List keys = new List<String>.from(keys2vals.keys);

      assert(keys.length <= limitNum);
      //print(keys2vals[keys[0]]['partner']); //Prints the state of that entry

      TransactionResult transactionResult;
      DatabaseReference waitListRef2;
      bool partnerFound = false;
      Future.forEach(keys.takeWhile((_) => !partnerFound), (key) async {
        waitListRef2 = globals.firebaseDB.child(waitCategory + '/' + key + '/partner');
        transactionResult = await waitListRef2.runTransaction((MutableData transaction) async {
          if (transaction.value == "") {
            transaction.value = globals.user.uid;
            partnerFound = true;
          }
          return transaction;
        });
        if (transactionResult.committed && partnerFound) {
          //committed means the transaction was successful.
          //However, this is true whether or not a value is committed.
          print('Partner Found and Transaction Committed.');
          myKey = key;
          _joinGame();
        } else {
          //Means we found a partner but the transaction wasn't successful
          //(because someone changed the value before us)
          print('Transaction not committed.');
          if (transactionResult.error != null) {
            print(transactionResult.error.message);
          }
          partnerFound = false;
        }
      }).then((_) {
        //We reach this point either because we found a partner or we finished looping
        if (!partnerFound) {
          print('No Partner Found - Joining Waitlist');
          _joinWaitList();
        }
      });
    }).catchError((e) {
      ///Adds you to Firebase waitlist, ordered by key.
      ///user.uid is unique to the user so you know who is who
      ///user.displayName is what we'll display to the opponent
      print('Error Caught - Joining WaitList');
      print(e.toString());
      _joinWaitList();
    });
  }

  ///Join WaitList and listen for a child to be added to your room
  _joinWaitList() {
    waitRoomRef = waitListRef.push();
    waitRoomRef.set({
      'userID' : globals.user.uid,
      'displayName' : globals.user.displayName,
      'partner' : ''
    });
    print(waitRoomRef.path);
    List<String> myKeys = waitRoomRef.path.split('/');
    myKey = myKeys.last;
    print(myKey);
    waitRoomRef.onChildChanged.listen((_) => _startGame());
    //waitListRef.child('').onChildAdded.listen(_onEntryAdded);
  }

  ///Remove Waiter From List, join Game Room, Play game with first query.
  ///First term is initialised as an empty string, and other term doesn't exits
  ///so the listener can distinguish between onChildAdded & Changed.
  _startGame() {
    
    isHost = true; //you'll end up being the host - is used for tracking who's who in firebase

    setState(() {
      hasPartner = true;
    });
    Fluttertoast.showToast(
      msg: "Opponent Found",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 1,
    );
    deleteWaitRoom();
    print('Starting Game');
    gamesListRef = globals.firebaseDB.child('Game Room');
    gameRoomRef = gamesListRef.child(myKey);
    _listenForPartnerLeaving();
    gameRoomRef.child('host').set({
      'term' : '',
      //'status': '',
      'query num': 0
    });
    gameRoomRef.child('joiner').set({
      'term' : '',
      //'status': '',
      'query num': 0
    });
    gameRoomRef.child('results').set({
      //Can't Set it to a number between 0 and 100 because isChanged won't trigger if a value equals the val in Firebase.
      'host' : "",
      'joiner' : ""
    });
  }
  
  _joinGame() {
    isHost = false;
    gamesListRef = globals.firebaseDB.child('Game Room');
    gameRoomRef = gamesListRef.child(myKey);
    _listenForPartnerLeaving();
    setState(() {
      hasPartner = true;
    });
    Fluttertoast.showToast(
      msg: "Opponent Found",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 1,
    );
  }

  _listenForPartnerLeaving() {
    listenerForLeaving = gameRoomRef.onChildRemoved.listen((_) {
      print('Partner Left');
      Navigator.popUntil(context, ModalRoute.withName('/OnlineMode'));
      Fluttertoast.showToast(
        msg: "Opponent Left The Game",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
      );
    });
  }

  ///Submit your term. Uses transactions.
  ///Whichever player answers first - they'll enter their term and wait for
  ///a result to appear telling them the scores.
  ///The other to answer looks up the terms using the trends server and posts
  ///the results to the room.
  void submitTerm() async {
    final FormState form = formKey.currentState;

    if (form.validate()) {
      form.save();
      form.reset();
      String myPath = (isHost) ? 'host' : 'joiner';
      String otherPath = (isHost) ? 'joiner' : 'host';
      gameRoomRef.child(myPath).update({
        'term': myTerm,
        'query num': queryNum
      });
      gameRoomRef.child(otherPath).once().then((DataSnapshot snapshot) {
        print('Data : ${snapshot.value}');
        Map keys2vals = new Map<String, dynamic>.from(snapshot.value);
        //if (keys2vals['query num'] == queryNum)
        if (queryNum == keys2vals['query num'] + 1) {
          //implies other player hasn't sent their term yet, therefore wait
          print('Waiting For Opponent');
          Map<String, int> getScore = {};
          setState(() {
            resultsWidget = Column(
              children: <Widget>[
                CircularProgressIndicator(),
                new Container(height: 10.0),
                new Text(
                  'Waiting for your opponent.',
                  style: customFont(
                      color: Colors.blue[600],
                      fontsize: 11.0
                  ),
                ),
              ],
            );
          });
          listenerToCancel = gameRoomRef.child('results').onChildChanged.listen((Event event) {
            print(event.snapshot.value);
            getScore[event.snapshot.key] = event.snapshot.value;
            if (getScore.containsKey('host') && getScore.containsKey('joiner')) {
              //other answerer has queried google trends server.
              gameRoomRef.child(otherPath + '/term').once().then((DataSnapshot snapshot) {
                setState(() {
                  if (isHost) {
                    resultsWidget = showResultsViaFirebase(
                      getScore['host'],
                      myTerm,
                      getScore['joiner'],
                      snapshot.value
                    );
                  } else  {
                    resultsWidget = showResultsViaFirebase(
                      getScore['joiner'],
                      snapshot.value,
                      getScore['host'],
                      myTerm
                    );
                  }
                });
              });
            }
          });
        } else if (queryNum == keys2vals['query num']) {
          //other player has sent their term so you need to update the results
          print(widget.queries[queryNum-1]);
          print([keys2vals['term'], myTerm].toString());
          Future<Post> fetchedPost = fetchPost('Party Mode', 'Alert Choice', widget.queries[queryNum-1], [keys2vals['term'], myTerm]);
          setState(() {
            //myBody.add(Text('Post Sent'));
            resultsWidget = showResultsViaPost(fetchedPost, keys2vals['term'], myTerm);
          });
          //Party Mode because we don't want CPU Mode that returns a computer answer.
          //'Alert Choice' can be anything because it only matters for CPU Mode.
        } else {
          //Not in sync with other player - need to avoid or a contingency to handle
          Exception('One Player is Not in Sync with the Other');
          setState(() {
            myBody.add(Text('Synchronisation Error - Check Logs'));
          });
        }
      });

      /* Don't need to transaction if concurrency is handled in app.
      TransactionResult transactionResult = await gameRoomRef.child(myPath).runTransaction(
      (MutableData transaction) async {
        if (transaction.value == null) {
          transaction.value = myTerm;
          gameRoomRef.child('results').onChildChanged.listen((_) {
            print('Answer Given');
          });
        } else {
        }
        return transaction;
      });
      if (transactionResult.committed) {
        print('Entered Term First');
      } else if (transactionResult.committed) {
        print('Entered Term Second');
        //don't need transaction as no possibility of concurrency clashes
        gameRoomRef.update({
          'joiner term' : myTerm
        });
        //Get name of host term
        gameRoomRef.child('host term').once().then((DataSnapshot snapshot) {
          print('Data : ${snapshot.value}');
          Future<Post> fetchedPost = fetchPost('Party Mode', 'Alert Choice', widget.queries[0], [snapshot.value, myTerm]);
          setState(() {
            //myBody.add(Text('Post Sent'));
            resultsWidget = showResultsViaPost(fetchedPost, snapshot.value, myTerm);
          });
        });
        //Party Mode because we don't want CPU Mode that returns a computer answer.
        //'Alert Choice' can be anything because it only matters for CPU Mode.
      } else {
        if (transactionResult.error != null) {
          print(transactionResult.error.message);
        }
      }*/
      //transaction to check if other answer exists - else wait for change before submitting both answers
    }
  }

  Widget showResultsViaPost(Future<Post> fetchedPost, String theirTerm, String yourTerm) {
    List results;
    return Center(
      child: new FutureBuilder<Post>(
        future: fetchedPost,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasData) {
            results = snapshot.data.avgs;
            gameRoomRef.child('results').set({
              'host': (isHost) ? results[1] : results[0],
              'joiner': (isHost) ? results[0] : results[1]
            });
            totals[0] += (isHost) ? results[1] : results[0];
            totals[1] += (isHost) ? results[0] : results[1];
            return new Column(
              children: <Widget>[
                Text(
                  'Your Term: ${widget.queries[queryNum-1]} $yourTerm: ${results[1].toString()}',
                  style: blackTextSmall,
                ),
                Text(
                  'Opponent\'s Term: ${widget.queries[queryNum-1]} $theirTerm: ${results[0].toString()}',
                  style: blackTextSmall
                ),
                Container(height: 20.0,),
                Text(
                  (isHost)
                    ? 'Your Total: ${totals[0].toString()}'
                    : 'Your Total: ${totals[1].toString()}',
                  style: blackTextSmall,
                ),
                Text(
                    (isHost)
                        ? 'Opponent\'s Total: ${totals[1].toString()}'
                        : 'Opponent\'s Total: ${totals[0].toString()}',
                    style: blackTextSmall
                ),
          ],
            );
          } else if (snapshot.hasError) {
            //Contingency plan can be found in the result.dart file
            return Text('Custom Error - GTrends Server Issue');
          }
          // By default, show a loading spinner
          // (although I think if connectionstate covers this already)
          return CircularProgressIndicator();
        },
      ),
    );
  }

  Widget showResultsViaFirebase(int yourScore, String yourTerm, int otherScore, String otherTerm) {
    listenerToCancel.cancel();
    totals[0] += yourScore;
    totals[1] += otherScore;
    return new Column(
      children: <Widget>[
        Text(
          'Your Term: ${widget.queries[queryNum-1]} $yourTerm: ${yourScore.toString()}',
          style: blackTextSmall,
        ),
        Text(
            'Opponent\'s Term: ${widget.queries[queryNum-1]} $otherTerm: ${otherScore.toString()}',
            style: blackTextSmall
        ),
        Container(height: 20.0,),
        Text(
          'Your Total: ${totals[0].toString()}',
          style: blackTextSmall,
        ),
        Text(
            'Opponent\'s Total: ${totals[1].toString()}',
            style: blackTextSmall
        ),
      ],
    );
  }

  ///Delete yourself from the waitlist upon activity disposal / a found match.
  void deleteWaitRoom(){
    print('#### Deleting Entry ####');
    /*waitListRef.orderByChild('userID').equalTo(globals.user.uid).once().then((DataSnapshot snapshot) {
      print('Data : ${snapshot.value}');
      if (snapshot.value != null) {
        Map keys2vals = new Map<String, dynamic>.from(snapshot.value);
        keys2vals.forEach((key, val) {
          waitListRef.child(key).remove();
        });
      }
    });*/
    //Cause it may be null
    waitRoomRef?.remove();
  }

  void deleteGameRoom() {
    //Cause it may be null
    listenerForLeaving.cancel();
    gameRoomRef?.remove();
  }

  @override
  void dispose() {
    super.dispose();
    deleteWaitRoom();
    deleteGameRoom();
  }

  @override
  Widget build(BuildContext context) {

    Widget myBody = (!hasPartner)
      ? new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Expanded(child: Container()),
          CircularProgressIndicator(),
          new Container(height: 10.0),
          new Text(
            'Searching for an opponent.',
            style: customFont(
              color: Colors.blue[600],
              fontsize: 12.0
            ),
          ),
          new Expanded(child: Container())
        ],
      )
      : new Column(
        children: [
          new Text(
            'Match 1 word with - ' + widget.queries[queryNum],
            style: blackTextSmall,
          ),
          new Flexible(
            flex: 0,
            child: Center(
              child: Form(
                key: formKey,
                child: Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    ListTile(
                      title: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Enter Term',
                          ),
                          onSaved: (val) => myTerm = val,
                          validator: (val) {
                            if (val.isEmpty) {
                              return 'Please enter some text';
                            }
                          }
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        if (queryNum < widget.queries.length-1) {
                          String otherPlayer = (isHost) ? 'joiner' : 'host';
                          gameRoomRef.child('$otherPlayer/query num').once().then((DataSnapshot snapshot) {
                            print(snapshot.value);
                            if (queryNum == snapshot.value || queryNum+1 == snapshot.value) {
                              queryNum++;
                              submitTerm();
                              setState(() {});
                            } else {
                              Fluttertoast.showToast(
                                msg: "Please Wait For The Results",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIos: 1,
                              );
                            }
                          });
                        } else {
                          Navigator.of(context).push(
                              new FinalScorePageRoute(scores: totals, mode: 'Online Mode')
                          );
                        }
                      },
                    ),
                    resultsWidget
                  ],
                ),
              ),
            ),
          )
        ]
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      resizeToAvoidBottomPadding: false,
      body: myBody,
    );
  }
}

class WaitRoom {
  String key;
  String displayName;
  String userID;
  String partner;

  WaitRoom(this.displayName, this.userID, this.partner);

  WaitRoom.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        displayName = snapshot.value["displayName"],
        userID = snapshot.value["userID"],
        partner = snapshot.value["partner"];

  toJson() {
    return {
      "displayName": displayName,
      "userID": userID,
      "partner": partner
    };
  }
}