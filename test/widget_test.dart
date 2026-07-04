import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_watch_app_new/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const GroupWatchApp());
    
    expect(find.text('Group Watch App'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsWidgets);
  });
}
