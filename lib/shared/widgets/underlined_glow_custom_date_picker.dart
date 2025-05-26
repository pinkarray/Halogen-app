import 'package:flutter/material.dart';

class UnderlinedGlowCustomDatePickerField extends StatefulWidget {
  final String label;
  final DateTime? selectedDate;
  final void Function(DateTime) onConfirm;

  const UnderlinedGlowCustomDatePickerField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onConfirm,
  });

  @override
  State<UnderlinedGlowCustomDatePickerField> createState() =>
      _UnderlinedGlowCustomDatePickerFieldState();
}

class _UnderlinedGlowCustomDatePickerFieldState
    extends State<UnderlinedGlowCustomDatePickerField> {
  late FocusNode _focusNode;
  bool _hasFocus = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode()
      ..addListener(() {
        setState(() => _hasFocus = _focusNode.hasFocus);
      });

    _controller = TextEditingController();

    // Safely set the formatted text after context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.selectedDate != null) {
        _controller.text =
            '${widget.selectedDate!.day}/${widget.selectedDate!.month}/${widget.selectedDate!.year}';
      }
    });
  }

  @override
  void didUpdateWidget(covariant UnderlinedGlowCustomDatePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedDate != oldWidget.selectedDate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.selectedDate != null) {
          _controller.text =
              '${widget.selectedDate!.day}/${widget.selectedDate!.month}/${widget.selectedDate!.year}';
        }
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openDateDialog(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 350),
            child: Material(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              child: child!,
            ),
          ),
        );
      },
    );
    if (picked != null) {
      widget.onConfirm(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _hasFocus
        ? const LinearGradient(colors: [Color(0xFF1C2B66), Color(0xFFFFCC29)])
        : const LinearGradient(colors: [Colors.grey, Colors.grey]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            _focusNode.requestFocus();
            _openDateDialog(context);
          },
          child: Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF1C2B66), Color(0xFFFFCC29)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Icon(Icons.calendar_today_outlined, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  enabled: false,
                  decoration: InputDecoration(
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
                  ),
                ),
              ),
            ],
          ),
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
