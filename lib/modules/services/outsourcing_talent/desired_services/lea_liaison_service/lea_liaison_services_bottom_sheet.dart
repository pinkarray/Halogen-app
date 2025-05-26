import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/outsourcing_talent_provider.dart';

class LeaLiaisonServicesBottomSheet extends StatefulWidget {
  const LeaLiaisonServicesBottomSheet({super.key});

  @override
  State<LeaLiaisonServicesBottomSheet> createState() => _LeaLiaisonServicesBottomSheetState();
}

class _LeaLiaisonServicesBottomSheetState extends State<LeaLiaisonServicesBottomSheet> {
  Map<String, bool> selectedOptions = {
    'police_liaison': false,
    'state_local_law_enforcement': false,
    'traffic': false,
  };

  Map<String, int> optionQuantities = {
    'police_liaison': 1,
    'state_local_law_enforcement': 1,
    'traffic': 1,
  };

  @override
  void initState() {
    super.initState();
    final data = context.read<OutsourcingTalentProvider>().allSectionDetails['lea_liaison'] ?? {};
    for (final key in selectedOptions.keys) {
      if (data[key] != null) {
        selectedOptions[key] = true;
        optionQuantities[key] = data[key];
      }
    }
  }

  void _autoSaveAndClose() {
    final provider = context.read<OutsourcingTalentProvider>();
    final Map<String, dynamic> leaLiaison = {};

    selectedOptions.forEach((key, isSelected) {
      if (isSelected) {
        leaLiaison[key] = optionQuantities[key];
      }
    });

    if (leaLiaison.isNotEmpty) {
      provider.updateSectionDetails('lea_liaison', {
        ...leaLiaison,
        'completed': true,
      });
      provider.markSectionComplete('lea_liaison');
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one option.')),
      );
    }
  }

  String _formatLabel(String key) {
    return key
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
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
                  'LEA Liaison Services',
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
              final label = _formatLabel(key);
              final selected = selectedOptions[key] ?? false;
              final quantity = optionQuantities[key] ?? 1;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: selected,
                      onChanged: (val) {
                        setState(() {
                          selectedOptions[key] = val ?? false;
                        });
                      },
                      activeColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Objective',
                        ),
                      ),
                    ),
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