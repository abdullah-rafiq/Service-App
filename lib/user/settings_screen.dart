import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme_mode_notifier.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

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
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
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
            ],
          ),
        ),
      ),
    );
  }
}
