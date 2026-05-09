import 'package:flutter/material.dart';
import 'services/content_service.dart';
import 'services/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

class EthiopianChroniclesApp extends StatefulWidget {
  const EthiopianChroniclesApp({super.key});

  @override
  State<EthiopianChroniclesApp> createState() => _EthiopianChroniclesAppState();
}

class _EthiopianChroniclesAppState extends State<EthiopianChroniclesApp>
    with SingleTickerProviderStateMixin {
  final ContentService _content = ContentService();
  final AppState _appState = AppState();
  bool _loading = true;
  late AnimationController _loadCtrl;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _loadCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadCtrl, curve: Curves.easeInOut),
    );
    _loadCtrl.repeat(reverse: true);
    _init();
  }

  @override
  void dispose() {
    _loadCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _content.load();
    if (mounted) {
      _loadCtrl.stop();
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appState,
      builder: (context, _) => MaterialApp(
        title: 'Ethiopian Chronicles',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: _loading
            ? _LoadingScreen(glowAnim: _glowAnim)
            : HomeScreen(content: _content, appState: _appState),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  final Animation<double> glowAnim;
  const _LoadingScreen({required this.glowAnim});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Ambient particles
          ...List.generate(20, (i) {
            final x = (i * 137.5) % 1.0;
            final y = (i * 251.7) % 1.0;
            final size = 1.5 + (i % 3) * 1.5;
            final speed = 0.4 + (i % 5) * 0.2;
            return AnimatedBuilder(
              animation: glowAnim,
              builder: (_, __) {
                final t = glowAnim.value;
                final py = (y + t * speed) % 1.0;
                final opacity = (0.05 + 0.1 * (0.5 + 0.5 * (3.14159 * (t * 3 + i * 0.7)).isNaN ? 0 : 0));
                return Positioned(
                  left: x * MediaQuery.of(context).size.width,
                  top: py * MediaQuery.of(context).size.height,
                  child: Container(
                    width: size, height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.accent.withOpacity(0.06 + glowAnim.value * 0.08),
                    ),
                  ),
                );
              },
            );
          }),

          // Center content
          Center(
            child: AnimatedBuilder(
              animation: glowAnim,
              builder: (_, __) {
                final glow = 0.5 + glowAnim.value * 0.5;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pulsing icon
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.accent.withOpacity(0.06 * glow),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accent.withOpacity(0.2 * glow),
                            blurRadius: 40 * glow,
                            spreadRadius: -10,
                          ),
                        ],
                        border: Border.all(
                          color: AppTheme.accent.withOpacity(0.15 * glow),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.account_balance,
                        color: AppTheme.accent.withOpacity(0.6 + 0.4 * glow),
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 36),
                    // Title
                    const Text(
                      'ETHIOPIAN\nCHRONICLES',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 24,
                        fontFamily: 'serif',
                        fontWeight: FontWeight.w900,
                        letterSpacing: 5,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Animated progress
                    SizedBox(
                      width: 180,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 0.85),
                          duration: const Duration(seconds: 4),
                          curve: Curves.easeInOut,
                          builder: (_, val, __) => LinearProgressIndicator(
                            value: val,
                            backgroundColor: AppTheme.surfaceLight,
                            color: AppTheme.accent,
                            minHeight: 2.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    AnimatedBuilder(
                      animation: glowAnim,
                      builder: (_, __) => Text(
                        'Unearthing the past...',
                        style: TextStyle(
                          color: AppTheme.textMuted.withOpacity(0.5 + glowAnim.value * 0.5),
                          fontSize: 12,
                          fontFamily: 'monospace',
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
