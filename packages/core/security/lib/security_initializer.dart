import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import 'screen/screen_protection_service.dart';
import 'threat_detection/device_threat_detector.dart';
import 'threat_detection/threat_report.dart';

/// Policy that determines how the app reacts to detected threats.
enum ThreatPolicy {
  /// Log threats but allow the app to continue (development).
  warn,

  /// Block the app on critical threats (production).
  block,
}

/// Orchestrates all security checks at app startup.
///
/// Call [initialize] from `main()` before `runApp()`.
class SecurityInitializer {
  SecurityInitializer({
    required DeviceThreatDetector threatDetector,
    required ScreenProtectionService screenProtection,
    required ThreatPolicy policy,
  })  : _threatDetector = threatDetector,
       _screenProtection = screenProtection,
       _policy = policy;

  final DeviceThreatDetector _threatDetector;
  final ScreenProtectionService _screenProtection;
  final ThreatPolicy _policy;

  static const _tag = 'SecurityInitializer';

  /// Last threat report from [initialize]. `null` if not yet evaluated.
  ThreatReport? lastReport;

  /// Runs all security checks and applies the configured [ThreatPolicy].
  ///
  /// Returns the [ThreatReport]. If [ThreatPolicy.block] is active and
  /// critical threats are found, calls [onBlocked] instead of allowing
  /// the app to continue.
  Future<ThreatReport> initialize({
    VoidCallback? onBlocked,
  }) async {
    developer.log('Starting security checks...', name: _tag);

    final report = await _threatDetector.evaluate();
    lastReport = report;

    if (report.hasAnyThreat) {
      developer.log('Threats detected: $report', name: _tag);
    } else {
      developer.log('No threats detected', name: _tag);
    }

    // Enable screen protection by default in production.
    if (_policy == ThreatPolicy.block && _screenProtection.isSupported) {
      await _screenProtection.enable();
    }

    // Block on critical threats in production.
    if (_policy == ThreatPolicy.block && report.hasCriticalThreats) {
      developer.log(
        'CRITICAL: Blocking app due to threats: $report',
        name: _tag,
      );
      onBlocked?.call();
    }

    return report;
  }
}
