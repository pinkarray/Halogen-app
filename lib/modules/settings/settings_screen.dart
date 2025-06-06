import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'wallet/wallet_check_wrapper.dart';
import 'package:halogen/shared/helpers/session_manager.dart';
import 'package:halogen/models/user_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await SessionManager.getUserModel();
    if (!mounted) return;
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFFFFAEA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              AssetImage('assets/images/avatar.jpeg'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _user?.fullName ?? "Loading...",
                            style: const TextStyle(
                              fontFamily: 'Objective',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF1C2B66),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _user?.email ?? "",
                            style: const TextStyle(
                              fontFamily: 'Objective',
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ).animate().fade(duration: 600.ms).slideY(begin: 0.2),

                const SizedBox(height: 30),
                _sectionTitle("Account"),
                _settingsGroup([
                  _buildSettingTile(Icons.person_outline, "My Profile", () {
                    Navigator.pushNamed(context, '/profile');
                  }),
                  _buildSettingTile(Icons.account_balance_wallet_outlined, "Wallet", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WalletCheckWrapper()),
                    );
                  }),
                  _buildSettingTile(Icons.notifications_none, "Notifications", () {
                    Navigator.pushNamed(context, '/notification-settings');
                  }),

                ]),

                const SizedBox(height: 20),
                _sectionTitle("Security"),
                _settingsGroup([
                  _buildSettingTile(Icons.warning_amber_outlined, "SOS Settings", () {
                    Navigator.pushNamed(context, '/sos-settings');
                  }),
                  _buildSettingTile(Icons.shield_outlined, "View Active Services", () {
                    Navigator.pushNamed(context, '/active-services');
                  }),
                ]),

                const SizedBox(height: 20),
                _sectionTitle("Preferences"),
                _settingsGroup([
                  _buildSettingTile(Icons.dark_mode_outlined, "App Theme", () {
                    Navigator.pushNamed(context, '/theme-settings');
                  }),
                  _buildSettingTile(Icons.language_outlined, "Language", () {
                    Navigator.pushNamed(context, '/language-settings');
                  }),
                ]),

                const SizedBox(height: 20),
                _sectionTitle("Help & Info"),
                _settingsGroup([
                  _buildSettingTile(Icons.help_outline, "FAQ", () {
                      Navigator.pushNamed(context, '/faq');
                  }),
                  _buildSettingTile(Icons.support_agent, "Support", () {
                    Navigator.pushNamed(context, '/support');
                  }),
                  _buildSettingTile(Icons.description_outlined, "Terms & Conditions", () {
                    Navigator.pushNamed(context, '/terms');
                  }),
                  _buildSettingTile(Icons.privacy_tip_outlined, "Privacy Policy", () {
                    Navigator.pushNamed(context, '/privacy');
                  }),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1C2B66),
        fontFamily: 'Objective',
      ),
    ).animate().fade(duration: 300.ms);
  }

  Widget _settingsGroup(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    ).animate().fade(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildSettingTile(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF1C2B66), size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Objective',
                  fontSize: 16,
                  color: Color(0xFF1C2B66),
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}