import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../models/chat_message.dart';
import '../../services/orchestrator_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/confidence_badge.dart';
import '../../widgets/citation_chips.dart';
import '../upload_document_screen.dart';

/// Day 3 deliverable: chat + voice input UI for the Knowledge Agent.
/// Talks to POST /query and renders merged_answer, confidence, and
/// source citations for every response (Explainable AI panel).
class ChatScreen extends StatefulWidget {
  final String userRole;
  const ChatScreen({super.key, this.userRole = 'technician'});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _orchestrator = OrchestratorService();
  final _textController = TextEditingController();
  final _equipmentIdController = TextEditingController();
  final _scrollController = ScrollController();
  final _speech = stt.SpeechToText();

  final List<ChatMessage> _messages = [];
  bool _isSending = false;
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
      },
    );
    setState(() {});
  }

  void _toggleListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voice input unavailable on this device/browser.')),
      );
      return;
    }
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }
    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _textController.text = result.recognizedWords;
          _textController.selection = TextSelection.fromPosition(
            TextPosition(offset: _textController.text.length),
          );
        });
      },
    );
  }

  Future<void> _send() async {
    final query = _textController.text.trim();
    if (query.isEmpty || _isSending) return;

    final equipmentId = _equipmentIdController.text.trim();

    setState(() {
      _messages.add(ChatMessage(text: query, isUser: true));
      _isSending = true;
      _textController.clear();
    });
    _scrollToBottom();

    try {
      final response = await _orchestrator.query(
        query,
        userRole: widget.userRole,
        equipmentId: equipmentId.isEmpty ? null : equipmentId,
      );
      setState(() {
        _messages.add(ChatMessage.fromOrchestratorResponse(response));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Could not reach the Knowledge Agent: $e',
          isUser: false,
          isError: true,
        ));
      });
    } finally {
      setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AtlasAI — Knowledge Agent'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Upload document',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UploadDocumentScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () => AuthService().signOut(),
            // No explicit navigation needed — AuthGate in main.dart
            // reacts to the auth state change and routes back to
            // LoginScreen automatically.
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: TextField(
              controller: _equipmentIdController,
              decoration: const InputDecoration(
                labelText: 'Equipment ID (optional)',
                hintText: 'e.g. PUMP-04',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _messages.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (context, i) => _MessageBubble(message: _messages[i]),
                  ),
          ),
          if (_isSending)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            IconButton(
              onPressed: _toggleListening,
              icon: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: _isListening ? Colors.red : null,
              ),
              tooltip: 'Ask by voice',
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Ask AtlasAI — e.g. "What do I check first when Pump 4 vibrates?"',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (_) => _send(),
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _isSending ? null : _send,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Ask a question by typing or tapping the mic.\nAnswers are grounded in your plant\'s documents.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final bgColor = isUser
        ? Theme.of(context).colorScheme.primaryContainer
        : (message.isError ? Colors.red.shade50 : Colors.grey.shade100);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.text),
            if (!isUser && !message.isError) ...[
              const SizedBox(height: 8),
              ConfidenceBadge(confidence: message.confidence ?? 0.0),
              if (message.sources.isNotEmpty) ...[
                const SizedBox(height: 6),
                CitationChips(sources: message.sources),
              ],
              if (message.reasoning != null && message.reasoning!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  message.reasoning!,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}