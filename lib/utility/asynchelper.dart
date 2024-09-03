import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:get/get_connect/http/src/response/response.dart';

typedef RequestHandler = Future<Response> Function(Request req);

/// Wraps a request handler with error handling.
RequestHandler asyncHandler(RequestHandler requestHandler) {
  return (Request req) async {
    try {
      return await requestHandler(req);
    } catch (error) {
      return Response(
        statusCode: 500,
        body: 'Something went wrong: $error',
      );
    }
  };
}
