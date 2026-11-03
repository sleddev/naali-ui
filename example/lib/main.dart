import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:naali_ui/naali_ui.dart';

import 'pages/components_page.dart';
import 'pages/home_demo.dart';
import 'pages/tokens_page.dart';

/// App-wide theme mode, toggled from the page headers.
final themeMode = ValueNotifier(ThemeMode.dark);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const GalleryApp());
}

class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: themeMode,
        builder: (context, mode, _) => MaterialApp(
          title: 'Naali Gallery',
          debugShowCheckedModeBanner: false,
          theme: NaaliTheme.light(),
          darkTheme: NaaliTheme.dark(),
          themeMode: mode,
          home: const GalleryShell(),
        ),
      );
}

/// Toggles light/dark. Sits in every tab header.
class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = context.naali.isDark;
    return NGlassIconButton(
      icon: dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
      tooltip: dark ? 'Light mode' : 'Dark mode',
      onPressed: () => themeMode.value = dark ? ThemeMode.light : ThemeMode.dark,
    );
  }
}

class GalleryShell extends StatefulWidget {
  const GalleryShell({super.key});

  @override
  State<GalleryShell> createState() => _GalleryShellState();
}

class _GalleryShellState extends State<GalleryShell> {
  int _index = 0;

  static const _items = [
    NNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'Home'),
    NNavItem(icon: Icons.widgets_outlined, selectedIcon: Icons.widgets_rounded, label: 'Components'),
    NNavItem(icon: Icons.palette_outlined, selectedIcon: Icons.palette_rounded, label: 'Tokens'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.naali;
    return AnnotatedRegion(
      value: (c.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: PopScope(
        canPop: _index == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) setState(() => _index = 0);
        },
        child: Scaffold(
          extendBody: true,
          body: BackdropGroup(
            child: IndexedStack(
              index: _index,
              children: const [HomeDemo(tabIndex: 0), ComponentsPage(tabIndex: 1), TokensPage(tabIndex: 2)],
            ),
          ),
          bottomNavigationBar: NNavBar(
            items: _items,
            index: _index,
            onTap: (i) {
              if (i == _index) NTabReselect.fire(i);
              setState(() => _index = i);
            },
          ),
        ),
      ),
    );
  }
}
