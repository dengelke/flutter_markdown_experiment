import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'config.dart'; // Config file
import 'token.dart';
export 'token.dart';

Future<Token> getToken() async {
  Stream<String> onCode = await _server();
  final FlutterWebviewPlugin webviewPlugin = new FlutterWebviewPlugin();
  String url = "https://www.facebook.com/dialog/oauth?client_id=$appId&redirect_uri=http://localhost:8080/&scope=public_profile";
  webviewPlugin.launch(url, fullScreen: true);
  final String code = await onCode.first;
  webviewPlugin.close();
  final http.Response response = await http.get(
      "https://graph.facebook.com/v2.10/oauth/access_token?client_id=$appId&redirect_uri=http://localhost:8080/&client_secret=$appSecret&code=$code");
  return new Token.fromMap(JSON.decode(response.body));
}

Future<Stream<String>> _server() async {
  final StreamController<String> onCode = new StreamController();
  HttpServer server =
      await HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, 8080);
  server.listen((HttpRequest request) async {
    final String code = request.uri.queryParameters["code"];
    request.response
      ..statusCode = 200;
    await request.response.close();
    await server.close(force: true);
    onCode.add(code);
    await onCode.close();
  });
  return onCode.stream;
}

