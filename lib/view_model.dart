import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model.dart';

class KanbanViewModel extends ChangeNotifier {
  static const _storageKey = 'kanban';

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  final tasks = <Task>[];

  Future<void> load() async {
    final data = await _prefs.getString(_storageKey);
    if (data == null) return;

    final decoded = jsonDecode(data) as List<dynamic>;
    tasks
      ..clear()
      ..addAll(
        decoded.map((item) {
          final task = item as Map<String, dynamic>;
          return Task(task['title'] as String, task['status'] as int);
        }),
      );
  }

  Future<void> save() async {
    notifyListeners();
    final data = [
      for (final task in tasks) {'title': task.title, 'status': task.status},
    ];
    await _prefs.setString(_storageKey, jsonEncode(data));
  }

  void add(String text) {
    tasks.add(Task(text));
    save();
  }

  void move(Task task, int status) {
    task.status = status;
    save();
  }

  void rename(Task task, String text) {
    task.title = text;
    save();
  }

  void remove(Task task) {
    tasks.remove(task);
    save();
  }
}
