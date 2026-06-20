import 'package:flutter_test/flutter_test.dart';
import 'package:solstice_turing_game/main.dart';

void main() {
  testWidgets('Verify solstice app boots', (WidgetTester tester) async {
    await tester.pumpWidget(const SolsticeTuringApp());
    expect(find.byType(SolsticeTuringApp), findsOneWidget);
  });
}
