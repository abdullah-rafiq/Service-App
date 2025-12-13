import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/auth/login_screen.dart';
import 'firebase_options.dart';
import 'splash screen/splash_screen.dart';
import 'auth/role_selection_screen.dart';
import 'common/profile_page.dart';
import 'user/my_bookings_page.dart';
import 'common/settings_screen.dart';
import 'common/faq_page.dart';
import 'common/contact_us_page.dart';
import 'common/terms_and_conditions_page.dart';
import 'common/privacy_policy_page.dart';
import 'common/role_home_page.dart';
import 'theme_mode_notifier.dart';
import 'app_locale.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AppTheme.init();
  await AppLocale.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static final _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/role',
        name: 'role',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const RoleHomePage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/bookings',
        name: 'bookings',
        builder: (context, state) => const MyBookingsPage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/faq',
        name: 'faq',
        builder: (context, state) => const FaqPage(),
      ),
      GoRoute(
        path: '/contact',
        name: 'contact',
        builder: (context, state) => const ContactUsPage(),
      ),
      GoRoute(
        path: '/terms',
        name: 'terms',
        builder: (context, state) => const TermsAndConditionsPage(),
      ),
      GoRoute(
        path: '/privacy',
        name: 'privacy',
        builder: (context, state) => const PrivacyPolicyPage(),
      ),
      GoRoute(
        path: '/worker',
        name: 'workerHome',
        builder: (context, state) => const RoleHomePage(),
      ),
      GoRoute(
        path: '/admin',
        name: 'adminHome',
        builder: (context, state) => const RoleHomePage(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeMode,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: AppLocale.locale,
          builder: (context, locale, __) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Assist',
              themeMode: themeMode,
              locale: locale,
              supportedLocales: const [
                Locale('en'),
                Locale('ur'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF29B6F6),
                  brightness: Brightness.light,
                ),
                scaffoldBackgroundColor: const Color(0xFFF4F7FB),
                appBarTheme: const AppBarTheme(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.black87,
                  centerTitle: false,
                ),
                cardColor: Colors.white,
                cardTheme: CardThemeData(
                  color: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,
                  selectedLabelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 11,
                  ),
                ),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF29B6F6),
                  brightness: Brightness.dark,
                ),
                scaffoldBackgroundColor: const Color(0xFF0F1115),
                appBarTheme: const AppBarTheme(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  centerTitle: false,
                ),
                cardColor: const Color(0xFF1E1E1E),
                cardTheme: CardThemeData(
                  color: const Color(0xFF1E1E1E),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,
                  selectedLabelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 11,
                  ),
                ),
              ),
              routerConfig: _router,
            );
          },
        );
      },
    );
  }
}
