import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme_mode_notifier.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _loadingNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _loadingNotifications = false;
        });
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        setState(() {
          _loadingNotifications = false;
        });
        return;
      }

      final data = doc.data();
      final value = data?['notificationsEnabled'];

      if (value is bool) {
        setState(() {
          _notificationsEnabled = value;
          _loadingNotifications = false;
        });
      } else {
        setState(() {
          _loadingNotifications = false;
        });
      }
    } catch (_) {
      setState(() {
        _loadingNotifications = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('App settings'),
      ),
      backgroundColor: const Color(0xFFF6FBFF),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
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
          child: ListView(
            shrinkWrap: true,
            children: [
              SwitchListTile(
                title: const Text('Push notifications'),
                subtitle: const Text(
                    'Receive updates about your bookings and offers.'),
                value: _notificationsEnabled,
                onChanged: _loadingNotifications
                    ? null
                    : (value) async {
                        setState(() {
                          _notificationsEnabled = value;
                        });

                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) return;

                        try {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .set(
                            {
                              'notificationsEnabled': value,
                            },
                            SetOptions(merge: true),
                          );
                        } catch (_) {
                          // Revert on failure
                          setState(() {
                            _notificationsEnabled = !value;
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Could not update notification preference. Please try again.',
                                ),
                              ),
                            );
                          }
                        }
                      },
              ),
              const Divider(height: 1),
              ValueListenableBuilder<ThemeMode>(
                valueListenable: AppTheme.themeMode,
                builder: (context, themeMode, _) {
                  final isDark = themeMode == ThemeMode.dark;
                  return SwitchListTile(
                    title: const Text('Dark mode'),
                    subtitle:
                        const Text('Use a dark theme for the application.'),
                    value: isDark,
                    onChanged: (value) {
                      AppTheme.setThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.lock_reset),
                title: const Text('Change password'),
                subtitle:
                    const Text('Send a password reset link to your email.'),
                onTap: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  final email = user?.email;

                  if (email == null || email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'No email found for this account. You may be using a social login.',
                        ),
                      ),
                    );
                    return;
                  }

                  try {
                    await FirebaseAuth.instance
                        .sendPasswordResetEmail(email: email);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Password reset email sent. Please check your inbox.',
                        ),
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Could not send reset email: $e',
                        ),
                      ),
                    );
                  }
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Terms & conditions'),
                subtitle:
                    const Text('View the legal terms of using the app.'),
                onTap: () {
                  context.push('/terms');
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Privacy policy'),
                subtitle: const Text('Learn how we handle your data.'),
                onTap: () {
                  context.push('/privacy');
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
                title: const Text('Delete account'),
                subtitle:
                    const Text('Permanently remove your account and data.'),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Delete account'),
                        content: const Text(
                          'This will permanently delete your account and data. This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm != true) return;

                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('You must be logged in to delete account.'),
                      ),
                    );
                    return;
                  }

                  try {
                    final uid = user.uid;
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .delete();

                    await user.delete();

                    if (!mounted) return;
                    context.go('/auth');
                  } on FirebaseAuthException catch (e) {
                    if (!mounted) return;
                    if (e.code == 'requires-recent-login') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please log in again and then try deleting your account.',
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Could not delete account: ${e.code}'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Could not delete account: $e'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
