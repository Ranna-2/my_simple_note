import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // For using custom Google Fonts
import '../models/note.dart';
import 'package:intl/intl.dart'; // For date and time formatting

class NoteCard extends StatefulWidget {
  final Note note; // Note object containing title, content, etc.
  final VoidCallback onTap; // Callback when the card is tapped
  final VoidCallback onDelete; // Callback when the delete button is pressed

  const NoteCard({
    required this.note,
    required this.onTap,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller; // Controls the jiggle animation
  late Animation<double> _jiggleAnimation; // Defines the jiggle effect

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this, // Ensures the animation is synced with the screen refresh rate
      duration: const Duration(milliseconds: 300), // Duration of the jiggle animation
    );

    // Define the jiggle animation sequence
    _jiggleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 0.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.1, end: -0.1), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.1, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the animation controller to free resources
    super.dispose();
  }

  // Helper method to format the note's timestamp into a readable format
  String formatDateTime(DateTime dateTime) {
    return DateFormat.yMMMd().add_jm().format(dateTime); // Format: e.g., 'Nov 27, 2024, 3:45 PM'
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Triggered when the card is tapped
      onTap: () {
        // Start the jiggle animation
        _controller.forward().then((_) {
          _controller.reset(); // Reset animation after it completes
          widget.onTap(); // Execute the onTap callback
        });
      },
      child: AnimatedBuilder(
        animation: _jiggleAnimation, // Links animation to this builder
        builder: (context, child) {
          return Transform.rotate(
            angle: _jiggleAnimation.value, // Applies the jiggle rotation
            child: child, // The card widget
          );
        },
        child: Container(
          margin: const EdgeInsets.all(8.0), // Space around the card
          decoration: BoxDecoration(
            color: widget.note.getColor(), // Get color from Note object
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Inner padding for content
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
              children: [
                // Row for the note's title and delete button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between title and delete button
                  children: [
                    // Display the note's title
                    Text(
                      widget.note.title,
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // White color for better contrast
                      ),
                    ),
                    // Delete button to remove the note
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white), // Trash icon
                      onPressed: widget.onDelete, // Executes the delete callback
                    ),
                  ],
                ),
                const SizedBox(height: 8), // Spacer for layout
                // Divider for visual separation
                const Divider(color: Colors.white30, thickness: 1),
                const SizedBox(height: 8), // Spacer for layout
                // Display the note's content
                Text(
                  widget.note.content,
                  maxLines: 2, // Limit content to 2 lines
                  overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.white, // White text for content
                  ),
                ),
                const SizedBox(height: 8), // Spacer for layout
                // Divider for visual separation
                const Divider(color: Colors.white30, thickness: 1),
                const SizedBox(height: 8), // Spacer for layout
                // Display the formatted timestamp
                Text(
                  formatDateTime(widget.note.timestamp),
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.white70, // Slightly lighter color for timestamp
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
