/// The delivery method for the OTP code.
enum OtpDeliveryType {
  /// OTP delivered via SMS.
  sms,

  /// OTP delivered via email.
  email,

  /// OTP delivered via push notification.
  push,
}

/// Configuration for OTP verification.
class OtpConfig {
  const OtpConfig({
    this.length = 6,
    this.deliveryType = OtpDeliveryType.sms,
    this.expirationSeconds = 120,
    this.resendCooldownSeconds = 30,
  });

  /// Number of digits in the OTP code.
  final int length;

  /// How the OTP is delivered to the user.
  final OtpDeliveryType deliveryType;

  /// Seconds until the OTP expires.
  final int expirationSeconds;

  /// Seconds before the user can request a new OTP.
  final int resendCooldownSeconds;
}
