import 'package:flutter/material.dart';
import 'profile/profile_screen.dart';
import 'profile/edit_profile_screen.dart';
import 'profile/change_password_screen.dart';
import 'faq/faq_screen.dart';
import 'terms/terms_and_conditions_screen.dart';
import 'privacy_policy/privacy_policy_screen.dart';
import 'support/support_screen.dart';
import 'sos/sos_settings.dart';
import 'sos/emergency_contacts_screen.dart'; // Add this import


final Map<String, WidgetBuilder> settingsRoutes = {
  '/profile': (context) => const ProfileScreen(),
  '/edit-profile': (context) => const EditProfileScreen(),
  '/change-password': (context) => const ChangePasswordScreen(),
  '/faq': (context) => const FAQScreen(),
  '/terms': (_) => const TermsAndConditionsScreen(),
  '/privacy': (_) => const PrivacyPolicyScreen(),
  '/support': (_) => const SupportScreen(),
  '/sos-settings': (context) => const SosSettingsScreen(),
  '/emergency-contacts': (context) => const EmergencyContactsScreen(), // Add this route
};