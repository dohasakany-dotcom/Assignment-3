import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'DatabaseHelper.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  Future<void> _addItem() async {

    if (titleController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty) {

      final uid = FirebaseAuth.instance.currentUser!.uid;

      int id = await DatabaseHelper.insertTask(
        titleController.text,
        descriptionController.text,
        uid,
      );

      try {
        await FirebaseDatabase.instance
            .ref("tasks/$uid")
            .child(id.toString())
            .set({
          "title": titleController.text,
          "description": descriptionController.text,
          "isComplete": 0,
        });

        print("✅ Task added with UID: $uid");
      } catch (e) {
        print("❌ Error: $e");
      }

      Navigator.pop(context, "refresh");

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter the data")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: "Title",
                border: OutlineInputBorder(),
                labelText: 'Task Title',
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                hintText: "Description",
                border: OutlineInputBorder(),
                labelText: 'Task Description',
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: _addItem,
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}