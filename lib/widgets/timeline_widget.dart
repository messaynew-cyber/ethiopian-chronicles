import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../theme/app_theme.dart';

class TimelineWidget extends StatefulWidget {
  final List<Era> eras;
  final String selectedEraId;
  final ValueChanged<String> onEraSelected;

  const TimelineWidget({
    super.key,
    required this.eras,
    required this.selectedEraId,
    required this.onEraSelected,
  });

  @override
  State<TimelineWidget> createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends State<TimelineWidget> {
  late ScrollController _controller;
  final double _nodeSize = 56;
  final double _spacing = 120;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    // Scroll to selected era
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected();
    });
  }

  void _scrollToSelected() {
    final index = widget.eras.indexWhere((e) => e.id == widget.selectedEraId);
    if (index >= 0) {
      final offset = index * _spacing - 40;
      _controller.animateTo(
        offset.clamp(0.0, _controller.position.maxScrollExtent),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutExpo,
      );
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: widget.eras.length,
            itemBuilder: (context, index) {
              final era = widget.eras[index];
              final isSelected = era.id == widget.selectedEraId;
              final color = Color(era.color);

              return GestureDetector(
                onTap: () => widget.onEraSelected(era.id),
                child: Container(
                  width: _spacing,
                  margin: const EdgeInsets.only(right: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Connecting line (left half)
                      if (index > 0)
                        Positioned(
                          child: Container(
                            height: 1,
                            width: (_spacing - _nodeSize) / 2,
                            color: isSelected ? color : Colors.white10,
                          ),
                        ),

                      // Era node
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _nodeSize,
                        height: _nodeSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? color.withOpacity(0.12) : Colors.white.withOpacity(0.02),
                          border: Border.all(
                            color: isSelected ? color.withOpacity(0.6) : Colors.white10,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 16)]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(AppTheme.eraEmoji(era.id), style: TextStyle(
                                fontSize: isSelected ? 20 : 16)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Era name
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          color: isSelected ? AppTheme.textPrimary : AppTheme.textMuted,
                          fontSize: isSelected ? 11 : 10,
                          fontFamily: 'monospace',
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        child: Text(era.name.split(' ').join('\n')),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Selected indicator dot row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.eras.map((e) {
            final isSelected = e.id == widget.selectedEraId;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isSelected ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: isSelected ? Color(e.color) : Colors.white10,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
