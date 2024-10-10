import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'notes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Notes App',
      home: NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  void _fetchNotes() async {
    final data = await DatabaseHelper().getNotes();
    setState(() {
      notes = data;
    });
  }

  void _addOrUpdateNoteDialog([Note? note]) {
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(note == null ? 'Add Note' : 'Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: InputDecoration(labelText: 'Title')),
              TextField(controller: contentController, decoration: InputDecoration(labelText: 'Content')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final newNote = Note(
                  id: note?.id,
                  title: titleController.text,
                  content: contentController.text,
                );
                if (note == null) {
                  await DatabaseHelper().insertNote(newNote);
                } else {
                  await DatabaseHelper().updateNote(newNote);
                }
                _fetchNotes();
                Navigator.of(context).pop();
              },
              child: Text(note == null ? 'Add' : 'Update'),
            ),
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
          ],
        );
      },
    );
  }

  void _deleteNoteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Note'),
          content: Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () async {
                await DatabaseHelper().deleteNote(id);
                _fetchNotes();
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return ListTile(
            title: Text(note.title),
            subtitle: Text(note.content),
            onTap: () => _addOrUpdateNoteDialog(note),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteNoteDialog(note.id!),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdateNoteDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
