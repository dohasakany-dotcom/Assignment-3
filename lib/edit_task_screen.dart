import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'DatabaseHelper.dart';

class EditTaskScreen extends StatefulWidget {
  final String id;
  const EditTaskScreen({super.key, required this.id});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  Future<void> _updateTask() async {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    // update SQLite (if you still use it)
    await DatabaseHelper.updateTask(
      int.parse(widget.id),
      titleController.text,
      descriptionController.text,
    );

    // update Firebase with UID
    await FirebaseDatabase.instance
        .ref("tasks/$uid/${widget.id}")
        .update({
      "title": titleController.text,
      "description": descriptionController.text,
    });

    Navigator.pop(context, "refresh");
  }

  Future<void> _getTask() async {

    var data = await DatabaseHelper.getTask(int.parse(widget.id));

    setState(() {
      titleController.text = data[0]["title"] ?? "";
      descriptionController.text = data[0]["description"] ?? "";
    });
  }

  @override
  void initState() {
    super.initState();
    _getTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Task Description',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _updateTask,
              child: const Text('Update Task'),
            ),
          ],
        ),
      ),
    );
  }
}