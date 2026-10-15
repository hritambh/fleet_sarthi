import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/features/owner/owner_widgets.dart';

void main() {
  testWidgets('a plate in a narrow space shrinks instead of cutting off', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox(width: 70, child: NumberPlate('KA 01 AB 1234')),
        ),
      ),
    );
    // The whole number is there, with no overflow and no ellipsis.
    final text = tester.widget<Text>(find.text('KA 01 AB 1234'));
    expect(text.overflow, isNot(TextOverflow.ellipsis));
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(NumberPlate)).width,
      lessThanOrEqualTo(70),
    );
  });
}
