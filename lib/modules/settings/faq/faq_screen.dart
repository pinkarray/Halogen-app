import 'package:flutter/material.dart';
import 'package:halogen/shared/widgets/halogen_back_button.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  final List<Map<String, String>> faqs = const [
    {
      'question': 'How do I request a security service?',
      'answer': 'Go to the Services tab, select a category, and follow the steps to submit your request.'
    },
    {
      'question': 'Can I schedule services in advance?',
      'answer': 'Yes. When booking a service, you can pick a future date and time that suits your needs.'
    },
    {
      'question': 'How do I add emergency contacts?',
      'answer': 'Navigate to your Profile and tap on Emergency Contacts to add and manage trusted people.'
    },
    {
      'question': 'Is my data secure?',
      'answer': 'Yes, all data is encrypted and we follow best security practices to protect user information.'
    },
    {
      'question': 'How do I reach support?',
      'answer': 'Tap on Support in Settings to send an email or get live assistance during business hours.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAEA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const HalogenBackButton(),
        centerTitle: true,
        title: const Text(
          'FAQ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Objective',
            color: Color(0xFF1C2B66),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return _buildAccordionItem(faq['question']!, faq['answer']!);
        },
      ),
    );
  }

  Widget _buildAccordionItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: const Color(0xFF1C2B66),
          collapsedIconColor: const Color(0xFF1C2B66),
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: 'Objective',
              color: Color(0xFF1C2B66),
            ),
          ),
          children: [
            Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Objective',
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}