/// Immutable report of all local security threats detected on the device.
///
/// Each field is `true` when the corresponding threat is detected.
/// A clean device returns all fields as `false`.
class ThreatReport {
  const ThreatReport({
    this.isRooted = false,
    this.isJailbroken = false,
    this.isEmulator = false,
    this.isMockLocation = false,
    this.isOnExternalStorage = false,
    this.isDeveloperMode = false,
    this.isUsbDebugging = false,
  });

  /// Device has root access (Android: Magisk, su, KernelSU).
  final bool isRooted;

  /// Device is jailbroken (iOS: Dopamine, unc0ver, checkra1n).
  final bool isJailbroken;

  /// App is running on an emulator or simulator.
  final bool isEmulator;

  /// Mock/fake GPS location is active (Android only).
  final bool isMockLocation;

  /// App is installed on external storage (Android only).
  final bool isOnExternalStorage;

  /// Developer mode is enabled on the device (Android only).
  final bool isDeveloperMode;

  /// USB debugging is enabled on the device (Android only).
  final bool isUsbDebugging;

  /// Returns `true` if any critical threat is detected.
  ///
  /// Critical threats are: root or jailbreak.
  bool get hasCriticalThreats => isRooted || isJailbroken;

  /// Returns `true` if any threat at all is detected.
  bool get hasAnyThreat =>
      isRooted ||
      isJailbroken ||
      isEmulator ||
      isMockLocation ||
      isOnExternalStorage ||
      isDeveloperMode ||
      isUsbDebugging;

  @override
  String toString() =>
      'ThreatReport(rooted: $isRooted, jailbroken: $isJailbroken, '
      'emulator: $isEmulator, mockLocation: $isMockLocation, '
      'externalStorage: $isOnExternalStorage, devMode: $isDeveloperMode, '
      'usbDebug: $isUsbDebugging)';
}
