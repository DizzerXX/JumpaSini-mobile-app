import 'package:flutter_test/flutter_test.dart';
import 'package:jumpa_sini/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const JumpaSiniApp());
    expect(find.byType(JumpaSiniApp), findsOneWidget);
  });
}
