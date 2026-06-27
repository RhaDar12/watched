import 'package:flutter_test/flutter_test.dart';

import 'package:watched/app/app.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const App(isLoggedIn: false));

    expect(find.text('Selamat Datang!'), findsOneWidget);
  });
}
