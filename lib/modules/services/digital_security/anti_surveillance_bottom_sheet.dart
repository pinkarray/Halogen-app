import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './provider/digital_security_provider.dart';

class AntiSurveillanceBottomSheet extends StatefulWidget {
  const AntiSurveillanceBottomSheet({super.key});

  @override
  State<AntiSurveillanceBottomSheet> createState() => _AntiSurveillanceBottomSheetState();
}

class _AntiSurveillanceBottomSheetState extends State<AntiSurveillanceBottomSheet> {
  Map<String, bool> selectedOptions = {
    'debug_device': false,
    'protect_device': false,
    'surveillance_proof_devices': false,
    'vapt': false,
    'monitoring_reporting': false,
  };

  @override
  void initState() {
    super.initState();
    final data = context.read<DigitalSecurityProvider>()
        .allSectionDetails['anti_surveillance'] ?? {};

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
      provider.updateSectionDetails('anti_surveillance', selected);
      provider.markSectionComplete('anti_surveillance');
    } else {
      provider.updateSectionDetails('anti_surveillance', {});
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: const [
                Icon(Icons.arrow_back, size: 18),
                Spacer(),
                Text(
                  'Anti-surveillance',
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

            const Text(
              'Mobile devices',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Objective',
              ),
            ),
            const SizedBox(height: 8),
            _buildCheckbox('debug_device', 'Debug a device'),
            _buildCheckbox('protect_device', 'Protect a device'),
            _buildCheckbox('surveillance_proof_devices', 'Surveillance proof devices'),

            const SizedBox(height: 20),
            const Text(
              'LAN',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Objective',
              ),
            ),
            const SizedBox(height: 8),
            _buildCheckbox('vapt', 'VAPT'),
            _buildCheckbox('monitoring_reporting', 'Monitoring & reporting'),
          ],
        ),
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
          _save(); // auto-save on toggle
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
