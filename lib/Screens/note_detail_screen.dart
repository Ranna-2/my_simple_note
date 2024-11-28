import 'package:flutter/material.dart';
import '../models/note.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note? note; // Note object to determine if editing an existing note or creating a new one
  NoteDetailScreen({Key? key, this.note}) : super(key: key);

  // Controllers to manage input for title and content fields
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // If a note is passed, populate the controllers with its data for editing
    if (note != null) {
      titleController.text = note!.title;
      contentController.text = note!.content;
    }

    final Color themeColor = Color(0xFF061DB3); // Pink-themed color for UI consistency

    return Scaffold(
      appBar: AppBar(
        // Title changes dynamically based on whether creating or editing a note
        title: Text(note == null ? "New Note" : "Edit Note"),
        backgroundColor: themeColor, // AppBar color matches theme
      ),
      resizeToAvoidBottomInset: true, // Prevents the keyboard from overlapping input fields
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Adds consistent padding around the form
        child: Column(
          children: [
            // Input field for the note title
            TextField(
              controller: titleController, // Binds the controller to this field
              decoration: InputDecoration(
                labelText: "Title", // Placeholder text for the input
                border: OutlineInputBorder(), // Adds a border to the input field
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: themeColor), // Highlights border when focused
                ),
                prefixIcon: Icon(Icons.title, color: themeColor), // Icon to indicate title field
              ),
              style: TextStyle(fontSize: 18), // Adjusts text size for better readability
            ),
            const SizedBox(height: 20), // Adds spacing between title and content fields

            // Multiline input field for the note content
            Expanded(
              child: TextField(
                controller: contentController, // Binds the controller to this field
                decoration: InputDecoration(
                  labelText: "Content", // Placeholder text for the input
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: themeColor),
                  ),
                  prefixIcon: Icon(Icons.edit, color: themeColor), // Icon to indicate content field
                  alignLabelWithHint: true, // Aligns the label with the top of the input
                ),
                maxLines: null, // Allows the input field to expand for longer content
                style: TextStyle(fontSize: 16), // Adjusts text size for content
              ),
            ),
            const SizedBox(height: 20), // Adds spacing between input fields and buttons

            // Row containing Cancel and Save/Update buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns buttons at opposite ends
              children: [
                // Cancel button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Closes the screen without saving
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey, // Grey color for Cancel button
                  ),
                  child: Text("Cancel"), // Button label
                ),

                // Save/Update button
                ElevatedButton(
                  onPressed: () {
                    // Validation to ensure title and content are not empty
                    if (titleController.text.isEmpty ||
                        contentController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Title and content cannot be empty."), // Error message
                        ),
                      );
                      return; // Stops execution if validation fails
                    }

                    // Create or update the note object
                    final updatedNote = Note(
                      id: note?.id ?? DateTime.now().millisecondsSinceEpoch, // Use existing ID or generate a new one
                      title: titleController.text, // Title from input
                      content: contentController.text, // Content from input
                      timestamp: DateTime.now(), // Current timestamp
                    );

                    // Pop the screen and return the updated note
                    Navigator.pop(context, updatedNote);

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Note saved successfully!"), // Confirmation message
                        backgroundColor: Colors.green, // Green color for success
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor, // Blue color for Save button
                  ),
                  child: Text(
                    note == null ? "Save Note" : "Update Note", // Dynamic label based on operation
                    style: TextStyle(color: Colors.white), // White text for contrast
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
