import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:plant_it/domain/models/rainpoint.dart';
import 'package:result_dart/result_dart.dart';

/// The RainPoint / HomGar cloud, as used by their phone apps. It has no
/// public API: the requests follow the community integrations.
class RainPointClient {
  static const String _base = 'https://region3.homgarus.com';
  // The cloud refuses some user agents; this is the one of the phone app
  static const String _userAgent = 'okhttp/4.9.2';

  final http.Client _http;

  RainPointClient({http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  /// The app code of each account type: accounts of the RainPoint Home app
  /// and of the HomGar app are separate.
  static const String rainPointApp = '2';
  static const String homGarApp = '1';

  /// Logs in and returns the token and when it expires.
  Future<Result<(String, DateTime)>> login({
    required String email,
    required String password,
    required String areaCode,
    required String appCode,
  }) async {
    try {
      http.Response response = await _http.post(
        Uri.parse('$_base/auth/basic/app/login'),
        headers: {
          'Content-Type': 'application/json',
          'lang': 'en',
          'appCode': appCode,
          'User-Agent': _userAgent,
        },
        body: json.encode({
          'areaCode': areaCode,
          'phoneOrEmail': email,
          'password': md5.convert(utf8.encode(password)).toString(),
          'deviceId': md5.convert(utf8.encode('$email$areaCode')).toString(),
        }),
      );
      Map<String, dynamic> body = _decode(response);
      if (body['code'] != 0) {
        return Failure(RainPointException(body['msg']?.toString() ??
            'Login failed (${body['code'] ?? response.statusCode})'));
      }
      Map<String, dynamic> data = body['data'];
      int seconds = (data['tokenExpired'] as num?)?.toInt() ?? 86400;
      return Success((
        data['token'] as String,
        DateTime.now().add(Duration(seconds: seconds)),
      ));
    } catch (e) {
      return Failure(RainPointException(e.toString()));
    }
  }

  /// The sensors and water timers of every home of the account, with what
  /// they last reported.
  Future<Result<List<RainPointDevice>>> devices(
      String token, String appCode) async {
    try {
      List<RainPointDevice> result = [];
      List<dynamic> homes =
          await _get(token, appCode, '/app/member/appHome/list') ?? [];
      for (dynamic home in homes) {
        List<dynamic> hubs = await _get(token, appCode,
                '/app/device/getDeviceByHid', {'hid': '${home['hid']}'}) ??
            [];
        for (dynamic hub in hubs) {
          Map<String, dynamic>? status = await _get(token, appCode,
              '/app/device/getDeviceStatus', {'mid': '${hub['mid']}'});
          Map<String, String> values = {
            for (dynamic s in (status?['subDeviceStatus'] as List?) ?? [])
              '${s['id']}': '${s['value'] ?? ''}'
          };
          for (dynamic sub in (hub['subDevices'] as List?) ?? []) {
            int? addr = (sub['addr'] as num?)?.toInt();
            String model = '${sub['model'] ?? ''}';
            if (addr == null ||
                RainPointDevice.kindOfModel(model) == RainPointKind.hub) {
              continue;
            }
            String? value = values['D${addr.toString().padLeft(2, '0')}'];
            result.add(RainPointDevice(
              key: '${hub['mid']}_$addr',
              model: model,
              name: '${sub['name'] ?? model}',
              reading: value == null ? null : decodeRainPoint(model, value),
            ));
          }
        }
      }
      return Success(result);
    } on RainPointException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(RainPointException(e.toString()));
    }
  }

  Future<dynamic> _get(String token, String appCode, String path,
      [Map<String, String>? params]) async {
    http.Response response = await _http.get(
      Uri.parse('$_base$path').replace(queryParameters: params),
      headers: {
        'auth': token,
        'lang': 'en',
        'appCode': appCode,
        'User-Agent': _userAgent,
      },
    );
    Map<String, dynamic> body = _decode(response);
    if (body['code'] != 0) {
      // 1001 and 1004: the token is no longer valid
      throw RainPointException(body['msg']?.toString() ?? 'Error',
          expiredToken: body['code'] == 1001 || body['code'] == 1004);
    }
    return body['data'];
  }

  static Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode != 200) {
      throw RainPointException('HTTP ${response.statusCode}');
    }
    return json.decode(utf8.decode(response.bodyBytes));
  }
}

class RainPointException implements Exception {
  final String message;
  final bool expiredToken;

  const RainPointException(this.message, {this.expiredToken = false});

  @override
  String toString() => 'RainPoint: $message';
}
