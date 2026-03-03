import 'package:common/routing/feature_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:payments/di/payments_providers.dart';
import 'package:payments/domain/entities/payment.dart';
import 'package:payments/domain/usecases/execute_payment_usecase.dart';
import 'package:payments/presentation/new_payment/new_payment_page.dart';
import 'package:payments/presentation/new_payment/payment_bloc.dart';
import 'package:payments/presentation/payment_confirm/payment_confirm_page.dart';
import 'package:payments/presentation/payment_result/payment_result_page.dart';

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
          final paymentRepo = container.read(PaymentProviders.repository);
          return BlocProvider(
            create: (_) => PaymentBloc(
              executePaymentUseCase: ExecutePaymentUseCase(
                repository: paymentRepo,
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
          final paymentRepo = container.read(PaymentProviders.repository);
          return BlocProvider(
            create: (_) => PaymentBloc(
              executePaymentUseCase: ExecutePaymentUseCase(
                repository: paymentRepo,
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
