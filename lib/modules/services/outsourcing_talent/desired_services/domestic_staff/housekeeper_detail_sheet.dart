import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/outsourcing_talent_provider.dart';

class HousekeeperDetailSheet extends StatefulWidget {
  const HousekeeperDetailSheet({super.key});

  @override
  State<HousekeeperDetailSheet> createState() => _HousekeeperDetailSheetState();
}

class _HousekeeperDetailSheetState extends State<HousekeeperDetailSheet> {
  String? selectedHousekeeperType;
  int selectedQuantity = 1;

  final housekeeperOptions = ['Full-time Housekeeper', 'Part-time Housekeeper'];

  @override
  void initState() {
    super.initState();
    final provider = context.read<OutsourcingTalentProvider>();
    final data = provider.allSectionDetails['domestic_staff']?['housekeepers'] ?? {};

    selectedHousekeeperType = data['type'];
    selectedQuantity = data['quantity'] ?? 1;
  }

  void _save({bool shouldClose = false}) {
    final provider = context.read<OutsourcingTalentProvider>();
    final domestic = Map<String, dynamic>.from(
      provider.allSectionDetails['domestic_staff'] ?? {},
    );

    domestic['housekeepers'] = {
      'type': selectedHousekeeperType,
      'quantity': selectedQuantity,
    };

    provider.updateSectionDetails('domestic_staff', domestic);

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: const [
              Icon(Icons.arrow_back, size: 18),
              Spacer(),
              Text(
                'Housekeepers',
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
          ...housekeeperOptions.map((label) {
            final isSelected = selectedHousekeeperType == label;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Radio<String>(
                value: label,
                groupValue: selectedHousekeeperType,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      selectedHousekeeperType = val;
                    });
                    _save(); // Save and keep open
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
