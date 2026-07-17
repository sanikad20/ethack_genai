import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/home_shell.dart';
import 'screens/auth/login_screen.dart';
import 'models/user_role.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AtlasAIApp());
}

class AtlasAIApp extends StatelessWidget {
  const AtlasAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AtlasAI',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1F4E5F),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

/// Day 4: listens to Firebase Auth state and routes to the right
/// screen. Replaces Day 1's DevHomeScreen as the real app entry point.
///
///   no session          -> LoginScreen
///   session, has role    -> HomeShell(role: <fetched role>)
///   session, no role doc -> back to LoginScreen (interrupted signup —
///                           see AuthService.fetchUserRole)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        final user = authSnapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        return FutureBuilder<UserRole>(
          future: authService.fetchUserRole(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }
            if (roleSnapshot.hasError) {
              // Profile doc missing (interrupted signup) — sign out and
              // send back to login rather than get stuck on a spinner.
              authService.signOut();
              return const LoginScreen();
            }
            return HomeShell(role: roleSnapshot.data!);
          },
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}