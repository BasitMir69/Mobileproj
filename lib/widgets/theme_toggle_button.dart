import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campus_wave/theme/theme_provider.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return IconButton(
          tooltip: themeProvider.isDarkMode
              ? 'Switch to light mode'
              : 'Switch to dark mode',
          icon: Icon(
            themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: themeProvider.primaryTextColor,
          ),
          onPressed: () {
            themeProvider.toggleTheme();
          },
        );
      },
    );
  }
}
