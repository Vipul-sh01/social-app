class ApiError implements Exception {
  final int statusCode;
  final String message;
  final List<String> errors;
  final String stack;
  final bool success = false;
  final dynamic data = null;

  ApiError({
    required this.statusCode,
    this.message = "Something went wrong",
    this.errors = const [],
    String? stack,
  }) : stack = stack ?? StackTrace.current.toString();

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'message': message,
      'success': success,
      'errors': errors,
    };
  }

  @override
  String toString() {
    return 'ApiError: $message';
  }
}
