import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './provider/language_provider.dart';
import '../../../shared/widgets/halogen_back_button.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAEA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const HalogenBackButton(),
        title: const Text(
          'Language',
          style: TextStyle(
            fontFamily: 'Objective',
            color: Color(0xFF1C2B66),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildTile(context, provider, 'English', const Locale('en')),
          _buildTile(context, provider, 'French', const Locale('fr')),
          _buildTile(context, provider, 'Yoruba', const Locale('yo')),
          _buildTile(context, provider, 'Igbo', const Locale('ig')),
          _buildTile(context, provider, 'Hausa', const Locale('ha')),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, LanguageProvider provider, String title, Locale locale) {
    final isSelected = provider.currentLocale.languageCode == locale.languageCode;

    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontFamily: 'Objective'),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF1C2B66)) : null,
      onTap: () => provider.setLocale(locale),
    );
  }
}
