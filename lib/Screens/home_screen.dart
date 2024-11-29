import 'package:flutter/material.dart';
import '../widgets/note_card.dart';
import 'note_detail_screen.dart';
import '../models/note.dart';
import '../services/db_helper.dart';
import 'dart:developer';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Note> notes; // List of all notes
  late List<Note> filteredNotes; // List of filtered notes for search
  bool isLoading = true; // Tracks loading state
  String searchQuery = ""; // Current search query
  final FocusNode searchFocusNode = FocusNode(); // Focus node for search bar

  @override
  void initState() {
    super.initState();
    refreshNotes(); // Load notes on initialization
  }

  @override
  void dispose() {
    searchFocusNode.dispose(); // Dispose of the focus node when the widget is destroyed
    super.dispose();
  }

  // Fetch notes from the database and update UI
  Future<void> refreshNotes() async {
    setState(() => isLoading = true); // Show loading indicator
    notes = await DbHelper().getNotes(); // Fetch notes from database
    log("Notes retrieved: ${notes.length}"); // Log the number of notes

    // Sort the notes by timestamp (updated notes should be on top)
    notes.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    filteredNotes = notes; // Initialize filtered notes
    setState(() => isLoading = false); // Hide loading indicator
  }

  // Filter notes based on the search query
  void filterNotes(String query) {
    setState(() {
      searchQuery = query;
      filteredNotes = notes
          .where((note) =>
      note.title.toLowerCase().contains(query.toLowerCase()) ||
          note.content.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Show a confirmation dialog before deleting a note
  Future<void> _showDeleteConfirmationDialog(int? id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (id != null) {
                  await deleteNote(id);
                  _showSnackbar("Note deleted successfully!");
                }
                Navigator.of(context).pop();
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
      log("Note ID is null, cannot delete.");
    }
  }

  // Show a snackbar with a custom message
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Focus on the search bar when search icon is clicked
  void _focusOnSearchBar() {
    searchFocusNode.requestFocus(); // Activate the cursor when clicked
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Simple Note"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              focusNode: searchFocusNode, // Attach the focus node to the TextField
              onChanged: filterNotes, // Update filter as the user types
              decoration: InputDecoration(
                hintText: "Search notes...",
                prefixIcon: IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: _focusOnSearchBar, // Focus when search icon is pressed
                ),
                filled: true, // Set the background to be filled with color
                fillColor: Colors.blue.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredNotes.isNotEmpty
          ? ListView.builder(
        itemCount: filteredNotes.length,
        itemBuilder: (context, index) {
          return NoteCard(
            note: filteredNotes[index],
            onTap: () async {
              searchFocusNode.unfocus(); // Ensure keyboard is closed
              final updatedNote = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NoteDetailScreen(note: filteredNotes[index]),
                ),
              );
              if (updatedNote != null) {
                await DbHelper().update(updatedNote);
                refreshNotes();
              }
            },
            onDelete: () =>
                _showDeleteConfirmationDialog(filteredNotes[index].id),
          );
        },
      )
          : const Center(
        child: Text("No notes match your search query."),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 35,
        ),
        backgroundColor: const Color(0xFF061DB3),
        onPressed: () async {
          searchFocusNode.unfocus(); // Ensure keyboard is closed
          final newNote = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteDetailScreen(),
            ),
          );
          if (newNote != null) {
            await DbHelper().insert(newNote);
            refreshNotes();
          }
        },
        elevation: 10.0,
        tooltip: 'Create Note',
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
