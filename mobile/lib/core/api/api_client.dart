import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_endpoints.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });
}

class ApiClient {
  static const String _tokenKey = 'auth_token';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Perform HTTP GET request
  static Future<ApiResponse<dynamic>> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');
      final response = await http.get(uri, headers: headers).timeout(
        const Duration(seconds: 10),
      );

      final decoded = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(
          success: true,
          data: decoded,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          success: false,
          message: decoded['message'] ?? 'Đã có lỗi xảy ra trên hệ thống (${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse(
        success: false,
        message: 'Mất kết nối mạng! Vui lòng kiểm tra Wifi/4G của điện thoại.',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Không thể kết nối đến máy chủ API TITSMART. ($e)',
      );
    }
  }

  /// Perform HTTP POST request
  static Future<ApiResponse<dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');
      final response = await http
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));

      final decoded = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(
          success: true,
          data: decoded,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          success: false,
          message: decoded['message'] ?? decoded['error'] ?? 'Đăng nhập hoặc xử lý thất bại.',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse(
        success: false,
        message: 'Mất kết nối mạng! Vui lòng kiểm tra Wifi/4G của điện thoại.',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Lỗi kết nối máy chủ: $e',
      );
    }
  }

  /// Perform Multipart Upload for Photos / Documents
  static Future<ApiResponse<dynamic>> multipartPost(
    String endpoint, {
    required Map<String, String> fields,
    required List<File> files,
    String fileParamName = 'photos[]',
  }) async {
    try {
      final token = await getToken();
      final uri = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);

      request.headers['Accept'] = 'application/json';
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      for (var file in files) {
        if (await file.exists()) {
          request.files.add(await http.MultipartFile.fromPath(fileParamName, file.path));
        }
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(
          success: true,
          data: decoded,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          success: false,
          message: decoded['message'] ?? 'Tải tệp tin lên thất bại.',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      return ApiResponse(
        success: false,
        message: 'Mất kết nối mạng trong quá trình tải ảnh!',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gửi báo cáo/điểm danh thất bại: $e',
      );
    }
  }
}
