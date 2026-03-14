// Basic widget test for the parking app.
import 'package:flutter_test/flutter_test.dart';
import 'package:parking_app/main.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(ParkingApp());
    expect(find.text('Parking Management'), findsOneWidget);
  });
}
