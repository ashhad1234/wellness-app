import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import 'create_journal_page.dart';

class JournalsPage extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Journals')),
      body: StreamBuilder(
        stream: _firebaseService.getJournals(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          var journals = snapshot.data!.docs;
          return ListView.builder(
            itemCount: journals.length,
            itemBuilder: (context, index) {
              var journal = journals[index];
              return Dismissible(
                key: Key(journal.id),
                onDismissed:
                    (direction) => _firebaseService.deleteJournal(journal.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                  title: Text(journal['title']),
                  subtitle: Text(journal['timestamp'].toDate().toString()),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                CreateJournalPage(editingJournal: journal),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateJournalPage()),
            ),
      ),
    );
  }
}
