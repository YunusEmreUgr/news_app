import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_template/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_template/core/init/app_initializer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App initialization widget test', (WidgetTester tester) async {
    await AppInitializer.init(navigatorKey);

    await tester.pumpWidget(const EnterpriseApp());
    await tester.pumpAndSettle();

    expect(find.byType(EnterpriseApp), findsOneWidget);
  });
}
