import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'dart:io';

class UserProfilePage extends StatefulWidget {
  final String email;

  const UserProfilePage({super.key, required this.email});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String? _userName;
  String? _fssaiNo;
  String? _termsAndConditions;
  final TextEditingController _fssaiController = TextEditingController();
  final TextEditingController _termsController = TextEditingController();
  bool _isEditingFSSAI = false;
  bool _isEditingTerms = false;

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
    _loadUserData();
  }

  @override
  void dispose() {
    _fssaiController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.email)
          .get();

      if (userDoc.exists) {
        setState(() {
          _userName = userDoc.get('name') as String;
          _fssaiNo = userDoc.get('FSSAI') as String?;
          _termsAndConditions = userDoc.get('TermsAndConditions') as String?;
          if (_fssaiNo != null) {
            _fssaiController.text = _fssaiNo!;
          }
          if (_termsAndConditions != null) {
            _termsController.text = _termsAndConditions!;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load user data')),
      );
    }
  }

  Future<void> _updateFSSAI() async {
    try {
      final String newFSSAI = _fssaiController.text.trim();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.email)
          .update({'FSSAI': newFSSAI});

      setState(() {
        _fssaiNo = newFSSAI;
        _isEditingFSSAI = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('FSSAI number updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update FSSAI number')),
      );
    }
  }

  Future<void> _updateTerms() async {
    try {
      final String newTerms = _termsController.text.trim();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.email)
          .update({'TermsAndConditions': newTerms});

      setState(() {
        _termsAndConditions = newTerms;
        _isEditingTerms = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Terms and Conditions updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update Terms and Conditions')),
      );
    }
  }

  Future<void> _loadProfilePicture() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString('${widget.email}_profile_picture');

      if (imagePath != null && File(imagePath).existsSync()) {
        setState(() {
          _imageFile = File(imagePath);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load profile picture')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            '${widget.email}_profile_picture', pickedFile.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick image')),
      );
    }
  }

  Widget _buildFSSAISection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FSSAI Number',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontFamily: 'SFPro',
          ),
        ),
        const SizedBox(height: 8),
        if (_isEditingFSSAI)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _fssaiController,
                  decoration: const InputDecoration(
                    hintText: 'Enter FSSAI Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.check, color: Color(0xFF52ed28)),
                onPressed: _updateFSSAI,
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _isEditingFSSAI = false;
                    _fssaiController.text = _fssaiNo ?? '';
                  });
                },
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: Text(
                  _fssaiNo ?? 'Not set',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'SFPro',
                    fontWeight: FontWeight.w500,
                    color: _fssaiNo == null ? Colors.grey : Colors.black,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF52ed28)),
                onPressed: () {
                  setState(() {
                    _isEditingFSSAI = true;
                  });
                },
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTermsSection() {
    // Check if the Terms and Conditions are long
    bool _isLongTerms = _termsAndConditions != null &&
        _termsAndConditions!.split('\n').length > 6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Terms and Conditions',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: 'SFPro',
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF52ed28)),
              onPressed: () {
                setState(() {
                  _isEditingTerms = true;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isEditingTerms)
          Column(
            children: [
              TextField(
                controller: _termsController,
                decoration: const InputDecoration(
                  hintText: 'Enter Terms and Conditions',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.check, color: Color(0xFF52ed28)),
                    label: const Text('Save',
                        style: TextStyle(color: Color(0xFF52ed28))),
                    onPressed: _updateTerms,
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text('Cancel',
                        style: TextStyle(color: Colors.red)),
                    onPressed: () {
                      setState(() {
                        _isEditingTerms = false;
                        _termsController.text = _termsAndConditions ?? '';
                      });
                    },
                  ),
                ],
              ),
            ],
          )
        else
          Column(
            children: [
              Text(
                _termsAndConditions != null
                    ? (_termsAndConditions!.split('\n').take(6).join('\n') +
                        (_isLongTerms ? '...' : ''))
                    : 'Not set',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'SFPro',
                  fontWeight: FontWeight.w500,
                  color:
                      _termsAndConditions == null ? Colors.grey : Colors.black,
                ),
              ),
              if (_isLongTerms)
                InkWell(
                  onTap: () {
                    setState(() {
                      _isEditingTerms = false; // Close editing mode
                    });
                    // Display full Terms and Conditions
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Terms and Conditions'),
                          content: SingleChildScrollView(
                            child: Text(
                                _termsAndConditions ?? 'No Terms available'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Close',
                                style: TextStyle(
                                  color: Color(0xFF52ed28), // Green color
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text(
                    'Read More',
                    style: TextStyle(
                      color: Color(0xFF52ed28),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'SFPro',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF52ed28)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF52ed28).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: Image.file(
                                _imageFile!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 60,
                              color: Color(0xFF52ed28),
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF52ed28),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  width: constraints.maxWidth * 0.9,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_userName != null) ...[
                            const Text(
                              'Name',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontFamily: 'SFPro',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _userName!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontFamily: 'SFPro',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          const Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontFamily: 'SFPro',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.email,
                            style: const TextStyle(
                              fontSize: 18,
                              fontFamily: 'SFPro',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildFSSAISection(),
                          const SizedBox(height: 20),
                          _buildTermsSection(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  width: constraints.maxWidth * 0.9,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'SFPro',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF52ed28),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
