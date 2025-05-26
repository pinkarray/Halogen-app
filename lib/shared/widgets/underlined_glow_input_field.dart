import 'package:flutter/material.dart';

class UnderlinedGlowInputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final void Function(String)? onChanged;
  final List<String>? dropdownOptions;
  final TextCapitalization textCapitalization;

  const UnderlinedGlowInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.onChanged,
    this.dropdownOptions,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<UnderlinedGlowInputField> createState() =>
      _UnderlinedGlowInputFieldState();
}

class _UnderlinedGlowInputFieldState extends State<UnderlinedGlowInputField> {

  late FocusNode _focusNode;
  bool _hasFocus = false;
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()
      ..addListener(() {
        setState(() {
          _hasFocus = _focusNode.hasFocus;
        });
      });

    _selectedValue = widget.controller.text.isNotEmpty ? widget.controller.text : null;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Widget _buildGradientIcon(IconData iconData) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFF1C2B66), Color(0xFFFFCC29)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Icon(iconData, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradientBorder = _hasFocus
        ? const LinearGradient(colors: [Color(0xFF1C2B66), Color(0xFFFFCC29)])
        : const LinearGradient(colors: [Colors.grey, Colors.grey]);

    final isDropdown = widget.dropdownOptions != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildGradientIcon(widget.icon),
            const SizedBox(width: 8),
            Expanded(
              child: isDropdown
                  ? DropdownButtonFormField<String>(
                      value: _selectedValue,
                      focusNode: _focusNode,
                      icon: const SizedBox.shrink(), // Hides default arrow
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: widget.label,
                        labelStyle: TextStyle(
                          fontFamily: 'Objective',
                          fontWeight: FontWeight.w500,
                          color: _hasFocus ? const Color(0xFF1C2B66) : Colors.grey,
                        ),
                        floatingLabelStyle: const TextStyle(
                          color: Color(0xFF1C2B66),
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        suffixIcon: _buildGradientIcon(Icons.keyboard_arrow_down),
                      ),
                      dropdownColor: Colors.white,
                      style: const TextStyle(
                        fontFamily: 'Objective',
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      items: widget.dropdownOptions!
                          .map((option) => DropdownMenuItem<String>(
                                value: option,
                                child: Text(option),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedValue = value;
                        });
                        widget.controller.text = value ?? '';
                        if (widget.onChanged != null) {
                          widget.onChanged!(value ?? '');
                        }
                      },
                    )
                  : TextFormField(
                      focusNode: _focusNode,
                      controller: widget.controller,
                      onChanged: widget.onChanged,
                      cursorColor: const Color(0xFF1C2B66),
                      textCapitalization: widget.textCapitalization,
                      style: const TextStyle(
                        fontFamily: 'Objective',
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        labelText: widget.label,
                        labelStyle: TextStyle(
                          fontFamily: 'Objective',
                          fontWeight: FontWeight.w500,
                          color: _hasFocus ? const Color(0xFF1C2B66) : Colors.grey,
                        ),
                        floatingLabelStyle: const TextStyle(
                          color: Color(0xFF1C2B66),
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
            ),
          ],
        ),
        Container(
          height: 2,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            gradient: gradientBorder,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}