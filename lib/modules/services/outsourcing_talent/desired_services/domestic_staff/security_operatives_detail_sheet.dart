import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/outsourcing_talent_provider.dart';

class SecurityOperativesDetailSheet extends StatefulWidget {
  const SecurityOperativesDetailSheet({super.key});

  @override
  State<SecurityOperativesDetailSheet> createState() => _SecurityOperativesDetailSheetState();
}

class _SecurityOperativesDetailSheetState extends State<SecurityOperativesDetailSheet> {
  final unarmedOptions = ['Standard', 'Supervisor'];
  List<String> selectedUnarmed = [];
  Map<String, int> unarmedQuantities = {};

  final armedOptions = ['12 hours', '24 hours'];
  String? selectedArmedShift;

  @override
  void initState() {
    super.initState();

    final provider = context.read<OutsourcingTalentProvider>();
    final domestic = provider.allSectionDetails['domestic_staff'] ?? {};
    final data = domestic['security_operatives'] ?? {};

    if (data['unarmed'] != null) {
      final unarmed = Map<String, dynamic>.from(data['unarmed']);
      selectedUnarmed = unarmed.keys.toList();
      for (final role in selectedUnarmed) {
        unarmedQuantities[role] = unarmed[role];
      }
    }

    selectedArmedShift = data['armed'];
  }

  void _save({bool shouldClose = false}) {
    final provider = context.read<OutsourcingTalentProvider>();
    final domesticStaff = Map<String, dynamic>.from(
      provider.allSectionDetails['domestic_staff'] ?? {},
    );

    final securityData = {};

    if (selectedUnarmed.isNotEmpty) {
      final unarmedMap = {
        for (var role in selectedUnarmed) role: unarmedQuantities[role] ?? 1,
      };
      securityData['unarmed'] = unarmedMap;
    }

    if (selectedArmedShift != null) {
      securityData['armed'] = selectedArmedShift;
    }

    domesticStaff['security_operatives'] = securityData;
    provider.updateSectionDetails('domestic_staff', domesticStaff);

    if (shouldClose) Navigator.pop(context);
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
                  'Security Operatives',
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

            /// Unarmed Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Unarmed',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Objective',
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...unarmedOptions.map((role) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Checkbox(
                    value: selectedUnarmed.contains(role),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          selectedUnarmed.add(role);
                          unarmedQuantities[role] = 1;
                        } else {
                          selectedUnarmed.remove(role);
                          unarmedQuantities.remove(role);
                        }
                      });
                      _save(); // Save only, don’t close
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    activeColor: Colors.black,
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(role, style: const TextStyle(fontSize: 14)),
                      if (selectedUnarmed.contains(role))
                        DropdownButton<int>(
                          value: unarmedQuantities[role],
                          underline: const SizedBox(),
                          borderRadius: BorderRadius.circular(8),
                          style: const TextStyle(fontSize: 14, color: Colors.black),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                unarmedQuantities[role] = val;
                              });
                              _save(); // Save only, don’t close
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
                )),
            const SizedBox(height: 24),

            /// Armed Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Armed',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Objective',
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...armedOptions.map((option) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Radio<String>(
                    value: option,
                    groupValue: selectedArmedShift,
                    onChanged: (val) {
                      setState(() {
                        selectedArmedShift = val;
                      });
                      _save(shouldClose: true); // Save and close
                    },
                    activeColor: Colors.black,
                  ),
                  title: Text(option, style: const TextStyle(fontSize: 14)),
                )),
          ],
        ),
      ),
    );
  }
}