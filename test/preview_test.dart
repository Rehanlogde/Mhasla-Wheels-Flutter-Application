import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhasla_wheels_mobile_application/main.dart';

void main() {
  testWidgets('Login preview', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final heading = FontLoader('BarlowCondensed')
      ..addFont(rootBundle.load('assets/fonts/BarlowCondensed-BoldItalic.ttf'));
    final serif = FontLoader('Lora')
      ..addFont(rootBundle.load('assets/fonts/Lora.ttf'));
    await heading.load();
    await serif.load();
    final body = FontLoader('DMSans')
      ..addFont(rootBundle.load('assets/fonts/DMSans.ttf'));
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await body.load();
    await icons.load();
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('login_preview.png'),
    );
  });
}
