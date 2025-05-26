import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './provider/digital_security_provider.dart';

class DigitalProtectionBottomSheet extends StatefulWidget {
  const DigitalProtectionBottomSheet({super.key});

  @override
  State<DigitalProtectionBottomSheet> createState() => _DigitalProtectionBottomSheetState();
}

class _DigitalProtectionBottomSheetState extends State<DigitalProtectionBottomSheet> {
  Map<String, bool> selectedOptions = {
    'access_monitoring': false,
    'intrusion_detection': false,
    'track_trace': false,
  };

  @override
  void initState() {
    super.initState();
    final data = context.read<DigitalSecurityProvider>()
        .allSectionDetails['digital_protection'] ?? {};

    for (final key in selectedOptions.keys) {
      if (data[key] == true) {
        selectedOptions[key] = true;
      }
    }
  }

  void _save() {
    final provider = context.read<DigitalSecurityProvider>();

    final Map<String, dynamic> selected = {};
    selectedOptions.forEach((key, value) {
      if (value) selected[key] = true;
    });

    if (selected.isNotEmpty) {
      provider.updateSectionDetails('digital_protection', selected);
      provider.markSectionComplete('digital_protection');
    } else {
      provider.updateSectionDetails('digital_protection', {});
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
          // Header
          Row(
            children: const [
              Icon(Icons.arrow_back, size: 18),
              Spacer(),
              Text(
                'Digital Protection',
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

          _buildCheckbox('access_monitoring', 'Access monitoring'),
          _buildCheckbox('intrusion_detection', 'Intrusion detection'),
          _buildCheckbox('track_trace', 'Track & trace'),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String key, String label) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Checkbox(
        value: selectedOptions[key],
        onChanged: (val) {
          setState(() {
            selectedOptions[key] = val ?? false;
          });
          _save(); // auto-save
        },
        activeColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      title: Text(
        label,
        style: const TextStyle(fontSize: 14, fontFamily: 'Objective'),
      ),
    );
  }
}