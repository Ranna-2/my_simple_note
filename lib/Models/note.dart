import 'package:flutter/material.dart';

// Model class representing a Note
class Note {
  final int? id; // Unique identifier for the note (nullable for new notes)
  final String title; // Title of the note
  final String content; // Content of the note
  final DateTime timestamp; // Timestamp of when the note was created/last updated

  // Constructor for the Note class
  Note({
    this.id, // Optional ID for new notes (will be auto-generated in the database)
    required this.title, // Title is required
    required this.content, // Content is required
    required this.timestamp, // Timestamp is required
  });

  // Convert Note object to a Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Include the ID if available
      'title': title, // Note title
      'content': content, // Note content
      'timestamp': timestamp.toIso8601String(), // Convert DateTime to string format
    };
  }

  // Factory constructor to create a Note object from a Map
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'], // Extract ID from the Map
      title: map['title'], // Extract title
      content: map['content'], // Extract content
      timestamp: DateTime.parse(map['timestamp']), // Parse string timestamp to DateTime
    );
  }

  // Generate a color for the note based on its ID
  Color getColor() {
    // Predefined list of colors for notes
    const List<Color> colors = [
      Color(0xFFD32F2F), // Dark red
      Color(0xFF00695C), // Dark teal
      Color(0xFFF9A825), // Dark yellow
      Color(0xFF6A1B9A), // Dark purple
      Color(0xFF0277BD), // Dark blue

    ];

    // Determine the color index using the ID (default to 0 if ID is null)
    int index = (id ?? 0) % colors.length;
    return colors[index]; // Return the corresponding color
  }
}
