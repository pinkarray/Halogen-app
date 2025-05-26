import 'package:flutter/material.dart';

class UnderlinedGlowPasswordField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final void Function(String)? onChanged;

  const UnderlinedGlowPasswordField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.onChanged,
  });

  @override
  State<UnderlinedGlowPasswordField> createState() =>
      _UnderlinedGlowPasswordFieldState();
}

class _UnderlinedGlowPasswordFieldState extends State<UnderlinedGlowPasswordField> {
  late FocusNode _focusNode;
  bool _hasFocus = false;
  bool _obscureText = true;

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

  @override
  Widget build(BuildContext context) {
    final gradient = _hasFocus
        ? const LinearGradient(colors: [Color(0xFF1C2B66), Color(0xFFFFCC29)])
        : const LinearGradient(colors: [Colors.grey, Colors.grey]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF1C2B66), Color(0xFFFFCC29)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Icon(widget.icon, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: _obscureText,
                onChanged: widget.onChanged,
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
                    color: _hasFocus ? const Color(0xFF1C2B66) : Colors.grey,
                  ),
                  floatingLabelStyle: const TextStyle(
                    color: Color(0xFF1C2B66),
                    fontWeight: FontWeight.bold,
                  ),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                    icon: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF1C2B66), Color(0xFFFFCC29)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white, // will be filled by gradient
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Container(
          height: 2,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}
