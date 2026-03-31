import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class DioClient {
  static Dio dio = Dio();
  static final cookieJar = CookieJar();

  static void init() {
    dio.interceptors.add(CookieManager(cookieJar));

    dio.options = BaseOptions(
      baseUrl: "https://easyshop-eg.com",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    );
  }
}
