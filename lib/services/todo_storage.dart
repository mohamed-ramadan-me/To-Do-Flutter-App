import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class TodoStorage {
  static const String _todosKey = 'todos';

  // Save todos to local storage
  Future<void> saveTodos(List<Todo> todos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = todos.map((todo) => todo.toJson()).toList();
      final todosString = jsonEncode(todosJson);
      await prefs.setString(_todosKey, todosString);
    } catch (e) {
      // Handle error silently
    }
  }

  // Load todos from local storage
  Future<List<Todo>> loadTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosString = prefs.getString(_todosKey);

      if (todosString == null || todosString.isEmpty) {
        return [];
      }

      final List<dynamic> todosJson = jsonDecode(todosString);
      return todosJson
          .map((json) => Todo.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Handle error and return empty list
      return [];
    }
  }

  // Clear all todos from storage
  Future<void> clearTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_todosKey);
    } catch (e) {
      // Handle error silently
    }
  }
}
