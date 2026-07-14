import 'package:flutter/material.dart';
import '../../models/user_role.dart';
import '../../widgets/role_badge.dart';

/// Day 1 stub. RCA support + Maintenance Agent UI built out Day 5.
class EngineerHome extends StatelessWidget {
  const EngineerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AtlasAI — Engineer'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: RoleBadge(role: UserRole.engineer),
          ),
        ],
      ),
      body: const Center(
        child: Text('Maintenance Engineer copilot — coming Day 5+'),
      ),
    );
  }
}
