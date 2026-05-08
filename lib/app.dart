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

class _EthiopianChroniclesAppState extends State<EthiopianChroniclesApp> {
  final ContentService _content = ContentService();
  final AppState _appState = AppState();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _content.load();
    setState(() => _loading = false);
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
            ? const _LoadingScreen()
            : HomeScreen(content: _content, appState: _appState),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(seconds: 2),
              curve: Curves.elasticOut,
              builder: (_, val, __) => Transform.scale(
                scale: val,
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: AppTheme.aksumGold.withOpacity(0.08),
                    border: Border.all(color: AppTheme.aksumGold.withOpacity(0.2), width: 1),
                  ),
                  child: const Icon(Icons.account_balance, color: AppTheme.aksumGold, size: 36),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'ETHIOPIAN\nCHRONICLES',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22, fontFamily: 'serif', fontWeight: FontWeight.w900, letterSpacing: 4, height: 1.3,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(seconds: 3),
                  builder: (_, val, __) => LinearProgressIndicator(
                    value: val, backgroundColor: AppTheme.surfaceLight,
                    color: AppTheme.aksumGold, minHeight: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Unearthing the past...',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontFamily: 'monospace', letterSpacing: 2)),
          ],
        ),
      ),
    );
  }
}
