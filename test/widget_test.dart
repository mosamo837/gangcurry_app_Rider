import 'package:app_rider/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows splash first and then parcel list', (tester) async {
    await tester.pumpWidget(const RiderApp());

    expect(find.text('APP RIDER'), findsOneWidget);
    expect(find.text('รายการพัสดุที่ต้องจัดส่ง'), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('รายการพัสดุที่ต้องจัดส่ง'), findsOneWidget);
    expect(find.text('สมชาย ใจดี'), findsOneWidget);
  });
}
