import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';

typedef AccessTokenProvider = Future<String?> Function();
typedef RefreshSessionCallback = Future<bool> Function();

class ApiClient {
  ApiClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 10),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.extra['_startedAt'] = DateTime.now();
          if (_isProtectedEndpoint(options.path)) {
            final token = await _accessTokenProvider?.call();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          if (kDebugMode) {
            debugPrint('${options.method} ${options.path}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logCompletion(response.requestOptions, response.statusCode);
          handler.next(response);
        },
        onError: (error, handler) async {
          final request = error.requestOptions;
          _logCompletion(request, error.response?.statusCode);
          final shouldRetry =
              error.response?.statusCode == 401 &&
              _isProtectedEndpoint(request.path) &&
              request.extra['_authRetried'] != true;
          if (!shouldRetry || _refreshSession == null) {
            handler.next(error);
            return;
          }

          try {
            final refreshed = await _refreshSession!.call();
            if (!refreshed) {
              handler.next(error);
              return;
            }
            final token = await _accessTokenProvider?.call();
            if (token == null || token.isEmpty) {
              handler.next(error);
              return;
            }
            request.extra['_authRetried'] = true;
            request.headers['Authorization'] = 'Bearer $token';
            final response = await dio.fetch<dynamic>(request);
            handler.resolve(response);
          } catch (_) {
            handler.next(error);
          }
        },
      ),
    );
  }

  final Dio dio;
  AccessTokenProvider? _accessTokenProvider;
  RefreshSessionCallback? _refreshSession;

  void configureAuthentication({
    required AccessTokenProvider accessTokenProvider,
    required RefreshSessionCallback refreshSession,
  }) {
    _accessTokenProvider = accessTokenProvider;
    _refreshSession = refreshSession;
  }

  bool _isProtectedEndpoint(String path) {
    return !_publicAuthPaths.any(path.endsWith);
  }

  static const _publicAuthPaths = <String>[
    '/api/v1/auth/signup',
    '/api/v1/auth/signin',
    '/api/v1/auth/refresh',
    '/api/v1/auth/forgot-password',
    '/api/v1/auth/reset-password',
    '/api/v1/auth/signout',
  ];

  void _logCompletion(RequestOptions request, int? statusCode) {
    if (!kDebugMode) {
      return;
    }
    final startedAt = request.extra['_startedAt'];
    final elapsed = startedAt is DateTime
        ? DateTime.now().difference(startedAt).inMilliseconds
        : 0;
    debugPrint(
      '${request.method} ${request.path} -> ${statusCode ?? 'error'} '
      '${elapsed}ms',
    );
  }
}
