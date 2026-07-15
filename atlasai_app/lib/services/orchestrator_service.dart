import 'dart:convert';
import 'package:http/http.dart' as http;

/// Talks to the FastAPI Multi-Agent Orchestrator.
class OrchestratorService {
  final String baseUrl;

  // Replace with your Ubuntu machine's IP address
  OrchestratorService({
    this.baseUrl = 'http://192.168.2.235:8000',
  });

  Future<bool> ping() async {
    try {
      final url = Uri.parse('$baseUrl/ping');

      print("=================================");
      print("Calling backend...");
      print("URL: $url");

      final res = await http.get(url);

      print("Status Code: ${res.statusCode}");
      print("Response Body: ${res.body}");
      print("=================================");

      return res.statusCode == 200;
    } catch (e, stackTrace) {
      print("=================================");
      print("PING FAILED");
      print("Error: $e");
      print("StackTrace:");
      print(stackTrace);
      print("=================================");

      return false;
    }
  }

  Future<Map<String, dynamic>> query(
    String userQuery, {
    String userRole = 'technician',
    String? equipmentId,
  }) async {
    final url = Uri.parse('$baseUrl/query');

    print("Sending query to: $url");

    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'query': userQuery,
        'user_role': userRole,
        'equipment_id': equipmentId,
      }),
    );

    print("Query Status: ${res.statusCode}");
    print("Query Response: ${res.body}");

    if (res.statusCode != 200) {
      throw Exception(
        'Orchestrator error: ${res.statusCode}\n${res.body}',
      );
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}