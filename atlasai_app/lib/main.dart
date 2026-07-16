import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/orchestrator_service.dart';
import 'screens/home_shell.dart';
import 'models/user_role.dart';
import 'screens/upload_document_screen.dart';
import 'screens/technician/chat_screen.dart';

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
      home: const DevHomeScreen(),
    );
  }
}

/// Temporary dev/demo menu — NOT the real app entry point.
/// Role-based login (Day 4) replaces this with HomeShell(role: <real role>)
/// straight after auth. Until then, this is the fastest way to jump
/// between whatever's currently working for testing and demos.
class DevHomeScreen extends StatelessWidget {
  const DevHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AtlasAI — Dev Menu')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _StatusCard(),
          const SizedBox(height: 20),
          _MenuTile(
            icon: Icons.chat_bubble_outline,
            title: 'Knowledge Agent Chat',
            subtitle: 'Day 3 — ask questions by text or voice',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen(userRole: 'technician')),
            ),
          ),
          _MenuTile(
            icon: Icons.upload_file,
            title: 'Upload Document',
            subtitle: 'Day 2 — ingest a PDF into the knowledge base',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UploadDocumentScreen()),
            ),
          ),
          _MenuTile(
            icon: Icons.dashboard_outlined,
            title: 'Role Shell (stub)',
            subtitle: 'Day 4+ — role-based navigation, technician role for now',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomeShell(role: UserRole.technician)),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Backend Status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Firebase connected ✅'),
            const SizedBox(height: 6),
            FutureBuilder<bool>(
              future: orchestrator.ping(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Pinging FastAPI orchestrator...'),
                    ],
                  );
                }
                final ok = snapshot.data ?? false;
                return Text(
                  ok
                      ? 'Backend reachable ✅ (Docker + FastAPI)'
                      : 'Backend unreachable ⚠️ — is docker-compose up?',
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
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}