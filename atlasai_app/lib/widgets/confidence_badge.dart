import 'package:flutter/material.dart';

/// Small colored badge showing the Knowledge Agent's confidence score.
/// Green >= 0.7, amber 0.4-0.69, red < 0.4 — matches the Explainable AI
/// panel described in the plan (confidence score, sources, reasoning).
class ConfidenceBadge extends StatelessWidget {
  final double confidence;
  const ConfidenceBadge({super.key, required this.confidence});

  Color get _color {
    if (confidence >= 0.7) return Colors.green;
    if (confidence >= 0.4) return Colors.amber.shade800;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final pct = (confidence * 100).toStringAsFixed(0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insights, size: 13, color: _color),
          const SizedBox(width: 4),
          Text(
            'Confidence $pct%',
            style: TextStyle(fontSize: 11, color: _color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}