import 'package:flutter/material.dart';
import 'services_routes.dart';
import '../../shared/widgets/bounce_tap.dart';
import 'package:halogen/shared/helpers/session_manager.dart';
import 'package:halogen/models/user_model.dart';
import 'package:halogen/shared/widgets/home_wrapper.dart';

class CategoryItem {
  final String title;
  final String icon;
  CategoryItem(this.title, this.icon);
}

final List<CategoryItem> categories = [
  CategoryItem("Physical Security", "physical_security.png"),
  CategoryItem("Secured Mobility", "secured_mobility.png"),
  CategoryItem("Outsourcing & Talent Risk", "outsourcing.png"),
  CategoryItem(
    "Digital Security & Privacy Protection",
    "digital_security.png",
  ),
  CategoryItem("Concierge Services", "concierge_services.png"),
  CategoryItem("Also By Halogen", "logocut.png"),
];

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final List<String> serviceShortcuts = [
    "Electric Fence",
    "Fire Alarm",
    "Motion Sensor",
    "Vehicle Tracker",
    "Dash Cam 1",
    "Armed Operator",
  ];

  final ScrollController _scrollController = ScrollController();
  int focusedIndex = 0;

  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await SessionManager.getUserModel();
    if (!mounted) return;
    setState(() {
      _user = user;
    });
  }

  void _handleScroll() {
    final itemWidth = 72.0 + 12.0;
    final offset = _scrollController.offset;
    final screenCenter = MediaQuery.of(context).size.width / 2;
    final centerIndex = (offset + screenCenter - itemWidth / 2) ~/ itemWidth;

    if (centerIndex != focusedIndex &&
        centerIndex >= 0 &&
        centerIndex < serviceShortcuts.length) {
      setState(() => focusedIndex = centerIndex);
    }
  }

  void _handleSnapScrollEnd() {
    final itemWidth = 72.0 + 12.0;
    final screenCenter = MediaQuery.of(context).size.width / 2;
    final offset = _scrollController.offset;
    final centerIndex = (offset + screenCenter - itemWidth / 2) ~/ itemWidth;
    final targetOffset = centerIndex * itemWidth;

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _showRegisterServiceModal(String serviceName, String iconFile) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF4F4F4),
                ),
                child: Image.asset(
                  'assets/icons/$iconFile',
                  width: 32,
                  height: 32,
                  color: const Color(0xFFFFCC29),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                serviceName,
                style: const TextStyle(
                  fontFamily: 'Objective',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Register for this service?",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Objective',
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF1C2B66),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomeWrapper(initialIndex: 2),
                          ),
                        );
                      },
                      child: const Text(
                        "Register",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Objective',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFFF4F4F4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.black87,
                          fontFamily: 'Objective',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFFFFAEA)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BounceTap(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeWrapper(initialIndex: 3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage('assets/images/avatar.jpeg'),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _user?.fullName ?? "Loading...",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Objective',
                                ),
                              ),
                              const Text(
                                "You can view your profile from here",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  "Service Shortcuts",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Objective',
                  ),
                ),
                const SizedBox(height: 12),
                NotificationListener<ScrollEndNotification>(
                  onNotification: (notification) {
                    _handleSnapScrollEnd();
                    return false;
                  },
                  child: SizedBox(
                    height: 110,
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: serviceShortcuts.length,
                      itemBuilder: (context, index) {
                        final title = serviceShortcuts[index];
                        final fileName =
                            '${title.toLowerCase().replaceAll(RegExp(r'[^\w]+'), '_')}.png';
                        final isFocused = index == focusedIndex;
                        final words = title.split(' ');

                        return BounceTap(
                          onTap: () {
                            setState(() => focusedIndex = index);
                            _showRegisterServiceModal(title, fileName);
                          },
                          child: Container(
                            width: 72,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: isFocused ? 58 : 48,
                                  height: isFocused ? 58 : 48,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFF4F4F4),
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/icons/$fileName',
                                      width: 24,
                                      height: 24,
                                      color: const Color(0xFFFFCC29),
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return const Icon(
                                          Icons.broken_image,
                                          size: 20,
                                          color: Colors.grey,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                isFocused && words.length > 1
                                    ? Column(
                                      children:
                                          words
                                              .map(
                                                (word) => Text(
                                                  word,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                    fontFamily: 'Objective',
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              )
                                              .toList(),
                                    )
                                    : Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey[800],
                                        fontFamily: 'Objective',
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  itemCount: categories.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.0,
                  ),
                  itemBuilder: (context, index) {
                    final item = categories[index];
                    return _CategoryTile(title: item.title, icon: item.icon);
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  "Security Tips",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Objective',
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 160,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildTipCard(
                        "Keep Doors Locked",
                        "Always lock your car doors while driving or parked.",
                        "assets/images/tip_bg.png",
                      ),
                      _buildTipCard(
                        "Plan your route",
                        "Avoid unfamiliar or high-risk areas.",
                        "assets/images/car.png",
                      ),
                      _buildTipCard(
                        "Stay Alert",
                        "Be aware of your surroundings.",
                        "assets/images/tip_bg.png",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildTipCard(String title, String subtitle, String imagePath) {
    return BounceTap(
      onTap: () {
        debugPrint("Tapped on: $title");
        // Optional: Navigate or show full blog
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color.fromARGB(160, 0, 0, 0), // darker left
                    Color.fromARGB(60, 0, 0, 0), // mid
                    Color.fromARGB(10, 0, 0, 0), // lighter right
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Objective',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Objective',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String title;
  final String icon;

  const _CategoryTile({required this.title, required this.icon});

  void _handleTap(BuildContext context) {
    switch (title) {
      case "Physical Security":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PhysicalSecurityScreen()),
        );
        break;
      case "Secured Mobility":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SecuredMobilityScreen()),
        );
        break;
      case "Outsourcing & Talent Risk":
        Navigator.pushNamed(context, '/outsourcing-talent');
        break;
      case "Digital Security & Privacy Protection":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DigitalSecurityScreen()),
        );
        break;
      case "Concierge Services":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ConciergeServicesScreen()),
        );
        break;
      case "Also By Halogen":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OtherServicesScreen()),
        );
        break;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No page defined for "$title"')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BounceTap(
      onTap: () => _handleTap(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6E6E6)),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F4F4),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    "assets/icons/$icon",
                    width: 12,
                    height: 12,
                    color: const Color(0xFFFFCC29),
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.broken_image,
                        size: 12,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Objective',
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
