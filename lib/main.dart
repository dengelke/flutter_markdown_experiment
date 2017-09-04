import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

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
  String markdown;
  @override
  void initState() {
    super.initState();
    _readMarkdown().then((String value) {
      setState(() {
        markdown = value;
      });
    });
  }

  Future<String> _getFileData(String path) async {
    return await rootBundle.loadString(path);
  }

  Future<String> _readMarkdown() async {
    try {
      var fileName = 'assets/ch1.md';
      String data = await _getFileData(fileName);
      return data;
    } on FileSystemException {
      print('exception');
      return 'error';
    }
  }


  @override
  Widget build(BuildContext context) {
    
    return new Scaffold(
      appBar: new AppBar(title: new Text("You Don't Know JS")),
      body: markdown.length > 0 ? new Markdown(data: markdown) : null,
    );
  }
}