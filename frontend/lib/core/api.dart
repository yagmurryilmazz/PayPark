import 'dart:io';

import 'package:dio/dio.dart';

import 'storage.dart';

class Api {
  Api._();

  
  static const String _realDeviceBaseUrl = 'http://192.168.1.20:3000';

  static String _defaultBaseUrl() {
    // Android Emulator -> 10.0.2.2
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    // iOS Simulator -> 127.0.0.1
    if (Platform.isIOS) return 'http://127.0.0.1:3000';

   
    return _realDeviceBaseUrl;
  }

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: _defaultBaseUrl(),
      connectTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'application/json'},
      responseType: ResponseType.json,
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) async {
          final token = await Storage.getToken();
          if (token != null && token.isNotEmpty) {
            o.headers['Authorization'] = 'Bearer $token';
          }
          h.next(o);
        },
      ),
    );

  static Future<Map<String, dynamic>> getMe() async {
    final res = await dio.get('/auth/me');
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  /// Backend: PUT /auth/profile  body: { fullName, phone, avatarUrl }
  static Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String phone,
    String? avatarUrl,
  }) async {
    final res = await dio.put(
      '/auth/profile',
      data: {
        'fullName': fullName,
        'phone': phone,
        'avatarUrl': avatarUrl,
      },
    );
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  /// Backend: POST /auth/change-password body: { oldPassword, newPassword }
  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final res = await dio.post(
      '/auth/change-password',
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }
}
