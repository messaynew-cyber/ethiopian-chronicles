import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../services/content_service.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class ChapterScreen extends StatefulWidget {
  final Chapter chapter;
  final ContentService content;
  final AppState appState;
  const ChapterScreen({super.key, required this.chapter, required this.content, required this.appState});

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  final ScrollController _scrollController = ScrollController();
  double _progress = 0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final max = _scrollController.position.maxScrollExtent;
    if (max > 0) {
      setState(() => _progress = (_scrollController.offset / max).clamp(0.0, 1.0));
    }
  }

  void _toggleNarration() {
    setState(() => _isPlaying = !_isPlaying);
    // TODO: Implement audio playback via AudioService
  }

  @override
  Widget build(BuildContext context) {
    final chapter = widget.chapter;
    final eraColor = AppTheme.eraColor(chapter.eraId);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Main content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Hero header
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: AppTheme.background,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          eraColor.withOpacity(0.2),
                          AppTheme.background,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Icon(AppTheme.eraIcon(chapter.eraId), color: eraColor, size: 48),
                          const SizedBox(height: 16),
                          Text(chapter.title, style: const TextStyle(
                            color: AppTheme.textPrimary, fontSize: 28,
                            fontFamily: 'serif', fontWeight: FontWeight.w900,
                          )),
                          const SizedBox(height: 8),
                          Text('${chapter.location} • ${chapter.yearStart}–${chapter.yearEnd} CE',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12, fontFamily: 'monospace')),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Key figures
              if (chapter.keyFigures.isNotEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    height: 50,
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: chapter.keyFigures.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: AppTheme.glassCard(borderColor: eraColor),
                          child: Center(
                            child: Text('👤 ${chapter.keyFigures[index]}',
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12,
                                    fontFamily: 'monospace')),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // Chapter sections
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildSection(chapter.sections[index], eraColor),
                    childCount: chapter.sections.length,
                  ),
                ),
              ),

              // Next chapter hint
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 60),
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.glassCard(borderColor: Colors.white10),
                  child: Column(
                    children: [
                      Text('Next: The Reign of King Ezana',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 11,
                              fontFamily: 'monospace', letterSpacing: 2)),
                      const SizedBox(height: 8),
                      Text('Continue your journey →',
                          style: TextStyle(color: eraColor, fontSize: 14, fontFamily: 'serif')),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Narration FAB
          Positioned(
            right: 20,
            bottom: 100,
            child: FloatingActionButton(
              backgroundColor: _isPlaying ? eraColor : AppTheme.surface,
              onPressed: _toggleNarration,
              child: Icon(_isPlaying ? Icons.pause : Icons.headphones,
                  color: _isPlaying ? Colors.black : AppTheme.textSecondary),
            ),
          ),

          // Progress bar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 3,
              color: eraColor.withOpacity(0.2),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progress,
                child: Container(color: eraColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(ChapterSection section, Color eraColor) {
    switch (section.type) {
      case 'quote':
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: eraColor.withOpacity(0.4), width: 2)),
            color: eraColor.withOpacity(0.04),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(section.body ?? '', style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 15, fontStyle: FontStyle.italic,
                height: 1.8, fontFamily: 'serif',
              )),
              if (section.attribution != null) ...[
                const SizedBox(height: 10),
                Text(section.attribution!, style: TextStyle(
                    color: eraColor, fontSize: 11, fontFamily: 'monospace')),
              ],
            ],
          ),
        );
      case 'image':
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: AppTheme.glassCard(borderColor: Colors.white10),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  height: 200,
                  color: AppTheme.surfaceLight,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image, color: eraColor.withOpacity(0.3), size: 40),
                        const SizedBox(height: 8),
                        Text(section.caption ?? 'Historical image',
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ),
              if (section.caption != null)
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(section.caption!, style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12, fontStyle: FontStyle.italic)),
                ),
            ],
          ),
        );
      default: // text
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (section.title != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(width: 20, height: 1, color: eraColor),
                      const SizedBox(width: 10),
                      Text(section.title!, style: TextStyle(
                        color: eraColor, fontSize: 16, fontFamily: 'serif',
                        fontWeight: FontWeight.w700, letterSpacing: 1,
                      )),
                    ],
                  ),
                ),
              Text(section.body ?? '', style: const TextStyle(
                color: AppTheme.textPrimary, fontSize: 16, height: 1.85,
                fontFamily: 'serif', letterSpacing: 0.2,
              )),
            ],
          ),
        );
    }
  }
}
