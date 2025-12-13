import 'package:flutter/material.dart';

import 'admin_workers_page.dart';
import 'admin_notifications_page.dart';
import 'admin_analytics_page.dart';
import 'package:flutter_application_1/common/profile_page.dart';
import 'package:flutter_application_1/common/app_bottom_nav.dart';
import 'package:flutter_application_1/localized_strings.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const AdminAnalyticsPage(),
      const AdminWorkersPage(),
      const AdminNotificationsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.insights_outlined),
            label: L10n.adminNavAnalytics(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.group_outlined),
            label: L10n.adminNavWorkers(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications_none),
            label: L10n.adminNavNotifications(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            label: L10n.userNavProfile(),
          ),
        ],
      ),
    );
  }
}
