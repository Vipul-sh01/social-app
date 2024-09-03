class ApiResponse {
  final int statusCode;
  final dynamic data;
  final String message;
  final bool success;

  ApiResponse({
    required this.statusCode,
    required this.data,
    this.message = "Success",
  }) : success = statusCode < 400;
}
