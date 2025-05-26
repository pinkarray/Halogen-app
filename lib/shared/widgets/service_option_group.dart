import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../modules/services/secured_mobility/providers/secured_mobility_provider.dart';

class ServiceOptionGroup extends StatefulWidget {
  final String title;
  final String sectionKey;
  final List<String> options;

  const ServiceOptionGroup({
    super.key,
    required this.title,
    required this.sectionKey,
    required this.options,
  });

  @override
  State<ServiceOptionGroup> createState() => _ServiceOptionGroupState();
}

class _ServiceOptionGroupState extends State<ServiceOptionGroup> {
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
                  color: isEnabled ? Colors.black : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Objective',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (isEnabled)
          Column(
            children: widget.options.map((option) {
              final isSelected = selectedOption == option;
              return GestureDetector(
                onTap: () => handleOptionSelect(option),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Icon(
                          isSelected ? Icons.check_circle : Icons.radio_button_off,
                          key: ValueKey(isSelected),
                          color: isSelected ? Colors.black : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Objective',
                            color: isSelected ? Colors.black : Colors.grey.shade700,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
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