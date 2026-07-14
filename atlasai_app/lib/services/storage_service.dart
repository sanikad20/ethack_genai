import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Day 1: stub only. Upload flow (with offline queueing) gets
/// built out on Day 2 alongside the /ingest backend endpoint.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadDocument(File file, String fileName) async {
    final ref = _storage.ref().child('documents/$fileName');
    // TODO (Day 2): offline queueing if no connectivity, progress tracking
    final task = await ref.putFile(file);
    return task.ref.getDownloadURL();
  }
}
