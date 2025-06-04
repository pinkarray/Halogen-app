import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:halogen/shared/widgets/halogen_back_button.dart';
import 'package:halogen/shared/widgets/underlined_glow_password_field.dart';
import 'package:halogen/shared/helpers/session_manager.dart';
import 'package:halogen/shared/widgets/glowing_arrows_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final token = await SessionManager.getAuthToken();
    final url = Uri.parse('http://185.203.216.113:3004/api/v1/profile/change-password');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'old_password': _currentController.text.trim(),
          'password': _newController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Password changed successfully')),
        );
        Navigator.pop(context);
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to change password')),
        );
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }

    setState(() => _isLoading = false);
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
          'Change Password',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Objective',
            color: Color(0xFF1C2B66),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              UnderlinedGlowPasswordField(
                label: 'Current Password',
                icon: Icons.lock_outline,
                controller: _currentController,
              ),
              UnderlinedGlowPasswordField(
                label: 'New Password',
                icon: Icons.lock_outline,
                controller: _newController,
              ),
              UnderlinedGlowPasswordField(
                label: 'Confirm New Password',
                icon: Icons.lock_outline,
                controller: _confirmController,
              ),
              const SizedBox(height: 30),
              GlowingArrowsButton(
                text: 'Change Password',
                showLoader: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
