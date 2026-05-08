import 'package:flutter/material.dart';
import 'services/content_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

class EthiopianChroniclesApp extends StatefulWidget {
  const EthiopianChroniclesApp({super.key});

  @override
  State<EthiopianChroniclesApp> createState() => _EthiopianChroniclesAppState();
}

class _EthiopianChroniclesAppState extends State<EthiopianChroniclesApp> {
  final ContentService _content = ContentService();
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
    return MaterialApp(
      title: 'Ethiopian Chronicles',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: _loading
          ? const _LoadingScreen()
          : HomeScreen(content: _content),
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
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.aksumGold.withOpacity(0.1),
                border: Border.all(color: AppTheme.aksumGold.withOpacity(0.3), width: 1),
              ),
              child: const Center(
                child: Icon(Icons.account_balance, color: AppTheme.aksumGold, size: 36),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'ETHIOPIAN\nCHRONICLES',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontFamily: 'serif',
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  backgroundColor: AppTheme.surfaceLight,
                  color: AppTheme.aksumGold,
                  minHeight: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Unearthing the past...',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontFamily: 'monospace', letterSpacing: 2),
            ),
          ],
        ),
      ),
    );
  }
}

// Re-export theme for app-wide access
class AppColors {
  static const background = AppTheme.background;
  static const surface = AppTheme.surface;
  static const aksumGold = AppTheme.aksumGold;
  static const textPrimary = AppTheme.textPrimary;
  static const textSecondary = AppTheme.textSecondary;
}
