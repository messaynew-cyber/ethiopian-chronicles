import 'package:flutter/material.dart';
import '../services/content_service.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final ContentService content;
  final AppState appState;
  const SettingsScreen({super.key, required this.content, required this.appState});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _narrationOn = true;
  bool _autoPlay = false;
  bool _reduceMotion = false;
  String _voice = 'Michelle (English)';

  @override
  Widget build(BuildContext context) {
    final a = widget.appState;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(a.t('Settings', 'ቅንብሮች'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _section(a.t('Language', 'ቋንቋ')),
          _switchTile(
            a.t('አማርኛ / English', 'አማርኛ / English'),
            a.t('Toggle Amharic mode', 'አማርኛ ቀይር'),
            a.amharicMode,
            (v) => a.toggleAmharic(),
          ),
          const SizedBox(height: 16),
          _section(a.t('Audio Narration', 'ድምጽ ትረካ')),
          _switchTile(a.t('AI Narration', 'AI ትረካ'), a.t('Narrate chapters with AI voice', 'ምዕራፎችን በAI ድምጽ ተርክ'), _narrationOn, (v) => setState(() => _narrationOn = v)),
          _tile(a.t('Voice', 'ድምጽ'), _voice, Icons.record_voice_over, () {
            setState(() => _voice = _voice.contains('Michelle') ? 'David (English)' : 'Michelle (English)');
          }),
          _switchTile(a.t('Auto-play', 'ራስ-አጫውት'), a.t('Start narration automatically', 'ትረካውን በራስ-ሰር ጀምር'), _autoPlay, (v) => setState(() => _autoPlay = v)),
          const SizedBox(height: 16),
          _section(a.t('Display', 'ማሳያ')),
          _switchTile(a.t('Reduce motion', 'እንቅስቃሴ ቀንስ'), a.t('Minimize animations', 'እነማዎችን ቀንስ'), _reduceMotion, (v) => setState(() => _reduceMotion = v)),
          const SizedBox(height: 16),
          _section(a.t('Progress', 'ሂደት')),
          _tile(a.t('Chapters unlocked', 'የተከፈቱ ምዕራፎች'), '${widget.content.chapters.length} / ${widget.content.chapters.length}', Icons.lock_open, () {}),
          _tile(a.t('Achievements', 'ሽልማቶች'), '0 / 12', Icons.emoji_events, () {}),
          _tile(a.t('Reading time', 'የንባብ ጊዜ'), '~45 min', Icons.timer, () {}),
          const SizedBox(height: 32),
          _section(a.t('About', 'ስለ መተግበሪያው')),
          Container(
            padding: const EdgeInsets.all(16), decoration: AppTheme.glassCard(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.account_balance, color: AppTheme.accent, size: 20), const SizedBox(width: 10),
                  Text(a.t('Ethiopian Chronicles', 'ኢትዮጵያዊ ታሪኮች'),
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontFamily: 'serif', fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 10),
                Text(a.t(
                  'Version 1.0 • Built with Flutter\nAI-narrated • Offline-capable\n\n"A people without knowledge of their history\nare like trees without roots."',
                  'ስሪት 1.0 • በFlutter የተሰራ\nበAI የሚተረክ\n\n"ታሪካቸውን የማያውቅ ህዝብ\nእንደ ስር የሌለው ዛፍ ነው።"'),
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
    child: Text(title, style: const TextStyle(color: AppTheme.accent, fontSize: 11, fontFamily: 'monospace', letterSpacing: 2, fontWeight: FontWeight.w600)),
  );

  Widget _tile(String title, String subtitle, IconData icon, VoidCallback onTap) => Container(
    margin: const EdgeInsets.only(bottom: 6), decoration: AppTheme.glassCard(),
    child: ListTile(
      leading: Icon(icon, color: AppTheme.textMuted, size: 18),
      title: Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
      trailing: Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
      onTap: onTap, dense: true, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );

  Widget _switchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) => Container(
    margin: const EdgeInsets.only(bottom: 6), decoration: AppTheme.glassCard(),
    child: SwitchListTile(
      title: Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
      value: value, onChanged: (v) => onChanged(v), dense: true,
      activeColor: AppTheme.accent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
