import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question_model.dart';
import '../providers/security_profile_provider.dart';
import '../../shared/widgets/custom_dropdown_field.dart';
import '../../shared/widgets/custom_text_field.dart';

class DynamicQuestionWidget extends StatefulWidget {
  final QuestionModel question;
  final int? instanceIndex;
  final void Function()? onCompleted;

  const DynamicQuestionWidget({
    super.key,
    required this.question,
    this.instanceIndex,
    this.onCompleted,
  });

  @override
  State<DynamicQuestionWidget> createState() => _DynamicQuestionWidgetState();
}

class _DynamicQuestionWidgetState extends State<DynamicQuestionWidget> {
  late TextEditingController controller;

  String getAnswerKey() {
    return widget.instanceIndex != null
        ? '${widget.question.id}-${widget.instanceIndex}'
        : widget.question.id;
  }

  @override
  void initState() {
    super.initState();
    final provider = context.read<SecurityProfileProvider>();
    final existingAnswer = provider.answers[getAnswerKey()];
    controller = TextEditingController(text: existingAnswer ?? '');
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DynamicQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final provider = context.read<SecurityProfileProvider>();
    final latestAnswer = provider.answers[getAnswerKey()];
    if (controller.text != latestAnswer) {
      controller.text = latestAnswer ?? '';
    }
  }

  IconData _getIconForQuestion(String refCode) {
    switch (refCode.toUpperCase()) {
      case 'SP-PP-TT':
        return Icons.badge;
      case 'SP-PP-MS':
        return Icons.favorite;
      case 'SP-PP-GD':
        return Icons.wc;
      case 'SP-PP-AG':
        return Icons.cake;
      case 'SP-PP-CC':
      case 'SP-PP-CC-NN':
        return Icons.family_restroom;
      case 'SP-PP-FN':
      case 'SP-PP-LN':
        return Icons.person;
      case 'SP-PP-CC-NN-AR':
        return Icons.cake;
      case 'SP-PP-CC-NN-SI':
        return Icons.school;
      case 'SP-PP-CC-NN-SI-SS':
        return Icons.map;
      case 'SP-PP-CC-NN-SI-LGA':
        return Icons.location_city;
      case 'SP-PP-CC-NN-SI-AR':
        return Icons.place;
      case 'SP-SS-TT':
        return Icons.badge;
      case 'SP-SS-FN':
      case 'SP-SS-LN':
        return Icons.person;
      case 'SP-SS-GD':
        return Icons.wc;
      case 'SP-SS-AR':
        return Icons.cake;
      case 'SP-HA-HN':
        return Icons.home;
      case 'SP-HA-SN1':
      case 'SP-HA-SN2':
        return Icons.signpost;
      case 'SP-HA-ST':
        return Icons.map;
      case 'SP-HA-LGA':
        return Icons.location_city;
      case 'SP-HA-AREA':
        return Icons.place;
      case 'SP-TOR-TOH':
        return Icons.house;
      case 'SP-TOR-GEOS':
        return Icons.security;
      case 'SP-OCP-OCC':
        return Icons.work;
      case 'SP-OCP-OCC-IN':
        return Icons.business;
      case 'SP-OCP-OCC-OL':
        return Icons.location_city;
      case 'SP-OCP-OCC-MOT':
        return Icons.directions_car;
      case 'SP-OCP-OCC-OL-ST':
        return Icons.map;
      case 'SP-OCP-OCC-OL-LGA':
        return Icons.location_city;
      case 'SP-OCP-OCC-OL-AR':
        return Icons.place;
      case 'SP-OCS-OCC':
        return Icons.work;
      case 'SP-OCS-OCC-I':
        return Icons.business;
      case 'SP-OCS-OCC-OL':
        return Icons.location_city;
      case 'SP-OCS-OCC-MOT':
        return Icons.directions_car;
      case 'SP-OCS-OCC-ST':
        return Icons.map;
      case 'SP-OCS-OCC-LGA':
        return Icons.location_city;
      case 'SP-OCS-OCC-AR':
        return Icons.place;
      case 'SP-DS-ND': 
        return Icons.drive_eta; 
      case 'SP-DS-ND-D': 
        return Icons.person;  
      case 'SP-DS-NN': 
        return Icons.child_friendly; 
      case 'SP-DS-NN-N': 
        return Icons.baby_changing_station; 
      case 'SP-DS-CS': 
        return Icons.restaurant; 
      case 'SP-DS-CS-NCS': 
        return Icons.kitchen;
      case 'SP-DS-NG': 
        return Icons.security; 
      case 'SP-DS-NG-AM': 
        return Icons.shield;
      case 'SP-DS-NG-LD': 
        return Icons.hotel; 
      case 'SP-DS-NG-U': 
        return Icons.badge; 
      case 'SP-SOP-CMN':
      case 'SP-SOS-CMN':
        return Icons.account_balance;
      case 'SP-SOP-NLP':
      case 'SP-SOS-NLS':
        return Icons.nightlife;
      case 'SP-SOP-ISTP':
      case 'SP-SOS-ISTP':
        return Icons.directions_bus;
      case 'SP-OTH-PP':
        return Icons.man;
      case 'SP-OTH-PP-AG':
        return Icons.timeline;
      case 'SP-OTH-PP-ST':
        return Icons.map;
      case 'SP-OTH-PP-LGA':
        return Icons.location_city;
      case 'SP-OTH-PP-AR':
        return Icons.place;

      case 'SP-OTH-PM':
        return Icons.woman;
      case 'SP-OTH-PM-AG':
        return Icons.timeline;
      case 'SP-OTH-PM-AA':
        return Icons.place;
      case 'SP-OTH-PM-LGA':
        return Icons.location_city;
      case 'SP-OTH-PM-ST':
        return Icons.map;
      case 'SP-OTH-PM-AR':
        return Icons.place;

      case 'SP-OTH-S-F':
        return Icons.man_2;
      case 'SP-OTH-S-F-AG':
        return Icons.timeline;
      case 'SP-OTH-S-F-ST':
        return Icons.map;
      case 'SP-OTH-S-F-LGA':
        return Icons.location_city;
      case 'SP-OTH-S-F-AA':
        return Icons.place;

      case 'SP-OTH-S-M':
        return Icons.woman_2;
      case 'SP-OTH-S-M-AG':
        return Icons.timeline;
      case 'SP-OTH-S-M-ST':
        return Icons.map;
      case 'SP-OTH-S-M-LGA':
        return Icons.location_city;
      case 'SP-OTH-S-M-AA':
        return Icons.place;

      default:
        return Icons.help_outline;
    }
  }

