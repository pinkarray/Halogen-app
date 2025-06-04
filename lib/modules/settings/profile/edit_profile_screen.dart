import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:halogen/shared/helpers/session_manager.dart';
import 'package:halogen/shared/widgets/halogen_back_button.dart';
import 'package:halogen/shared/widgets/underlined_glow_input_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadSavedImageUrl();
  }

  Future<void> _loadUser() async {
    final user = await SessionManager.getUserProfile();
    if (user != null) {
      _nameController.text = user['full_name'] ?? '';
      _emailController.text = user['email'] ?? '';
      _phoneController.text = user['phone_number'] ?? '';
      setState(() {
        _profileImageUrl = user['image']; // If available
      });
    }
  }

  Future<void> _loadSavedImageUrl() async {
    final savedUrl = await SessionManager.getProfileImageUrl();
    if (savedUrl != null && mounted) {
      setState(() {
        _profileImageUrl = savedUrl;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      final Uint8List imageBytes = await pickedFile.readAsBytes();
      final token = await SessionManager.getAuthToken();
      final uri = Uri.parse('http://185.203.216.113:3004/api/v1/profile/upload/image');

      final mimeType = lookupMimeType(pickedFile.path);
      final typeParts = mimeType?.split('/') ?? ['image', 'jpeg'];

      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: pickedFile.name,
          contentType: MediaType(typeParts[0], typeParts[1]),
        ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final relativeUrl = data['data']?['url'];
        final fullUrl = 'http://185.203.216.113:3004/$relativeUrl'.replaceFirst('undefined/', '');

        setState(() {
          _profileImageUrl = fullUrl;
        });

        await SessionManager.saveProfileImageUrl(fullUrl);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Upload successful!')),
        );
        debugPrint('✅ Cleaned Image URL: $_profileImageUrl');
      } else {
        debugPrint('❌ Upload failed: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint('❌ Upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload failed. Please try again.')),
      );
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );

    setState(() => _isLoading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAEA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const HalogenBackButton(),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Objective',
            color: Color(0xFF1C2B66),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickAndUploadImage,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFFEDEDED),
                  backgroundImage: _profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!)
                      : null,
                  child: _profileImageUrl == null
                      ? const Icon(Icons.camera_alt, size: 28, color: Colors.black45)
                      : null,
                ),
              ),
              const SizedBox(height: 24),

              UnderlinedGlowInputField(
                label: 'Full Name',
                icon: Icons.person_outline,
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
              ),

              UnderlinedGlowInputField(
                label: 'Email',
                icon: Icons.email_outlined,
                controller: _emailController,
                textCapitalization: TextCapitalization.none,
              ),

              UnderlinedGlowInputField(
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                controller: _phoneController,
                textCapitalization: TextCapitalization.none,
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C2B66),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontFamily: 'Objective',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
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
