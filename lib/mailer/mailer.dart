

import 'package:shelf/shelf.dart';

class Mailer {

  Future<Response> process(Request request) async {

    //todo
    return Response.ok(
      null,
      headers: {'Content-Type': 'application/json'},
    );
  }
}