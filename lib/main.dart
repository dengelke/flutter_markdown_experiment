import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
      return _updateMarkdown();
    });
  }

  Future _updateMarkdown() async {
    print('_updateMarkdown $contents $contentsIndex ${JSON.encode(contents[contentsIndex])}');
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
    print('back $contents $contentsIndex');
    setState(() {
      contentsIndex = contentsIndex == 0 ? contents.length - 1 : contentsIndex - 1;
    });
    _updateMarkdown();
  }

  forward() {
    print('forward $contents $contentsIndex');
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
          new FlatButton(child: new Icon(Icons.arrow_back), onPressed: back),
          new Text(
            '${contents != null && contents[contentsIndex] != null ? contents[contentsIndex]["title"] : ""}',
          ),
          new FlatButton(child: new Icon(Icons.arrow_forward), onPressed: forward)],
        )
      ]
    );
  }
}