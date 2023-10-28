import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../model/task_model.dart';

class FirebaseDatasource {
  Future<void> write(Task task) async {
    try {
      final id = FirebaseAuth.instance.currentUser?.uid;
      if (id == null) return;
      // Берём ссылку на корень дерева с записями для текущего пользователя
      final ref = FirebaseDatabase.instance.ref("Tasks/$id");
      // Сначала генерируем новую ветку с помощью push() и потом в эту же ветку
      // добавляем запись

      await ref.push().set({
        "title": task.title,
        "description": task.description,
        "isDone": task.isDone,
        'duration': task.duration,
      });
    } catch (e) {
      print(e);
    }
  }

  Stream<DatabaseEvent> readAll() {
    try {
      final id = FirebaseAuth.instance.currentUser?.uid;
      final ref = FirebaseDatabase.instance.ref("Tasks/$id");

      return ref.onValue;
    } catch (e) {
      return const Stream.empty();
    }
  }

  Future<void> edit(Task task) async {
    try {
      final id = FirebaseAuth.instance.currentUser?.uid;
      if (id == null) return;
      final ref = FirebaseDatabase.instance.ref("Tasks/$id");
      await ref.child(task.key!).set({
        "title": task.title,
        "description": task.description,
        "isDone": task.isDone,
        'duration': task.duration,
      });
    } catch (e) {}
  }

  Future<void> remove(String key) async {
    try {
      final id = FirebaseAuth.instance.currentUser?.uid;
      if (id == null) return;
      final ref = FirebaseDatabase.instance.ref("notes/$id");
      await ref.child(key).remove();
    } catch (e) {}
  }
}
