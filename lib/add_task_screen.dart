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

      await DatabaseHelper.insertTask(
        titleController.text,
        descriptionController.text,
      );

Navigator.pop(context, "refresh");

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter the data"),
        ),
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
            ),   SizedBox(height:15 ,),




            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                 hintText: "Description",
                border: OutlineInputBorder(),
                labelText: 'Task Description',
              ),
            ),SizedBox(height:15 ,),


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