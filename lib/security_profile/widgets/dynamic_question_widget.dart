import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question_model.dart';
import '../providers/security_profile_provider.dart';
import '../../shared/widgets/custom_dropdown_field.dart';
import '../../shared/widgets/custom_text_field.dart';

class DynamicQuestionWidget extends StatefulWidget {
  final QuestionModel question;

  const DynamicQuestionWidget({super.key, required this.question});

  @override
  State<DynamicQuestionWidget> createState() => _DynamicQuestionWidgetState();
}

class _DynamicQuestionWidgetState extends State<DynamicQuestionWidget> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    final provider = context.read<SecurityProfileProvider>();
    final existingAnswer = provider.answers[widget.question.id];
    controller = TextEditingController(text: existingAnswer ?? '');
  }

  IconData _getIconForQuestion(String refCode) {
    switch (refCode) {
      case 'SP-PP-TT':
        return Icons.badge;
      case 'SP-PP-MS':
        return Icons.favorite;
      case 'SP-PP-GD':
        return Icons.wc;
      case 'SP-PP-AG':
        return Icons.cake;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SecurityProfileProvider>();
    final icon = _getIconForQuestion(widget.question.refCode);

    final isDropdown = widget.question.type == 'dropdown';
    final dropdownLabels = widget.question.options.map((e) => e.label).toList();

    if (isDropdown) {
      return CustomDropdownField(
        label: widget.question.question,
        icon: icon,
        options: dropdownLabels,
        selectedValue: controller.text.isEmpty ? null : controller.text,
        onChanged: (val) {
          controller.text = val;
          provider.saveAnswer(widget.question.id, val);

          if (widget.question.refCode == 'SP-PP-MS' && val == 'Married') {
            provider.showSpouseProfile = true;
          }
        },
      );
    }

    return CustomTextField(
      label: widget.question.question,
      icon: icon,
      controller: controller,
      onChanged: (val) => provider.saveAnswer(widget.question.id, val),
    );
  }
}