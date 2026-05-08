import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class TimelineWidget extends StatefulWidget {
  final List<Era> eras;
  final String selectedEraId;
  final ValueChanged<String> onEraSelected;
  final AppState appState;

  const TimelineWidget({
    super.key,
    required this.eras,
    required this.selectedEraId,
    required this.onEraSelected,
    required this.appState,
  });

  @override
  State<TimelineWidget> createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends State<TimelineWidget> {
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  void _scrollToSelected() {
    final index = widget.eras.indexWhere((e) => e.id == widget.selectedEraId);
    if (index >= 0) {
      final offset = (index * 100.0 - 40).clamp(0.0, _controller.position.maxScrollExtent);
      _controller.animateTo(offset, duration: const Duration(milliseconds: 400), curve: Curves.easeOutExpo);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            itemCount: widget.eras.length,
            itemBuilder: (context, index) {
              final era = widget.eras[index];
              final isSelected = era.id == widget.selectedEraId;
              final color = Color(era.color);

              return GestureDetector(
                onTap: () => widget.onEraSelected(era.id),
                child: Container(
                  width: 90,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Era icon in glass container
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutExpo,
                        width: 52,
                        height: 52,
                        decoration: isSelected
                            ? BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: color.withOpacity(0.4), width: 1.2),
                                boxShadow: [
                                  BoxShadow(color: color.withOpacity(0.15), blurRadius: 12, spreadRadius: -2),
                                ],
                              )
                            : BoxDecoration(
                                color: Colors.white.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.06), width: 0.8),
                              ),
                        child: Icon(
                          AppTheme.eraIcon(era.id),
                          color: isSelected ? color : AppTheme.textMuted,
                          size: isSelected ? 24 : 20,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Era name
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          color: isSelected ? AppTheme.textPrimary : AppTheme.textMuted,
                          fontSize: 10,
                          fontFamily: 'monospace',
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          letterSpacing: 1.2,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        child: Text(widget.appState.t(era.name, AppTheme.eraAmharic(era.id).isNotEmpty ? AppTheme.eraAmharic(era.id) : era.name)),
                      ),
                      // Amharic name below
                      if (AppTheme.eraAmharic(era.id).isNotEmpty)
                        Text(
                          AppTheme.eraAmharic(era.id),
                          style: TextStyle(
                            color: isSelected ? color.withOpacity(0.6) : Colors.white24,
                            fontSize: 8,
                            fontFamily: 'serif',
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Dot indicators
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.eras.map((e) {
              final isSelected = e.id == widget.selectedEraId;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: isSelected ? 20 : 5,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: isSelected ? Color(e.color).withOpacity(0.6) : Colors.white10,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
