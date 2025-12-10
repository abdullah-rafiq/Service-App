import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_application_1/models/app_user.dart';
import 'package:flutter_application_1/services/user_service.dart';
import 'package:flutter_application_1/user/main_page.dart';
import 'package:flutter_application_1/worker/worker_main_page.dart';
import 'package:flutter_application_1/admin/admin_main_page.dart';

class RoleHomePage extends StatelessWidget {
  const RoleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final current = FirebaseAuth.instance.currentUser;

    if (current == null) {
      // Not logged in: send to auth and show a simple loading state.
      Future.microtask(() {
        if (context.mounted) {
          context.go('/auth');
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return StreamBuilder<AppUser?>(
      stream: UserService.instance.watchUser(current.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error loading profile: ${snapshot.error}'),
            ),
          );
        }

        final profile = snapshot.data;

        if (profile == null) {
          // No profile yet: send to role selection.
          Future.microtask(() {
            if (context.mounted) {
              context.go('/role');
            }
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        switch (profile.role) {
          case UserRole.customer:
            return const MainPage();
          case UserRole.provider:
            return const WorkerMainPage();
          case UserRole.admin:
            return const AdminMainPage();
        }
      },
    );
  }
}
