import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:google_sign_in/google_sign_in.dart';   
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

import 'fb/fb.dart' as fb;

void main() {
  runApp(
    new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(brightness: Brightness.dark),
      home: new FlutterDemo(),
    ),
  );
}

class FlutterDemo extends StatefulWidget {
  FlutterDemo({Key key}) : super(key: key);
  @override
  _FlutterDemoState createState() => new _FlutterDemoState();
}

class _FlutterDemoState extends State<FlutterDemo> {
  final googleSignIn = new GoogleSignIn();   
  final analytics = new FirebaseAnalytics(); 
  final auth = FirebaseAuth.instance;

  List contents;
  String markdown;
  int contentsIndex = 0;

  @override
  void initState() {
    super.initState();
    _readFolder()
    .then((List value) {
      setState(() {
        contents = value;
      });
    }).then((Future value) {
      _updateMarkdown();
    });
  }

  Future<Null> _signOut() async {
    await _currentUser();
    await auth.signOut();
  }

  Future<Null> _googleLogin() async {
    await _currentUser();
    GoogleSignInAccount user = googleSignIn.currentUser;
    if (user == null)
      user = await googleSignIn.signInSilently();
    if (user == null) {
      await googleSignIn.signIn();
    }
    if (await auth.currentUser() == null) {      
      GoogleSignInAuthentication credentials = 
      await googleSignIn.currentUser.authentication;
      await auth.signInWithGoogle(
        idToken: credentials.idToken,
        accessToken: credentials.accessToken,
      );
    }
  }

  Future<Null> _facebookLogin() async {
    await _currentUser();
    if (await auth.currentUser() == null) {  
      final fb.Token _token = await fb.getToken();
      await auth.signInWithFacebook(
        accessToken: _token.access,
      );
    }
  }

  Future<Null> _currentUser() async {
    var user = await auth.currentUser();
    print('User ${user != null ? user.providerData : "none"}');
  }

  Future _updateMarkdown() async {
    await _getFileData('assets/book/${contents[contentsIndex]["file"]}')
    .then((String value) {
      setState(() {
        markdown = value;
      });
    });
  }

  Future<String> _getFileData(String path) async {
    return await rootBundle.loadString(path);
  }

  Future<List> _readFolder() async {
    try {
      // var fileName = 'assets/book/ch1.md';
      String data = await _getFileData('assets/book/index.json');
      List parsedList = JSON.decode(data);
      return parsedList;
    } on FileSystemException {
      print('exception');
      return [];
    }
  }

  back() {
    setState(() {
      contentsIndex = contentsIndex == 0 ? contents.length - 1 : contentsIndex - 1;
    });
    _updateMarkdown();
  }

  forward() {
    setState(() {
      contentsIndex = contentsIndex == contents.length - 1 ? 0 : contentsIndex + 1;
    });
    _updateMarkdown();
  }

  @override
  Widget build(BuildContext context) {
    
    return new Scaffold(
      appBar: new AppBar(title: new Text("You Don't Know JS")),
      body: new Markdown(data: markdown != null ? markdown : ''),
      persistentFooterButtons: [
        new Row(children: [
          new RaisedButton(
            child: new Text("Facebook"),
            onPressed: () async {
              await _facebookLogin();
            }
          ),
          new RaisedButton(
            child: new Text("Google"),
            onPressed: () async {
              await _googleLogin();
            }
          ),
          new RaisedButton(
            child: new Text("Signout"),
            onPressed: () async {
              await _signOut();
            }
          ),
        ])

          // new FlatButton(child: new Icon(Icons.arrow_back), onPressed: back),
          // new Text(
          //   '${contents != null && contents[contentsIndex] != null ? contents[contentsIndex]["title"] : ""}',
          // ),
          // new FlatButton(child: new Icon(Icons.arrow_forward), onPressed: forward)],
      ]
    );
  }
}