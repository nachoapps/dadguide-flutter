import 'dart:io' show HttpStatus;

import 'package:dio/dio.dart';

import 'endpoints.dart';

class ApiClient {
  final Endpoints _endpoints;
  final Dio _dio;
  ApiClient(this._endpoints, this._dio);

  Future<bool> isDonor(String email) async {
    var url = _endpoints.donor(email);
    var resp = await _dio.get(url);

    if (resp.statusCode != HttpStatus.ok) {
      throw StateError('Bad response status: ${resp.statusCode}');
    }

    var items = resp.data['items'] as Map<String, dynamic>;
    return items['is_donor'] as bool;
  }
}
