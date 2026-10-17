import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhasla_wheels_mobile_application/View/homepage.dart';

void main() {
  testWidgets('Dashboard primary action opens Explore and returns', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(home: HomePage(showWelcome: false)),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Explore routes'));
    await tester.tap(find.text('Explore routes'));
    await tester.pumpAndSettle();
    expect(find.text('Explore Kokan.'), findsOneWidget);
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('Hello, Rehan.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Dashboard handles large text and long names on phone and desktop',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final size in [const Size(320, 568), const Size(1024, 768)]) {
        tester.view.physicalSize = size;
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                size: size,
                textScaler: const TextScaler.linear(1.8),
                disableAnimations: true,
                padding: const EdgeInsets.only(top: 24, bottom: 20),
              ),
              child: const HomePage(
                displayName: 'Abdulrahman Logde',
                showWelcome: false,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('₹2,800'));
        expect(tester.takeException(), isNull);
        expect(find.text('Dashboard').hitTestable(), findsOneWidget);
      }
    },
  );
}
