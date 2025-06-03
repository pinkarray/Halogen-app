import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'widgets/greeting_header.dart';
import 'widgets/dashboard_search_bar.dart';
import 'widgets/continue_registration_prompt.dart';
import 'package:halogen/shared/helpers/session_manager.dart';
import 'package:halogen/models/user_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  UserModel? _user;
  bool _isRegistered = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await SessionManager.getUserModel();
    final stage = await SessionManager.getStage();

    if (!mounted) return;
    setState(() {
      _user = user;
      _isRegistered = stage >= 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const GreetingHeader()
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: -0.2),
              const SizedBox(height: 20),
              const DashboardSearchBar()
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideX(begin: -0.3),
              const SizedBox(height: 20),

              if (_isRegistered) ...[
                const Text(
                  "Services",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Objective',
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: 0.2),
                const SizedBox(height: 12),
              ],

              Expanded(
                child: Center(
                  child: _isRegistered
                      ? const Text(
                          "Services will appear here once available.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontFamily: 'Objective',
                          ),
                        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1)
                      : _user == null
                          ? const CircularProgressIndicator()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _UserInfoRow(label: "First Name", value: _user?.fullName.split(' ').first),
                                _UserInfoRow(label: "Last Name", value: _user?.fullName.split(' ').skip(1).join(" ")),
                                _UserInfoRow(label: "Email", value: _user?.email),
                                _UserInfoRow(label: "Phone", value: _user?.phoneNumber),
                                
                                const SizedBox(height: 20),
                                ContinueRegistrationPrompt(
                                  onContinue: () => Navigator.pushNamed(
                                    context,
                                    '/continue-registration',
                                  ),
                                ),
                              ],
                            )
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .slideY(begin: 0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserInfoRow extends StatelessWidget {
  final String label;
  final String? value;

  const _UserInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Objective',
              fontSize: 15,
            ),
          ),
          Expanded(
            child: Text(
              value?.isNotEmpty == true ? value! : "-",
              style: const TextStyle(
                fontFamily: 'Objective',
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}