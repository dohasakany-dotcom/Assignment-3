import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/add_task_screen.dart';
import 'package:todo_app/edit_task_screen.dart';
import 'package:todo_app/DatabaseHelper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:todo_app/login_screen.dart';
import 'package:todo_app/about_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 👇 تشغيل Firebase
 await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "AIzaSyAeMn4U9SNimmwEgF1F1yZ_MNsHUSTXQ2Y",
    appId: "1:632919756612:android:d0cec291b534f46b615111",
    messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
    projectId: "todo-app-8d58a",
    storageBucket:  "todo-app-8d58a.firebasestorage.app",
  ),
);

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
home: StreamBuilder(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) {

    if (snapshot.hasData) {
      return MyApp(); // المستخدم مسجل دخول
    } else {
      return LoginScreen(); // غير مسجل
    }

  },
),  ));
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final uid = FirebaseAuth.instance.currentUser!.uid;

  bool isLoading = true; 
  List<Map<String, dynamic>> dataStorage = [];

  void refreshData() async {
    setState(() {
      isLoading = true;
    });

    final data = await DatabaseHelper.getTasks(uid);

    setState(() {
      dataStorage = data;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  void toggleTaskStatus(int id, int currentStatus) async {
    int newStatus = currentStatus == 1 ? 0 : 1;
    await DatabaseHelper.toggleStatus(id, newStatus);
     // Firebase update
  FirebaseDatabase.instance
    .ref("tasks/$uid")
      .child(id.toString())
      .update({
    "isComplete": newStatus,
  });
    refreshData();
  }

  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteTask(id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void deleteTask(int id) async {
    await DatabaseHelper.deleteTask(id);
    // Firebase حذف
    FirebaseDatabase.instance
      .ref("tasks/$uid")
      .child(id.toString())
      .remove();
    refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
  title: const Text("To-Do App"),
  backgroundColor: Colors.orange,

  actions: [

    IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AboutScreen(),
          ),
        );
      },
      icon: const Icon(Icons.info),
    ),

    IconButton(
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
      },
      icon: const Icon(Icons.logout),
    ),

  ],
),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: dataStorage.length,
              itemBuilder: (context, index) => Card(
                color: Colors.orange[200],
                margin: const EdgeInsets.all(15),
                child: ListTile(

                  leading: Checkbox(
                    value: dataStorage[index]['isComplete'] == 1,
                    onChanged: (_) => toggleTaskStatus(
                      dataStorage[index]['id'],
                      dataStorage[index]['isComplete'],
                    ),
                  ),

                  title: Text(
                    dataStorage[index]['title'],
                    style: TextStyle(
                      decoration: dataStorage[index]['isComplete'] == 1
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),

                  subtitle: Text(
                    dataStorage[index]['description'],
                  ),

                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [

                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditTaskScreen(
                                  id: dataStorage[index]["id"].toString(),
                                ),
                              ),
                            ).then((_) => refreshData());
                          },
                          icon: const Icon(Icons.edit),
                        ),

                        IconButton(
                          onPressed: () =>
                              confirmDelete(dataStorage[index]["id"]),
                          icon: const Icon(Icons.delete),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );

          if (result == "refresh") {
            refreshData();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}