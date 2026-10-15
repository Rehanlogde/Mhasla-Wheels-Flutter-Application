import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhasla_wheels_mobile_application/View/homepage.dart';
import 'package:mhasla_wheels_mobile_application/View/registration.dart';

void main() {
  testWidgets('Registration and dashboard visual previews', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final entry in {
      'DMSans': 'assets/fonts/DMSans.ttf',
      'Lora': 'assets/fonts/Lora.ttf',
      'BarlowCondensed': 'assets/fonts/BarlowCondensed-BoldItalic.ttf',
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    }.entries) {
      await (FontLoader(
        entry.key,
      )..addFont(rootBundle.load(entry.value))).load();
    }
    for (final entry in <String, Widget>{
      'registration': const RegistrationPage(),
      'homepage': const HomePage(showWelcome: false),
    }.entries) {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(fontFamily: 'DMSans', useMaterial3: true),
          home: entry.value,
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('${entry.key}_preview.png'),
      );
    }
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'DMSans'),
        home: const HomePage(key: ValueKey('popup')),
      ),
    );
    await tester.pump();
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage('assets/images/mhasla_wheels.jpg'),
        tester.element(find.byType(HomePage)),
      );
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('welcome_preview.png'),
    );
    await tester.pumpAndSettle();
  });
}
