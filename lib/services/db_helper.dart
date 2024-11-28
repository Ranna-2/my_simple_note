import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';
import 'dart:developer';

// Database Helper class for managing SQLite database operations
class DbHelper {
  // Singleton pattern implementation
  static final DbHelper _instance = DbHelper._internal();
  static Database? _database;

  // Factory constructor to return the singleton instance
  factory DbHelper() {
    return _instance;
  }

  // Private named constructor
  DbHelper._internal();

  // Getter to retrieve or initialize the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Method to initialize the SQLite database
  Future<Database> _initDatabase() async {
    // Get the path for storing the database
    String path = join(await getDatabasesPath(), 'notes.db');
    // Open the database and create the notes table if it doesn't exist
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY,          -- Unique identifier for each note
            title TEXT NOT NULL,             -- Title of the note
            content TEXT NOT NULL,           -- Content of the note
            timestamp TEXT NOT NULL          -- Timestamp when the note was created/modified
          )
        ''');
      },
    );
  }

  // Method to insert a new note into the database
  Future<int> insert(Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap()); // Insert note as a map
  }

  // Method to retrieve all notes from the database
  Future<List<Note>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notes'); // Query all notes
    log("Fetched notes: $maps"); // Log the fetched notes for debugging
    return List.generate(
      maps.length,
          (i) => Note.fromMap(maps[i]), // Convert each map to a Note object
    );
  }

  // Method to update an existing note in the database
  Future<int> update(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(), // Update note with new data
      where: 'id = ?', // Specify which note to update by ID
      whereArgs: [note.id],
    );
  }

  // Method to delete a note from the database by its ID
  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?', // Specify which note to delete by ID
      whereArgs: [id],
    );
  }
}
