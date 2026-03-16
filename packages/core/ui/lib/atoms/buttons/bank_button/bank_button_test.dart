// flutter_test is a dev_dependency intentionally imported alongside the widget
// source so the component and its tests ship as a co-located unit.
// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'bank_button.dart';
import 'bank_button.types.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('BankButton', () {
    testWidgets('solid renders label', (tester) async {
      await tester.pumpWidget(
        wrap(const BankButton(label: 'Aceptar')),
      );
      expect(find.text('Aceptar'), findsOneWidget);
    });

    testWidgets('callback fires on tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrap(BankButton(label: 'Aceptar', onPressed: () => tapped = true)),
      );
      await tester.tap(find.byType(BankButton));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('onPressed null does not fire', (tester) async {
      await tester.pumpWidget(
        wrap(const BankButton(label: 'Aceptar')),
      );
      // Tapping a disabled button must not throw or invoke any callback.
      await tester.tap(find.byType(BankButton), warnIfMissed: false);
      await tester.pump();
      expect(find.byType(BankButton), findsOneWidget);
    });

    testWidgets('loading shows CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(
        wrap(const BankButton(label: 'Aceptar', isLoading: true)),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('ghost renders icon and label', (tester) async {
      await tester.pumpWidget(
        wrap(
          BankButton(
            label: 'Compartir',
            type: BankButtonType.ghost,
            icon: Icons.share,
            onPressed: () {},
          ),
        ),
      );
      expect(find.text('Compartir'), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('semantics label is correct', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        wrap(const BankButton(label: 'Confirmar')),
      );
      expect(
        tester.getSemantics(find.text('Confirmar')).label,
        'Confirmar',
      );

      handle.dispose();
    });
  });
}
