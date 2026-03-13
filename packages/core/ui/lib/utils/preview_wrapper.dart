import 'package:flutter/material.dart';
import '../theme/banking_theme.dart';

/// A wrapper for Flutter Widget Previews that applies the [BankingTheme].
///
/// This version displays both Light and Dark modes simultaneously in a column
/// to ensure design consistency across themes.
Widget appPreviewWrapper(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: BankingTheme.light,
    darkTheme: BankingTheme.dark,
    home: Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Light Mode section
            Theme(
              data: BankingTheme.light,
              child: Container(
                color: BankingTheme.light.scaffoldBackgroundColor,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'LIGHT MODE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    child,
                  ],
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1),
            // Dark Mode section
            Theme(
              data: BankingTheme.dark,
              child: Container(
                color: BankingTheme.dark.scaffoldBackgroundColor,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'DARK MODE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    child,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
