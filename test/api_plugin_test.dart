import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:api_plugin/api_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('api_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await ApiPlugin.platformVersion, '42');
  });
}
