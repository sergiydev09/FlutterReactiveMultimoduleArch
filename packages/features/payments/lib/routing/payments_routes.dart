import 'package:common/routing/feature_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../di/payments_providers.dart';
import '../domain/entities/payment.dart';
import '../presentation/new_payment/bloc/new_payment_bloc.dart';
import '../presentation/new_payment/page/new_payment_page.dart';
import '../presentation/payment_confirm/page/payment_confirm_page.dart';
import '../presentation/payment_result/page/payment_result_page.dart';

/// Route paths and route definitions for the payments feature.
abstract final class PaymentRoutes {
  /// Base path for matching any payment route in navigation.
  static const base = '/payments';
  static const newPayment = '/payments/new';
  static const confirm = '/payments/confirm';
  static const result = '/payments/result';

  static final routes = FeatureRoutes(
    shellRoutes: [
      GoRoute(
        path: newPayment,
        builder: (context, state) {
          final container = ProviderScope.containerOf(context);
          return BlocProvider(
            create: (_) => NewPaymentBloc(
              executePaymentUseCase: container.read(
                PaymentProviders.executePaymentUseCase,
              ),
            ),
            child: const NewPaymentPage(),
          );
        },
      ),
    ],
    fullScreenRoutes: [
      GoRoute(
        path: confirm,
        builder: (context, state) {
          final payment = state.extra! as Payment;
          final container = ProviderScope.containerOf(context);
          return BlocProvider(
            create: (_) => NewPaymentBloc(
              executePaymentUseCase: container.read(
                PaymentProviders.executePaymentUseCase,
              ),
            ),
            child: PaymentConfirmPage(payment: payment),
          );
        },
      ),
      GoRoute(
        path: result,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PaymentResultPage(
            isSuccess: extra?['isSuccess'] as bool? ?? false,
            confirmationId: extra?['confirmationId'] as String?,
            errorMessage: extra?['errorMessage'] as String?,
          );
        },
      ),
    ],
  );
}
