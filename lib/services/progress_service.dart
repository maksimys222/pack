import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const String _completedKey = 'completed_tasks';

  static Future<Set<int>> getCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_completedKey) ?? [];
    return list.map((e) => int.parse(e)).toSet();
  }

  static Future<void> markCompleted(int taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = await getCompleted();
    completed.add(taskId);
    await prefs.setStringList(
        _completedKey, completed.map((e) => e.toString()).toList());
  }

  static Future<void> markUncompleted(int taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = await getCompleted();
    completed.remove(taskId);
    await prefs.setStringList(
        _completedKey, completed.map((e) => e.toString()).toList());
  }

  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedKey);
  }
}
