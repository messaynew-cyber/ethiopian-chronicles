import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/chapter.dart';
import '../services/content_service.dart';
import '../theme/app_theme.dart';
import '../widgets/timeline_widget.dart';
import 'chapter_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final ContentService content;
  const HomeScreen({super.key, required this.content});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedEraId = 'aksumite';

  void _onEraSelected(String eraId) {
    setState(() => _selectedEraId = eraId);
  }

  void _openChapter(Chapter chapter) {
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (_, __, ___) => ChapterScreen(chapter: chapter, content: widget.content),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final era = widget.content.getEra(_selectedEraId);
    final chapters = widget.content.getChaptersForEra(_selectedEraId);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Subtle parchment texture overlay
          Positioned.fill(
            child: IgnorePointer(
              child: Container(decoration: AppTheme.parchmentOverlay()),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 20, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ETHIOPIAN', style: TextStyle(
                            color: AppTheme.textPrimary, fontSize: 20,
                            fontFamily: 'serif', fontWeight: FontWeight.w900, letterSpacing: 3,
                          )),
                          Text('CHRONICLES', style: TextStyle(
                            color: AppTheme.aksumGold, fontSize: 11,
                            fontFamily: 'monospace', letterSpacing: 5, fontWeight: FontWeight.w600,
                          )),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune, color: AppTheme.textMuted, size: 18),
                        onPressed: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => SettingsScreen(content: widget.content))),
                      ),
                    ],
                  ),
                ),

                // Timeline — glassmorphism icons
                SizedBox(
                  height: 110,
                  child: TimelineWidget(
                    eras: widget.content.eras,
                    selectedEraId: _selectedEraId,
                    onEraSelected: _onEraSelected,
                  ),
                ),

                // Era description card — centered icon, cream/gold title
                if (era != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      decoration: AppTheme.glassCard(
                        borderColor: Color(era.color),
                        opacity: 0.08,
                      ),
                      child: Column(
                        children: [
                          // Centered icon
                          Icon(AppTheme.eraIcon(era.id),
                              color: Color(era.color).withOpacity(0.7), size: 28),
                          const SizedBox(height: 10),
                          // Date label ABOVE title
                          Text(
                            '${era.startYear} – ${era.endYear} CE',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 10,
                              fontFamily: 'monospace', letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Title in warm cream
                          Text(
                            era.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.textTitle, fontSize: 20,
                              fontFamily: 'serif', fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            era.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13, height: 1.55, letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Chapters
                Expanded(
                  child: chapters.isEmpty
                      ? const Center(child: Text('Coming soon...',
                          style: TextStyle(color: AppTheme.textMuted)))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          itemCount: chapters.length,
                          itemBuilder: (context, index) {
                            final ch = chapters[index];
                            return _ChapterCard(
                              chapter: ch,
                              onTap: () => _openChapter(ch),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final Chapter chapter;
  final VoidCallback onTap;

  const _ChapterCard({required this.chapter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.eraColor(chapter.eraId);
    final locked = !chapter.isFree;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: locked ? null : onTap,
        child: locked
            ? _LockedCard(color: color, title: chapter.title, subtitle: '${chapter.location} • ${chapter.yearStart} CE')
            : Hero(
                tag: 'chapter_${chapter.id}',
                child: Material(
                  type: MaterialType.transparency,
                  child: _UnlockedCard(color: color, chapter: chapter),
                ),
              ),
      ),
    );
  }
}

class _UnlockedCard extends StatelessWidget {
  final Color color;
  final Chapter chapter;
  const _UnlockedCard({required this.color, required this.chapter});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutExpo,
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.glassCard(borderColor: color, opacity: 0.08),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: color.withOpacity(0.08),
              border: Border.all(color: color.withOpacity(0.25), width: 1),
            ),
            child: Icon(Icons.menu_book_rounded, color: color.withOpacity(0.7), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(chapter.title, style: TextStyle(
                  color: AppTheme.textTitle, fontSize: 15,
                  fontFamily: 'serif', fontWeight: FontWeight.w600,
                )),
                const SizedBox(height: 3),
                Text(
                  '${chapter.location} • ${chapter.yearStart} CE',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontFamily: 'monospace', letterSpacing: 1),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.4), size: 22),
        ],
      ),
    );
  }
}

class _LockedCard extends StatelessWidget {
  final Color color;
  final String title;
  final String subtitle;

  const _LockedCard({required this.color, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.frostedCard(tint: color),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white.withOpacity(0.03),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: const Icon(Icons.lock_outline, color: AppTheme.textMuted, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 15,
                  fontFamily: 'serif', fontWeight: FontWeight.w500,
                )),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontFamily: 'monospace')),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Text('UNLOCK', style: TextStyle(
                color: color.withOpacity(0.5), fontSize: 9,
                fontFamily: 'monospace', fontWeight: FontWeight.w600, letterSpacing: 2)),
          ),
        ],
      ),
    );
  }
}
