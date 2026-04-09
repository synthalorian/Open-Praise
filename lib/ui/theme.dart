import 'package:flutter/material.dart';

/// Neon grid theme constants used across the app.
class NeonTheme {
  NeonTheme._();

  static const Color neonGreen = Colors.greenAccent;
  static const Color neonPink = Colors.pinkAccent;
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color bg = Colors.black;
  static const Color surface = Color(0xFF1A1A1A);
  static const Color muted = Colors.white38;
  static const Color text = Colors.white;

  static const TextStyle mono = TextStyle(
    fontFamily: 'monospace',
    color: neonGreen,
  );

  static const TextStyle heading = TextStyle(
    fontFamily: 'monospace',
    color: neonGreen,
    fontWeight: FontWeight.bold,
    letterSpacing: 2.0,
  );

  static BoxDecoration neonBorder([Color color = neonGreen]) => BoxDecoration(
        border: Border.all(color: color.withValues(alpha:0.6)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.black,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha:0.15), blurRadius: 8),
        ],
      );

  static ButtonStyle neonButton([Color color = neonGreen]) =>
      OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      );

  static AppBar appBar(String title, {List<Widget>? actions}) => AppBar(
        title: Text(title, style: heading.copyWith(fontSize: 16)),
        backgroundColor: bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: neonGreen),
        actions: actions,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              color: neonGreen,
              boxShadow: [
                BoxShadow(color: neonGreen, blurRadius: 4, spreadRadius: 1),
              ],
            ),
          ),
        ),
      );
}
