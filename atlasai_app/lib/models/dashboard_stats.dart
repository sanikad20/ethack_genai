/// Day 6: Plant Intelligence Dashboard data shapes.
/// All computed client-side from the `documents` Firestore collection
/// (fields written by storage_service.dart since Day 5: fileName,
/// uploadedBy, uploadedAt, status, linkedEquipmentIds, docType,
/// similarIncidents, alertSent) — no new backend endpoint needed, same
/// pattern the Lessons Learned Timeline already uses to read Firestore
/// directly.
library;

class CriticalAsset {
  final String equipmentId;
  final int incidentCount;
  final DateTime? lastIncidentDate;

  CriticalAsset({
    required this.equipmentId,
    required this.incidentCount,
    this.lastIncidentDate,
  });
}

class RecentAlert {
  final String fileName;
  final String? equipmentId;
  final int matchCount;
  final DateTime? uploadedAt;

  RecentAlert({
    required this.fileName,
    this.equipmentId,
    required this.matchCount,
    this.uploadedAt,
  });
}

class DashboardStats {
  final int totalDocuments;
  final int totalEquipment;
  final int coveredEquipment; // has an SOP/manual on file
  final double decayScore; // 0-100, higher = staler documentation
  final List<CriticalAsset> criticalAssets;
  final List<RecentAlert> recentAlerts;

  DashboardStats({
    required this.totalDocuments,
    required this.totalEquipment,
    required this.coveredEquipment,
    required this.decayScore,
    required this.criticalAssets,
    required this.recentAlerts,
  });

  double get coveragePercent =>
      totalEquipment == 0 ? 0 : (coveredEquipment / totalEquipment) * 100;

  factory DashboardStats.empty() => DashboardStats(
        totalDocuments: 0,
        totalEquipment: 0,
        coveredEquipment: 0,
        decayScore: 0,
        criticalAssets: [],
        recentAlerts: [],
      );
}