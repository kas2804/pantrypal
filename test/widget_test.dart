import 'package:flutter_test/flutter_test.dart';
import 'package:pantrypal/main.dart';

void main() {
  testWidgets('PantryPal smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PantryPalApp());
  });
}
