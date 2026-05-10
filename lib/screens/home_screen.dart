import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/chapter.dart';
import '../services/content_service.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/timeline_widget.dart';
import 'chapter_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final ContentService content;
  final AppState appState;
  const HomeScreen({super.key, required this.content, required this.appState});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedEraId = 'aksumite';

  void _onEraSelected(String eraId) => setState(() => _selectedEraId = eraId);

  void _openChapter(Chapter chapter) {
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (_, __, ___) => ChapterScreen(
        chapter: chapter, content: widget.content, appState: widget.appState,
      ),
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutExpo);
        return AnimatedBuilder(
          animation: curved,
          builder: (_, w) => Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..translate(0.0, 0.0, (1 - curved.value) * -200)
              ..scale(curved.value.clamp(0.7, 1.0)),
            alignment: Alignment.center,
            child: Opacity(
              opacity: curved.value.clamp(0.0, 1.0),
              child: w,
            ),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 650),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final era = widget.content.getEra(_selectedEraId);
    final chapters = widget.content.getChaptersForEra(_selectedEraId);
    final a = widget.appState;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Positioned.fill(child: IgnorePointer(child: Container(decoration: AppTheme.parchmentOverlay()))),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 20, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.t('ETHIOPIAN', 'ኢትዮጵያዊ'), style: const TextStyle(
                            color: AppTheme.textPrimary, fontSize: 20,
                            fontFamily: 'serif', fontWeight: FontWeight.w900, letterSpacing: 3,
                          )),
                          Text(a.t('CHRONICLES', 'ታሪኮች'), style: const TextStyle(
                            color: AppTheme.accent, fontSize: 11,
                            fontFamily: 'monospace', letterSpacing: 5, fontWeight: FontWeight.w600,
                          )),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune, color: AppTheme.textMuted, size: 18),
                        onPressed: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => SettingsScreen(content: widget.content, appState: a))),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 110, child: TimelineWidget(
                  eras: widget.content.eras,
                  selectedEraId: _selectedEraId,
                  onEraSelected: _onEraSelected,
                  appState: a,
                )),
                if (era != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      decoration: AppTheme.glassCard(borderColor: Color(era.color), opacity: 0.08),
                      child: Column(
                        children: [
                          Icon(AppTheme.eraIcon(era.id), color: Color(era.color).withOpacity(0.7), size: 28),
                          const SizedBox(height: 10),
                          Text('${era.startYear} – ${era.endYear} CE',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 10,
                                  fontFamily: 'monospace', letterSpacing: 2)),
                          const SizedBox(height: 6),
                          Text(a.t(era.name, AppTheme.eraAmharic(era.id).isNotEmpty
                              ? AppTheme.eraAmharic(era.id) : era.name),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppTheme.textTitle, fontSize: 20,
                                  fontFamily: 'serif', fontWeight: FontWeight.w700, letterSpacing: 1)),
                          const SizedBox(height: 8),
                          Text(era.description, textAlign: TextAlign.center, style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13, height: 1.55, letterSpacing: 0.2)),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: chapters.isEmpty
                      ? Center(child: Text(a.t('Coming soon...', 'በቅርቡ...'), style: const TextStyle(color: AppTheme.textMuted)))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          itemCount: chapters.length,
                          itemBuilder: (context, index) {
                            // V2: Staggered entrance animation
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(milliseconds: 500 + index * 60),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) => Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 30 * (1 - value)),
                                  child: Transform.scale(
                                    scale: 0.92 + 0.08 * value,
                                    child: child,
                                  ),
                                ),
                              ),
                              child: _ChapterCard(
                                chapter: chapters[index],
                                appState: a,
                                onTap: () => _openChapter(chapters[index]),
                              ),
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

class _ChapterCard extends StatefulWidget {
  final Chapter chapter;
  final AppState appState;
  final VoidCallback onTap;

  const _ChapterCard({required this.chapter, required this.appState, required this.onTap});

  @override
  State<_ChapterCard> createState() => _ChapterCardState();
}

class _ChapterCardState extends State<_ChapterCard> with SingleTickerProviderStateMixin {
  late AnimationController _tiltCtrl;
  double _tiltX = 0, _tiltY = 0;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _tiltCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _tiltCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tiltCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.eraColor(widget.chapter.eraId);
    final a = widget.appState;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          _tiltCtrl.reverse();
          setState(() { _tiltX = 0; _tiltY = 0; _scale = 1.0; });
          widget.onTap();
        },
        onTapDown: (d) {
          final box = context.findRenderObject() as RenderBox;
          final local = box.globalToLocal(d.globalPosition);
          final cx = box.size.width / 2;
          final cy = box.size.height / 2;
          setState(() {
            _tiltX = (local.dy - cy) / cy * 0.06;
            _tiltY = (local.dx - cx) / cx * -0.06;
            _scale = 0.97;
          });
        },
        onTapUp: (_) {
          _tiltCtrl.forward().then((_) => _tiltCtrl.reverse());
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) setState(() { _tiltX = 0; _tiltY = 0; _scale = 1.0; });
          });
        },
        onTapCancel: () {
          setState(() { _tiltX = 0; _tiltY = 0; _scale = 1.0; });
        },
        child: Hero(
          tag: 'chapter_${widget.chapter.id}',
          child: Material(
            type: MaterialType.transparency,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(_tiltX)
                ..rotateY(_tiltY),
              child: Transform.scale(
                scale: _scale,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutExpo,
                  padding: const EdgeInsets.all(18),
                  decoration: AppTheme.glassCard(borderColor: color, opacity: 0.07),
                  child: Row(
                    children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: color.withOpacity(0.08),
                          border: Border.all(color: color.withOpacity(0.25)),
                        ),
                        child: Icon(Icons.menu_book_rounded, color: color.withOpacity(0.7), size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.chapter.title, style: TextStyle(
                              color: AppTheme.textTitle, fontSize: 15,
                              fontFamily: 'serif', fontWeight: FontWeight.w600,
                            )),
                            const SizedBox(height: 3),
                            Text('${widget.chapter.location} • ${widget.chapter.yearStart} CE',
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 10,
                                    fontFamily: 'monospace', letterSpacing: 1)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.4), size: 22),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
