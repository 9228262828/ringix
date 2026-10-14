import 'package:flutter/material.dart';

import 'screens.dart';
import 'store.dart';
import 'ui.dart';

class RingixApp extends StatefulWidget {
  const RingixApp({super.key});

  @override
  State<RingixApp> createState() => _RingixAppState();
}

class _RingixAppState extends State<RingixApp> {
  final store = RingixStore();

  @override
  void initState() {
    super.initState();
    store.load();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'RINGIX',
          theme: ringixTheme(Brightness.light),
          darkTheme: ringixTheme(Brightness.dark),
          themeMode: store.darkMode ? ThemeMode.dark : ThemeMode.light,
          home: SplashScreen(store: store),
        );
      },
    );
  }
}
