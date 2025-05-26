import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()
      ..addListener(() {
        setState(() {
          _hasFocus = _focusNode.hasFocus;
        });
      });
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
    final hasText = widget.controller.text.trim().isNotEmpty;
    final shouldShowGradient = _hasFocus || hasText;

    final gradientBorder = BoxDecoration(
      gradient: shouldShowGradient
          ? const LinearGradient(
              colors: [Color(0xFF1C2B66), Color(0xFFFFCC29)],
            )
          : const LinearGradient(
              colors: [Colors.grey, Colors.grey],
            ),
      borderRadius: BorderRadius.circular(4),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            children: [
              _buildGradientIcon(widget.icon),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  focusNode: _focusNode,
                  controller: widget.controller,
                  onChanged: (val) {
                    widget.onChanged?.call(val);
                    setState(() {}); // update underline
                  },
                  cursorColor: const Color(0xFF1C2B66),
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(
                    fontFamily: 'Objective',
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    labelText: widget.label,
                    labelStyle: TextStyle(
                      fontFamily: 'Objective',
                      fontWeight: FontWeight.w500,
                      color: _hasFocus
                          ? const Color(0xFF1C2B66)
                          : Colors.grey,
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
        ),
        // Full-width gradient underline
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          height: 2,
          decoration: gradientBorder,
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}