import 'package:flutter/material.dart';
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
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onEraSelected(String eraId) {
    setState(() => _selectedEraId = eraId);
    final eraIndex = widget.content.eras.indexWhere((e) => e.id == eraId);
    if (eraIndex >= 0 && eraIndex < widget.content.eras.length) {
      _pageController.animateToPage(eraIndex,
          duration: const Duration(milliseconds: 500), curve: Curves.easeOutExpo);
    }
  }

  void _openChapter(Chapter chapter) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ChapterScreen(chapter: chapter, content: widget.content),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final era = widget.content.getEra(_selectedEraId);
    final chapters = widget.content.getChaptersForEra(_selectedEraId);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ETHIOPIAN', style: TextStyle(
                        color: AppTheme.textPrimary, fontSize: 22,
                        fontFamily: 'serif', fontWeight: FontWeight.w900, letterSpacing: 4,
                      )),
                      Text('CHRONICLES', style: TextStyle(
                        color: AppTheme.aksumGold, fontSize: 14,
                        fontFamily: 'monospace', letterSpacing: 6, fontWeight: FontWeight.w600,
                      )),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune, color: AppTheme.textMuted, size: 20),
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => SettingsScreen(content: widget.content))),
                  ),
                ],
              ),
            ),

            // Timeline
            SizedBox(
              height: 100,
              child: TimelineWidget(
                eras: widget.content.eras,
                selectedEraId: _selectedEraId,
                onEraSelected: _onEraSelected,
              ),
            ),

            // Era description
            if (era != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.glassCard(borderColor: Color(era.color)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(AppTheme.eraEmoji(era.id), style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(era.name,
                                style: TextStyle(color: Color(era.color), fontSize: 18,
                                    fontFamily: 'serif', fontWeight: FontWeight.w700)),
                          ),
                          Text('${era.startYear} – ${era.endYear} CE',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11,
                                  fontFamily: 'monospace')),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(era.description,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5)),
                    ],
                  ),
                ),
              ),

            // Chapters list
            Expanded(
              child: chapters.isEmpty
                  ? const Center(child: Text('Coming soon...',
                      style: TextStyle(color: AppTheme.textMuted)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: chapters.length,
                      itemBuilder: (context, index) {
                        final ch = chapters[index];
                        final isLocked = !ch.isFree;
                        return _ChapterCard(
                          chapter: ch,
                          locked: isLocked,
                          onTap: () => _openChapter(ch),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final Chapter chapter;
  final bool locked;
  final VoidCallback onTap;

  const _ChapterCard({required this.chapter, required this.locked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.eraColor(chapter.eraId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: locked ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(18),
          decoration: AppTheme.glassCard(borderColor: locked ? Colors.white10 : color),
          child: Row(
            children: [
              // Chapter number indicator
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (locked ? Colors.white10 : color).withOpacity(locked ? 0.05 : 0.1),
                  border: Border.all(color: (locked ? Colors.white10 : color).withOpacity(locked ? 0.15 : 0.3)),
                ),
                child: Center(
                  child: locked
                      ? const Icon(Icons.lock, color: AppTheme.textMuted, size: 16)
                      : Icon(Icons.menu_book, color: color, size: 18),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(chapter.title, style: TextStyle(
                      color: locked ? AppTheme.textMuted : AppTheme.textPrimary,
                      fontSize: 16, fontFamily: 'serif', fontWeight: FontWeight.w600,
                    )),
                    const SizedBox(height: 4),
                    Text('${chapter.location} • ${chapter.yearStart} CE',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontFamily: 'monospace')),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: locked ? AppTheme.textMuted : color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
