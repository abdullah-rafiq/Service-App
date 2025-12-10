import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_application_1/services/user_service.dart';

class WorkerVerificationPage extends StatefulWidget {
  const WorkerVerificationPage({super.key});

  @override
  State<WorkerVerificationPage> createState() => _WorkerVerificationPageState();
}

class _WorkerVerificationPageState extends State<WorkerVerificationPage> {
  bool _submitting = false;
  String? _cnicUrl;
  String? _selfieUrl;
  String? _shopUrl;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUpload(String field) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to verify.')),
      );
      return;
    }

    try {
      final picked = await _picker.pickImage(source: ImageSource.camera);
      if (picked == null) return;

      final file = File(picked.path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('worker_verification')
          .child(user.uid)
          .child('$field.jpg');

      await storageRef.putFile(file);
      final url = await storageRef.getDownloadURL();

      await UserService.instance.updateUser(user.uid, {
        field: url,
      });

      setState(() {
        if (field == 'cnicImageUrl') {
          _cnicUrl = url;
        } else if (field == 'selfieImageUrl') {
          _selfieUrl = url;
        } else if (field == 'shopImageUrl') {
          _shopUrl = url;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not upload image: $e')),
        );
      }
    }
  }

  Future<void> _submitVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to verify.')),
      );
      return;
    }

    if (_cnicUrl == null || _selfieUrl == null || _shopUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload CNIC, selfie, and shop/tools photos first.'),
        ),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      await UserService.instance.updateUser(user.uid, {
        'verificationStatus': 'pending',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification details submitted. Your account is under review.'),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not submit verification: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker verification'),
      ),
      backgroundColor: const Color(0xFFF6FBFF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'To start taking jobs, please upload the following live photos:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            _VerificationTile(
              title: 'CNIC photo',
              description: 'Take a clear photo of your CNIC.',
              uploaded: _cnicUrl != null,
              onTap: () => _pickAndUpload('cnicImageUrl'),
            ),
            const SizedBox(height: 12),
            _VerificationTile(
              title: 'Live selfie',
              description: 'Take a live selfie matching your CNIC.',
              uploaded: _selfieUrl != null,
              onTap: () => _pickAndUpload('selfieImageUrl'),
            ),
            const SizedBox(height: 12),
            _VerificationTile(
              title: 'Shop / tools photo',
              description: 'Take a photo of your shop or tools.',
              uploaded: _shopUrl != null,
              onTap: () => _pickAndUpload('shopImageUrl'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitting ? null : _submitVerification,
              child: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit verification'),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationTile extends StatelessWidget {
  final String title;
  final String description;
  final bool uploaded;
  final VoidCallback onTap;

  const _VerificationTile({
    required this.title,
    required this.description,
    required this.uploaded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            uploaded ? Icons.check_circle : Icons.photo_camera_outlined,
            color: uploaded ? Colors.green : Colors.blueAccent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: onTap,
                    child: Text(uploaded ? 'Retake photo' : 'Take photo'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
