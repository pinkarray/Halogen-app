import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './provider/digital_security_provider.dart';

class SurveillanceBottomSheet extends StatefulWidget {
  const SurveillanceBottomSheet({super.key});

  @override
  State<SurveillanceBottomSheet> createState() => _SurveillanceBottomSheetState();
}

class _SurveillanceBottomSheetState extends State<SurveillanceBottomSheet> {
  bool isChecked = false;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    final data = context.read<DigitalSecurityProvider>()
        .allSectionDetails['surveillance'] ?? {};

    if (data['private_investigators'] != null) {
      isChecked = true;
      quantity = data['private_investigators'];
    }
  }

  void _autoSaveAndClose() {
    final provider = context.read<DigitalSecurityProvider>();

    provider.updateSectionDetails('surveillance', {
      'private_investigators': quantity,
    });

    provider.markSectionComplete('surveillance');
    Navigator.pop(context);
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
          // Header
          Row(
            children: const [
              Icon(Icons.arrow_back, size: 18),
              Spacer(),
              Text(
                'Surveillance',
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

          // List Item
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Checkbox(
              value: isChecked,
              onChanged: (val) {
                setState(() {
                  isChecked = val ?? false;
                });
              },
              activeColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Private investigators',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Objective',
                  ),
                ),
                if (isChecked)
                  DropdownButton<int>(
                    value: quantity,
                    underline: const SizedBox(),
                    borderRadius: BorderRadius.circular(8),
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          quantity = val;
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
          ),
        ],
      ),
    );
  }
}
