import 'dart:async';
import 'dart:convert' show json;
import 'package:flutter/services.dart';

class FlutterLocation {
  static const MethodChannel _channel = const MethodChannel('flutter_location');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<LocationData> getLocation() async {
    String strlocation = await _channel.invokeMethod('action_getLocation');
    var jsonRes = json.decode(strlocation);
    return LocationData(
        provider: jsonRes['provider'],
        desc: jsonRes['desc'],
        longitude: jsonRes['longitude'],
        latitude: jsonRes['latitude'],
        code: jsonRes['code']);
  }
}

class LocationData {
  final String provider;
  final String desc;
  final double longitude;
  final double latitude;
  final int code;

  LocationData(
      {this.provider, this.desc, this.longitude, this.latitude, this.code});

  @override
  String toString() {
    return "code:${code}  latitude:${latitude} longitude:${longitude} provider:${provider} desc:${desc}";
  }
}
