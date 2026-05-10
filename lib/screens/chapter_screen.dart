import 'dart:math';
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
  static const _ttsChannel = MethodChannel('com.adwa.chronicles/tts');
  double _progress = 0;
  double _scrollOffset = 0;
  bool _isSpeaking = false;
  late AnimationController _sectionAnimCtrl;
  late AnimationController _headerAnimCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _ambientCtrl;
  final List<_Particle> _particles = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _sectionAnimCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _headerAnimCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _particleCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 12));
    _ambientCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 8));
    _headerAnimCtrl.forward();
    _particleCtrl.repeat();
    _ambientCtrl.repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 200), () => _sectionAnimCtrl.forward());
    _ttsChannel.setMethodCallHandler((call) {
      if (call.method == 'onDone') {
        if (mounted) setState(() => _isSpeaking = false);
      }
      return Future.value();
    });
    _generateParticles();
  }

  void _generateParticles() {
    _particles.clear();
    for (int i = 0; i < 18; i++) {
      _particles.add(_Particle(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        size: 1.5 + _rng.nextDouble() * 2.5,
        speed: 0.3 + _rng.nextDouble() * 0.7,
        opacity: 0.08 + _rng.nextDouble() * 0.12,
      ));
    }
  }

  @override
  void dispose() {
    _ttsChannel.invokeMethod('stop');
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _sectionAnimCtrl.dispose();
    _headerAnimCtrl.dispose();
    _pulseCtrl.dispose();
    _particleCtrl.dispose();
    _ambientCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    final max = _scrollController.position.maxScrollExtent;
    setState(() {
      _scrollOffset = _scrollController.offset;
      _progress = max > 0 ? (_scrollController.offset / max).clamp(0.0, 1.0) : 0;
    });
  }

  Future<void> _stopNarration() async {
    await _ttsChannel.invokeMethod('stop');
    if (mounted) setState(() => _isSpeaking = false);
  }

  Future<void> _toggleNarration() async {
    HapticFeedback.lightImpact();
    if (_isSpeaking) {
      await _stopNarration();
    } else {
      final a = widget.appState;
      final ch = widget.chapter;
      final isAm = a.amharicMode && ch.sectionsAm != null && ch.sectionsAm!.isNotEmpty;
      final sections = isAm ? ch.sectionsAm! : ch.sections;
      final buffer = StringBuffer();
      buffer.writeln(a.t(ch.title, ch.title));
      buffer.writeln();
      for (final section in sections) {
        if (section.body != null) { buffer.writeln(section.body); buffer.writeln(); }
      }
      try {
        await _ttsChannel.invokeMethod('speak', {
          'text': buffer.toString(),
          'language': a.amharicMode ? 'am' : 'en',
        });
        if (mounted) {
          setState(() => _isSpeaking = true);
          _pulseCtrl.repeat(reverse: true);
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(a.t('TTS not available', 'ድምጽ አይገኝም')), backgroundColor: AppTheme.surface),
          );
        }
      }
    }
  }

  void _goToNextChapter() {
    _stopNarration();
    final era = widget.content.getEra(widget.chapter.eraId);
    if (era == null) return;
    final chapters = widget.content.getChaptersForEra(widget.chapter.eraId);
    final currentIdx = chapters.indexWhere((c) => c.id == widget.chapter.id);
    if (currentIdx < chapters.length - 1) {
      Navigator.pushReplacement(context, _chapterRoute(chapters[currentIdx + 1]));
    } else {
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
          position: Tween<Offset>(begin: const Offset(0.12, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutExpo)),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 550),
  );

  @override
  Widget build(BuildContext context) {
    final chapter = widget.chapter;
    final eraColor = AppTheme.eraColor(chapter.eraId);
    final a = widget.appState;
    final isAm = a.amharicMode && chapter.sectionsAm != null && chapter.sectionsAm!.isNotEmpty;
    final sections = isAm ? chapter.sectionsAm! : chapter.sections;

    return AnimatedBuilder(
      animation: _ambientCtrl,
      builder: (_, __) => Scaffold(
        backgroundColor: AppTheme.background,
        body: Stack(
          children: [
            // Ambient floating particles
            ..._particles.map((p) => AnimatedBuilder(
              animation: _particleCtrl,
              builder: (_, __) {
                final t = _particleCtrl.value;
                final py = (p.y + t * p.speed) % 1.0;
                return Positioned(
                  left: p.x * MediaQuery.of(context).size.width,
                  top: py * MediaQuery.of(context).size.height,
                  child: Container(
                    width: p.size, height: p.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: eraColor.withOpacity(p.opacity * (0.5 + 0.5 * sin(t * 6 + p.x * 10))),
                    ),
                  ),
                );
              },
            )),

            // Parchment overlay
            Positioned.fill(child: IgnorePointer(child: Container(decoration: AppTheme.parchmentOverlay()))),

            // V2: Reading progress bar (Spotdly-inspired thin gold line)
            Positioned(
              top: 0, left: 0, right: 0,
              child: SafeArea(
                bottom: false,
                child: Container(
                  height: 2.5,
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(eraColor.withOpacity(0.7)),
                  ),
                ),
              ),
            ),

            // Main scroll
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Parallax header
                SliverAppBar(
                  expandedHeight: 260,
                  pinned: true,
                  backgroundColor: AppTheme.background,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textSecondary),
                    onPressed: () {
                      _stopNarration();
                      Navigator.pop(context);
                    },
                  ),
                  flexibleSpace: FadeTransition(
                    opacity: CurvedAnimation(parent: _headerAnimCtrl, curve: Curves.easeOut),
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero)
                          .animate(CurvedAnimation(parent: _headerAnimCtrl, curve: Curves.easeOutExpo)),
                      child: FlexibleSpaceBar(
                        background: LayoutBuilder(
                          builder: (_, constraints) {
                            final parallax = (_scrollOffset * 0.3).clamp(0.0, 60.0);
                            return Transform.translate(
                              offset: Offset(0, -parallax),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                    colors: [eraColor.withOpacity(0.2), AppTheme.background.withOpacity(0.0), AppTheme.background],
                                    stops: const [0.0, 0.5, 1.0],
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 30),
                                      // Glowing era icon with 3D rotation
                                      Transform(
                                        transform: Matrix4.identity()
                                          ..setEntry(3, 2, 0.001)
                                          ..rotateY(_scrollOffset * 0.0005)
                                          ..rotateX(-_scrollOffset * 0.0003),
                                        alignment: Alignment.center,
                                        child: Container(
                                          width: 64, height: 64,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: eraColor.withOpacity(0.08),
                                            boxShadow: [
                                              BoxShadow(color: eraColor.withOpacity(0.15), blurRadius: 20, spreadRadius: -2),
                                            ],
                                          ),
                                          child: Icon(AppTheme.eraIcon(chapter.eraId), color: eraColor, size: 32),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Text(chapter.title, style: TextStyle(
                                        color: AppTheme.textPrimary, fontSize: 24,
                                        fontFamily: 'serif', fontWeight: FontWeight.w900, letterSpacing: 1,
                                        shadows: [Shadow(color: eraColor.withOpacity(0.3), blurRadius: 12)],
                                      )),
                                      const SizedBox(height: 6),
                                      Text('${chapter.location} • ${chapter.yearStart}–${chapter.yearEnd} CE',
                                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontFamily: 'monospace', letterSpacing: 2)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // Key figures with 3D hover-ready chips
                if (chapter.keyFigures.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 50,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        itemCount: chapter.keyFigures.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final delay = 400 + index * 120;
                          final figAnim = CurvedAnimation(
                            parent: _sectionAnimCtrl,
                            curve: Interval(delay / 1000.0, 1.0, curve: Curves.easeOutBack),
                          );
                          return AnimatedBuilder(
                            animation: figAnim,
                            builder: (_, __) => Transform(
                              transform: Matrix4.identity()
                                ..translate(0.0, (1 - figAnim.value) * 30, 0.0)
                                ..scale(figAnim.value.clamp(0.0, 1.0)),
                              child: Opacity(
                                opacity: figAnim.value,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: AppTheme.glassCard(borderColor: eraColor, opacity: 0.1),
                                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                                    Text('👤', style: TextStyle(fontSize: 10)),
                                    const SizedBox(width: 4),
                                    Text(chapter.keyFigures[index],
                                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontFamily: 'monospace')),
                                  ]),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // Sections — staggered animations with 3D entry
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final delay = index * 0.12;
                        final anim = CurvedAnimation(
                          parent: _sectionAnimCtrl,
                          curve: Interval(delay.clamp(0.0, 1.0), (delay + 0.35).clamp(0.0, 1.0), curve: Curves.easeOutExpo),
                        );
                        // Parallax per section
                        final sectionOffset = (_scrollOffset - index * 200).clamp(-30.0, 30.0);
                        return AnimatedBuilder(
                          animation: anim,
                          builder: (_, child) => Transform.translate(
                            offset: Offset(0, (1 - anim.value) * 60 + sectionOffset * 0.15),
                            child: Opacity(
                              opacity: anim.value.clamp(0.0, 1.0),
                              child: Transform(
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateX((1 - anim.value) * 0.3)
                                  ..scale(anim.value.clamp(0.85, 1.0)),
                                alignment: Alignment.topCenter,
                                child: child,
                              ),
                            ),
                          ),
                          child: _SectionCard(section: sections[index], color: eraColor, index: index),
                        );
                      },
                      childCount: sections.length,
                    ),
                  ),
                ),

                // Next chapter button with pulsing glow
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                    child: AnimatedBuilder(
                      animation: _ambientCtrl,
                      builder: (_, __) {
                        final glow = 0.6 + _ambientCtrl.value * 0.4;
                        return GestureDetector(
                          onTap: _goToNextChapter,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: AppTheme.accent.withOpacity(0.04 * glow),
                              border: Border.all(color: AppTheme.accent.withOpacity(0.15 * glow), width: 0.8),
                              boxShadow: [
                                BoxShadow(color: AppTheme.accent.withOpacity(0.08 * glow), blurRadius: 20, spreadRadius: -4),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_forward_rounded, color: AppTheme.accent.withOpacity(glow), size: 20),
                                const SizedBox(width: 10),
                                Text(a.t('Continue your journey', 'ጉዞህን ቀጥል'),
                                    style: TextStyle(color: AppTheme.accent.withOpacity(glow), fontSize: 14, fontFamily: 'serif', fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            // Narration FAB — animated pulse ring when speaking
            Positioned(
              right: 20, bottom: 100,
              child: _isSpeaking ? _speakingFab(eraColor) : _idleFab(),
            ),

            // Progress bar with glow
            Positioned(bottom: 0, left: 0, right: 0,
              child: Container(
                height: 3,
                color: Colors.white.withOpacity(0.04),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      boxShadow: [BoxShadow(color: AppTheme.accent.withOpacity(0.5), blurRadius: 6)],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _speakingFab(Color color) => AnimatedBuilder(
    animation: _pulseCtrl,
    builder: (_, __) {
      final scale = 1.0 + _pulseCtrl.value * 0.15;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulse ring
          Container(
            width: 56 * scale, height: 56 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3 * (1 - _pulseCtrl.value)), width: 2),
            ),
            child: FloatingActionButton(
              heroTag: 'narration_active',
              backgroundColor: color,
              onPressed: _toggleNarration,
              child: const Icon(Icons.pause_rounded, color: AppTheme.background, size: 24),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Text('Narrating...', style: TextStyle(color: color, fontSize: 9, fontFamily: 'monospace', letterSpacing: 1)),
          ),
        ],
      );
    },
  );

  Widget _idleFab() => FloatingActionButton(
    heroTag: 'narration_idle',
    backgroundColor: AppTheme.surface,
    onPressed: _toggleNarration,
    child: const Icon(Icons.headphones_rounded, color: AppTheme.textSecondary, size: 22),
  );
}

// ─── Particle model ───
class _Particle {
  final double x, y, size, speed, opacity;
  const _Particle({required this.x, required this.y, required this.size, required this.speed, required this.opacity});
}

// ─── Section card with 3D tilt and glass morphing ───
class _SectionCard extends StatefulWidget {
  final ChapterSection section;
  final Color color;
  final int index;
  const _SectionCard({required this.section, required this.color, required this.index});

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> with SingleTickerProviderStateMixin {
  double _tiltX = 0, _tiltY = 0;
  double _scale = 1.0;
  late AnimationController _hoverCtrl;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _hoverCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final section = widget.section;
    final color = widget.color;
    final child = _buildContent(section, color);

    return GestureDetector(
      onTapDown: (d) {
        final box = context.findRenderObject() as RenderBox;
        final local = box.globalToLocal(d.globalPosition);
        final cx = box.size.width / 2;
        final cy = box.size.height / 2;
        setState(() {
          _tiltX = (local.dy - cy) / cy * 0.04;
          _tiltY = (local.dx - cx) / cx * -0.04;
          _scale = 0.985;
        });
      },
      onTapUp: (_) {
        _hoverCtrl.forward().then((_) => _hoverCtrl.reverse());
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) setState(() { _tiltX = 0; _tiltY = 0; _scale = 1.0; });
        });
      },
      onTapCancel: () {
        if (mounted) setState(() { _tiltX = 0; _tiltY = 0; _scale = 1.0; });
      },
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_tiltX)
          ..rotateY(_tiltY),
        child: Transform.scale(
          scale: _scale,
          child: child,
        ),
      ),
    );
  }

  Widget _buildContent(ChapterSection section, Color color) {
    final isEven = widget.index % 2 == 0;

    switch (section.type) {
      case 'quote':
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color.withOpacity(0.5), width: 3)),
            color: color.withOpacity(0.05),
            borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.format_quote, color: color.withOpacity(0.4), size: 16),
                const SizedBox(width: 8),
                Container(width: 20, height: 1, color: color.withOpacity(0.3)),
              ]),
              const SizedBox(height: 14),
              Text(section.body ?? '', style: TextStyle(
                color: AppTheme.textSecondary, fontSize: 16, fontStyle: FontStyle.italic,
                height: 1.9, fontFamily: 'serif', letterSpacing: 0.3,
              )),
              if (section.attribution != null) ...[
                const SizedBox(height: 12),
                Row(children: [
                  const Spacer(),
                  Icon(Icons.horizontal_rule, color: color.withOpacity(0.3), size: 14),
                  const SizedBox(width: 6),
                  Text(section.attribution!, style: TextStyle(
                      color: color, fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.w600)),
                ]),
              ],
            ],
          ),
        );
      case 'image':
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: AppTheme.glassCard(borderColor: color, opacity: 0.08),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: Container(
                  height: 200, color: AppTheme.surfaceLight,
                  child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.08),
                        border: Border.all(color: color.withOpacity(0.2)),
                      ),
                      child: Icon(Icons.image_outlined, color: color.withOpacity(0.4), size: 28),
                    ),
                    const SizedBox(height: 10),
                    Text(section.caption ?? 'Historical image',
                        style: TextStyle(color: color.withOpacity(0.5), fontSize: 12, letterSpacing: 1)),
                  ])),
                ),
              ),
              if (section.caption != null)
                Padding(padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      Container(width: 3, height: 14, color: color.withOpacity(0.3)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(section.caption!,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontStyle: FontStyle.italic))),
                    ])),
            ],
          ),
        );
      default: // 'text'
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: isEven ? Alignment.topLeft : Alignment.topRight,
              end: Alignment.bottomCenter,
              colors: [color.withOpacity(0.04), Colors.transparent],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.04), width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (section.title != null) ...[
                Row(children: [
                  Container(
                    width: 32, height: 2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1),
                      gradient: LinearGradient(colors: [color, color.withOpacity(0.2)]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(section.title!, style: TextStyle(
                      color: color, fontSize: 16, fontFamily: 'serif', fontWeight: FontWeight.w700, letterSpacing: 1,
                    )),
                  ),
                ]),
                const SizedBox(height: 16),
              ],
              Text(section.body ?? '', style: const TextStyle(
                color: AppTheme.textPrimary, fontSize: 16, height: 1.9, fontFamily: 'serif', letterSpacing: 0.2,
              )),
            ],
          ),
        );
    }
  }
}
