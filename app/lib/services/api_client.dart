import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({this.baseUrl = 'http://localhost:8000'});

  final String baseUrl;

  Uri _u(String path, [Map<String, dynamic>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query?.map((k, v) => MapEntry(k, '$v')));

  // Settings
  Future<Map<String, dynamic>> getSettings() async {
    final res = await http.get(_u('/settings'));
    _ensureOk(res);
    return json.decode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateSettings({int? iqdStep, String? baseCurrency}) async {
    final body = <String, dynamic>{};
    if (iqdStep != null) body['iqd_step'] = iqdStep;
    if (baseCurrency != null) body['base_currency'] = baseCurrency;
    final res = await http.put(
      _u('/settings/update'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    _ensureOk(res);
    return json.decode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> setExchangeRate({String from = 'USD', String to = 'IQD', required String effective, required double rate}) async {
    final res = await http.post(
      _u('/settings/exchange-rate', {
        'from_currency': from,
        'to_currency': to,
        'effective': effective,
        'rate': rate,
      }),
    );
    _ensureOk(res);
    return json.decode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getLatestExchangeRate({String from = 'USD', String to = 'IQD'}) async {
    final res = await http.get(_u('/settings/exchange-rate/latest', {
      'from_currency': from,
      'to_currency': to,
    }));
    _ensureOk(res);
    return json.decode(res.body) as Map<String, dynamic>;
  }

  // Organization: Branches
  Future<List<Map<String, dynamic>>> listBranches() async {
    final res = await http.get(_u('/org/branches'));
    _ensureOk(res);
    final data = json.decode(res.body) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createBranch({required String code, required String name, String? address}) async {
    final res = await http.post(
      _u('/org/branches'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'code': code, 'name': name, 'address': address}),
    );
    _ensureOk(res);
    return json.decode(res.body) as Map<String, dynamic>;
  }

  // Organization: Warehouses
  Future<List<Map<String, dynamic>>> listWarehouses({int? branchId}) async {
    final res = await http.get(_u('/org/warehouses', {
      if (branchId != null) 'branch_id': branchId,
    }));
    _ensureOk(res);
    final data = json.decode(res.body) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createWarehouse({required String code, required String name, required int branchId}) async {
    final res = await http.post(
      _u('/org/warehouses'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'code': code, 'name': name, 'branch_id': branchId}),
    );
    _ensureOk(res);
    return json.decode(res.body) as Map<String, dynamic>;
  }

  void _ensureOk(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw HttpException('HTTP ${res.statusCode}: ${res.body}');
    }
  }
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => message;
}