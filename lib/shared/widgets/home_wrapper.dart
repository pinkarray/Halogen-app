import 'package:flutter/material.dart';
import 'package:halogen/modules/dashboard/dashboard_screen.dart';
import 'package:halogen/modules/services/services_screen.dart';
import 'package:halogen/modules/settings/settings_screen.dart';
import 'package:halogen/screens/monitoring_services_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
  late final List<Animation<double>> _scaleAnimations;
  

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.initialIndex;

    _controllers = List.generate(
      4,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );

    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutBack,
        ),
      );
    }).toList();

    _controllers[_selectedIndex].forward();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    _controllers[_selectedIndex].reverse();
    _controllers[index].forward();

    setState(() => _selectedIndex = index);
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
    return PopScope(
      canPop: false, // Prevents swipe or back gestures from popping the screen
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: _buildCustomBottomNavigationBar(),
      ),
    );
  }

  Widget _buildCustomBottomNavigationBar() {
    return Container(
      height: 80,
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(0, LucideIcons.layoutGrid, "Home"),
              _buildNavItem(1, LucideIcons.shield, "Services"),
              _buildNavItem(2, LucideIcons.monitor, "Monitor"),
              _buildNavItem(3, LucideIcons.settings, "Settings"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData iconData, String label) {
    final isSelected = _selectedIndex == index;

    return Flexible(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _scaleAnimations[index],
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimations[index].value,
                    child: child,
                  );
                },
                child: Icon(
                  iconData,
                  color: isSelected ? const Color(0xFFFFCC29) : const Color(0xFF1C2B66),
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFFFFCC29) : const Color(0xFF1C2B66),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}