
import 'package:flutter_test/flutter_test.dart';
import 'package:my_simple_note/main.dart'; // Ensure this path is correct.

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(MySimpleNoteApp()); // Use the correct widget name.

    // Verify that the app builds properly by checking for the title on the HomeScreen.
    expect(find.text('My Simple Note'), findsOneWidget);

    // Since this is a note-taking app, you can verify other functionalities here.
    // For example:
    // Verify that no notes are displayed initially.
    expect(find.text('No notes available. Add a new note!'), findsOneWidget);
  });
}
