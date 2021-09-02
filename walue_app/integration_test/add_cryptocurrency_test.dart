import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:walue_app/main.dart' as app;
import 'package:walue_app/widgets/google_sign_in_button.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Add cryptocurrency test', (WidgetTester tester) async {
    await app.main();

    await tester.pumpAndSettle();

    await Future.delayed(const Duration(seconds: 1));

    final Finder googleSignInButton = find.byWidgetPredicate((widget) => widget is GoogleSignInButton);

    await tester.tap(googleSignInButton);

    await tester.pumpAndSettle();

    await Future.delayed(const Duration(seconds: 10));
  });
}
