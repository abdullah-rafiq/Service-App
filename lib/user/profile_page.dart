import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_application_1/models/app_user.dart';
import 'package:flutter_application_1/services/user_service.dart';

import 'wallet_page.dart';
import 'my_bookings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color yellow = Color(0xFFFFC107);
    final current = FirebaseAuth.instance.currentUser;

    if (current == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view your profile.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF6FBFF),
      body: SafeArea(
        child: StreamBuilder<AppUser?>(
          stream: UserService.instance.watchUser(current.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final profile = snapshot.data;
            final displayName =
                profile?.name ?? current.displayName ?? 'User';
            final profileImageUrl = profile?.profileImageUrl;

            final avatarImage = (profileImageUrl != null && profileImageUrl.isNotEmpty)
                    ? NetworkImage(profileImageUrl)
                    : ResizeImage(
                     const AssetImage('assets/profile.png'),
                          width: 125,
                          height: 125,
                          ) as ImageProvider;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 12,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: avatarImage,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: IconButton(
                                iconSize: 18,
                                padding: const EdgeInsets.all(2),
                                constraints: const BoxConstraints(
                                  minWidth: 28,
                                  minHeight: 28,
                                ),
                                icon: const Icon(Icons.add_a_photo, size: 16),
                                onPressed: () =>
                                    _changeProfileImage(context, current.uid),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (profile != null) ...[
                          Text(
                            'Role: ${profile.role.name}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                profile.verified
                                    ? Icons.verified
                                    : Icons.error_outline,
                                size: 16,
                                color: profile.verified
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                profile.verified
                                    ? 'Verified account'
                                    : 'Not verified',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: profile.verified
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Wallet: PKR ${profile.walletBalance.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 12,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        _QuickAction(
                          iconPath: 'assets/icons/wallet.png',
                          label: 'Wallet',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const WalletPage()),
                            );
                          },
                        ),
                        _QuickAction(
                          iconPath: 'assets/icons/booking.png',
                          label: 'Booking',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const MyBookingsPage()),
                            );
                          },
                        ),
                        _QuickAction(
                          iconPath: 'assets/icons/card.png',
                          label: 'Payment',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const MyBookingsPage()),
                            );
                          },
                        ),
                        _QuickAction(
                          iconPath: 'assets/icons/contact-us.png',
                          label: 'Support',
                          onTap: () {
                            context.push('/contact');
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Settings'),
                    subtitle: const Text('Privacy and logout'),
                    leading: Image.asset(
                      'assets/icons/setting.png',
                      width: 30,
                      height: 30,
                      cacheWidth: 125,  
                      cacheHeight: 125,
                      fit: BoxFit.scaleDown,
                    ),
                    trailing: const Icon(Icons.chevron_right, color: yellow),
                    onTap: () {
                      context.push('/settings');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Help & Support'),
                    subtitle: const Text('Help center and legal support'),
                    leading: Image.asset('assets/icons/support.png',cacheWidth: 125,  
                      cacheHeight: 125,),
                    trailing: const Icon(Icons.chevron_right, color: yellow),
                    onTap: () {
                      context.push('/contact');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('FAQ'),
                    subtitle: const Text('Questions and Answers'),
                    leading: Image.asset('assets/icons/faq.png',cacheWidth: 125,  
                      cacheHeight: 125,),
                    trailing: const Icon(Icons.chevron_right, color: yellow),
                    onTap: () {
                      context.push('/faq');
                    },
                  ),
                  const Divider(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

Future<void> _changeProfileImage(BuildContext context, String uid) async {
  try {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);

    // Show loading SnackBar
    final loadingSnack = SnackBar(
      content: Row(
        children: const [
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Text('Uploading profile picture...')
        ],
      ),
      duration: const Duration(minutes: 1), // will hide manually
    );
    ScaffoldMessenger.of(context).showSnackBar(loadingSnack);

    // Upload to Firebase Storage
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('$uid.jpg');

    final uploadTask = await storageRef.putFile(file);
    final downloadUrl = await storageRef.getDownloadURL();

    // Update Firestore
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'profileImageUrl': downloadUrl,
    });

    // Hide loading SnackBar and show success
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile picture updated.')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not update profile picture: $e')),
    );
  }
}
class _QuickAction extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive sizes
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = (screenWidth * 0.10).clamp(40.0, 50.0); // 40-50 px
    final fontSize = (screenWidth * 0.03).clamp(12.0, 14.0); // 12-14 px
    final spacing = iconSize * 0.2; // spacing proportional to icon

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: onTap,
          child: Image.asset(
            iconPath,
            width: iconSize,
            height: iconSize,
            cacheWidth: 125,
            cacheHeight: 125,
          ),
        ),
        SizedBox(height: spacing),
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
        ),
      ],
    );
  }
}
