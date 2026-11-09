import 'package:cleanspot/config/app_constants.dart';
import 'package:cleanspot/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CleanSpot app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CleanSpotApp());
    await tester.pump();

    // Verify that CleanSpot title appears on splash screen
    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
