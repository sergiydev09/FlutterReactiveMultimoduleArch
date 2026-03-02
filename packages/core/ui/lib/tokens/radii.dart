import 'package:flutter/material.dart';

/// Design tokens for border radii.
abstract final class BankingRadii {
  /// Small radius - 4.
  static const double sm = 4;

  /// Medium radius - 8.
  static const double md = 8;

  /// Large radius - 16.
  static const double lg = 16;

  /// Extra large radius - 24.
  static const double xl = 24;

  /// Fully rounded (pill shape).
  static const double full = 999;

  // ---- Convenience BorderRadius values ----

  /// BorderRadius with [sm] radius on all corners.
  static final BorderRadius borderRadiusSm = BorderRadius.circular(sm);

  /// BorderRadius with [md] radius on all corners.
  static final BorderRadius borderRadiusMd = BorderRadius.circular(md);

  /// BorderRadius with [lg] radius on all corners.
  static final BorderRadius borderRadiusLg = BorderRadius.circular(lg);

  /// BorderRadius with [xl] radius on all corners.
  static final BorderRadius borderRadiusXl = BorderRadius.circular(xl);

  /// Fully rounded BorderRadius.
  static final BorderRadius borderRadiusFull = BorderRadius.circular(full);
}
