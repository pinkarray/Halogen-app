import 'package:flutter/material.dart';
import 'package:halogen/shared/helpers/session_manager.dart';

class GreetingHeader extends StatefulWidget {
  const GreetingHeader({super.key});

  @override
  State<GreetingHeader> createState() => _GreetingHeaderState();
}

class _GreetingHeaderState extends State<GreetingHeader> {
  String? firstName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await SessionManager.getUserModel();
    if (!mounted) return;

    setState(() {
      firstName = user?.fullName.split(" ").first ?? "there";
      isLoading = false;
    });
  }

  String getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  Widget build(BuildContext context) {
    final greeting = isLoading
        ? "Welcome"
        : "${getTimeBasedGreeting()}, $firstName";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Objective',
                  color: Color(0xFF1C2B66),
                ),
              ),
              const Text(
                "Your security is in check",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blueGrey,
                  fontFamily: 'Objective',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/images/avatar.jpeg'),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/notifications');
              },
              child: Stack(
                alignment: Alignment.topRight,
                children: const [
                  Icon(Icons.notifications_none, size: 28, color: Color(0xFF1C2B66)),
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      radius: 5,
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}