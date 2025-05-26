import 'package:flutter/material.dart';

class DashboardSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final String hintText;

  const DashboardSearchBar({
    super.key,
    this.onChanged,
    this.hintText = "Search for anything",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          icon: const Icon(Icons.search),
        ),
        style: const TextStyle(
          fontFamily: 'Objective',
        ),
      ),
    );
  }
}
