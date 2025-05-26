import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PeopleRiskScreen extends StatelessWidget {
  const PeopleRiskScreen({super.key});

  final List<Map<String, dynamic>> _categories = const [
    {'title': 'Outsourcing', 'icon': Icons.business_center, 'color': Colors.deepPurple},
    {'title': 'Human Capacity Dev.', 'icon': Icons.school, 'color': Colors.orange},
    {'title': 'Background Checks', 'icon': Icons.search, 'color': Colors.red},
    {'title': 'Assessment Services', 'icon': Icons.assessment, 'color': Colors.teal},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF1C2B66)),
        title: Text(
          "People Risk Management",
          style: TextStyle(
            fontFamily: 'Objective',
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C2B66),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: _categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 5 / 2,
          ),
          itemBuilder: (context, index) {
            final category = _categories[index];
            return _buildTile(
              icon: category['icon'],
              label: category['title'],
              iconColor: category['color'],
              delay: 100 * index,
            );
          },
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String label,
    required Color iconColor,
    int delay = 0,
  }) {
    final int adjustedAlpha = (iconColor.a * 0.1).round();

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to sub-category detail screen
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color.fromARGB(
                  adjustedAlpha,
                  iconColor.red,
                  iconColor.green,
                  iconColor.blue,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: iconColor),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Objective',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1C2B66),
                ),
              ),
            ),
          ],
        ),
      ).animate(delay: delay.ms).fade(duration: 500.ms).scale(duration: 400.ms),
    );
  }
}