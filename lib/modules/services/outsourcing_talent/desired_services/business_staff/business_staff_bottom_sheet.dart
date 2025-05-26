import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/outsourcing_talent_provider.dart';
import 'front_desk_officer_detail_sheet.dart';
import 'direct_sales_agent_detail_sheet.dart';
import 'office_administrator_detail_sheet.dart';
import 'janitor_detail_sheet.dart';

class BusinessStaffBottomSheet extends StatelessWidget {
  const BusinessStaffBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OutsourcingTalentProvider>();
    final businessStaff = provider.allSectionDetails['business_staff'] ?? {};

    final items = [
      {'label': 'Front Desk Officers', 'key': 'front_desk_officer'},
      {'label': 'Direct Sales Agent', 'key': 'direct_sales_agent'},
      {'label': 'Office Administrator', 'key': 'office_administrator'},
      {'label': 'Janitor', 'key': 'janitor'},
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, size: 20),
              ),
              const Spacer(),
              const Text(
                'Business Staff',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Objective',
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
          const SizedBox(height: 24),
          ...items.map((item) {
            final roleData = businessStaff[item['key']] ?? {};
            final hasMale = roleData['male'] != null;
            final hasFemale = roleData['female'] != null;

            final hasSelection = hasMale || hasFemale;
            final totalQuantity = (roleData['male'] ?? 0) + (roleData['female'] ?? 0);

            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                item['label']!,
                style: const TextStyle(fontSize: 14, fontFamily: 'Objective'),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasSelection)
                    const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  if (totalQuantity > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDEDED),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$totalQuantity',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_right_rounded, size: 22),
                    onPressed: () => _openDetail(context, item['label']!),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context, String label) {
    Widget sheet;

    if (label == 'Front Desk Officers') {
      sheet = const FrontDeskOfficerDetailSheet();
    } else if (label == 'Direct Sales Agent') {
      sheet = const DirectSalesAgentDetailSheet();
    } else if (label == 'Office Administrator') {
      sheet = const OfficeAdministratorDetailSheet();
    } else if (label == 'Janitor') {
      sheet = const JanitorDetailSheet();
    } else {
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => sheet,
    );
  }
}
