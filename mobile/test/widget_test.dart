import 'package:flutter_test/flutter_test.dart';
import 'package:titsmart_mobile/main.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    await tester.pumpWidget(const TitSmartApp());
    expect(find.byType(TitSmartApp), findsOneWidget);
  });
}
