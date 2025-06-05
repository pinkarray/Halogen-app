import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:halogen/shared/widgets/halogen_back_button.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final List<Contact> _emergencyContacts = [];
  List<Contact> _deviceContacts = [];
  bool _isLoading = true;
  bool _hasPermission = false;

  static const _storageKey = 'emergency_contact_ids';

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLoadContacts();
  }

  Future<void> _checkPermissionAndLoadContacts() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      setState(() => _hasPermission = true);
      await _loadContacts();
      await _loadSavedEmergencyContacts();
    } else {
      setState(() {
        _hasPermission = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      setState(() {
        _deviceContacts = contacts.toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading contacts: $e')),
      );
    }
  }

  Future<void> _loadSavedEmergencyContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds = prefs.getStringList(_storageKey) ?? [];

    final restoredContacts = _deviceContacts.where((contact) => savedIds.contains(contact.id)).toList();

    setState(() {
      _emergencyContacts.clear();
      _emergencyContacts.addAll(restoredContacts);
    });
  }

  Future<void> _saveEmergencyContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = _emergencyContacts.map((c) => c.id).toList();
    await prefs.setStringList(_storageKey, ids);
  }

  void _addEmergencyContact(Contact contact) {
    if (_emergencyContacts.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only select up to 5 emergency contacts')),
      );
      return;
    }

    setState(() {
      if (!_emergencyContacts.any((c) => c.id == contact.id)) {
        _emergencyContacts.add(contact);
        _saveEmergencyContacts();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${contact.displayName} added as emergency contact')),
        );
      }
    });
  }

  void _removeEmergencyContact(Contact contact) {
    setState(() {
      _emergencyContacts.removeWhere((c) => c.id == contact.id);
      _saveEmergencyContacts();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${contact.displayName} removed from emergency contacts')),
    );
  }

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
          'Emergency Contacts',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Objective',
            color: Color(0xFF1C2B66),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1C2B66)))
          : !_hasPermission
          ? _buildPermissionDeniedView()
          : _buildContactsView(),
    );
  }

  Widget _buildPermissionDeniedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.no_accounts, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Contact Permission Required',
              style: TextStyle(
                fontFamily: 'Objective',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C2B66),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'We need access to your contacts to set up emergency contacts for SOS alerts.',
              style: TextStyle(
                fontFamily: 'Objective',
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _checkPermissionAndLoadContacts,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C2B66),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Grant Permission', style: TextStyle(fontFamily: 'Objective')),
            ),
          ],
        ).animate().fade().slideY(begin: 0.1),
      ),
    );
  }

  Widget _buildContactsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_emergencyContacts.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Text(
              'Your Emergency Contacts',
              style: const TextStyle(
                fontFamily: 'Objective',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF1C2B66),
              ),
            ).animate().fade(duration: 300.ms),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _emergencyContacts.length,
              itemBuilder: (context, index) {
                final contact = _emergencyContacts[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1C2B66),
                    child: Text(
                      contact.displayName.isNotEmpty == true
                          ? contact.displayName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    contact.displayName,
                    style: const TextStyle(fontFamily: 'Objective'),
                  ),
                  subtitle: Text(
                    contact.phones.isNotEmpty == true
                        ? contact.phones.first.number
                        : 'No phone number',
                    style: const TextStyle(fontFamily: 'Objective', fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    onPressed: () => _removeEmergencyContact(contact),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Text(
            'Add from Contacts',
            style: const TextStyle(
              fontFamily: 'Objective',
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF1C2B66),
            ),
          ).animate().fade(duration: 300.ms),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _deviceContacts.isEmpty
                ? Center(
              child: Text(
                'No contacts found',
                style: TextStyle(fontFamily: 'Objective', color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: _deviceContacts.length,
              itemBuilder: (context, index) {
                final contact = _deviceContacts[index];
                final isAlreadyAdded = _emergencyContacts.any((c) => c.id == contact.id);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1C2B66),
                    child: Text(
                      contact.displayName.isNotEmpty == true
                          ? contact.displayName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    contact.displayName,
                    style: const TextStyle(fontFamily: 'Objective'),
                  ),
                  subtitle: Text(
                    contact.phones.isNotEmpty == true
                        ? contact.phones.first.number
                        : 'No phone number',
                    style: const TextStyle(fontFamily: 'Objective', fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      isAlreadyAdded ? Icons.check_circle : Icons.add_circle_outline,
                      color: isAlreadyAdded ? Colors.green : const Color(0xFF1C2B66),
                    ),
                    onPressed: isAlreadyAdded ? null : () => _addEmergencyContact(contact),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
