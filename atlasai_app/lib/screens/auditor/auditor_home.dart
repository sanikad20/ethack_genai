import 'package:flutter/material.dart';
import '../../models/user_role.dart';
import '../../widgets/role_badge.dart';
import '../../services/auth_service.dart';

/// Day 1 stub. Compliance status + audit reports built out Day 6.
class AuditorHome extends StatelessWidget {
  const AuditorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AtlasAI — Auditor'),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: RoleBadge(role: UserRole.auditor),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
      body: const Center(
        child: Text('Compliance & audit view — coming Day 6'),
      ),
    );
  }
}