import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhasla_wheels_mobile_application/main.dart';
import 'package:mhasla_wheels_mobile_application/View/loginpage.dart';

void main() {
  testWidgets('Login fits phone, tablet, and keyboard layouts', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    for (final size in [
      const Size(320, 568),
      const Size(390, 844),
      const Size(1024, 768),
      const Size(1440, 900),
      const Size(844, 390),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.text('Welcome back.'), findsOneWidget);
      final header = find.byWidgetPredicate(
        (widget) =>
            widget is CustomPaint &&
            widget.painter.runtimeType.toString() == 'RentalRoadPainter',
      );
      expect(tester.getRect(header).left, 0);
      expect(tester.getSize(header).width, size.width);
      expect(tester.takeException(), isNull);
      tester.view.viewInsets = FakeViewPadding(bottom: size.height * .4);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Sign in'));
      expect(tester.takeException(), isNull);
      tester.view.resetViewInsets();
    }
  });

  testWidgets('Validates credentials and passes entered values to sign-in', (
    tester,
  ) async {
    String? receivedEmail;
    String? receivedPassword;
    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(
          onSignIn: (email, password) async {
            receivedEmail = email;
            receivedPassword = password;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Sign in'));
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your email address'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).first,
      'driver@example.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'a-password');
    await tester.ensureVisible(find.text('Sign in'));
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(receivedEmail, 'driver@example.com');
    expect(receivedPassword, 'a-password');
    expect(tester.takeException(), isNull);
  });
}
