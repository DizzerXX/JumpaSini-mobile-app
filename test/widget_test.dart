import 'package:flutter_test/flutter_test.dart';
import 'package:jumpa_sini/core/di/injection_container.dart' as di;
import 'package:jumpa_sini/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    // main() calls di.setup() before runApp; without it the first bloc lookup
    // throws, so the test must register dependencies too.
    await di.sl.reset();
    SharedPreferences.setMockInitialValues({});
    di.setup();
  });

  testWidgets('App renders the home page without crashing', (tester) async {
    await tester.pumpWidget(const JumpaSiniApp());

    expect(find.byType(JumpaSiniApp), findsOneWidget);
    expect(find.text('Start a Meetup'), findsWidgets);
  });
}
