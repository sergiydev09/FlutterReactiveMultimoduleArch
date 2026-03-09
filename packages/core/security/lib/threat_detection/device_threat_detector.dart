import 'dart:developer' as developer;
import 'dart:io';

import 'package:safe_device/safe_device.dart';

import 'threat_report.dart';

/// Contract for evaluating device security threats.
///
/// All checks run locally on the device — no data is sent to third parties.
abstract class DeviceThreatDetector {
  /// Evaluates the current device and returns a [ThreatReport].
  Future<ThreatReport> evaluate();
}

/// No-op implementation for development and testing environments.
///
/// Always returns a clean [ThreatReport] so emulators and debug builds
/// do not trigger false positives.
class NoOpDeviceThreatDetector implements DeviceThreatDetector {
  @override
  Future<ThreatReport> evaluate() async => const ThreatReport();
}

/// Implementation using [SafeDevice] for comprehensive local threat detection.
///
/// Covers: root/jailbreak (via rootbeer/IOSSecuritySuite), emulator,
/// mock GPS, external storage, developer mode, USB debugging.
class DeviceThreatDetectorImpl implements DeviceThreatDetector {
  static const _tag = 'DeviceThreatDetector';

  @override
  Future<ThreatReport> evaluate() async {
    try {
      // Run all checks in parallel for performance.
      final results = await Future.wait([
        _checkJailbroken(), // 0
        _checkRealDevice(), // 1
        _checkMockLocation(), // 2
        _checkExternalStorage(), // 3
        _checkDeveloperMode(), // 4
        _checkUsbDebugging(), // 5
      ]);

      final report = ThreatReport(
        isRooted: Platform.isAndroid && results[0],
        isJailbroken: Platform.isIOS && results[0],
        isEmulator: !results[1],
        isMockLocation: results[2],
        isOnExternalStorage: results[3],
        isDeveloperMode: results[4],
        isUsbDebugging: results[5],
      );

      developer.log('$report', name: _tag);
      return report;
    } on Exception catch (e) {
      developer.log('Threat evaluation failed: $e', name: _tag);
      // On failure, assume the worst for safety.
      return const ThreatReport(
        isRooted: true,
        isJailbroken: true,
        isEmulator: true,
      );
    }
  }

  Future<bool> _checkJailbroken() async {
    try {
      return await SafeDevice.isJailBroken;
    } on Exception catch (e) {
      developer.log('Jailbreak check failed: $e', name: _tag);
      return false;
    }
  }

  Future<bool> _checkRealDevice() async {
    try {
      return await SafeDevice.isRealDevice;
    } on Exception catch (e) {
      developer.log('Real device check failed: $e', name: _tag);
      return true; // Assume real device on failure.
    }
  }

  Future<bool> _checkMockLocation() async {
    try {
      if (!Platform.isAndroid) return false;
      return await SafeDevice.isMockLocation;
    } on Exception catch (e) {
      developer.log('Mock location check failed: $e', name: _tag);
      return false;
    }
  }

  Future<bool> _checkExternalStorage() async {
    try {
      if (!Platform.isAndroid) return false;
      return await SafeDevice.isOnExternalStorage;
    } on Exception catch (e) {
      developer.log('External storage check failed: $e', name: _tag);
      return false;
    }
  }

  Future<bool> _checkDeveloperMode() async {
    try {
      if (!Platform.isAndroid) return false;
      return await SafeDevice.isDevelopmentModeEnable;
    } on Exception catch (e) {
      developer.log('Developer mode check failed: $e', name: _tag);
      return false;
    }
  }

  Future<bool> _checkUsbDebugging() async {
    try {
      if (!Platform.isAndroid) return false;
      return await SafeDevice.isUsbDebuggingEnabled;
    } on Exception catch (e) {
      developer.log('USB debugging check failed: $e', name: _tag);
      return false;
    }
  }
}
