import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// Day 5: same upload/ingest logic as before — only additions are
/// passing technician_id to the backend (enables the new person<->
/// equipment graph edges) and persisting docType/similarIncidents/
/// alertSent from the response, which the Lessons Learned Timeline
/// screen reads. No existing field or behavior changed.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String backendBaseUrl;

  StorageService({this.backendBaseUrl = 'http://10.64.147.154:8000'});

  Future<Map<String, dynamic>> uploadAndIngest(
    File file,
    String fileName, {
    String? equipmentId,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

    final ref = _storage.ref().child('documents/$fileName');
    await ref.putFile(file);
    final downloadUrl = await ref.getDownloadURL();

    final docRef = await _db.collection('documents').add({
      'fileName': fileName,
      'storageUrl': downloadUrl,
      'uploadedBy': uid,
      'uploadedAt': FieldValue.serverTimestamp(),
      'status': 'pending',
      'linkedEquipmentIds': <String>[],
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$backendBaseUrl/ingest'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      if (equipmentId != null) {
        request.fields['equipment_id'] = equipmentId;
      }
      // Day 5: lets the backend build technician<->document and
      // technician<->equipment graph edges.
      request.fields['technician_id'] = uid;

      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode != 200) {
        await docRef.update({'status': 'failed'});
        throw Exception('Ingest failed: ${res.statusCode} ${res.body}');
      }

      final result = jsonDecode(res.body) as Map<String, dynamic>;
      final equipmentTags = List<String>.from(result['equipmentTags'] ?? []);
      final graphEdges = List<Map<String, dynamic>>.from(
        (result['graphEdges'] as List).map((e) => Map<String, dynamic>.from(e)),
      );
      // Day 5: additive fields from the updated /ingest response.
      final docType = result['docType'] as String?;
      final similarIncidents = List<Map<String, dynamic>>.from(
        (result['similarIncidents'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)),
      );
      final alertSent = result['alertSent'] as bool? ?? false;

      final batch = _db.batch();
      for (final edge in graphEdges) {
        final edgeRef = _db.collection('graph_edges').doc(edge['edgeId'] as String);
        batch.set(edgeRef, edge);
      }
      batch.update(docRef, {
        'status': 'ingested',
        'linkedEquipmentIds': equipmentTags,
        'backendDocId': result['docId'],
        'docType': docType,
        'similarIncidents': similarIncidents,
        'alertSent': alertSent,
      });
      await batch.commit();

      return result;
    } catch (e) {
      await docRef.update({'status': 'failed'});
      rethrow;
    }
  }
}
