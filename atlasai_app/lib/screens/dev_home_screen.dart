import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../services/orchestrator_service.dart';
import '../theme/app_theme.dart';
import '../widgets/status_pill.dart';
import 'upload_document_screen.dart';
import 'technician/chat_screen.dart';
import 'home_shell.dart';
import 'lessons_learned/lessons_learned_timeline_screen.dart';
import 'knowledge_capture/knowledge_capture_screen.dart';

/// Optional dev/testing menu — bypasses login entirely so you can jump
/// straight to a screen while iterating. Not part of the real user flow
/// (AuthGate is); swap `home:` in main.dart to this only for local testing.
class DevHomeScreen extends StatelessWidget {
  const DevHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AtlasAI — Dev Menu')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const _StatusCard(),
          const SizedBox(height: AppSpacing.lg),
          _MenuTile(
            icon: Icons.chat_bubble_outline,
            title: 'Knowledge Agent Chat',
            subtitle: 'Skip auth — go straight to the technician chat',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen(userRole: 'technician')),
            ),
          ),
          _MenuTile(
            icon: Icons.upload_file,
            title: 'Upload Document',
            subtitle: 'Ingest a PDF into the knowledge base',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UploadDocumentScreen()),
            ),
          ),
          _MenuTile(
            icon: Icons.timeline_outlined,
            title: 'Lessons Learned Timeline',
            subtitle: 'Day 5 — recurring failure patterns across incidents',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LessonsLearnedTimelineScreen()),
            ),
          ),
          _MenuTile(
            icon: Icons.record_voice_over_outlined,
            title: 'Knowledge Capture',
            subtitle: 'Day 5 — guided voice interview for tacit knowledge',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const KnowledgeCaptureScreen()),
            ),
          ),
          _MenuTile(
            icon: Icons.dashboard_outlined,
            title: 'Role Shell — Engineer',
            subtitle: 'Preview the Engineer roadmap screen',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomeShell(role: UserRole.engineer)),
            ),
          ),
          _MenuTile(
            icon: Icons.dashboard_outlined,
            title: 'Role Shell — Manager',
            subtitle: 'Preview the Plant Manager roadmap screen',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomeShell(role: UserRole.manager)),
            ),
          ),
          _MenuTile(
            icon: Icons.dashboard_outlined,
            title: 'Role Shell — Auditor',
            subtitle: 'Preview the Auditor roadmap screen',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomeShell(role: UserRole.auditor)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard();

  @override
  Widget build(BuildContext context) {
    final orchestrator = OrchestratorService();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Backend Status', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            const StatusPill(
              state: StatusPillState.success,
              loadingText: '', successText: 'Firebase connected', errorText: '',
            ),
            const SizedBox(height: 6),
            FutureBuilder<bool>(
              future: orchestrator.ping(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const StatusPill(
                    state: StatusPillState.loading,
                    loadingText: 'Pinging FastAPI orchestrator...',
                    successText: '', errorText: '',
                  );
                }
                final ok = snapshot.data ?? false;
                return StatusPill(
                  state: ok ? StatusPillState.success : StatusPillState.error,
                  loadingText: '',
                  successText: 'Backend reachable (Docker + FastAPI)',
                  errorText: 'Backend unreachable — is docker-compose up?',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
