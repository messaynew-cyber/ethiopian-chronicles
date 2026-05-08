import 'package:flutter/material.dart';
import '../services/content_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  final ContentService content;
  const SettingsScreen({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _section('Language'),
          _tile('English / አማርኛ', 'English', Icons.translate, () {}),
          const SizedBox(height: 16),
          _section('Audio'),
          _tile('AI Narration', 'On', Icons.headphones, () {}),
          _tile('Narration Voice', 'Michelle (English)', Icons.record_voice_over, () {}),
          const SizedBox(height: 16),
          _section('Display'),
          _tile('Auto-play narration', 'Off', Icons.play_circle, () {}),
          _tile('Reduce motion', 'Off', Icons.animation, () {}),
          const SizedBox(height: 16),
          _section('Progress'),
          _tile('Chapters completed', '1 / ${content.chapters.length}', Icons.checklist, () {}),
          _tile('Achievements unlocked', '0 / 12', Icons.emoji_events, () {}),
          const SizedBox(height: 32),
          _section('About'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Ethiopian Chronicles v1.0\nBuilt with Flutter • AI-narrated\nContent curated from historical sources',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontFamily: 'monospace', height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title, style: const TextStyle(
      color: AppTheme.aksumGold, fontSize: 11, fontFamily: 'monospace',
      letterSpacing: 2, fontWeight: FontWeight.w600,
    )),
  );

  Widget _tile(String title, String subtitle, IconData icon, VoidCallback onTap) => Container(
    margin: const EdgeInsets.only(bottom: 6),
    decoration: AppTheme.glassCard(),
    child: ListTile(
      leading: Icon(icon, color: AppTheme.textMuted, size: 18),
      title: Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
      trailing: Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
      onTap: onTap,
      dense: true,
    ),
  );
}
