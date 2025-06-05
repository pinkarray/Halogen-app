import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'widgets/greeting_header.dart';
import 'widgets/dashboard_search_bar.dart';
import 'widgets/continue_registration_prompt.dart';
import 'package:halogen/shared/helpers/session_manager.dart';
import 'package:halogen/models/user_model.dart';
import 'package:halogen/shared/widgets/bounce_tap.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  UserModel? _user;
  bool _isRegistered = false;
  String _selectedFilter = 'All';

  final List<String> _filterOptions = [
    'All',
    'Active',
    'Issues',
    'No subscription',
    'Physical Security Service',
    'Secured Mobility',
    'Outsourcing & Talent Risk',
    'Digital Security & Privacy Protection',
    'Concierge Services',
    'Also By Halogen',
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  List<Map<String, dynamic>> get _allServices => [
    { 'title': 'Electric Fence', 'status': 'No subscription', 'isActive': false, 'type': 'Physical Security Service', 'icon': Icons.electric_bolt, 'route': '/electric-fence', },
    { 'title': 'Motion Sensor', 'status': 'No subscription', 'isActive': false, 'type': 'Physical Security Service', 'icon': Icons.sensors, },
    { 'title': 'Fire Alarm', 'status': 'No subscription', 'isActive': false, 'type': 'Physical Security Service', 'icon': Icons.local_fire_department, },
    { 'title': 'CCTV Monitoring', 'status': 'No subscription', 'isActive': false, 'type': 'Physical Security Service', 'icon': Icons.videocam, },
    { 'title': 'On-Site Guard', 'status': 'No subscription', 'isActive': false, 'type': 'Physical Security Service', 'icon': Icons.shield, },

    {'title': 'Vehicle Tracker', 'status': 'No subscription', 'isActive': false, 'type': 'Secured Mobility','icon': Icons.gps_fixed,},
    { 'title': 'Armed Escort', 'status': 'No subscription','isActive': false,'type': 'Secured Mobility','icon': Icons.security,},
    {'title': 'Secure Pickup', 'status': 'No subscription', 'isActive': false, 'type': 'Secured Mobility', 'icon': Icons.directions_car_filled,},

    { 'title': 'Device Audit', 'status': 'No subscription', 'isActive': false, 'type': 'Digital Security & Privacy Protection', 'icon': Icons.phonelink_lock,},
    { 'title': 'App Security Monitoring', 'status': 'No subscription', 'isActive': false, 'type': 'Digital Security & Privacy Protection', 'icon': Icons.security_update_warning, },

    { 'title': 'Executive Driver', 'status': 'No subscription', 'isActive': false, 'type': 'Outsourcing & Talent Risk', 'icon': Icons.drive_eta, },
    { 'title': 'Office Security Personnel', 'status': 'Absent', 'isActive': false, 'type': 'Outsourcing & Talent Risk', 'icon': Icons.badge, },

    { 'title': 'Errand Services', 'status': 'No subscription', 'isActive': false, 'type': 'Concierge Services', 'icon': Icons.delivery_dining, },
    { 'title': 'Premium Shopping Assistance', 'status': 'No subscription', 'isActive': false,  'type': 'Concierge Services', 'icon': Icons.shopping_bag, },

    { 'title': 'VIP Event Security', 'status': 'No subscription', 'isActive': false, 'type': 'Also By Halogen', 'icon': Icons.emoji_events, },
    { 'title': 'Emergency Response Team', 'status': 'No subscription', 'isActive': false, 'type': 'Also By Halogen', 'icon': Icons.local_police, },
  ];


  List<Map<String, dynamic>> get _filteredServices {
    List<Map<String, dynamic>> services = [..._allServices];

    if (_searchQuery.isNotEmpty) {
      services = services.where((s) =>
        s['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    if (_selectedFilter != 'All') {
      if (_selectedFilter == 'Active') {
        services = services.where((s) => s['isActive'] == true).toList();
      } else if (_selectedFilter == 'Issues') {
        services = services.where((s) =>
          s['status'].toString().toLowerCase().contains('issue')).toList();
      } else if (_selectedFilter == 'No subscription') {
        services = services.where((s) => s['status'] == 'No subscription').toList();
      } else {
        services = services.where((s) => s['type'] == _selectedFilter).toList();
      }
    }

    return services;
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white, 
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Filters",
                  style: TextStyle(
                    fontFamily: 'Objective',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1C2B66),
                  ),
                ),
                const SizedBox(height: 20),
                ..._filterOptions.map((option) => RadioListTile<String>(
                  value: option,
                  groupValue: _selectedFilter,
                  onChanged: (value) {
                    setState(() => _selectedFilter = value!);
                    Navigator.pop(context);
                  },
                  title: Text(
                    option,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Objective',
                    ),
                  ),
                  activeColor: const Color(0xFF1C2B66),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Update the build method in _DashboardScreenState
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
              const GreetingHeader().animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),
              const SizedBox(height: 20),
              DashboardSearchBar(
                controller: _searchController,
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
              ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.3),
              const SizedBox(height: 20),
              if (_isRegistered) ...[
                Text(
                  "Services",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Objective',
                    color: Color(0xFF1C2B66),
                  ),
                ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2),
                const SizedBox(height: 12),
              ],
              Expanded(
                child: _isRegistered
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Filter: $_selectedFilter',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Objective',
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1C2B66),
                                ),
                              ),
                              IconButton(
                                onPressed: _showFilterSheet,
                                icon: const Icon(Icons.filter_list),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: _searchQuery.isNotEmpty
                                ? ListView.builder(
                                    itemCount: _filteredServices.length,
                                    itemBuilder: (context, index) {
                                      final service = _filteredServices[index];
                                      return ServiceTile(
                                        title: service['title'],
                                        status: service['status'],
                                        isActive: service['isActive'],
                                        icon: service['icon'],
                                      );
                                    },
                                  )
                                : ListView.builder(
                                    itemCount: _filteredServices.length,
                                    itemBuilder: (context, index) {
                                      final service = _filteredServices[index];
                                      return ServiceTile(
                                        title: service['title'],
                                        status: service['status'],
                                        isActive: service['isActive'],
                                        icon: service['icon'],
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1)
                    : _user == null
                        ? const Center(child: CircularProgressIndicator())
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
                          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1),
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

class ServiceTile extends StatelessWidget {
  final String title;
  final String status;
  final bool isActive;
  final IconData icon;

  const ServiceTile({
    super.key,
    required this.title,
    required this.status,
    required this.isActive,
    required this.icon,
  });

  Color _getStatusColor() {
    if (status.toLowerCase().contains('issue')) return Colors.red;
    if (status == 'No subscription') return Colors.grey;
    return isActive ? Colors.green : Colors.orange;
  }

  String _getStatusLabel() {
    if (status.toLowerCase().contains('issue')) return 'Issue';
    if (status == 'No subscription') return 'No Subscription';
    return isActive ? 'Active' : 'Inactive';
  }

  @override
  Widget build(BuildContext context) {
    return BounceTap(
      onTap: () {}, // Hook up service navigation
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFFF8F9FF),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFE3E7F3),
              child: Icon(icon, color: const Color(0xFF1C2B66), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Objective',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C2B66),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusLabel(),
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Objective',
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF1C2B66), size: 24),
          ],
        ),
      ),
    );
  }
}

