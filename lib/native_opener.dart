import 'package:flutter/services.dart';

class NativeOpener {
  static const MethodChannel _channel =
      MethodChannel('device_id_channel'); // ✅ SAME

  static Future<void> open(String path) async {
    try {
      await _channel.invokeMethod(
        'openFileOrUrl', // ✅ SAME
        {
          'path': path,
        },
      );
    } catch (e) {
      print("Native open error: $e");
    }
  }
}
