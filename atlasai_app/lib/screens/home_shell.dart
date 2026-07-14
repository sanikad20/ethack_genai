import 'package:flutter/material.dart';
import '../models/user_role.dart';
import 'technician/technician_home.dart';
import 'engineer/engineer_home.dart';
import 'manager/manager_home.dart';
import 'auditor/auditor_home.dart';

/// Day 1 stub: routes to a role-specific home screen.
/// Real role lookup (from Firestore, after login) replaces the
/// hardcoded `role` param on Day 4.
class HomeShell extends StatelessWidget {
  final UserRole role;

  const HomeShell({super.key, this.role = UserRole.technician});

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case UserRole.technician:
        return const TechnicianHome();
      case UserRole.engineer:
        return const EngineerHome();
      case UserRole.manager:
        return const ManagerHome();
      case UserRole.auditor:
        return const AuditorHome();
    }
  }
}
