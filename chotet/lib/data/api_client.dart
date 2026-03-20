import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static String get _effectiveBaseUrl {
    if (_baseUrl != 'http://localhost:8080') return _baseUrl;
    
    // Fallback logic for localhost on different platforms if not provided via env
    if (kIsWeb) return 'http://localhost:8080';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

  final Dio dio;
  String? _accessToken;

  // Callbacks for AuthViewModel to handle storage and state
  Future<String?> Function()? getRefreshToken;
  Future<void> Function(String accessToken, String? refreshToken)? onTokenRefreshed;
  VoidCallback? onLogout;

  ApiClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: '$_effectiveBaseUrl/api',
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 60),
            headers: {
              'Accept': 'application/json',
            },
          ),
        ) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint(obj.toString()),
    ));

    dio.interceptors.add(QueuedInterceptorsWrapper(
      onRequest: (options, handler) {
        if (_accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        if (options.data is Map || options.data is List) {
          options.headers['Content-Type'] = 'application/json';
        }
        
        return handler.next(options);
      },
      onError: (e, handler) async {
        if (e.requestOptions.data is FormData) {
          return handler.next(e);
        }

        if (e.response?.statusCode == 401 && getRefreshToken != null) {
          final refreshToken = await getRefreshToken!();
          if (refreshToken != null) {
            try {
              final refreshDio = Dio(BaseOptions(baseUrl: dio.options.baseUrl));
              final response = await refreshDio.post(
                '/auth/refresh',
                data: {'refreshToken': refreshToken},
              );

              if (response.statusCode == 200) {
                final data = response.data['data'];
                final newAccessToken = data['accessToken'];
                final newRefreshToken = data['refreshToken'];

                _accessToken = newAccessToken;
                if (onTokenRefreshed != null) {
                  await onTokenRefreshed!(newAccessToken, newRefreshToken);
                }

                e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                final opts = Options(
                  method: e.requestOptions.method,
                  headers: e.requestOptions.headers,
                );
                final retryResponse = await dio.request(
                  e.requestOptions.path,
                  options: opts,
                  data: e.requestOptions.data,
                  queryParameters: e.requestOptions.queryParameters,
                );
                return handler.resolve(retryResponse);
              }
            } catch (refreshError) {
              if (onLogout != null) onLogout!();
            }
          } else {
            if (onLogout != null) onLogout!();
          }
        }
        return handler.next(e);
      },
    ));
  }

  void setAccessToken(String? token) {
    _accessToken = token;
  }
}
