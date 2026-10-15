import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhasla_wheels_mobile_application/main.dart';
import 'package:mhasla_wheels_mobile_application/View/homepage.dart';
import 'package:mhasla_wheels_mobile_application/View/registration.dart';

void main() {
  void phone(WidgetTester tester) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('Signup opens registration and sign-in returns to login', (
    tester,
  ) async {
    phone(tester);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    final signup = find.text('New here?  Create an account ↗');
    await tester.ensureVisible(signup);
    await tester.tap(signup);
    await tester.pumpAndSettle();
    expect(find.byType(RegistrationPage), findsOneWidget);
    final back = find.text('Already have an account?  Sign in');
    await tester.ensureVisible(back);
    await tester.tap(back);
    await tester.pumpAndSettle();
    expect(find.text('Welcome back.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Login opens dashboard; centered logo dismisses and stays dismissed',
    (tester) async {
      phone(tester);
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).first,
        'rehan@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.ensureVisible(find.text('Sign in'));
      await tester.tap(find.text('Sign in'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      await tester.runAsync(() async {
        await precacheImage(
          const AssetImage('assets/images/mhasla_wheels.jpg'),
          tester.element(find.byType(HomePage)),
        );
      });
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsNothing);
      expect(find.text('Hello, Rehan.'), findsOneWidget);
      expect(
        Navigator.of(tester.element(find.byType(HomePage))).canPop(),
        isFalse,
      );
      await tester.tap(find.text('Explore'));
      await tester.pumpAndSettle();
      expect(find.text('Explore Kokan.'), findsOneWidget);
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsNothing);
      expect(find.text('Hello, Rehan.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Registration validates fields and opens personalized dashboard',
    (tester) async {
      phone(tester);
      await tester.pumpWidget(const MaterialApp(home: RegistrationPage()));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Create account'));
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your full name'), findsOneWidget);
      expect(find.text('Enter a valid email address'), findsOneWidget);
      expect(find.text('Enter a valid 10-digit mobile number'), findsOneWidget);
      expect(find.text('Use at least 8 characters'), findsOneWidget);
      final fields = find.byType(TextFormField);
      for (final entry in [
        'Ayesha Khan',
        'ayesha@example.com',
        '9876543210',
        'password123',
      ].asMap().entries) {
        await tester.enterText(fields.at(entry.key), entry.value);
      }
      await tester.ensureVisible(find.text('Create account'));
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();
      expect(find.text('Hello, Ayesha.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('New screens fit phone, landscape, desktop, and keyboard', (
    tester,
  ) async {
    phone(tester);
    addTearDown(tester.view.resetViewInsets);
    for (final size in [
      const Size(320, 568),
      const Size(390, 844),
      const Size(844, 390),
      const Size(1440, 900),
    ]) {
      tester.view.physicalSize = size;
      for (final page in [
        const RegistrationPage(),
        const HomePage(showWelcome: false),
      ]) {
        await tester.pumpWidget(MaterialApp(home: page));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        tester.view.viewInsets = FakeViewPadding(bottom: size.height * .4);
        await tester.pumpAndSettle();
        if (page is RegistrationPage) {
          await tester.ensureVisible(find.text('Create account'));
        }
        expect(tester.takeException(), isNull);
        tester.view.resetViewInsets();
      }
    }
  });

  testWidgets('Reduced motion skips welcome popup', (tester) async {
    phone(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: HomePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsNothing);
    expect(find.text('Hello, Rehan.'), findsOneWidget);
  });
}
