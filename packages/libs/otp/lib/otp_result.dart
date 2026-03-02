/// The result of an OTP verification flow.
enum OtpResult {
  /// The OTP was verified successfully.
  verified,

  /// The user cancelled the OTP flow.
  cancelled,

  /// The OTP expired before verification.
  expired,
}
