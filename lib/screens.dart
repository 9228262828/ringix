import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game_controller.dart';
import 'models.dart';
import 'store.dart';
import 'ui.dart';

class SplashScreen extends StatefulWidget {
  final RingixStore store;

  const SplashScreen({super.key, required this.store});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    while (!widget.store.ready) {
      await Future.delayed(const Duration(milliseconds: 40));
    }

    await Future.delayed(const Duration(milliseconds: 550));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(store: widget.store),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RingixLogo(size: 100),
            SizedBox(height: 22),
            Text(
              'RINGIX',
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w900,
                letterSpacing: 5,
              ),
            ),
            SizedBox(height: 7),
            Text(
              'CIRCLE SWITCH',
              style: TextStyle(
                color: ringixCyan,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final RingixStore store;

  const HomeScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 34),
              children: [
                Row(
                  children: [
                    const RingixLogo(size: 54),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RINGIX',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                            ),
                          ),
                          Text(
                            'CIRCLE SWITCH',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StatsScreen(store: store),
                        ),
                      ),
                      icon: const Icon(Icons.bar_chart_rounded),
                    ),
                    IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SettingsScreen(store: store),
                        ),
                      ),
                      icon: const Icon(Icons.settings_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  'Match the ring.\nTap to survive.',
                  style: TextStyle(
                    fontSize: 31,
                    fontWeight: FontWeight.w900,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'Rotate the colors before the moving point reaches the edge.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 25),
                ...GameMode.values.map(
                  (mode) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ModeCard(
                      mode: mode,
                      store: store,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameScreen(
                            store: store,
                            mode: mode,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ModeCard extends StatelessWidget {
  final GameMode mode;
  final RingixStore store;
  final VoidCallback onTap;

  const ModeCard({
    super.key,
    required this.mode,
    required this.store,
    required this.onTap,
  });

  int get best {
    switch (mode) {
      case GameMode.endless:
        return store.endlessBest;
      case GameMode.rush60:
        return store.rushBest;
      case GameMode.oneMistake:
        return store.oneMistakeBest;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: ringixPurple.withOpacity(.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  modeIcon(mode),
                  color: ringixPurple,
                  size: 29,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      modeName(mode),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      modeSubtitle(mode),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'BEST SCORE $best',
                      style: const TextStyle(
                        color: ringixCyan,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.play_arrow_rounded),
            ],
          ),
        ),
      ),
    );
  }
}


class GameScreen extends StatefulWidget {
  final RingixStore store;
  final GameMode mode;

  const GameScreen({
    super.key,
    required this.store,
    required this.mode,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final RingixGameController controller;
  bool navigatedToResult = false;

  @override
  void initState() {
    super.initState();
    controller = RingixGameController(
      store: widget.store,
      mode: widget.mode,
    );
    controller.addListener(_watchResult);
    controller.start();
  }

  void _watchResult() {
    if (!mounted || !controller.gameOver || navigatedToResult) return;

    navigatedToResult = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            store: widget.store,
            mode: widget.mode,
            score: controller.score,
            matches: controller.matches,
            perfectHits: controller.perfectHits,
            misses: controller.misses,
            bestCombo: controller.runBestCombo,
            accuracy: controller.accuracy,
          ),
        ),
      );
    });
  }

  void _rotate() {
    controller.rotateRing();

    if (widget.store.haptics) {
      HapticFeedback.selectionClick();
    }
  }

  @override
  void dispose() {
    controller.removeListener(_watchResult);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(modeName(widget.mode).toUpperCase()),
            actions: [
              IconButton(
                onPressed: controller.togglePause,
                icon: Icon(
                  controller.paused
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: GameStat(
                            value: '${controller.score}',
                            label: 'SCORE',
                            color: ringixPurple,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GameStat(
                            value: '${controller.combo}',
                            label: 'COMBO',
                            color: ringixCyan,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GameStat(
                            value: _thirdValue(),
                            label: _thirdLabel(),
                            color: ringixOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.mode == GameMode.rush60)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: LinearProgressIndicator(
                        value: controller.rushProgress,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(99),
                        color: ringixCyan,
                      ),
                    ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _rotate,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return CustomPaint(
                                size: Size(
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                ),
                                painter: RingGamePainter(
                                  rotationSteps: controller.rotationSteps,
                                  targetSegment: controller.targetSegment,
                                  progress: controller.progress,
                                ),
                              );
                            },
                          ),
                          Positioned(
                            bottom: 32,
                            child: Column(
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 170),
                                  child: controller.feedback == null
                                      ? const Text(
                                          'TAP TO ROTATE',
                                          key: ValueKey('tap'),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.4,
                                          ),
                                        )
                                      : Text(
                                          hitGradeLabel(controller.feedback!),
                                          key: ValueKey(
                                            controller.feedbackPulse,
                                          ),
                                          style: TextStyle(
                                            color: hitGradeColor(
                                              controller.feedback!,
                                            ),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Accuracy ${controller.accuracy.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (controller.paused)
                Positioned.fill(
                  child: ColoredBox(
                    color: Theme.of(context)
                        .scaffoldBackgroundColor
                        .withOpacity(.96),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.pause_circle_filled_rounded,
                            color: ringixCyan,
                            size: 72,
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'PAUSED',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 18),
                          FilledButton(
                            onPressed: controller.togglePause,
                            child: const Text('RESUME'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _thirdValue() {
    if (widget.mode == GameMode.rush60) {
      return '${(controller.remainingMs / 1000).ceil().clamp(0, 60)}s';
    }

    if (widget.mode == GameMode.endless) {
      return '${(3 - controller.misses).clamp(0, 3)}';
    }

    return '${controller.matches}';
  }

  String _thirdLabel() {
    if (widget.mode == GameMode.rush60) return 'TIME';
    if (widget.mode == GameMode.endless) return 'LIVES';
    return 'MATCHES';
  }
}

class ResultScreen extends StatelessWidget {
  final RingixStore store;
  final GameMode mode;
  final int score;
  final int matches;
  final int perfectHits;
  final int misses;
  final int bestCombo;
  final double accuracy;

  const ResultScreen({
    super.key,
    required this.store,
    required this.mode,
    required this.score,
    required this.matches,
    required this.perfectHits,
    required this.misses,
    required this.bestCombo,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 42, 22, 28),
          children: [
            const Center(child: RingixLogo(size: 86)),
            const SizedBox(height: 20),
            const Text(
              'RUN COMPLETE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: GameStat(
                    value: '$score',
                    label: 'SCORE',
                    color: ringixPurple,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GameStat(
                    value: '${accuracy.toStringAsFixed(0)}%',
                    label: 'ACCURACY',
                    color: ringixCyan,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GameStat(
                    value: '$matches',
                    label: 'MATCHES',
                    color: ringixCyan,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GameStat(
                    value: '$perfectHits',
                    label: 'PERFECT',
                    color: ringixOrange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GameStat(
                    value: '$misses',
                    label: 'MISS',
                    color: ringixPink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GameStat(
              value: '$bestCombo',
              label: 'BEST COMBO',
              color: ringixPurple,
            ),
            const SizedBox(height: 26),
            FilledButton.icon(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => GameScreen(
                    store: store,
                    mode: mode,
                  ),
                ),
              ),
              icon: const Icon(Icons.replay_rounded),
              label: const Padding(
                padding: EdgeInsets.all(14),
                child: Text('PLAY AGAIN'),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.home_outlined),
              label: const Padding(
                padding: EdgeInsets.all(14),
                child: Text('BACK HOME'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class StatsScreen extends StatelessWidget {
  final RingixStore store;

  const StatsScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('STATISTICS')),
          body: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const Text(
                'Your ring stats',
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: GameStat(
                      value: '${store.gamesPlayed}',
                      label: 'GAMES',
                      color: ringixPurple,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GameStat(
                      value: '${store.bestCombo}',
                      label: 'BEST COMBO',
                      color: ringixOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GameStat(
                      value: '${store.totalMatches}',
                      label: 'MATCHES',
                      color: ringixCyan,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GameStat(
                      value: '${store.totalPerfect}',
                      label: 'PERFECT',
                      color: ringixPink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _record('Endless best score', store.endlessBest),
              const SizedBox(height: 10),
              _record('60 Sec best score', store.rushBest),
              const SizedBox(height: 10),
              _record('One Mistake best score', store.oneMistakeBest),
            ],
          ),
        );
      },
    );
  }

  Widget _record(String title, int value) {
    return Card(
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        trailing: Text(
          '$value',
          style: const TextStyle(
            color: ringixCyan,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final RingixStore store;

  const SettingsScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('SETTINGS')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      value: store.darkMode,
                      onChanged: store.setDarkMode,
                      secondary: const Icon(Icons.dark_mode_outlined),
                      title: const Text('Dark mode'),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      value: store.haptics,
                      onChanged: store.setHaptics,
                      secondary: const Icon(Icons.vibration_rounded),
                      title: const Text('Haptic feedback'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalScreen(
                            title: 'Privacy Policy',
                            body: privacyText,
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: const Text('Terms & Conditions'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalScreen(
                            title: 'Terms & Conditions',
                            body: termsText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  textColor: ringixDanger,
                  iconColor: ringixDanger,
                  leading: const Icon(Icons.delete_sweep_outlined),
                  title: const Text('Reset progress'),
                  subtitle: const Text(
                    'Delete all scores and statistics.',
                  ),
                  onTap: () => _reset(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _reset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset RINGIX?'),
        content: const Text(
          'All saved scores and statistics will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('RESET'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await store.reset();
    }
  }
}

class LegalScreen extends StatelessWidget {
  final String title;
  final String body;

  const LegalScreen({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SelectableText(
            body,
            style: const TextStyle(height: 1.7),
          ),
        ],
      ),
    );
  }
}

const privacyText = '''RINGIX PRIVACY POLICY

RINGIX is an offline-first casual color matching game.

The current core version does not require an account, login, Firebase, backend services, advertising, analytics, cloud synchronization, or personal profile.

Gameplay information such as best scores, games played, total matches, perfect hits, best combo, dark-mode preference, and haptic-feedback preference is stored locally on your device.

The current core version does not require access to your location, camera, microphone, contacts, phone, SMS, calendar, photos, media, files, or payment information.

RINGIX does not intentionally sell or rent your locally stored gameplay information and does not use it for personalized advertising.

You can reset saved progress from the Settings screen. Clearing application storage or uninstalling the app may also remove locally stored information, subject to operating-system backup and restore behavior.

If future versions add online services, accounts, cloud sync, analytics, crash reporting, advertising, purchases, leaderboards, multiplayer, or additional permissions, this policy should be reviewed and updated before release.''';

const termsText = '''RINGIX TERMS & CONDITIONS

RINGIX is a casual color matching game intended for entertainment.

Gameplay challenges you to rotate a four-color ring before a moving point reaches the edge. Scores, combos, matches, and other results are for entertainment only.

Scores, best results, total matches, perfect hits, best combo, and preferences may be stored locally on your device.

The current core version stores progress locally. We do not guarantee recovery after uninstalling the app, clearing app data, device loss, storage failure, or operating-system changes.

RINGIX is provided on an "as available" basis to the extent permitted by applicable law. Features may be changed, improved, added, or removed in future versions.''';
