import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'themeSelect.dart';
import 'multiplayerMode.dart';

class MultiplayerPage extends StatefulWidget {
  MultiplayerPage({Key key, this.title, this.alertChoice, this.mode}) : super(key: key);

  final String title;
  final dynamic alertChoice;
  final String mode;

  @override
  _MultiplayerPageState createState() => new _MultiplayerPageState();
}

class _MultiplayerPageState extends State<MultiplayerPage> {
  final roomController = new TextEditingController();
  final usernameController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return _multiplayerPageUI();
  }

  @override
  void dispose() {
    // Clean up the controller when Widget is disposed
    roomController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  Widget _multiplayerPageUI() {

    String roomText = "";
    if (widget.alertChoice == "Host Game") {
      roomText = "What do you want to call the room (5 character minimum";
    } else {
      roomText = "Please enter the room name you wish to enter";
    }
    List<Widget> children = [
      new Text(roomText),
      new TextField(
          controller: roomController,
          autofocus: true,
          decoration: new InputDecoration(
              filled: true,
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(12.0),
              ),
              hintText: 'Please Enter Room Name'
          )
      ),
      new Text("What do you want your team name to be?"),
      new TextField(
          controller: usernameController,
          autofocus: true,
          decoration: new InputDecoration(
              filled: true,
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(12.0),
              ),
              hintText: 'Please Enter Team Name'
          )
      )
    ];


    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.mode),
        ),
        body: new Padding(
            padding: const EdgeInsets.all(16.0),
            child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,//align left
                children: children
            )
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: () => _pushThemeSelect(widget.alertChoice, widget.mode, roomController.text, usernameController.text),
          tooltip: 'Show me the value!',
          child: new Icon(Icons.send),
        ),
    );
  }

  void _pushThemeSelect(var alertChoice, String mode, String roomName, String teamName) {
    if (widget.alertChoice == "Host Game") {
      Navigator.of(context).push(
          new MaterialPageRoute(
              builder: (context) {
                return new ThemeSelectPage(
                    title: "Hello", alertChoice: alertChoice, mode: mode, teamName: teamName, roomName: roomName);
              }
          )
      );
    } else {
      Navigator.of(context).push(
          new MaterialPageRoute(
              builder: (context) {
                return new MyHomePage(
                  title: "Hello",
                  channel: IOWebSocketChannel.connect(
                    ('ws://trends-app-server.herokuapp.com/' + roomName)
                  ),
                  teamName: teamName
                );
              }
          )
      );
    }
  }
}