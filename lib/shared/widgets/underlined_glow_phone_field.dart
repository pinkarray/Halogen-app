import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UnderlinedGlowPhoneField extends StatefulWidget {
  final String selectedCountryCode;
  final ValueChanged<String?> onCountryCodeChanged;
  final TextEditingController phoneController;
  final ValueChanged<String>? onChanged;

  const UnderlinedGlowPhoneField({
    super.key,
    required this.selectedCountryCode,
    required this.onCountryCodeChanged,
    required this.phoneController,
    this.onChanged,
  });

  @override
  State<UnderlinedGlowPhoneField> createState() => _UnderlinedGlowPhoneFieldState();
}

class _UnderlinedGlowPhoneFieldState extends State<UnderlinedGlowPhoneField> {
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()
      ..addListener(() {
        setState(() => _hasFocus = _focusNode.hasFocus);
      });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String getPhonePlaceholder(String code) {
    switch (code) {
      case '+234':
        return 'e.g. 8123456789';
      case '+1':
        return 'e.g. 4155552671';
      case '+44':
        return 'e.g. 7123456789';
      case '+91':
        return 'e.g. 9876543210';
      default:
        return 'Enter number';
    }
  }

  int getRequiredLength(String code) {
    switch (code) {
      case '+234':
      case '+1':
      case '+44':
      case '+91':
        return 10;
      default:
        return 6;
    }
  }

  void _handleNumberChanged(String input) {
    String trimmed = input.trim();
    final requiredLength = getRequiredLength(widget.selectedCountryCode);

    // Auto-prepend 0 for Nigerian numbers if not already present
    if (widget.selectedCountryCode == '+234' &&
        trimmed.isNotEmpty &&
        !trimmed.startsWith('0')) {
      trimmed = '0$trimmed';
      widget.phoneController.value = TextEditingValue(
        text: trimmed,
        selection: TextSelection.collapsed(offset: trimmed.length),
      );
    }

    if (trimmed.length > requiredLength + 1) {
      trimmed = trimmed.substring(0, requiredLength + 1);
    }

    if (widget.onChanged != null) widget.onChanged!(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      colors: [Color(0xFF1C2B66), Color(0xFFFFCC29)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final placeholder = getPhonePlaceholder(widget.selectedCountryCode);
    final requiredLength = getRequiredLength(widget.selectedCountryCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Country Code Dropdown
            Expanded(
              flex: 1,
              child: Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: const InputDecorationTheme(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  value: widget.selectedCountryCode,
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF1C2B66)),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Objective',
                    color: Colors.black,
                  ),
                  items: ["+234", "+1", "+44", "+91"].map((code) {
                    return DropdownMenuItem(
                      value: code,
                      child: ShaderMask(
                        shaderCallback: (bounds) => gradient.createShader(bounds),
                        child: Text(
                          code,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Objective',
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: widget.onCountryCodeChanged,
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Phone Number Input
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => gradient.createShader(bounds),
                        child: const Icon(Icons.phone, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          focusNode: _focusNode,
                          controller: widget.phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(requiredLength + 1),
                          ],
                          onChanged: _handleNumberChanged,
                          cursorColor: const Color(0xFF1C2B66),
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Objective',
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: placeholder,
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Objective',
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            labelText: "Phone Number",
                            labelStyle: TextStyle(
                              fontFamily: 'Objective',
                              color: _hasFocus ? const Color(0xFF1C2B66) : Colors.grey,
                            ),
                            floatingLabelStyle: const TextStyle(
                              color: Color(0xFF1C2B66),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(top: 4),
          height: 2,
          decoration: BoxDecoration(
            gradient: _hasFocus
                ? gradient
                : const LinearGradient(colors: [Colors.grey, Colors.grey]),
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        const SizedBox(height: 18),
      ],
    );
  }
}
