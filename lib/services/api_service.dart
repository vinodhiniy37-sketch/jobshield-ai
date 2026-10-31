import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ApiService {
  // Configured Base URL
  // Can be configured via --dart-define=API_BASE_URL=https://... or runtime setter
  static String? _customProductionUrl;
  static void setProductionApiUrl(String url) => _customProductionUrl = url;

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (_customProductionUrl != null && _customProductionUrl!.isNotEmpty) {
      return _customProductionUrl!;
    }
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5000/api';
      }
    } catch (_) {}
    return 'http://localhost:5000/api';
  }

  static const String _tokenKey = 'jwt_token';
  String? _token;

  String? get token => _token;

  // Initialize service & load token
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  // Save authentication token to persistent memory
  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Clear authentication token
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Get common request headers
  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Send GET request
  Future<http.Response> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      );
      return response;
    } catch (e) {
      throw Exception('GET request failed: $e');
    }
  }

  // Send POST request
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception('POST request failed: $e');
    }
  }

  // Send PUT request
  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw Exception('PUT request failed: $e');
    }
  }

  // Send DELETE request
  Future<http.Response> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      );
      return response;
    } catch (e) {
      throw Exception('DELETE request failed: $e');
    }
  }

  // Send multipart request (for File Uploads: PDF, Image, Screenshots)
  Future<http.StreamedResponse> multipartRequest(
    String method,
    String endpoint,
    Map<String, String> fields, {
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
    String? fileFieldName,
  }) async {
    try {
      final request = http.MultipartRequest(
        method,
        Uri.parse('$baseUrl$endpoint'),
      );

      // Add Headers
      request.headers.addAll({
        'Accept': 'application/json',
      });
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }

      // Add Fields
      request.fields.addAll(fields);

      // Add File from bytes
      if (fileBytes != null && fileFieldName != null && fileName != null) {
        request.files.add(http.MultipartFile.fromBytes(
          fileFieldName,
          fileBytes,
          filename: fileName,
        ));
      }
      // Add File from path (native fallback)
      else if (filePath != null && fileFieldName != null) {
        if (kIsWeb) {
          request.files.add(await http.MultipartFile.fromPath(fileFieldName, filePath));
        } else {
          final file = File(filePath);
          if (await file.exists()) {
            request.files.add(await http.MultipartFile.fromPath(fileFieldName, filePath));
          }
        }
      }

      return await request.send();
    } catch (e) {
      throw Exception('Multipart request failed: $e');
    }
  }
}