  bool _shouldRender(BuildContext context) {
    final provider = context.read<SecurityProfileProvider>();
    final allQuestions = provider.allQuestions;
    final answers = provider.answers;

    final baseCode = widget.question.baseCode;
    if (baseCode.isEmpty) return true;

    final parent = allQuestions.firstWhere(
      (q) => q.refCode == baseCode,
      orElse: () => QuestionModel.empty(),
    );
    if (parent.id.isEmpty) return true;

    final parentKey = widget.instanceIndex != null
        ? '${parent.id}-${widget.instanceIndex}'
        : parent.id;

    final parentAnswer = answers[parentKey]?.toString().toLowerCase();
    print('[PARENT CHECK] ${widget.question.refCode} → baseCode: $baseCode → parentAnswer: $parentAnswer');

    // Apply special boarding logic ONLY for child questions
    final isChildSchoolQuestion = widget.question.refCode.startsWith('SP-PP-CC-NN-SI') ||
        widget.question.refCode.startsWith('SP-PP-CC-NN-SI-');

    if (isChildSchoolQuestion) {
      final schoolTypeQuestion = allQuestions.firstWhere(
        (q) => q.refCode == 'SP-PP-CC-NN-SI',
        orElse: () => QuestionModel.empty(),
      );

      final schoolTypeKey = widget.instanceIndex != null
          ? '${schoolTypeQuestion.id}-${widget.instanceIndex}'
          : schoolTypeQuestion.id;

      final schoolTypeAnswer = answers[schoolTypeKey]?.toString().toLowerCase();
      print('[CONDITIONAL CHECK] ${widget.question.refCode}: instanceIndex=${widget.instanceIndex}, schoolTypeKey=$schoolTypeKey, schoolTypeAnswer=$schoolTypeAnswer');

      return schoolTypeAnswer == 'boarding' || schoolTypeAnswer == 'day';
    }

    return parentAnswer != null && parentAnswer.isNotEmpty && parentAnswer != 'no';
  }


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SecurityProfileProvider>();

    final shouldShow = _shouldRender(context);
    print('[DEBUG] Rendering ${widget.question.refCode}, visible: $shouldShow');

    if (!shouldShow) {
      return const SizedBox.shrink();
    }

    final icon = _getIconForQuestion(widget.question.refCode);
    final isDropdown = widget.question.type == 'dropdown';
    final dropdownLabels = widget.question.options.map((e) => e.label).toList();

    final isSpouseQuestion = widget.question.refCode.startsWith('SP-SS-') ||
                         widget.question.refCode.startsWith('SP-OCS') ||
                         widget.question.refCode.startsWith('SP-SOS') ||
                         widget.question.refCode.startsWith('SP-OTH-S');

    final labelSuffix = widget.instanceIndex != null &&
            !widget.question.refCode.contains('SP-DS-NG') // exclude gatemen
        ? ' (Child ${widget.instanceIndex! + 1})'
        : isSpouseQuestion ? ' (Spouse)' : '';


    if (isDropdown) {
      return CustomDropdownField(
        label: widget.question.question + labelSuffix,
        icon: icon,
        options: dropdownLabels,
        selectedValue: controller.text.isEmpty ? null : controller.text,
        onChanged: (val) {
          if (controller.text != val) {
            controller.text = val;
            provider.saveAnswer(getAnswerKey(), val);
            widget.onCompleted?.call();
          }
          print('[DROPDOWN] Saved ${getAnswerKey()} = $val');


          if (widget.question.refCode == 'SP-PP-MS') {
            provider.showSpouseProfile = val == 'Married';
          }
        },
      );
    }

    return CustomTextField(
      label: widget.question.question + labelSuffix,
      icon: icon,
      controller: controller,
      onChanged: (val) {
        controller.text = val;
        provider.saveAnswer(getAnswerKey(), val);
        print('[INPUT] Saved ${getAnswerKey()} = $val');
        Future.microtask(() {
          widget.onCompleted?.call();
        });
      },
    );
  }
}