
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../shared/widgets/halogen_back_button.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();
    final current = provider.currentAppTheme;

    Widget buildOption(AppThemeMode mode, String title, IconData icon) {
      final selected = current == mode;

      return ListTile(
        leading: Icon(icon, color: const Color(0xFF1C2B66)),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Objective',
            fontSize: 16,
            color: Color(0xFF1C2B66),
          ),
        ),
        trailing: selected
            ? const Icon(Icons.check_circle, color: Color(0xFF1C2B66))
            : null,
        onTap: () => provider.setTheme(mode),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAEA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const HalogenBackButton(),
        title: const Text(
          'App Theme',
          style: TextStyle(
            fontFamily: 'Objective',
            color: Color(0xFF1C2B66),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          buildOption(AppThemeMode.light, "Light Mode", Icons.light_mode),
          buildOption(AppThemeMode.dark, "Dark Mode", Icons.dark_mode),
          buildOption(AppThemeMode.system, "System Default", Icons.settings),
        ],
      ),
    );
  }
}
