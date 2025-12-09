import 'dart:async';
import 'package:dream/firebase_options.dart';
import 'package:dream/logic/auth_prefs.dart';
import 'package:dream/logic/firebase/Login/login.dart';
import 'package:dream/page/call/PresenceService.dart';
import 'package:dream/page/home/homescreen/home sreen.dart';
import 'package:dream/page/account/my_account.dart';
import 'package:dream/page/profile/edit_profile_page.dart';
import 'package:dream/page/privacy/privacy_page.dart';
import 'package:dream/page/auth/forgot_password.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:dream/theme/app_theme.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AuthPrefs.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      navigatorKey: navigatorKey,
      routes: {
        '/my_account': (_) => const MyAccountPage(),
        '/edit_profile': (_) => const EditProfilePage(),
        '/privacy': (_) => const PrivacyPage(),
        '/forgot_password': (_) => const ForgotPasswordPage(),
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            Future.microtask(() => PresenceService.startPresence());
            return const HomePage();
          }

          return LoginPage();
        },
      ),
    );
  }
}
