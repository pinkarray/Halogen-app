import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:halogen/shared/widgets/underlined_glow_input_field.dart';
import 'package:halogen/providers/service_provider.dart';

class DashboardSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final TextEditingController controller;
  final String hintText;

  const DashboardSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.hintText = "Search for anything",
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ServiceProvider>(context);
    final filtered = provider.filteredServices;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UnderlinedGlowInputField(
          label: hintText,
          icon: Icons.search,
          controller: controller,
          onChanged: (value) {
            provider.updateSearch(value);
            if (onChanged != null) onChanged!(value);
          },
        ),
        const SizedBox(height: 8),
        if (filtered.isNotEmpty && controller.text.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final service = filtered[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    service['title'],
                    style: const TextStyle(fontFamily: 'Objective'),
                  ),
                  onTap: () {
                    provider.clearSearch();
                    controller.clear();
                    FocusScope.of(context).unfocus();
                    Navigator.pushNamed(context, service['route']);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
