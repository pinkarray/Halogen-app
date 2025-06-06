import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../modules/services/secured_mobility/providers/secured_mobility_provider.dart';

class VehicleChoiceGroup extends StatefulWidget {
  final String title;
  final String sectionKey;
  final List<Map<String, dynamic>> vehicles;

  const VehicleChoiceGroup({
    super.key,
    required this.title,
    required this.sectionKey,
    required this.vehicles,
  });

  @override
  State<VehicleChoiceGroup> createState() => _VehicleChoiceGroupState();
}

class _VehicleChoiceGroupState extends State<VehicleChoiceGroup> {
  static const Color brandBlue = Color(0xFF1C2B66);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SecuredMobilityProvider>(context);
    final config = provider.serviceConfiguration[widget.sectionKey] ?? {};
    final isEnabled = config['enabled'] ?? false;
    final selectedOption = config['selection'];

    void handleEnabledChange(bool? value) {
      provider.updateServiceConfig(
        widget.sectionKey,
        enabled: value ?? false,
        selection: selectedOption,
      );
    }

    void handleOptionSelect(String value) {
      provider.updateServiceConfig(
        widget.sectionKey,
        enabled: true,
        selection: value,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => handleEnabledChange(!isEnabled),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  isEnabled ? Icons.check_box : Icons.check_box_outline_blank,
                  key: ValueKey(isEnabled),
                  color: isEnabled ? brandBlue : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Objective',
                  color: brandBlue,
                ),
              ),
            ],
          ),
        ),
        if (isEnabled) 
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Available ${widget.title.split(' ')[0].toLowerCase()} in your pickup location',
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Objective',
                color: Colors.black54,
              ),
            ),
          ),
        const SizedBox(height: 12),
        if (isEnabled)
          Column(
            children: widget.vehicles.map((vehicle) {
              final isSelected = selectedOption == vehicle['type'];
              return GestureDetector(
                onTap: () => handleOptionSelect(vehicle['type']),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Vehicle Image
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        child: Image.asset(
                          vehicle['image'],
                          width: 100,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Vehicle Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicle['model'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Objective',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              vehicle['regNumber'],
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Objective',
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              vehicle['color'],
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Objective',
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Selection Indicator
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Icon(
                          isSelected ? Icons.check_circle : Icons.circle_outlined,
                          color: isSelected ? brandBlue : Colors.grey,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}