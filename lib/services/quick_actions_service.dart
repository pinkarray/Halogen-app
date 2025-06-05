import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';

class QuickActionsService {
  final QuickActions quickActions = const QuickActions();
  final GlobalKey<NavigatorState> navigatorKey;

  QuickActionsService({required this.navigatorKey});

  void initialize() {
    quickActions.initialize((shortcutType) {
      _handleQuickAction(shortcutType);
    });

    quickActions.setShortcutItems([
      const ShortcutItem(
        type: 'emergency_contacts',
        localizedTitle: 'Emergency contact',
        icon: 'logocut',
      ),
      const ShortcutItem(
        type: 'sos',
        localizedTitle: 'SOS',
        icon: 'logocut',
      ),
    ]);
  }

  void _handleQuickAction(String shortcutType) {
    if (shortcutType == 'emergency_contacts') {
      navigatorKey.currentState?.pushNamed('/emergency-contacts');
    } else if (shortcutType == 'sos') {
      navigatorKey.currentState?.pushNamed('/sos');
    }
  }
}