import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/login_page.dart';
import 'chat_page.dart'; // Import Chat Page
import 'journal_page.dart'; // Import Journal Page
//import 'library_page.dart'; // Import Library Page (if it exists)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String userName = "Jim"; // User name
  bool _isMoodSelected = false; // Flag for mood selection
  double _chatMargin = 20.0; // Margin for chat section
  double _opacity = 1.0; // Opacity for fade effect

  // List of moods
  final List<Map<String, dynamic>> moods = [
    {
      'icon': Icons.sentiment_satisfied,
      'label': 'Happy',
      'color': Colors.pinkAccent,
    },
    {'icon': Icons.nights_stay, 'label': 'Calm', 'color': Colors.blueAccent},
    {'icon': Icons.emoji_nature, 'label': 'Manic', 'color': Colors.green},
    {'icon': Icons.mood_bad, 'label': 'Angry', 'color': Colors.orange},
    {
      'icon': Icons.sentiment_very_dissatisfied,
      'label': 'Sad',
      'color': Colors.yellow,
    },
  ];

  int _selectedMoodIndex = -1; // To track the selected mood index

  // Hide mood selection after a tap
  void _onMoodSelected(int index) async {
    if (_isMoodSelected) return; // Prevent multiple selections per day

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Ensure user is logged in

    String today = DateTime.now().toIso8601String().split("T")[0]; // YYYY-MM-DD
    String mood = moods[index]['label'];
    String keyword = mood.toLowerCase(); // Use mood as a keyword for now

    DocumentReference moodDocRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("moodHistory")
        .doc(today);

    // Check if mood is already selected for today
    var moodDoc = await moodDocRef.get();
    if (moodDoc.exists) {
      print("Mood already selected today.");
      return;
    }

    // Save mood selection
    await moodDocRef.set({
      "mood": mood,
      "keyword": keyword,
      "timestamp": DateTime.now().toIso8601String(),
    });

    print("Mood saved successfully.");

    // Update UI
    setState(() {
      _selectedMoodIndex = index;
      _isMoodSelected = true;
    });
  }

  // Logout method
  void _logOut() async {
    await FirebaseAuth.instance.signOut();
    // Redirect to login page after log out
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  // Navigate to pages
  void _navigateToChatPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(),
      ), // Navigate to ChatPage
    );
  }

  void _navigateToJournalPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalPage(),
      ), // Navigate to JournalPage
    );
  }

  void _navigateToLibraryPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalPage(),
      ), // Navigate to LibraryPage
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting heading with adjustable top margin
            Padding(
              padding: EdgeInsets.only(
                top: 40,
              ), // Top margin for greeting heading
              child: Text(
                'Welcome Back!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Username below greeting
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                userName,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.black),
            onPressed: _logOut, // Log out button
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "How are you feeling today?" mini heading
              Padding(
                padding: EdgeInsets.only(
                  top: 20,
                ), // Margin between greeting and mini heading
                child:
                    !_isMoodSelected
                        ? Text(
                          'How are you feeling today?',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        )
                        : SizedBox(),
              ),
              SizedBox(height: 10),

              // Mood Tracker Section with hover effect
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:
                    moods.map((mood) {
                      int index = moods.indexOf(mood);
                      return GestureDetector(
                        onTap:
                            () =>
                                _onMoodSelected(index), // Call updated function
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: mood['color'].withOpacity(0.2),
                              child: Icon(
                                mood['icon'],
                                color:
                                    _selectedMoodIndex == index
                                        ? mood['color']
                                        : Colors.black,
                                size: 30,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              mood['label'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
              SizedBox(height: 20),

              // Chat Now Section
              GestureDetector(
                onTap: _navigateToChatPage, // Navigate to Chat Now page
                child: Container(
                  margin: EdgeInsets.only(top: _chatMargin),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Let's open up to the things that matter the most",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Chat Now ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.people,
                        color: Colors.white,
                        size: 40,
                      ), // Icon for Chat Now
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Journal & Library Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed:
                          _navigateToJournalPage, // Navigate to JournalPage
                      icon: Icon(Icons.book, color: Colors.white),
                      label: Text(
                        'Journal',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed:
                          _navigateToLibraryPage, // Navigate to LibraryPage
                      icon: Icon(Icons.library_books, color: Colors.white),
                      label: Text(
                        'Library',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Quotes Section
              QuoteCard(
                quote:
                    "It is better to conquer yourself than to win a thousand battles",
              ),
              QuoteCard(
                quote:
                    "It is better to conquer yourself than to win a thousand battles",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Quote Card Widget
class QuoteCard extends StatelessWidget {
  final String quote;

  QuoteCard({required this.quote});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              quote,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Icon(Icons.format_quote, color: Colors.blue, size: 24),
        ],
      ),
    );
  }
}
