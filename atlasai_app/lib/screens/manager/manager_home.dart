import 'package:flutter/material.dart';
import '../../models/user_role.dart';
import '../../models/dashboard_stats.dart';
import '../../services/dashboard_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/role_badge.dart';
import '../../widgets/stat_card.dart';
import '../../services/auth_service.dart';
import '../actions/action_result_screen.dart';
import '../equipment/equipment_timeline_screen.dart';

/// Day 6: Plant Intelligence Dashboard — Knowledge Coverage, Knowledge
/// Decay Score, Critical Assets, and AI Recommendations, computed from
/// the same `documents` Firestore collection the Lessons Learned
/// Timeline already reads. Replaces the Day 1 stub.
class ManagerHome extends StatefulWidget {
  const ManagerHome({super.key});

  @override
  State<ManagerHome> createState() => _ManagerHomeState();
}

class _ManagerHomeState extends State<ManagerHome> {
  final _service = DashboardService();
  late Future<DashboardStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _service.loadStats();
  }

  Future<void> _refresh() async {
    setState(() => _statsFuture = _service.loadStats());
    await _statsFuture;
  }

  Color _decayColor(double score) {
    if (score >= 70) return AppColors.danger;
    if (score >= 40) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Intelligence Dashboard'),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: RoleBadge(role: UserRole.manager),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<DashboardStats>(
          future: _statsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Text('Could not load dashboard: ${snapshot.error}',
                      style: const TextStyle(color: AppColors.danger)),
                ],
              );
            }

            final stats = snapshot.data ?? DashboardStats.empty();

            if (stats.totalDocuments == 0) {
              return ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: const [
                  SizedBox(height: 80),
                  Icon(Icons.insights_outlined, size: 48, color: AppColors.textFaint),
                  SizedBox(height: 12),
                  Text(
                    'No documents ingested yet — the dashboard fills in as '
                    'technicians upload maintenance logs, SOPs, and incident reports.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                // LAYOUT CHANGE: GridView.count with a fixed
                // childAspectRatio: 1.5 forces every cell to a fixed
                // height derived purely from cell width — it cannot
                // grow if a StatCard's subtitle wraps to 2-3 lines on
                // a narrow 320-480dp phone, which is exactly what
                // caused "BOTTOM OVERFLOWED BY xx PIXELS". Replaced
                // with _ResponsiveStatGrid (defined below), which lays
                // the same 4 StatCards out in two-column rows using
                // IntrinsicHeight + Expanded instead of a fixed aspect
                // ratio, so each row's height is determined by its
                // tallest card's actual content and can grow as
                // needed. Same cards, same props, same spacing/visual
                // design — only the sizing strategy changed.
                _ResponsiveStatGrid(
                  spacing: AppSpacing.sm,
                  cards: [
                    StatCard(
                      label: 'Knowledge Coverage',
                      value: '${stats.coveragePercent.toStringAsFixed(0)}%',
                      icon: Icons.library_books_outlined,
                      accentColor: AppColors.primary,
                      subtitle: '${stats.coveredEquipment}/${stats.totalEquipment} equipment documented',
                    ),
                    StatCard(
                      label: 'Knowledge Decay',
                      value: stats.decayScore.toStringAsFixed(0),
                      icon: Icons.hourglass_bottom,
                      accentColor: _decayColor(stats.decayScore),
                      subtitle: 'avg. document age vs. 90-day window',
                    ),
                    StatCard(
                      label: 'Documents Ingested',
                      value: '${stats.totalDocuments}',
                      icon: Icons.description_outlined,
                    ),
                    StatCard(
                      label: 'Equipment Tracked',
                      value: '${stats.totalEquipment}',
                      icon: Icons.precision_manufacturing_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Critical Assets', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                if (stats.criticalAssets.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('No recurring incidents recorded.', style: TextStyle(color: AppColors.textFaint)),
                  )
                else
                  ...stats.criticalAssets.map((asset) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                          title: Text(asset.equipmentId, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            '${asset.incidentCount} incident(s) recorded'
                            '${asset.lastIncidentDate != null ? ' · last ${_formatDate(asset.lastIncidentDate!)}' : ''}',
                          ),
                          // NEW: tapping the tile itself opens the
                          // equipment's timeline + health score.
                          // "Generate RCA" stays as the trailing
                          // action, unchanged.
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EquipmentTimelineScreen(
                                equipmentId: asset.equipmentId,
                              ),
                            ),
                          ),
                          trailing: TextButton(
                            child: const Text('Generate RCA'),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ActionResultScreen(
                                  actionType: 'rca_report',
                                  equipmentId: asset.equipmentId,
                                  userRole: 'manager',
                                ),
                              ),
                            ),
                          ),
                        ),
                      )),
                const SizedBox(height: AppSpacing.lg),
                Text('AI Recommendations', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                if (stats.recentAlerts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('No pattern alerts yet.', style: TextStyle(color: AppColors.textFaint)),
                  )
                else
                  ...stats.recentAlerts.map((alert) {
                    // CHANGE: previously this always rendered a
                    // generic templated subtitle ("Matched N similar
                    // incident(s) — filename") regardless of what was
                    // actually found. Now it surfaces the single best
                    // matched incident's real snippet and similarity
                    // score — the actual AI insight — and falls back
                    // to the old generic line only if, for some
                    // reason, no match detail is available.
                    final best = alert.bestMatch;
                    final subtitle = best != null
                        ? '"${best.snippet.trim()}"\n'
                            '${(best.similarity * 100).toStringAsFixed(0)}% match'
                            '${best.equipmentId != null ? ' · ${best.equipmentId}' : ''}'
                            ' · from ${best.fileName}'
                            '${alert.matchCount > 1 ? ' (+${alert.matchCount - 1} more similar)' : ''}'
                        : 'Matched ${alert.matchCount} similar past incident(s) — ${alert.fileName}';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                        title: Text(
                          'Recommend reviewing ${alert.equipmentId ?? alert.fileName}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(subtitle),
                        isThreeLine: best != null,
                        trailing: alert.equipmentId == null
                            ? null
                            : TextButton(
                                child: const Text('Checklist'),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ActionResultScreen(
                                      actionType: 'maintenance_checklist',
                                      equipmentId: alert.equipmentId,
                                      userRole: 'manager',
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

/// LAYOUT-ONLY helper: arranges StatCards two-per-row without forcing
/// a fixed aspect ratio (unlike GridView.count), so each row's height
/// is determined by its tallest card's actual content. Wraps each row
/// in IntrinsicHeight so both cards in that row stretch to match
/// whichever one is taller (e.g. if one has a longer wrapping
/// subtitle), keeping the "same design" look of equal-height card
/// pairs while still letting the row as a whole grow vertically when
/// content needs more room. Purely presentational — does not touch
/// StatCard's own props or any business/data logic.
class _ResponsiveStatGrid extends StatelessWidget {
  final List<Widget> cards;
  final double spacing;

  const _ResponsiveStatGrid({
    required this.cards,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < cards.length; i += 2) {
      final hasSecond = i + 1 < cards.length;
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: i + 2 < cards.length ? spacing : 0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: cards[i]),
                if (hasSecond) ...[
                  SizedBox(width: spacing),
                  Expanded(child: cards[i + 1]),
                ] else
                  // Odd number of cards: keep the second column's
                  // space empty rather than stretching the last card
                  // to full width, preserving the existing two-column
                  // visual design.
                  Expanded(child: Container()),
              ],
            ),
          ),
        ),
      );
    }

    return Column(children: rows);
  }
}