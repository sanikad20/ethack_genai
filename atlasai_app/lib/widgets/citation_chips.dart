import 'package:flutter/material.dart';

/// Tappable chips for each source document cited in an answer.
/// Tap currently just shows the raw source id in a snackbar —
/// wire this to open the actual document (Firebase Storage URL
/// lookup via doc_id) once that mapping is available.
class CitationChips extends StatelessWidget {
  final List<String> sources;
  const CitationChips({super.key, required this.sources});

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: sources.asMap().entries.map((entry) {
        final i = entry.key + 1;
        final source = entry.value;
        return ActionChip(
          avatar: CircleAvatar(
            backgroundColor: Colors.blueGrey.shade100,
            child: Text('$i', style: const TextStyle(fontSize: 11)),
          ),
          label: Text(
            source.length > 24 ? '${source.substring(0, 24)}…' : source,
            style: const TextStyle(fontSize: 11),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Source: $source')),
            );
          },
        );
      }).toList(),
    );
  }
}