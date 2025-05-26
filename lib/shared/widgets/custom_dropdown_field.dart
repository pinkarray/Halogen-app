import 'package:flutter/material.dart';

class CustomDropdownField extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String> onChanged;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.icon,
    required this.options,
    required this.onChanged,
    this.selectedValue,
  });

  @override
  State<CustomDropdownField> createState() => _CustomDropdownFieldState();
}

class _CustomDropdownFieldState extends State<CustomDropdownField> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    } else {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 6,
        width: size.width * 0.9,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 6),
          child: Material(
            elevation: 6,
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: widget.options.map((option) {
                return ListTile(
                  title: Text(option),
                  onTap: () {
                    widget.onChanged(option);
                    _toggleDropdown();
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showGradient = _isDropdownOpen || (widget.selectedValue?.isNotEmpty ?? false);

    final underline = Container(
      height: 2,
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        gradient: showGradient
            ? const LinearGradient(
                colors: [Color(0xFF1C2B66), Color(0xFFFFCC29)],
              )
            : const LinearGradient(
                colors: [Colors.grey, Colors.grey],
              ),
        borderRadius: BorderRadius.circular(4),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            onTap: _toggleDropdown,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Row(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF1C2B66), Color(0xFFFFCC29)],
                    ).createShader(bounds),
                    child: Icon(widget.icon, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.selectedValue ?? widget.label,
                      style: TextStyle(
                        fontFamily: 'Objective',
                        fontSize: 14,
                        color: widget.selectedValue == null
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF1C2B66), Color(0xFFFFCC29)],
                    ).createShader(bounds),
                    child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
        underline,
        const SizedBox(height: 18),
      ],
    );
  }
}