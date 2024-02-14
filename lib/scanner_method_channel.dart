import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'scanner_platform_interface.dart';

/// An implementation of [ScannerPlatform] that uses method channels.
class MethodChannelScanner extends ScannerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('io.dkargo.lodis/scanner');

  @override
  Future<String?> isScannerReady() async {
    try {
      final isReady = await methodChannel.invokeMethod<String>('isNativeReady');
      return isReady;
    } catch (e) {
      return null;
    }
  }

  Future<void> setCaptureEnabled(bool enabled) async {
    try {
      await methodChannel.invokeMethod('setAutoCaptureEnabled', {'enableAutoCapture': enabled});
    } catch (e) {
    }
  }

   Future<void> disableAutoCapture() async {
    final version = await methodChannel.invokeMethod('disableAutoCapture');
  }
}
