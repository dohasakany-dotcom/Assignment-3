import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {

  static final DatabaseReference tasksRef =
      FirebaseDatabase.instanceFor(
        databaseURL: "https://todo-app-8d58a-default-rtdb.firebaseio.com/",
        app: Firebase.app(),
      ).ref().child("tasks");

}