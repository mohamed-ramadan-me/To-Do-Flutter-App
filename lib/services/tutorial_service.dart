import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialService extends ChangeNotifier {
  static const String _keyHasSeenDeleteTutorial = 'has_seen_delete_tutorial';
  bool _hasSeenDeleteTutorial = false;
  bool _isInitialized = false;

  bool get hasSeenDeleteTutorial => _hasSeenDeleteTutorial;
  bool get isInitialized => _isInitialized;

  TutorialService() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _hasSeenDeleteTutorial = prefs.getBool(_keyHasSeenDeleteTutorial) ?? false;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> markDeleteTutorialAsSeen() async {
    if (_hasSeenDeleteTutorial) return;

    _hasSeenDeleteTutorial = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenDeleteTutorial, true);
  }

  Future<void> resetTutorials() async {
    _hasSeenDeleteTutorial = false;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHasSeenDeleteTutorial);
  }
}
