import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class RingixStore extends ChangeNotifier {
  static const _darkKey = 'ringix_dark_v1';
  static const _hapticKey = 'ringix_haptic_v1';
  static const _endlessKey = 'ringix_endless_best_v1';
  static const _rushKey = 'ringix_rush_best_v1';
  static const _oneMistakeKey = 'ringix_onemistake_best_v1';
  static const _gamesKey = 'ringix_games_v1';
  static const _matchesKey = 'ringix_matches_v1';
  static const _perfectKey = 'ringix_perfect_v1';
  static const _comboKey = 'ringix_combo_v1';

  bool ready = false;
  bool darkMode = true;
  bool haptics = true;

  int endlessBest = 0;
  int rushBest = 0;
  int oneMistakeBest = 0;
  int gamesPlayed = 0;
  int totalMatches = 0;
  int totalPerfect = 0;
  int bestCombo = 0;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    darkMode = prefs.getBool(_darkKey) ?? true;
    haptics = prefs.getBool(_hapticKey) ?? true;
    endlessBest = prefs.getInt(_endlessKey) ?? 0;
    rushBest = prefs.getInt(_rushKey) ?? 0;
    oneMistakeBest = prefs.getInt(_oneMistakeKey) ?? 0;
    gamesPlayed = prefs.getInt(_gamesKey) ?? 0;
    totalMatches = prefs.getInt(_matchesKey) ?? 0;
    totalPerfect = prefs.getInt(_perfectKey) ?? 0;
    bestCombo = prefs.getInt(_comboKey) ?? 0;
    ready = true;
    notifyListeners();
  }

  Future<void> registerRun({
    required GameMode mode,
    required int score,
    required int matches,
    required int perfect,
    required int runBestCombo,
  }) async {
    gamesPlayed++;
    totalMatches += matches;
    totalPerfect += perfect;
    if (runBestCombo > bestCombo) bestCombo = runBestCombo;

    switch (mode) {
      case GameMode.endless:
        if (score > endlessBest) endlessBest = score;
        break;
      case GameMode.rush60:
        if (score > rushBest) rushBest = score;
        break;
      case GameMode.oneMistake:
        if (score > oneMistakeBest) oneMistakeBest = score;
        break;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_endlessKey, endlessBest);
    await prefs.setInt(_rushKey, rushBest);
    await prefs.setInt(_oneMistakeKey, oneMistakeBest);
    await prefs.setInt(_gamesKey, gamesPlayed);
    await prefs.setInt(_matchesKey, totalMatches);
    await prefs.setInt(_perfectKey, totalPerfect);
    await prefs.setInt(_comboKey, bestCombo);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkKey, value);
    notifyListeners();
  }

  Future<void> setHaptics(bool value) async {
    haptics = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticKey, value);
    notifyListeners();
  }

  Future<void> reset() async {
    endlessBest = 0;
    rushBest = 0;
    oneMistakeBest = 0;
    gamesPlayed = 0;
    totalMatches = 0;
    totalPerfect = 0;
    bestCombo = 0;

    final prefs = await SharedPreferences.getInstance();
    for (final key in [
      _endlessKey,
      _rushKey,
      _oneMistakeKey,
      _gamesKey,
      _matchesKey,
      _perfectKey,
      _comboKey,
    ]) {
      await prefs.remove(key);
    }

    notifyListeners();
  }
}
