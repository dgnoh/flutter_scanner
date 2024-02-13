import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'scanner_platform_interface.dart';

/// An implementation of [ScannerPlatform] that uses method channels.
class MethodChannelScanner extends ScannerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('io.dkargo.lodis/scanner');

  @override
  Future<String?> getPlatformVersion() async {
    try {
      print('getPlatformVersion ');
      final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
      print('version $version');
      return version;
    } catch (e) {
      print('Error fetching platform version: $e');
      return null;
    }
  }

  Future<void> setCaptureEnabled(bool enabled) async {
    print('setCaptureEnabled: $enabled');
    try {
      await methodChannel.invokeMethod('setAutoCaptureEnabled', {'enableAutoCapture': enabled});
    } catch (e) {
      print('Error setting capture enabled: $e');
    }
  }

   Future<void> disableAutoCapture() async {
    print('disableAutoCapture');
    final version = await methodChannel.invokeMethod('disableAutoCapture');
    print(version);
  }
}
