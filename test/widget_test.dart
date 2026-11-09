import 'package:flutter_test/flutter_test.dart';
import 'package:budgetbuddy/main.dart';

void main() {
  testWidgets('Budget Buddy app test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Budget Buddy'), findsWidgets);
  });
}