import 'package:flutter/material.dart';

class ThemeSwitcher extends InheritedWidget {
  final ThemeMode themeMode;
  final void Function(ThemeMode) changeTheme;

  const ThemeSwitcher({
    super.key,
    required this.themeMode,
    required this.changeTheme,
    required super.child,
  });

  static ThemeSwitcher of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeSwitcher>()!;
  }

  @override
  bool updateShouldNotify(ThemeSwitcher oldWidget) {
    return themeMode != oldWidget.themeMode;
  }
}
