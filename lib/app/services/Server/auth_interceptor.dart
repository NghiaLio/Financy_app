import 'package:financy_ui/core/utils/logger.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check if token expired (403 status OR error field contains "token_expired")
    final isTokenExpired =
        err.response?.statusCode == 403 ||
        (err.response?.data is Map &&
            (err.response?.data['error'] == 'token_expired' ||
                err.response?.data['message']?.toString().contains('hết hạn') ==
                    true));

    if (isTokenExpired) {
      debugLog('Token expired, attempting refresh...');
      final refreshToken = Hive.box('jwt').get('refreshToken');
      final oldAccessToken = Hive.box('jwt').get('accessToken');

      if (refreshToken != null) {
        try {
          // Gọi API refresh token
          final dio = Dio();
          dio.options.baseUrl = err.requestOptions.baseUrl;
          final res = await dio.post(
            '/auth/refresh',
            data: {'refreshToken': refreshToken},
            options: Options(
              headers: {'Authorization': 'Bearer $oldAccessToken'},
            ),
          );

          debugLog('Refresh token response: ${res.data}');
          final newAccessToken = res.data['accessToken'];

          // Lưu lại accessToken mới
          Hive.box('jwt').put('accessToken', newAccessToken);
          debugLog('New access token saved');

          // Gắn accessToken mới vào header và retry request cũ
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newAccessToken';

          final cloneReq = await dio.request(
            opts.path,
            options: Options(method: opts.method, headers: opts.headers),
            data: opts.data,
            queryParameters: opts.queryParameters,
          );

          debugLog('Retry request successful');
          return handler.resolve(cloneReq);
        } catch (e) {
          debugLog('Refresh token failed: $e');
          // Nếu refresh cũng lỗi, logout hoặc chuyển về màn login
          return handler.reject(err);
        }
      } else {
        debugLog('No refresh token available');
      }
    }

    return handler.next(err);
  }
}
