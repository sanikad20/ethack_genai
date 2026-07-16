import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class StorageService {
  final String backendBaseUrl;

  StorageService({
    this.backendBaseUrl = 'http://10.43.240.154:8000',
  });

  Future<Map<String, dynamic>> uploadAndIngest(
    File file,
    String fileName, {
    String? equipmentId,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$backendBaseUrl/ingest'),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: fileName,
      ),
    );

    if (equipmentId != null && equipmentId.isNotEmpty) {
      request.fields['equipment_id'] = equipmentId;
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception(
        'Upload failed (${response.statusCode})\n${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}