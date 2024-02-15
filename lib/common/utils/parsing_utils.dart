import 'dart:convert';

import 'package:shelf/shelf.dart';

Future<T> parseRequestBody<T>(Request request) async {
  final bodyBytes = await request.read().toList();
  final bodyString = utf8.decode(bodyBytes.expand((i) => i).toList());
  final jsonObject = jsonDecode(bodyString) as T;

  return jsonObject;
}
