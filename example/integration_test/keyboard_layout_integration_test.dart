import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:keyboard_layout_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('verify keyboard layout', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    final pattern = RegExp(r'Keyboard layout: \w+');
    expect(find.textContaining(pattern), findsOneWidget);
  });
}
