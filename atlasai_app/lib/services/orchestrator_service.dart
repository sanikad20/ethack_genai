import 'dart:convert';
import 'package:http/http.dart' as http;

/// Talks to the FastAPI Multi-Agent Orchestrator.
///
/// Day 1 target: baseUrl points at the Dockerized backend and
/// /ping succeeds — that's the whole Day 1 deliverable for this file.
///
/// Use 10.0.2.2 instead of localhost when running on the Android
/// emulator (localhost on the emulator refers to the emulator itself,
/// not your host machine). Use your machine's LAN IP for a physical device.
class OrchestratorService {
  final String baseUrl;

  OrchestratorService({this.baseUrl = 'http://10.0.2.2:8000'});

  Future<bool> ping() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/ping'));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> query(
    String userQuery, {
    String userRole = 'technician',
    String? equipmentId,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/query'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'query': userQuery,
        'user_role': userRole,
        'equipment_id': equipmentId,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception('Orchestrator error: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
