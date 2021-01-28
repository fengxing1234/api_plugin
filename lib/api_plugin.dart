
library api_plugin;
import 'dart:async';

import 'package:flutter/services.dart';
export 'package:api_plugin/dio/dio_manager.dart';

class ApiPlugin {
  static const MethodChannel _channel =
      const MethodChannel('api_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
