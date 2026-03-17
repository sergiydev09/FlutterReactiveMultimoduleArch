import 'dart:async';
import 'dart:developer' as developer;

import 'package:cookie_jar/cookie_jar.dart';
import 'package:domain/entities/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/atoms/buttons/bank_button/bank_button.dart';
import 'package:ui/atoms/buttons/bank_button/bank_button.types.dart';
import 'package:ui/tokens/colors.dart';
import 'package:webview_lib/webview_lib.dart';

import '../bloc/transaction_web_detail_bloc.dart';

/// Displays transaction detail inside a WebView with bidirectional JS bridge.
///
/// Observes [TransactionWebDetailBloc] for the resolved WebView URL and
/// session token, then renders [BankingWebView] once both are available.
/// Business logic (URL resolution, token fetch) lives entirely in the BLoC.
class TransactionWebDetailPage extends StatelessWidget {
  const TransactionWebDetailPage({
    required this.transaction,
    required this.cookieJar,
    super.key,
  });

  final Transaction transaction;
  final CookieJar cookieJar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BankingColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Detalle del movimiento'),
        backgroundColor: BankingColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<TransactionWebDetailBloc, TransactionWebDetailState>(
        builder: (context, state) => switch (state.status) {
          TransactionWebDetailStatus.initial ||
          TransactionWebDetailStatus.loading =>
            const Center(child: CircularProgressIndicator()),
          TransactionWebDetailStatus.error =>
            _ErrorView(message: state.errorMessage),
          TransactionWebDetailStatus.loaded => _WebViewBody(
              transaction: transaction,
              url: state.url!,
              token: state.token ?? '',
              cookieJar: cookieJar,
            ),
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: BankingColors.error,
          ),
          const SizedBox(height: 16),
          Text(message.isNotEmpty ? message : 'Error al cargar el detalle'),
        ],
      ),
    );
  }
}

class _WebViewBody extends StatelessWidget {
  const _WebViewBody({
    required this.transaction,
    required this.url,
    required this.token,
    required this.cookieJar,
  });

  final Transaction transaction;
  final String url;
  final String token;
  final CookieJar cookieJar;

  static const _tag = 'TransactionWebDetail';

  @override
  Widget build(BuildContext context) {
    return BankingWebView(
      source: WebViewUrlSource(url),
      config: WebViewConfig(
        allowedDomains: const [
          'google.com',
          'banking-app.com',
          'pre-api.banking-app.com',
          'api.banking-app.com',
        ],
        cookieJar: cookieJar,
        supportMultipleWindows: true,
        enableJavaScript: true,
        navigationDelegate: WebViewNavigationDelegate(
          actions: [
            TelNavigationAction(),
            MailToNavigationAction(),
            SmsNavigationAction(),
          ],
        ),
      ),
      onEvent: (event) => _handleEvent(context, event),
      initialData: () async => {
        'transaction': _serializeTransaction(),
        'token': token,
      },
    );
  }

  void _handleEvent(BuildContext context, WebViewEvent event) {
    switch (event) {
      case WebViewCustomEvent(:final name, :final data):
        _handleBridgeAction(context, name, data);
      case WebViewSessionExpiredEvent():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La sesion ha expirado')),
        );
        Navigator.of(context).pop();
      case WebViewCloseEvent():
        Navigator.of(context).pop();
      case WebViewNavigateEvent(:final url):
        developer.log('Navigation: $url', name: _tag);
    }
  }

  void _handleBridgeAction(
    BuildContext context,
    String action,
    Map<String, dynamic>? data,
  ) {
    developer.log('Bridge action: $action, data: $data', name: _tag);
    switch (action) {
      case 'share_receipt':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Compartiendo recibo de ${transaction.description}...',
            ),
          ),
        );
      case 'download_pdf':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Descargando PDF...')),
        );
      case 'dispute':
        unawaited(_showDisputeDialog(context));
      case 'OPEN_NEW_WINDOW':
        final windowUrl = data?['url'] as String? ?? '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nueva ventana: $windowUrl')),
        );
      case 'process_payment':
        final amount = data?['amount'];
        final currency = data?['currency'] as String? ?? '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pago recibido: $amount $currency')),
        );
      case 'custom_action':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Accion custom: $data')),
        );
      default:
        developer.log('Unknown bridge action: $action, data: $data', name: _tag);
    }
  }

  Future<void> _showDisputeDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Disputar cargo'),
        content: Text(
          'Se iniciara el proceso de disputa para el movimiento '
          '"${transaction.description}". ¿Deseas continuar?',
        ),
        actions: [
          BankButton(
            label: 'Cancelar',
            type: BankButtonType.subtle,
            size: BankButtonSize.small,
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          BankButton(
            label: 'Confirmar',
            type: BankButtonType.solid,
            size: BankButtonSize.small,
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Disputa iniciada correctamente')),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Serializes the [Transaction] entity into the JS bridge `initialData`
  /// format expected by `transaction_detail.html`.
  ///
  /// This is view-model mapping (domain entity → web page contract) and
  /// belongs in the presentation layer, not in the domain or data layers.
  Map<String, dynamic> _serializeTransaction() {
    return {
      'id': transaction.id,
      'accountId': transaction.accountId,
      'amount': transaction.amount,
      'currency': transaction.currency,
      'description': transaction.description,
      'category': transaction.category.name,
      'status': transaction.status.name,
      'createdAt': transaction.createdAt.toIso8601String(),
      if (transaction.merchant != null) 'merchant': transaction.merchant,
    };
  }
}
