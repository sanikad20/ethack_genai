import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';
import 'auth/login_screen.dart';
import 'home_shell.dart';

/// Day 4: listens to Firebase Auth state and routes to the right
/// screen. This is the real app entry point (main.dart points `home:`
/// at this widget).
///
///   no session          -> LoginScreen
///   session, has role    -> HomeShell(role: <fetched role>)
///   session, no role doc -> back to LoginScreen (interrupted signup —
///                           see AuthService.fetchUserRole)
///
/// Unchanged from Day 4 — moved out of main.dart into its own file so
/// Day 5's main.dart (now handling FCM registration too) stays focused
/// on app bootstrap rather than auth routing.
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