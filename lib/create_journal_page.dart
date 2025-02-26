import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_service.dart';

class CreateJournalPage extends StatefulWidget {
  final QueryDocumentSnapshot? editingJournal;

  CreateJournalPage({this.editingJournal});

  @override
  _CreateJournalPageState createState() => _CreateJournalPageState();
}

class _CreateJournalPageState extends State<CreateJournalPage> {
  final FirebaseService _firebaseService = FirebaseService();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  File? _selectedImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.editingJournal != null) {
      _titleController.text = widget.editingJournal!['title'];
      _contentController.text = widget.editingJournal!['content'];
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _saveJournal() async {
    setState(() => _isUploading = true);

    if (widget.editingJournal == null) {
      await _firebaseService.addJournal(
        _titleController.text,
        _contentController.text,
        null,
      );
    } else {
      await _firebaseService.updateJournal(
        widget.editingJournal!.id,
        _titleController.text,
        _contentController.text,
        null,
      );
    }

    setState(() => _isUploading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.editingJournal == null ? 'New Journal' : 'Edit Journal',
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: 4,
            ),
            SizedBox(height: 10),
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 100, width: 100)
                : Container(),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.image),
              label: Text('Attach Image'),
            ),
            SizedBox(height: 10),
            _isUploading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: _saveJournal, child: Text('Save')),
          ],
        ),
      ),
    );
  }
}
