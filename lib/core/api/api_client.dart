import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Live production Base URL for the EventITT backend.
const String kBaseUrl = 'https://api.eventitt.afaqmis.com';

/// Typed API response wrapper.
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int statusCode;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    required this.statusCode,
  });

  factory ApiResponse.ok(T data, int code) =>
      ApiResponse(success: true, data: data, statusCode: code);

  factory ApiResponse.err(String message, int code) =>
      ApiResponse(success: false, error: message, statusCode: code);
}

/// Lightweight HTTP client that wraps the [http] package.
class ApiClient {
  final String? token;

  const ApiClient({this.token});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null && token!.isNotEmpty)
          'Authorization': 'Bearer $token',
      };

  Uri _uri(String path) => Uri.parse('$kBaseUrl$path');

  dynamic _parse(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return response.body;
    }
  }

  String _errorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      final msg = body['error'] ?? body['message'] ?? 'Server error ${response.statusCode}';
      debugPrint('❌ [API ERROR RESPONSE] Status: ${response.statusCode} | Error: $msg | Body: ${response.body}');
      return msg.toString();
    } catch (_) {
      debugPrint('❌ [API ERROR RESPONSE] Status: ${response.statusCode} | Raw Body: ${response.body}');
      return 'Server error ${response.statusCode}';
    }
  }

  String _cleanError(dynamic e, [StackTrace? stack]) {
    debugPrint('==================================================');
    debugPrint('❌ [API EXCEPTION THROWN] Error: $e');
    if (stack != null) debugPrint('Stacktrace:\n$stack');
    debugPrint('==================================================');

    final str = e.toString();
    if (str.contains('Permission denied') || str.contains('errno = 13')) {
      return 'Internet permission denied by OS. Please enable network access.';
    }
    if (str.contains('SocketException') || str.contains('Failed host lookup')) {
      return 'Unable to reach server. Please check internet connection.';
    }
    if (str.contains('TimeoutException')) {
      return 'Connection timed out. Server did not respond.';
    }
    if (str.contains('HandshakeException') || str.contains('CERTIFICATE_VERIFY_FAILED')) {
      return 'SSL Certificate error. Unable to connect securely.';
    }
    if (str.contains('PlatformException')) {
      return 'Platform network channel error: $e';
    }
    return 'Network error: $e';
  }

  Future<ApiResponse<dynamic>> get(String path) async {
    debugPrint('🌐 [API GET] $kBaseUrl$path');
    try {
      final res = await http.get(_uri(path), headers: _headers).timeout(const Duration(seconds: 10));
      debugPrint('✅ [API GET RESPONSE] Status: ${res.statusCode} for $path');
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return ApiResponse.ok(_parse(res), res.statusCode);
      }
      return ApiResponse.err(_errorMessage(res), res.statusCode);
    } catch (e, stack) {
      return ApiResponse.err(_cleanError(e, stack), 0);
    }
  }

  Future<ApiResponse<dynamic>> post(String path, Map<String, dynamic> body) async {
    debugPrint('🌐 [API POST] $kBaseUrl$path | Payload: ${jsonEncode(body)}');
    try {
      final res = await http.post(
        _uri(path),
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));
      debugPrint('✅ [API POST RESPONSE] Status: ${res.statusCode} for $path | Body: ${res.body}');
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return ApiResponse.ok(_parse(res), res.statusCode);
      }
      return ApiResponse.err(_errorMessage(res), res.statusCode);
    } catch (e, stack) {
      return ApiResponse.err(_cleanError(e, stack), 0);
    }
  }

  Future<ApiResponse<dynamic>> put(String path, Map<String, dynamic> body) async {
    debugPrint('🌐 [API PUT] $kBaseUrl$path');
    try {
      final res = await http.put(
        _uri(path),
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));
      debugPrint('✅ [API PUT RESPONSE] Status: ${res.statusCode} for $path | Body: ${res.body}');
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return ApiResponse.ok(_parse(res), res.statusCode);
      }
      return ApiResponse.err(_errorMessage(res), res.statusCode);
    } catch (e, stack) {
      return ApiResponse.err(_cleanError(e, stack), 0);
    }
  }

  Future<ApiResponse<dynamic>> patch(String path, Map<String, dynamic> body) async {
    debugPrint('🌐 [API PATCH] $kBaseUrl$path');
    try {
      final res = await http.patch(
        _uri(path),
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));
      debugPrint('✅ [API PATCH RESPONSE] Status: ${res.statusCode} for $path | Body: ${res.body}');
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return ApiResponse.ok(_parse(res), res.statusCode);
      }
      return ApiResponse.err(_errorMessage(res), res.statusCode);
    } catch (e, stack) {
      return ApiResponse.err(_cleanError(e, stack), 0);
    }
  }

  Future<ApiResponse<dynamic>> delete(String path) async {
    debugPrint('🌐 [API DELETE] $kBaseUrl$path');
    try {
      final res = await http.delete(_uri(path), headers: _headers).timeout(const Duration(seconds: 10));
      debugPrint('✅ [API DELETE RESPONSE] Status: ${res.statusCode} for $path');
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return ApiResponse.ok(_parse(res), res.statusCode);
      }
      return ApiResponse.err(_errorMessage(res), res.statusCode);
    } catch (e, stack) {
      return ApiResponse.err(_cleanError(e, stack), 0);
    }
  }
}
