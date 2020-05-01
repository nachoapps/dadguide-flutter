import 'dart:convert';
import 'dart:io' show HttpStatus;

import 'package:dadguide2/services/device_utils.dart';
import 'package:dio/dio.dart';
import 'package:fimber_io/fimber_io.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

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

    var data = resp.data as Map<String, dynamic>;
    return data['is_donor'] as bool;
  }

  Future<void> submitPurchase(PurchaseDetails pd) async {
    var deviceId = await getDeviceId();
    final data = <String, dynamic>{
      'device_id': deviceId ?? 'missing',
    };
    if (pd == null) {
      data['error'] = 'no purchase found';
    } else {
      var err = pd.error;
      var vd = pd.verificationData;
      data.addAll({
        'purchase_id': pd.purchaseID ?? 'missing',
        'product_id': pd.productID ?? 'missing',
        'transaction_date': pd.transactionDate ?? 'missing',
        'status': pd.status?.toString() ?? 'missing',
        'err_details':
            err == null ? '' : 'code=${err.code} details=${err.details} msg=${err.message}',
        'local_verification': vd?.localVerificationData ?? '',
        'server_verification': vd?.serverVerificationData ?? '',
        'source': vd?.source?.toString() ?? '',
      });
    }
    Fimber.w('Submitting purchase details: ${jsonEncode(data)}');
    var url = _endpoints.purchase();
    await _dio.post(url, data: data);
  }
}
