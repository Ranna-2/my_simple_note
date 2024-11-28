import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Import the HomeScreen widget

void main() {
  runApp(MySimpleNoteApp()); // Run the app by initializing MySimpleNoteApp
}

class MySimpleNoteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable the debug banner in the app
      title: 'My Simple Note', // Set the title of the app for the app bar and system
      theme: ThemeData(
        // Define the theme for the app
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF061DB3), // Set background color of the app bar
          titleTextStyle: TextStyle(
            fontFamily: 'Roboto', // Set the font family for the app bar title
            fontSize: 24, // Set the font size for the app bar title
            fontWeight: FontWeight.bold, // Set the title font weight to bold
            color: Colors.white, // Set the title text color to white
          ),
        ),
        // Define the overall text theme for the app
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontSize: 16, // Set the font size for body text
            color: Colors.black, // Set the body text color to black
          ),
        ),
      ),
      home: HomeScreen(), // Set the HomeScreen widget as the default screen of the app
    );
  }
}
