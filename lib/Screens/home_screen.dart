import 'package:flutter/material.dart';
import '../widgets/note_card.dart'; // Custom widget to display notes
import 'note_detail_screen.dart'; // Screen for viewing/editing note details
import '../models/note.dart'; // Note model
import '../services/db_helper.dart'; // Database services for CRUD operations
import 'dart:developer'; // For logging

// Home screen for displaying and managing notes
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Note> notes; // List of notes to display
  bool isLoading = true; // Tracks loading state

  @override
  void initState() {
    super.initState();
    refreshNotes(); // Load notes on initialization
  }

  // Fetch notes from the database and update UI
  Future<void> refreshNotes() async {
    setState(() => isLoading = true); // Show loading indicator
    notes = await DbHelper().getNotes(); // Fetch notes from database
    log("Notes retrieved: ${notes.length}"); // Log the number of notes

    // Sort the notes by timestamp (updated notes should be on top)
    notes.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    setState(() => isLoading = false); // Hide loading indicator
  }

  // Show a confirmation dialog before deleting a note
  Future<void> _showDeleteConfirmationDialog(int? id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dismissing dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: <Widget>[
            // Cancel button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            // Delete button
            TextButton(
              onPressed: () async {
                if (id != null) {
                  await deleteNote(id); // Delete the note
                  _showSnackbar("Note deleted successfully!"); // Show success message
                }
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Delete a note from the database
  Future<void> deleteNote(int? id) async {
    if (id != null) {
      await DbHelper().delete(id); // Delete note by ID
      refreshNotes(); // Refresh the notes list
    } else {
      log("Note ID is null, cannot delete."); // Log error if ID is null
    }
  }

  // Show a snackbar with a custom message
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), // Display the message
        behavior: SnackBarBehavior.floating, // Floating snackbar style
        duration: const Duration(seconds: 2), // Auto-hide after 2 seconds
        backgroundColor: Colors.green, // Background color
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Simple Note"), // App bar title
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loader if loading
          : notes.isNotEmpty
          ? ListView.builder(
        itemCount: notes.length, // Number of notes
        itemBuilder: (context, index) {
          return NoteCard(
            note: notes[index], // Pass note data to the card
            onTap: () async {
              // Navigate to note details screen and get the updated note
              final updatedNote = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NoteDetailScreen(note: notes[index]),
                ),
              );
              if (updatedNote != null) {
                await DbHelper().update(updatedNote); // Update the note in DB
                refreshNotes(); // Refresh the notes list
              }
            },
            onDelete: () =>
                _showDeleteConfirmationDialog(notes[index].id), // Delete note
          );
        },
      )
          : const Center(
        child: Text("No notes available. Add a new note!"), // Message for empty list
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.add, // Add icon
          color: Colors.white,
          size: 35, // Increased icon size
        ),
        backgroundColor: const Color(0xFF061DB3), // Dark button color
        onPressed: () async {
          // Navigate to note details screen to create a new note
          final newNote = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteDetailScreen(),
            ),
          );
          if (newNote != null) {
            await DbHelper().insert(newNote); // Insert new note into DB
            refreshNotes(); // Refresh the notes list
          }
        },
        elevation: 10.0, // Elevated button with shadow
        tooltip: 'Create Note', // Tooltip for accessibility
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded button
        ),
      ),
    );
  }
}
