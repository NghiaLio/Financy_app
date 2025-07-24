import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Nếu lỗi là 401 (token hết hạn)
    if (err.response?.statusCode == 403) {
      final refreshToken = Hive.box('jwt').get('refreshToken');
      if (refreshToken != null) {
        try {
          // Gọi API refresh token
          final dio = Dio();
          dio.options.baseUrl = err.requestOptions.baseUrl;
          final res = await dio.post(
            '/google/refresh',
            data: {'refreshToken': refreshToken},
          );
          final newAccessToken = res.data['accessToken'];
          // Lưu lại accessToken mới
          Hive.box('jwt').put('accessToken', newAccessToken);

          // Gắn accessToken mới vào header và retry request cũ
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newAccessToken';
          final cloneReq = await dio.request(
            opts.path,
            options: Options(method: opts.method, headers: opts.headers),
            data: opts.data,
            queryParameters: opts.queryParameters,
          );
          return handler.resolve(cloneReq);
        } catch (e) {
          // Nếu refresh cũng lỗi, logout hoặc chuyển về màn login
          return handler.reject(err);
        }
      }
    }
    return handler.next(err);
  }
}
