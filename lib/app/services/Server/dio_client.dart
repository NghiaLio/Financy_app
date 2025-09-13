import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:financy_ui/app/services/Server/auth_interceptor.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// ApiException carries the server status code and the response data (usually JSON)
/// so callers can read fields like `error` or `message`.
class ApiException implements Exception {
  final int? statusCode;
  final dynamic data;

  ApiException(this.statusCode, this.data);

  @override
  String toString() => 'ApiException(statusCode: $statusCode, data: $data)';
}

class ApiService {
  final Dio _dio;

  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() : _dio = Dio() {
    _dio.options.baseUrl = dotenv.env['URL_DB']!;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.interceptors.add(AuthInterceptor());
  }

  void setToken(String? token) {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(
        path,
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
    } on DioException catch (e) {
      // If server provided structured JSON, throw ApiException with that data
      final resp = e.response;
      log('API error [${resp?.statusCode}]: ${resp?.data}');
      if (resp != null && resp.data != null) {
        throw ApiException(resp.statusCode, resp.data);
      }
      throw Exception(e.message);
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      final resp = e.response;
      if (resp != null && resp.data != null) {
        log('API error [${resp.statusCode}]: ${resp.data}');
        throw ApiException(resp.statusCode, resp.data);
      }
      throw Exception(e.message);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      final resp = e.response;
      if (resp != null && resp.data != null) {
        log('API error [${resp.statusCode}]: ${resp.data}');
        throw ApiException(resp.statusCode, resp.data);
      }
      throw Exception(e.message);
    }
  }

  Future<Response> delete(String path, {dynamic data}) async {
    try {
      return await _dio.delete(path, data: data);
    } on DioException catch (e) {
      final resp = e.response;
      if (resp != null && resp.data != null) {
        log('API error [${resp.statusCode}]: ${resp.data}');
        throw ApiException(resp.statusCode, resp.data);
      }
      throw Exception(e.message);
    }
  }
}
