import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/outsourcing_talent_provider.dart';
import '../../../shared/widgets/halogen_back_button.dart';
import '../../../shared/widgets/glowing_arrows_button.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DescriptionOfNeedScreen extends StatefulWidget {
  const DescriptionOfNeedScreen({super.key});

  @override
  State<DescriptionOfNeedScreen> createState() => _DescriptionOfNeedScreenState();
}

class _DescriptionOfNeedScreenState extends State<DescriptionOfNeedScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<OutsourcingTalentProvider>();
    final existing = provider.allSectionDetails['description'] ?? {};
    _controller.text = existing['text'] ?? '';
    _isValid = _controller.text.trim().isNotEmpty;

    _controller.addListener(() {
      final valid = _controller.text.trim().isNotEmpty;
      if (valid != _isValid) {
        setState(() {
          _isValid = valid;
        });
      }
    });
  }

  void _saveAndContinue() {
    final provider = context.read<OutsourcingTalentProvider>();

    provider.updateSectionDetails('description', {
      'text': _controller.text.trim(),
    });

    provider.markStage2Completed();

    Navigator.pushNamed(context, '/outsourcing-talent/confirmation');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Color(0xFFFFFAEA)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: HalogenBackButton(),
                  ),
                  const Text(
                    'Description of Need',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Objective',
                      color: Color(0xFF1C2B66), // ✅ Brand blue
                    ),
                  )
                      .animate()
                      .fade(duration: 400.ms)
                      .slideY(begin: 0.2), // ✅ Animation
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Explain your need',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Objective',
                  color: Color(0xFF1C2B66),
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: 'My need is.........',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Objective',
                  ),
                ),
              ),
              const SizedBox(height: 24),

              AnimatedOpacity(
                opacity: _isValid ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 300),
                child: Center(
                  child: GlowingArrowsButton(
                    text: 'Continue',
                    onPressed: _isValid ? _saveAndContinue : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}