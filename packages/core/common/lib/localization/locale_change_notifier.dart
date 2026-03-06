import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Incrementing this counter forces [routerProvider] to recreate [GoRouter],
/// which causes [BankingApp] to receive a new [routerConfig] and rebuild the
/// entire widget tree. Use this as the single point of control for triggering
/// a full-app locale refresh after calling [EasyLocalization.setLocale].
class LocaleChangeNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void rebuild() => state++;
}
