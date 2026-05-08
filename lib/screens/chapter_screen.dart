import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _ChapterScreenState extends State<ChapterScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  double _progress = 0;
  bool _isPlaying = false;
  late AnimationController _sectionAnimCtrl;
  late AnimationController _headerAnimCtrl;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _sectionAnimCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _headerAnimCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _headerAnimCtrl.forward();
    Future.delayed(const Duration(milliseconds: 200), () => _sectionAnimCtrl.forward());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _sectionAnimCtrl.dispose();
    _headerAnimCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    final max = _scrollController.position.maxScrollExtent;
    if (max > 0) setState(() => _progress = (_scrollController.offset / max).clamp(0.0, 1.0));
  }

  void _toggleNarration() {
    HapticFeedback.lightImpact();
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.appState.t('🔊 Narrating...', '🔊 በማተረክ ላይ...')),
          duration: const Duration(seconds: 2),
          backgroundColor: AppTheme.surface,
        ),
      );
    }
  }

  void _goToNextChapter() {
    final era = widget.content.getEra(widget.chapter.eraId);
    if (era == null) return;
    final chapters = widget.content.getChaptersForEra(widget.chapter.eraId);
    final currentIdx = chapters.indexWhere((c) => c.id == widget.chapter.id);
    if (currentIdx < chapters.length - 1) {
      // Next chapter in same era
      Navigator.pushReplacement(context, _chapterRoute(chapters[currentIdx + 1]));
    } else {
      // Next era
      final eraIdx = widget.content.eras.indexWhere((e) => e.id == widget.chapter.eraId);
      if (eraIdx < widget.content.eras.length - 1) {
        final nextEraChapters = widget.content.getChaptersForEra(widget.content.eras[eraIdx + 1].id);
        if (nextEraChapters.isNotEmpty) {
          Navigator.pushReplacement(context, _chapterRoute(nextEraChapters.first));
        }
      }
    }
  }

  PageRouteBuilder _chapterRoute(Chapter ch) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => ChapterScreen(chapter: ch, content: widget.content, appState: widget.appState),
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutExpo)),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 450),
  );

  @override
  Widget build(BuildContext context) {
    final chapter = widget.chapter;
    final eraColor = AppTheme.eraColor(chapter.eraId);
    final a = widget.appState;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Parchment
          Positioned.fill(child: IgnorePointer(child: Container(decoration: AppTheme.parchmentOverlay()))),

          // Main scroll
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Animated header
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: AppTheme.background,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FadeTransition(
                  opacity: CurvedAnimation(parent: _headerAnimCtrl, curve: Curves.easeOut),
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero)
                        .animate(CurvedAnimation(parent: _headerAnimCtrl, curve: Curves.easeOutExpo)),
                    child: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [eraColor.withOpacity(0.15), AppTheme.background],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 30),
                              Icon(AppTheme.eraIcon(chapter.eraId), color: eraColor, size: 42),
                              const SizedBox(height: 12),
                              Text(chapter.title, style: const TextStyle(
                                color: AppTheme.textPrimary, fontSize: 24,
                                fontFamily: 'serif', fontWeight: FontWeight.w900, letterSpacing: 1,
                              )),
                              const SizedBox(height: 6),
                              Text('${chapter.location} • ${chapter.yearStart}–${chapter.yearEnd} CE',
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontFamily: 'monospace', letterSpacing: 2)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Key figures
              if (chapter.keyFigures.isNotEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      itemCount: chapter.keyFigures.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: AppTheme.glassCard(borderColor: eraColor),
                        child: Text('👤 ${chapter.keyFigures[index]}',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontFamily: 'monospace')),
                      ),
                    ),
                  ),
                ),

              // Sections with staggered animation
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final delay = index * 0.15;
                      final anim = CurvedAnimation(
                        parent: _sectionAnimCtrl,
                        curve: Interval(delay.clamp(0.0, 1.0), (delay + 0.4).clamp(0.0, 1.0), curve: Curves.easeOutExpo),
                      );
                      return SectionAnimator(
                        animation: anim,
                        builder: (_, child) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(anim),
                            child: child,
                          ),
                        ),
                        child: _buildSection(chapter.sections[index], eraColor),
                      );
                    },
                    childCount: chapter.sections.length,
                  ),
                ),
              ),

              // Next chapter button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                  child: GestureDetector(
                    onTap: _goToNextChapter,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(18),
                      decoration: AppTheme.glassCard(borderColor: AppTheme.accent, opacity: 0.06),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_forward_rounded, color: AppTheme.accent.withOpacity(0.6), size: 20),
                          const SizedBox(width: 10),
                          Text(a.t('Continue your journey', 'ጉዞህን ቀጥል'),
                              style: TextStyle(color: AppTheme.accent, fontSize: 14, fontFamily: 'serif', fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Narration FAB with pulse animation
          Positioned(
            right: 20, bottom: 100,
            child: _isPlaying
                ? _PulseAnimation(child: _narrationFab(eraColor))
                : _narrationFab(eraColor),
          ),

          // Progress bar
          Positioned(bottom: 0, left: 0, right: 0,
            child: Container(
              height: 3,
              color: Colors.white.withOpacity(0.04),
              child: AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.centerLeft,
                widthFactor: _progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    boxShadow: [BoxShadow(color: AppTheme.accent.withOpacity(0.3), blurRadius: 4)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _narrationFab(Color color) => FloatingActionButton(
    heroTag: 'narration',
    backgroundColor: _isPlaying ? color : AppTheme.surface,
    onPressed: _toggleNarration,
    child: Icon(_isPlaying ? Icons.pause_rounded : Icons.headphones_rounded,
        color: _isPlaying ? AppTheme.background : AppTheme.textSecondary, size: 22),
  );

  Widget _buildSection(ChapterSection section, Color color) {
    switch (section.type) {
      case 'quote':
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: AppTheme.accent.withOpacity(0.4), width: 2)),
            color: AppTheme.accent.withOpacity(0.04),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(section.body ?? '', style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 15, fontStyle: FontStyle.italic,
                height: 1.85, fontFamily: 'serif', letterSpacing: 0.3,
              )),
              if (section.attribution != null) ...[
                const SizedBox(height: 10),
                Text(section.attribution!, style: const TextStyle(
                    color: AppTheme.accent, fontSize: 11, fontFamily: 'monospace')),
              ],
            ],
          ),
        );
      case 'image':
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: AppTheme.glassCard(),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: Container(
                  height: 200, color: AppTheme.surfaceLight,
                  child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.image_outlined, color: AppTheme.accent.withOpacity(0.3), size: 40),
                    const SizedBox(height: 8),
                    Text(section.caption ?? 'Historical image',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  ])),
                ),
              ),
              if (section.caption != null)
                Padding(padding: const EdgeInsets.all(14),
                    child: Text(section.caption!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontStyle: FontStyle.italic))),
            ],
          ),
        );
      default:
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (section.title != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(children: [
                    Container(width: 24, height: 1.5, color: AppTheme.accent),
                    const SizedBox(width: 10),
                    Text(section.title!, style: const TextStyle(
                      color: AppTheme.accent, fontSize: 16, fontFamily: 'serif', fontWeight: FontWeight.w700, letterSpacing: 1,
                    )),
                  ]),
                ),
              Text(section.body ?? '', style: const TextStyle(
                color: AppTheme.textPrimary, fontSize: 16, height: 1.85, fontFamily: 'serif', letterSpacing: 0.2,
              )),
            ],
          ),
        );
    }
  }
}

class _PulseAnimation extends StatefulWidget {
  final Widget child;
  const _PulseAnimation({required this.child});

  @override
  State<_PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<_PulseAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SectionAnimator(
      animation: _ctrl,
      builder: (_, child) => Transform.scale(scale: 1.0 + _ctrl.value * 0.08, child: child),
      child: widget.child,
    );
  }
}

class AnimatedFractionallySizedBox extends StatelessWidget {
  final Duration duration;
  final AlignmentGeometry alignment;
  final double widthFactor;
  final Widget child;
  const AnimatedFractionallySizedBox({
    super.key, required this.duration, required this.alignment,
    required this.widthFactor, required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: widthFactor),
      duration: duration,
      curve: Curves.easeOut,
      builder: (_, val, child) => FractionallySizedBox(
        alignment: alignment, widthFactor: val, child: child,
      ),
      child: child,
    );
  }
}

class SectionAnimator extends AnimatedWidget {
  final Widget? child;
  final TransitionBuilder builder;
  const SectionAnimator({super.key, required super.listenable, required this.builder, this.child});

  @override
  Widget build(BuildContext context) => builder(context, child);
}
