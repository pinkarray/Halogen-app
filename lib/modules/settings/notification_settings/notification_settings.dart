import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../provider/settings_provider.dart';
import '../../../shared/widgets/halogen_back_button.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  Widget buildToggle(String title, bool value, void Function(bool) onChanged) {
    return AnimatedContainer(
      duration: 300.ms,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Objective',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1C2B66),
              ),
            ),
          ),
          Switch(
            value: value,
            activeColor: const Color(0xFF1C2B66),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAEA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const HalogenBackButton(),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Objective',
            color: Color(0xFF1C2B66),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildToggle("Enable All Notifications", settings.allNotifications, (val) {
              settings.setAllNotifications(val);
            }),
            AnimatedOpacity(
              opacity: settings.allNotifications ? 1 : 0.3,
              duration: 300.ms,
              child: Column(
                children: [
                  buildToggle("Push Alerts", settings.pushAlerts, (val) {
                    settings.setPushAlerts(val);
                  }),
                  buildToggle("App Tips", settings.appTips, (val) {
                    settings.setAppTips(val);
                  }),
                  buildToggle("Emergency Warnings", settings.emergencyWarnings, (val) {
                    settings.setEmergencyWarnings(val);
                  }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}