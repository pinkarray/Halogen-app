import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:halogen/shared/widgets/halogen_back_button.dart';
import 'package:provider/provider.dart';
import 'provider/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ProfileProvider>(context, listen: false).loadUser();
    });
  }

  Future<void> _launchSupportEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@halogen.com',
      query: 'subject=Customer Support Request',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open email app')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAEA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const HalogenBackButton(),
        centerTitle: true,
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Objective',
            color: Color(0xFF1C2B66),
          ),
        ),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          final user = profileProvider.user;

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFFEDEDED),
                      child: const Icon(Icons.person, size: 40, color: Colors.black45),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user['full_name'] ?? 'Unnamed',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Objective',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user['email'] ?? 'No email',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontFamily: 'Objective',
                      ),
                    ),
                    if (user['phone_number'] != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        user['phone_number'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontFamily: 'Objective',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 30),

              _buildSectionTitle('Account'),
              _buildProfileOption(
                icon: Icons.edit,
                label: 'Edit Profile',
                onTap: () => Navigator.pushNamed(context, '/edit-profile'),
              ),
              _buildProfileOption(
                icon: Icons.lock_outline,
                label: 'Change Password',
                onTap: () => Navigator.pushNamed(context, '/change-password'),
              ),
              _buildProfileOption(
                icon: Icons.contact_phone,
                label: 'Emergency Contacts',
                onTap: () => Navigator.pushNamed(context, '/emergency-contacts'), // To be implemented
              ),

              const SizedBox(height: 30),
              _buildSectionTitle('Support'),
              _buildProfileOption(
                icon: Icons.help_outline,
                label: 'Contact Support',
                onTap: _launchSupportEmail,
              ),

              const SizedBox(height: 30),
              const Divider(),
              _buildProfileOption(
                icon: Icons.logout,
                label: 'Logout',
                color: Colors.red,
                onTap: () => _confirmLogout(context),
              ),
              const SizedBox(height: 30),

                GestureDetector(
                  onTap: () {
                    
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.delete_forever, color: Colors.red),
                      SizedBox(width: 10),
                      Text(
                        "Delete Account",
                        style: TextStyle(
                          fontFamily: 'Objective',
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ).animate().fade(duration: 600.ms).moveX(begin: 30),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'Objective',
          color: Color(0xFF1C2B66),
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String label,
    Color color = Colors.black,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'Objective',
          color: color,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: onTap,
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: const Text("Confirm Logout", style: TextStyle(fontFamily: 'Objective')),
        content: const Text("Are you sure you want to log out?", style: TextStyle(fontFamily: 'Objective')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(fontFamily: 'Objective')),
          ),
          TextButton(
            onPressed: () async {
              final success = await context.read<ProfileProvider>().logout();
              if (success && context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/splash', (route) => false);
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logout failed. Try again.')),
                );
              }
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red, fontFamily: 'Objective')),
          ),
        ],
      ),
    );
  }
}