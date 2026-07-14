import 'package:flutter/material.dart';
import '../../models/user_role.dart';
import '../../widgets/role_badge.dart';

/// Day 1 stub. Voice-first Q&A + checklists built out Day 3, 5, 6.
class TechnicianHome extends StatelessWidget {
  const TechnicianHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AtlasAI — Technician'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: RoleBadge(role: UserRole.technician),
          ),
        ],
      ),
      body: const Center(
        child: Text('Technician copilot — coming Day 3+'),
      ),
    );
  }
}
