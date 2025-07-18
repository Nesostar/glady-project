import 'package:church_app/theme_switcher.dart';
import 'package:flutter/material.dart';

class DarkThemePage extends StatefulWidget {
  const DarkThemePage({super.key});

  @override
  State<DarkThemePage> createState() => _DarkThemePageState();
}

class _DarkThemePageState extends State<DarkThemePage> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dark Theme Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Enable Dark Mode', style: TextStyle(fontSize: 18)),
            Switch(
              value: isDark,
              onChanged: (value) {
                setState(() {
                  isDark = value;
                });
                // Notify the app to switch theme
                ThemeSwitcher.of(context).changeTheme(
                  value ? ThemeMode.dark : ThemeMode.light,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
