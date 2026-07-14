import 'package:flutter/material.dart';
import '../../models/user_role.dart';
import '../../widgets/role_badge.dart';

/// Day 1 stub. Plant Intelligence Dashboard built out Day 6.
class ManagerHome extends StatelessWidget {
  const ManagerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AtlasAI — Plant Manager'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: RoleBadge(role: UserRole.manager),
          ),
        ],
      ),
      body: const Center(
        child: Text('Plant Intelligence Dashboard — coming Day 6'),
      ),
    );
  }
}
