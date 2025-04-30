import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marthasart/main.dart';

void main() {
  testWidgets('App should start', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text("Martha's Art Jewelry"), findsOneWidget);
  });
}
