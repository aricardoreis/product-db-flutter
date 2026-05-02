import 'package:flutter_test/flutter_test.dart';
import 'package:product_db_flutter/app.dart';

void main() {
  testWidgets('App renders bootstrap screen', (tester) async {
    await tester.pumpWidget(const ProductDbApp());
    expect(find.text('Bootstrap OK'), findsOneWidget);
  });
}
