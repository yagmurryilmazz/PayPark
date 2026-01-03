import 'package:flutter_test/flutter_test.dart';
import 'package:paypark/main.dart';

void main() {
  testWidgets('app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const PayParkApp());
    expect(find.text('PayPark - Login'), findsOneWidget);
  });
}
