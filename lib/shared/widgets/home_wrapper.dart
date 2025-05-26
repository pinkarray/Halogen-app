import 'package:flutter/material.dart';
import 'package:halogen/modules/dashboard/dashboard_screen.dart';
import 'package:halogen/modules/services/services_screen.dart';
import 'package:halogen/modules/settings/settings_screen.dart';
import 'package:halogen/screens/monitoring_services_screen.dart';

class HomeWrapper extends StatefulWidget {
  final int initialIndex;

  const HomeWrapper({super.key, this.initialIndex = 0});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> with TickerProviderStateMixin {
  late int _selectedIndex;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ServicesScreen(),
    MonitoringServicesScreen(),
    SettingsScreen(),
  ];

  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _jumpAnimations;

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.initialIndex;

    _controllers = List.generate(
      4,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    _jumpAnimations = _controllers.map((controller) {
      return TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(begin: 0.0, end: -10.0),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween(begin: -10.0, end: 0.0),
          weight: 50,
        ),
      ]).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutBack,
        ),
      );
    }).toList();
  }

  void _onItemTapped(int index) {
    final controller = _controllers[index];

    if (!controller.isAnimating) {
      controller.forward(from: 0.0);
    }

    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedItemColor: const Color(0xFFFFCC29),
        unselectedItemColor: Color(0xFF1C2B66),
        showUnselectedLabels: true,
        items: List.generate(4, (index) {
          final iconData = [
            Icons.dashboard,
            Icons.shield_outlined,
            Icons.videocam_outlined,
            Icons.settings_outlined,
          ][index];

          final label = ["Dashboard", "Services", "Monitoring", "Settings"][index];

          return BottomNavigationBarItem(
            icon: AnimatedBuilder(
              animation: _jumpAnimations[index],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _jumpAnimations[index].value),
                  child: child,
                );
              },
              child: Icon(iconData),
            ),
            label: label,
          );
        }),
      ),
    );
  }
}