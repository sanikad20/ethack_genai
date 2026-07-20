import 'package:flutter/material.dart';
import '../../models/user_role.dart';
import '../../services/auth_service.dart';
import '../../services/orchestrator_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/role_badge.dart';
import '../../widgets/explainable_ai_panel.dart';
import '../actions/action_result_screen.dart';

/// Day 6: Compliance Status view — runs the real backend Compliance
/// Agent (Day 6: rule-based deviation checking, no longer a stub)
/// against a chosen equipment ID, and offers full Audit Report
/// generation via the Action Engine. Replaces the Day 1 stub.
class AuditorHome extends StatefulWidget {
  const AuditorHome({super.key});

  @override
  State<AuditorHome> createState() => _AuditorHomeState();
}

class _AuditorHomeState extends State<AuditorHome> {
  final _orchestrator = OrchestratorService();
  final _equipmentController = TextEditingController();

  bool _checking = false;
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void dispose() {
    _equipmentController.dispose();
    super.dispose();
  }

  Future<void> _runComplianceCheck() async {
    final equipmentId = _equipmentController.text.trim();
    if (equipmentId.isEmpty) return;

    setState(() {
      _checking = true;
      _error = null;
      _result = null;
    });

    try {
      // CHANGE: pass `agents: ['compliance_agent']` so the backend
      // only runs the Compliance Agent for this screen, instead of
      // whatever default agent set /query would otherwise pick.
      // This is why the Auditor screen was previously getting "no
      // result for this query" — it was never asking the backend to
      // run compliance_agent in the first place, even though Swagger
      // requests that explicitly included "agents": ["compliance_agent"]
      // worked fine.
      final response = await _orchestrator.query(
        'Is $equipmentId compliant with its maintenance interval?',
        userRole: 'auditor',
        equipmentId: equipmentId,
        agents: ['compliance_agent'],
      );

      // Debug: confirm exactly what the Auditor screen received back,
      // in addition to the request/response logging already inside
      // OrchestratorService.query().
      print('===== AuditorHome: response received =====');
      print(response);

      final results = (response['results'] as List?) ?? [];

      // Debug: show what agent name(s) actually came back, so a
      // mismatch (e.g. "ComplianceAgent" vs "compliance_agent") is
      // immediately visible instead of silently failing the
      // firstWhere lookup below.
      print('===== AuditorHome: agents in response =====');
      print(results.map((r) => r['agent']).toList());

      final complianceResult = results.firstWhere(
        (r) => r['agent'] == 'compliance_agent',
        orElse: () => null,
      );

      setState(() => _result = complianceResult as Map<String, dynamic>?);
      if (_result == null) {
        setState(() => _error = 'Compliance Agent did not return a result for this query.');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compliance & Audit'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Run Compliance Check', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _equipmentController,
              decoration: const InputDecoration(
                labelText: 'Equipment ID',
                hintText: 'e.g. PUMP-04',
                prefixIcon: Icon(Icons.tag),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // LAYOUT CHANGE: the two action buttons previously sat in a
            // plain Row, which has no way to shrink or wrap its
            // children — on narrow phones (320-480dp) their combined
            // intrinsic width exceeded the available width, causing
            // "RIGHT OVERFLOWED BY xx PIXELS". LayoutBuilder now checks
            // the actual width available to this Row at build time:
            //  - Wide enough (>= 360dp here, tune as needed): buttons
            //    stay side-by-side in a Row, each wrapped in Expanded so
            //    they share the width instead of using their intrinsic
            //    (overflow-prone) width.
            //  - Narrow: buttons stack vertically at full width via a
            //    Column, so each button keeps its full label, icon, and
            //    tap-target size (no shrinking text/icons, so
            //    accessibility/tap size is preserved either way).
            // No onPressed/navigation logic changed — only the
            // container arrangement around the same two buttons.
            LayoutBuilder(
              builder: (context, constraints) {
                final checkComplianceButton = FilledButton.icon(
                  onPressed: _checking ? null : _runComplianceCheck,
                  icon: _checking
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.fact_check_outlined, size: 18),
                  label: const Text('Check Compliance'),
                );

                final fullAuditReportButton = OutlinedButton.icon(
                  onPressed: _equipmentController.text.trim().isEmpty
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ActionResultScreen(
                                actionType: 'audit_report',
                                equipmentId: _equipmentController.text.trim(),
                                userRole: 'auditor',
                              ),
                            ),
                          ),
                  icon: const Icon(Icons.summarize_outlined, size: 18),
                  label: const Text('Full Audit Report'),
                );

                const wideBreakpoint = 360.0;

                if (constraints.maxWidth >= wideBreakpoint) {
                  return Row(
                    children: [
                      Expanded(child: checkComplianceButton),
                      const SizedBox(width: 8),
                      Expanded(child: fullAuditReportButton),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    checkComplianceButton,
                    const SizedBox(height: 8),
                    fullAuditReportButton,
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: AppColors.danger)),
            if (_result != null) ...[
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  _result!['answer'] as String? ?? '',
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
              const SizedBox(height: 12),
              // No change needed here: ExplainableAiPanel already reads
              // confidence / sources / reasoning off `_result`, which
              // now actually gets populated because the request above
              // asks the backend to run compliance_agent.
              ExplainableAiPanel(
                confidence: (_result!['confidence'] as num?)?.toDouble() ?? 0.0,
                sources: List<String>.from(_result!['sources'] ?? const []),
                reasoning: _result!['reasoning'] as String?,
              ),
            ],
          ],
        ),
      ),
    );
  }
}