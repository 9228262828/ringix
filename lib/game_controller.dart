import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'models.dart';
import 'store.dart';

class RingixGameController extends ChangeNotifier {
  static const int tickMs = 16;
  static const int rushDurationMs = 60000;

  final RingixStore store;
  final GameMode mode;
  final Random _random = Random();

  Timer? _ticker;
  Timer? _feedbackTimer;

  int rotationSteps = 0;
  int targetSegment = 0;
  int score = 0;
  int combo = 0;
  int runBestCombo = 0;
  int matches = 0;
  int perfectHits = 0;
  int misses = 0;
  int elapsedMs = 0;
  int remainingMs = rushDurationMs;

  double progress = 0;
  double speed = .32;
  bool clockwise = true;

  bool paused = false;
  bool gameOver = false;
  bool registered = false;

  HitGrade? feedback;
  int feedbackPulse = 0;

  RingixGameController({
    required this.store,
    required this.mode,
  });

  double get rushProgress =>
      (remainingMs / rushDurationMs).clamp(0.0, 1.0).toDouble();

  double get accuracy {
    final total = matches + misses;
    if (total == 0) return 100;
    return (matches / total) * 100;
  }

  void start() {
    _ticker?.cancel();
    _feedbackTimer?.cancel();

    rotationSteps = _random.nextInt(4);
    targetSegment = _random.nextInt(4);
    score = 0;
    combo = 0;
    runBestCombo = 0;
    matches = 0;
    perfectHits = 0;
    misses = 0;
    elapsedMs = 0;
    remainingMs = rushDurationMs;
    progress = 0;
    speed = .32;
    clockwise = true;
    paused = false;
    gameOver = false;
    registered = false;
    feedback = null;
    feedbackPulse = 0;

    _ticker = Timer.periodic(
      const Duration(milliseconds: tickMs),
      (_) => _tick(),
    );

    notifyListeners();
  }

  void rotateRing() {
    if (paused || gameOver) return;
    rotationSteps = (rotationSteps + 1) % 4;
    notifyListeners();
  }

  void togglePause() {
    if (gameOver) return;
    paused = !paused;
    notifyListeners();
  }

  int colorAtTarget() {
    return (targetSegment - rotationSteps) % 4;
  }

  void _tick() {
    if (paused || gameOver) return;

    elapsedMs += tickMs;

    if (mode == GameMode.rush60) {
      remainingMs -= tickMs;
      if (remainingMs <= 0) {
        remainingMs = 0;
        _finish();
        return;
      }
    }

    final direction = clockwise ? 1.0 : -1.0;
    progress += direction * speed * (tickMs / 1000);

    if (clockwise && progress >= 1) {
      progress = 1;
      _resolveImpact();
    } else if (!clockwise && progress <= 0) {
      progress = 0;
      _resolveImpact();
    }

    notifyListeners();
  }

  void _resolveImpact() {
    final expectedColor = targetSegment;
    final actualColor = colorAtTarget();

    if (actualColor == expectedColor) {
      matches++;
      combo++;
      if (combo > runBestCombo) runBestCombo = combo;

      final isPerfect = combo >= 3;
      if (isPerfect) {
        perfectHits++;
        score += 20 + min(combo * 2, 40);
        _setFeedback(HitGrade.perfect);
      } else {
        score += 12 + min(combo, 10);
        _setFeedback(HitGrade.match);
      }

      _advanceDifficulty();
      _prepareNext();
    } else {
      misses++;
      combo = 0;
      score = max(0, score - 10);
      _setFeedback(HitGrade.miss);

      if (mode == GameMode.oneMistake) {
        _finish();
        return;
      }

      if (mode == GameMode.endless && misses >= 3) {
        _finish();
        return;
      }

      _prepareNext();
    }
  }

  void _advanceDifficulty() {
    speed = min(.75, .32 + matches * .012);

    if (matches > 0 && matches % 5 == 0) {
      clockwise = !clockwise;
    }
  }

  void _prepareNext() {
    targetSegment = _random.nextInt(4);

    if (_random.nextBool()) {
      rotationSteps = _random.nextInt(4);
    }

    progress = clockwise ? 0 : 1;
  }

  void _setFeedback(HitGrade value) {
    feedback = value;
    feedbackPulse++;

    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(
      const Duration(milliseconds: 420),
      () {
        feedback = null;
        notifyListeners();
      },
    );
  }

  Future<void> _finish() async {
    if (gameOver) return;

    gameOver = true;
    paused = false;
    _ticker?.cancel();
    _feedbackTimer?.cancel();

    if (!registered) {
      registered = true;
      await store.registerRun(
        mode: mode,
        score: score,
        matches: matches,
        perfect: perfectHits,
        runBestCombo: runBestCombo,
      );
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }
}
