import 'dart:convert';
import '../models/chapter.dart';
import 'package:flutter/services.dart' show rootBundle;

class ContentService {
  List<Era>? _eras;
  Map<String, Chapter>? _chapters;
  Map<String, BattleEvent>? _battles;

  List<Era> get eras => _eras ?? [];
  Map<String, Chapter> get chapters => _chapters ?? {};
  Map<String, BattleEvent> get battles => _battles ?? {};

  bool get isLoaded => _eras != null;

  Future<void> load() async {
    // Load era index
    final eraJson = await rootBundle.loadString('assets/eras.json');
    final List<dynamic> eraList = json.decode(eraJson);
    _eras = eraList.map((e) => Era.fromJson(e)).toList();

    // Load chapters metadata index
    _chapters = {};
    try {
      final chIndexJson = await rootBundle.loadString('assets/chapters_index.json');
      final List<dynamic> chList = json.decode(chIndexJson);
      for (final ch in chList) {
        final chapter = Chapter.fromJson(ch);
        _chapters![chapter.id] = chapter;
      }
    } catch (_) {}

    // Override with detailed chapter files where available
    for (final chId in _chapters!.keys.toList()) {
      try {
        final detailJson = await rootBundle.loadString('assets/chapters/$chId.json');
        final detail = Chapter.fromJson(json.decode(detailJson));
        _chapters![chId] = detail;
      } catch (_) {
        // Keep metadata version
      }
    }

    // Load battles
    _battles = {};
    try {
      final battleJson = await rootBundle.loadString('assets/battles.json');
      final List<dynamic> battleList = json.decode(battleJson);
      for (final b in battleList) {
        final battle = BattleEvent.fromJson(b);
        _battles![battle.id] = battle;
      }
    } catch (_) {}
  }

  Chapter? getChapter(String id) => _chapters?[id];
  BattleEvent? getBattle(String id) => _battles?[id];

  Era? getEra(String id) {
    try { return _eras!.firstWhere((e) => e.id == id); } catch (_) { return null; }
  }

  List<Chapter> getChaptersForEra(String eraId) {
    final era = getEra(eraId);
    if (era == null) return [];
    return era.chapterIds
        .map((id) => _chapters![id])
        .where((c) => c != null)
        .cast<Chapter>()
        .toList();
  }
}
