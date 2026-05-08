import 'package:flutter/material.dart';
import '../services/content_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final ContentService content;
  const SettingsScreen({super.key, required this.content});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _amharicMode = false;
  bool _narrationOn = true;
  bool _autoPlay = false;
  bool _reduceMotion = false;
  String _voice = 'Michelle (English)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _section('Language'),
          _switchTile('አማርኛ / English', 'Toggle Amharic mode', _amharicMode, (v) {
            setState(() => _amharicMode = v);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(v ? 'Amharic mode enabled' : 'English mode'), duration: const Duration(seconds: 1)),
            );
          }),
          const SizedBox(height: 16),
          _section('Audio Narration'),
          _switchTile('AI Narration', 'Narrate chapters with AI voice', _narrationOn, (v) => setState(() => _narrationOn = v)),
          _tile('Voice', _voice, Icons.record_voice_over, () {
            setState(() => _voice = _voice.contains('Michelle') ? 'David (English)' : 'Michelle (English)');
          }),
          _switchTile('Auto-play', 'Start narration automatically', _autoPlay, (v) => setState(() => _autoPlay = v)),
          const SizedBox(height: 16),
          _section('Display'),
          _switchTile('Reduce motion', 'Minimize animations', _reduceMotion, (v) => setState(() => _reduceMotion = v)),
          const SizedBox(height: 16),
          _section('Progress'),
          _tile('Chapters unlocked', '1 / ${widget.content.chapters.length}', Icons.lock_open, () {}),
          _tile('Achievements', '0 / 12', Icons.emoji_events, () {}),
          _tile('Reading time', '~45 minutes', Icons.timer, () {}),
          const SizedBox(height: 32),
          _section('About'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.glassCard(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Text('🏛️', style: TextStyle(fontSize: 20)), const SizedBox(width: 10),
                  const Text('Ethiopian Chronicles', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontFamily: 'serif', fontWeight: FontWeight.w700))]),
                const SizedBox(height: 10),
                Text('Version 1.0 • Built with Flutter\nAI-narrated • Offline-capable\nContent curated from historical sources\n\n"A people without knowledge of their history are like trees without roots."',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontFamily: 'monospace', height: 1.6)),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title, style: const TextStyle(
      color: AppTheme.aksumGold, fontSize: 11, fontFamily: 'monospace', letterSpacing: 2, fontWeight: FontWeight.w600,
    )),
  );

  Widget _tile(String title, String subtitle, IconData icon, VoidCallback onTap) => Container(
    margin: const EdgeInsets.only(bottom: 6),
    decoration: AppTheme.glassCard(),
    child: ListTile(
      leading: Icon(icon, color: AppTheme.textMuted, size: 18),
      title: Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
      trailing: Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
      onTap: onTap, dense: true, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  Widget _switchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) => Container(
    margin: const EdgeInsets.only(bottom: 6),
    decoration: AppTheme.glassCard(),
    child: SwitchListTile(
      title: Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
      value: value, onChanged: onChanged, dense: true,
      activeColor: AppTheme.aksumGold,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
