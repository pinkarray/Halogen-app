import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/outsourcing_talent_provider.dart';

class InvestigationBottomSheet extends StatefulWidget {
  const InvestigationBottomSheet({super.key});

  @override
  State<InvestigationBottomSheet> createState() => _InvestigationBottomSheetState();
}

class _InvestigationBottomSheetState extends State<InvestigationBottomSheet> {
  Map<String, bool> selectedOptions = {
    'polygraph_services': false,
    'private_investigator': false,
    'process_risk_assessment': false,
  };

  Map<String, int> optionQuantities = {
    'polygraph_services': 1,
    'private_investigator': 1,
    'process_risk_assessment': 1,
  };

  @override
  void initState() {
    super.initState();
    final data = context.read<OutsourcingTalentProvider>()
        .allSectionDetails['investigation'] ?? {};

    for (final key in selectedOptions.keys) {
      if (data[key] != null) {
        selectedOptions[key] = true;
        optionQuantities[key] = data[key];
      }
    }
  }

  void _autoSaveAndClose() {
    final provider = context.read<OutsourcingTalentProvider>();
    final Map<String, dynamic> investigation = {};

    selectedOptions.forEach((key, isSelected) {
      if (isSelected) {
        investigation[key] = optionQuantities[key];
      }
    });

    if (investigation.isNotEmpty) {
      provider.updateSectionDetails('investigation', {
        ...investigation,
        'completed': true,
      });

      provider.markSectionComplete('investigation');
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one option.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: const [
                Icon(Icons.arrow_back, size: 18),
                Spacer(),
                Text(
                  'Investigation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Objective',
                  ),
                ),
                Spacer(),
              ],
            ),
            const SizedBox(height: 24),

            ...selectedOptions.keys.map((key) {
              final label = key.replaceAll('_', ' ').toUpperCase();
              final selected = selectedOptions[key] ?? false;
              final quantity = optionQuantities[key] ?? 1;

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Checkbox(
                  value: selected,
                  onChanged: (val) {
                    setState(() {
                      selectedOptions[key] = val ?? false;
                    });
                  },
                  activeColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 14)),
                    if (selected)
                      DropdownButton<int>(
                        value: quantity,
                        borderRadius: BorderRadius.circular(8),
                        style: const TextStyle(fontSize: 14, color: Colors.black),
                        underline: const SizedBox(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              optionQuantities[key] = val;
                            });
                            _autoSaveAndClose();
                          }
                        },
                        items: [1, 2, 3]
                            .map((num) => DropdownMenuItem<int>(
                                  value: num,
                                  child: Text('$num'),
                                ))
                            .toList(),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
