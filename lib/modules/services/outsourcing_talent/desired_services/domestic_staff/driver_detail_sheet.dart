import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/outsourcing_talent_provider.dart';

class DriverDetailSheet extends StatefulWidget {
  const DriverDetailSheet({super.key});

  @override
  State<DriverDetailSheet> createState() => _DriverDetailSheetState();
}

class _DriverDetailSheetState extends State<DriverDetailSheet> {
  String? selectedDriverType;
  int selectedQuantity = 1;

  final driverOptions = ['Standard Driver', 'Executive Driver', 'Spy Driver'];

  @override
  void initState() {
    super.initState();
    final provider = context.read<OutsourcingTalentProvider>();
    final domesticStaff = provider.allSectionDetails['domestic_staff'] ?? {};
    final drivers = domesticStaff['drivers'] ?? {};

    selectedDriverType = drivers['type'];
    selectedQuantity = drivers['quantity'] ?? 1;
  }

  void _save({bool shouldClose = false}) {
    final provider = context.read<OutsourcingTalentProvider>();
    final existing = Map<String, dynamic>.from(
      provider.allSectionDetails['domestic_staff'] ?? {},
    );

    existing['drivers'] = {
      'type': selectedDriverType,
      'quantity': selectedQuantity,
    };

    provider.updateSectionDetails('domestic_staff', existing);

    if (shouldClose) {
      Navigator.pop(context);
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: const [
              Icon(Icons.arrow_back, size: 18),
              Spacer(),
              Text(
                'Driver',
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
          ...driverOptions.map((label) {
            final isSelected = selectedDriverType == label;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Radio<String>(
                value: label,
                groupValue: selectedDriverType,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      selectedDriverType = val;
                    });
                    _save(); // Save without closing
                  }
                },
                activeColor: Colors.black,
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: const TextStyle(fontSize: 14)),
                  if (isSelected)
                    DropdownButton<int>(
                      value: selectedQuantity,
                      underline: const SizedBox(),
                      borderRadius: BorderRadius.circular(8),
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            selectedQuantity = val;
                          });
                          _save(shouldClose: true); // Save and close
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
    );
  }
}