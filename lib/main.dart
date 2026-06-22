import 'package:flutter/material.dart';
import 'package:todo_app/add_task_screen.dart';
import 'package:todo_app/edit_task_screen.dart';
import 'package:todo_app/DatabaseHelper.dart';
void main() {
  runApp(  MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool isLoading = false;

  List<Map<String, dynamic>> dataStorage = [];

  void refreshData() async {

    final data = await DatabaseHelper.getTasks();

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
  void deleteTask(int id)async{
    await DatabaseHelper.deleteTask(id);
    refreshData();
  }
 @override
Widget build(BuildContext context) {

  return Scaffold(

    appBar: AppBar(
      title: const Text("To-Do App"),
      backgroundColor: Colors.orange,
    ),

    body: isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : ListView.builder(
            itemCount: dataStorage.length,

            itemBuilder: (context, index)=> Card(
              color: Colors.orange[200],
              margin: EdgeInsets.all(15),
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
                  trailing: SizedBox(width: 100,child:
                   Row(children: [
                    IconButton(onPressed: (){
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context)=> EditTaskScreen(
                        id:dataStorage[index]["id"].toString(),
                      ),
                        ),
                      ).then((_)=>refreshData());
                    },icon: Icon(Icons.edit)),
                     IconButton(onPressed: ()=> confirmDelete(dataStorage[index]["id"]),icon:Icon(Icons.delete)),
                  ],),),
              ),
            ),
            ),
    floatingActionButton: FloatingActionButton(onPressed: ()async{
      final result = await Navigator.push(context,MaterialPageRoute(builder: (context)=>AddTaskScreen()));
       if(result=="refresh"){
        refreshData();
       }
   },
   child: Icon(Icons.add),
   ),     
  );
}
}