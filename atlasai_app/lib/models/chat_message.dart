/// Represents one turn in the Knowledge Agent chat.
/// Assistant messages carry the extra fields the backend now returns:
/// merged_answer, per-agent confidence, and source citations —
/// this is what the Explainable AI panel (badge + chips) renders from.
class ChatMessage {
  final String text;
  final bool isUser;
  final double? confidence; // null for user messages
  final List<String> sources;
  final String? reasoning;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.confidence,
    this.sources = const [],
    this.reasoning,
    this.isError = false,
  });

  /// Builds the assistant message straight from the /query response body.
  factory ChatMessage.fromOrchestratorResponse(Map<String, dynamic> json) {
    final results = (json['results'] as List?) ?? [];
    final sources = <String>{};
    for (final r in results) {
      sources.addAll(List<String>.from(r['sources'] ?? const []));
    }
    final reasoning = results.isNotEmpty ? results.first['reasoning'] as String? : null;

    return ChatMessage(
      text: json['merged_answer'] as String? ?? '',
      isUser: false,
      confidence: (json['overall_confidence'] as num?)?.toDouble() ?? 0.0,
      sources: sources.toList(),
      reasoning: reasoning,
    );
  }
}