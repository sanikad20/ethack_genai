import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/storage_service.dart';

class UploadDocumentScreen extends StatefulWidget {
  const UploadDocumentScreen({super.key});

  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

enum _UploadState { idle, uploading, success, error }

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  final _storageService = StorageService();
  final _equipmentIdController = TextEditingController();

  _UploadState _state = _UploadState.idle;
  String? _fileName;
  String? _errorMessage;
  Map<String, dynamic>? _result;

  Future<void> _pickAndUpload() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (picked == null || picked.files.single.path == null) return;

    final file = File(picked.files.single.path!);
    final fileName = picked.files.single.name;

    setState(() {
      _state = _UploadState.uploading;
      _fileName = fileName;
      _errorMessage = null;
      _result = null;
    });

    try {
      final result = await _storageService.uploadAndIngest(
        file,
        fileName,
        equipmentId: _equipmentIdController.text.trim().isEmpty
            ? null
            : _equipmentIdController.text.trim(),
      );
      setState(() {
        _state = _UploadState.success;
        _result = result;
      });
    } catch (e) {
      setState(() {
        _state = _UploadState.error;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Document')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _equipmentIdController,
              decoration: const InputDecoration(
                labelText: 'Equipment ID (optional)',
                hintText: 'e.g. PUMP-04',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _state == _UploadState.uploading ? null : _pickAndUpload,
              icon: const Icon(Icons.upload_file),
              label: const Text('Pick PDF & Upload'),
            ),
            const SizedBox(height: 24),
            if (_state == _UploadState.uploading) ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 8),
              Center(child: Text('Uploading & ingesting $_fileName...')),
            ],
            if (_state == _UploadState.success && _result != null) _buildSuccess(),
            if (_state == _UploadState.error) _buildError(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    final tags = List<String>.from(_result!['equipmentTags'] ?? []);
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ingested successfully',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 8),
            Text('File: $_fileName'),
            Text('Chunks stored: ${_result!['chunkCount']}'),
            Text('Pages: ${_result!['pageCount']}'),
            const SizedBox(height: 8),
            if (tags.isNotEmpty) ...[
              const Text('Equipment linked:'),
              Wrap(
                spacing: 6,
                children: tags.map((t) => Chip(label: Text(t))).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Upload failed: $_errorMessage',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}
