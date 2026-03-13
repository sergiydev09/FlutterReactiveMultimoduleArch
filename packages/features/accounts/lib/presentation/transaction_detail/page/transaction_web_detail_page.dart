import 'dart:async';
import 'dart:developer' as developer;

import 'package:domain/entities/transaction.dart';
import 'package:flutter/material.dart';
import 'package:security/session/session_manager.dart';
import 'package:ui/tokens/colors.dart';
import 'package:webview_lib/webview_lib.dart';
import 'package:webview_lib/webview_source.dart';

import '../../../domain/repositories/account_repository.dart';

/// Displays transaction detail inside a WebView with bidirectional JS bridge.
///
/// Resolves the WebView URL from the [AccountRepository] and sends the
/// transaction data and session token via the [JsBridge].
class TransactionWebDetailPage extends StatefulWidget {
  const TransactionWebDetailPage({
    required this.transaction,
    required this.sessionManager,
    required this.accountRepository,
    super.key,
  });

  final Transaction transaction;
  final SessionManager sessionManager;
  final AccountRepository accountRepository;

  @override
  State<TransactionWebDetailPage> createState() =>
      _TransactionWebDetailPageState();
}

class _TransactionWebDetailPageState extends State<TransactionWebDetailPage> {
  static const _tag = 'TransactionWebDetail';

  String? _url;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_loadUrl());
  }

  Future<void> _loadUrl() async {
    final result = await widget.accountRepository.getTransactionDetailUrl(
      widget.transaction.id,
    );
    if (!mounted) return;
    result.fold(
      (failure) => setState(() => _error = 'Error al cargar el detalle'),
      (url) => setState(() => _url = url),
    );
  }

  void _handleEvent(WebViewEvent event) {
    switch (event) {
      case WebViewCustomEvent(:final name, :final data):
        _handleBridgeAction(name, data);
      case WebViewSessionExpiredEvent():
        _showSnackBar('La sesion ha expirado');
        if (mounted) Navigator.of(context).pop();
      case WebViewCloseEvent():
        Navigator.of(context).pop();
      case WebViewNavigateEvent():
        break;
    }
  }

  void _handleBridgeAction(String action, Map<String, dynamic>? data) {
    developer.log('Bridge action: $action, data: $data', name: _tag);

    switch (action) {
      case 'share_receipt':
        _showSnackBar(
          'Compartiendo recibo de ${widget.transaction.description}...',
        );
      case 'download_pdf':
        _showSnackBar('Descargando PDF...');
      case 'dispute':
        unawaited(_showDisputeDialog());
      default:
        developer.log('Unknown bridge action: $action', name: _tag);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showDisputeDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disputar cargo'),
        content: Text(
          'Se iniciara el proceso de disputa para el movimiento '
          '"${widget.transaction.description}". ¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSnackBar('Disputa iniciada correctamente');
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _serializeTransaction() {
    final tx = widget.transaction;
    return {
      'id': tx.id,
      'accountId': tx.accountId,
      'amount': tx.amount,
      'currency': tx.currency,
      'description': tx.description,
      'category': tx.category.name,
      'status': tx.status.name,
      'createdAt': tx.createdAt.toIso8601String(),
      if (tx.merchant != null) 'merchant': tx.merchant,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BankingColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Detalle del movimiento'),
        backgroundColor: BankingColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: BankingColors.error),
            const SizedBox(height: 16),
            Text(_error!),
          ],
        ),
      );
    }

    if (_url == null) {
      return const SizedBox.shrink();
    }

    return BankingWebView(
      source: WebViewUrlSource(_url!),
      config: const WebViewConfig(
        allowedDomains: [],
        enableJavaScript: true
      ),
      onEvent: _handleEvent,
      initialData: () async {
        final token = await widget.sessionManager.getToken();
        return {
          'transaction': _serializeTransaction(),
          'token': token ?? '',
        };
      },
    );
  }
}
