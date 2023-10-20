import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

Future<Dio> buildDioClient(String? base) async {
  print('Using base moqui backend url: $base');
  bool android = false;
  try {
    if (Platform.isAndroid) {
      android = true;
    }
  } catch (e) {}

  final dio = Dio()
    ..options = BaseOptions(
        baseUrl: base == null
            ? (android == true)
                ? 'http://10.0.2.2:8080/'
                : 'http://localhost:8080/'
            : base)
    ..options.connectTimeout = const Duration(milliseconds: 5000)
    ..options.receiveTimeout = const Duration(milliseconds: 5000)
    ..httpClientAdapter;

  dio.options.headers['Content-Type'] = 'application/json; charset=UTF-8';
  dio.options.responseType = ResponseType.plain;

  var box = await Hive.openBox('growerp');
  dio.interceptors.add(KeyInterceptor(box));

  dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: true,
      error: true,
      compact: true,
      maxWidth: 133));

  return dio;
}

class KeyInterceptor extends Interceptor {
  KeyInterceptor(this._box);

  Box? _box;

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
//    print(
//        "=====interceptor key: ${_box?.get('apiKey')} ${options.headers['requireApiKey']}");
    if (options.headers['requireApiKey'] == true) {
      options.headers['api_key'] = await _box?.get('apiKey');
    }

    if (options.method != 'GET') {
      options.headers['moquiSessionToken'] =
          await _box?.get('moquiSessionToken');
    }

    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    await _box?.put('moquiSessionToken', response.headers['moquisessiontoken']);
    super.onResponse(response, handler);
  }
}
