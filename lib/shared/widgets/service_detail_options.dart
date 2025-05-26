import 'package:flutter/material.dart';
import 'bounce_tap.dart';

class ServiceDetailOptions extends StatefulWidget {
  final String serviceTitle;
  final List<Map<String, dynamic>> items;
  final Map<String, Map<String, String>>? initialSelections;
  final Function(String groupTitle, String category, String value)? onOptionSelected;

  const ServiceDetailOptions({
    super.key,
    required this.serviceTitle,
    required this.items,
    this.initialSelections,
    this.onOptionSelected,
  });

  @override
  State<ServiceDetailOptions> createState() => _ServiceDetailOptionsState();
}

class _ServiceDetailOptionsState extends State<ServiceDetailOptions> {
  final Map<String, Map<String, String>> selectedOptions = {};

  @override
  void initState() {
    super.initState();
    for (var item in widget.items) {
      final group = item['title'];
      final subOptions = item['subOptions'] as Map<String, List<String>>;
      selectedOptions[group] = {};

      for (var category in subOptions.keys) {
        selectedOptions[group]![category] =
            widget.initialSelections?[group]?[category] ?? '';
      }
    }
  }

  void updateSelection(String itemTitle, String category, String value) {
    setState(() {
      selectedOptions[itemTitle]![category] = value;
    });
    widget.onOptionSelected?.call(itemTitle, category, value);
  }

  Widget buildRadioRow({
    required String label,
    required String groupValue,
    required VoidCallback onTap,
  }) {
    return BounceTap(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Radio<String>(
            value: label,
            groupValue: groupValue,
            onChanged: (_) => onTap(),
            activeColor: const Color(0xFFFFCC29),
          ),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Objective',
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 377),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          children: widget.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final title = item['title'];
            final subOptions = item['subOptions'] as Map<String, List<String>>;

            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Color(0xFF1C2B66),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Objective',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: 'Objective',
                            color: Color(0xFF1C2B66)
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ...subOptions.entries.map((entry) {
                    final category = entry.key;
                    final options = entry.value;
                    final selected = selectedOptions[title]![category] ?? '';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Objective',
                              color: Color(0xFF1C2B66)
                            ),
                          ),
                          const SizedBox(height: 6),
                          Column(
                            children: options.map((opt) {
                              return buildRadioRow(
                                label: opt,
                                groupValue: selected,
                                onTap: () => updateSelection(title, category, opt),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}