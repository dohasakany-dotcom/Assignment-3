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
  List<Map<String, dynamic>> dataStorage = [];

  void refreshData() async {
    final data = await DatabaseHelper.getTasks();

    setState(() {
      dataStorage = data;
    });
  }

  Future<void> _updateTask() async {
    await DatabaseHelper.updateTask(
      int.parse(widget.id),
      titleController.text,
      descriptionController.text,
    );

    Navigator.pop(context, "refresh");
  }

  Future<void> _getTask() async {
    var data1 = await DatabaseHelper.getTask(int.parse(widget.id));

    setState(() {
      titleController.text = data1[0]["title"] as String;
      descriptionController.text = data1[0]["description"] as String;
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
              onPressed: _updateTask,
              child: const Text('edit Task'),
            ),
          ],
        ),
      ),
    );
  }
}