import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/orchestrator_service.dart';
import 'screens/home_shell.dart';
import 'models/user_role.dart';
import 'screens/upload_document_screen.dart';

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
      home: const UploadDocumentScreen(),
    );
  }
}

/// Day 1 deliverable screen: confirms Firebase initialized AND the
/// Flutter app can reach the FastAPI orchestrator through Docker.
/// Replace `home:` above with HomeShell(role: ...) once login (Day 4)
/// determines the real role.
class Day1StatusScreen extends StatelessWidget {
  const Day1StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orchestrator = OrchestratorService();

    return Scaffold(
      appBar: AppBar(title: const Text('AtlasAI — Day 1 Status')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 12),
              const Text('Firebase connected ✅', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              FutureBuilder<bool>(
                future: orchestrator.ping(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Pinging FastAPI orchestrator...'),
                      ],
                    );
                  }
                  final ok = snapshot.data ?? false;
                  return Column(
                    children: [
                      Icon(
                        ok ? Icons.check_circle : Icons.error,
                        color: ok ? Colors.green : Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        ok
                            ? 'Backend reachable ✅ (Docker + FastAPI)'
                            : 'Backend unreachable — is docker-compose up?',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HomeShell(role: UserRole.technician),
                    ),
                  );
                },
                child: const Text('Continue to role shell (stub)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
