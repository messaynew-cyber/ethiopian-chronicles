class Era {
  final String id;
  final String name;
  final String amharicName;
  final int startYear;
  final int endYear;
  final String description;
  final int color; // primary color for this era
  final List<String> chapterIds;

  const Era({
    required this.id,
    required this.name,
    required this.amharicName,
    required this.startYear,
    required this.endYear,
    required this.description,
    required this.color,
    this.chapterIds = const [],
  });

  factory Era.fromJson(Map<String, dynamic> json) => Era(
    id: json['id'],
    name: json['name'],
    amharicName: json['amharic_name'] ?? '',
    startYear: json['start_year'],
    endYear: json['end_year'],
    description: json['description'] ?? '',
    color: int.parse(json['color'].toString().replaceFirst('#', '0xff')),
    chapterIds: List<String>.from(json['chapter_ids'] ?? []),
  );
}

class ChapterSection {
  final String type; // 'text', 'image', 'quote', 'map', 'timeline'
  final String? title;
  final String? body;
  final String? imageUrl;
  final String? caption;
  final String? attribution;

  const ChapterSection({
    this.type = 'text',
    this.title,
    this.body,
    this.imageUrl,
    this.caption,
    this.attribution,
  });

  factory ChapterSection.fromJson(Map<String, dynamic> json) => ChapterSection(
    type: json['type'] ?? 'text',
    title: json['title'],
    body: json['body'],
    imageUrl: json['image_url'],
    caption: json['caption'],
    attribution: json['attribution'],
  );
}

class Chapter {
  final String id;
  final String eraId;
  final String title;
  final String subtitle;
  final int yearStart;
  final int yearEnd;
  final String location;
  final String? narrationUrl;
  final String? narrationUrlAm;
  final List<ChapterSection> sections;
  final List<String> keyFigures;
  final bool isFree;

  const Chapter({
    required this.id,
    required this.eraId,
    required this.title,
    required this.subtitle,
    required this.yearStart,
    required this.yearEnd,
    required this.location,
    this.narrationUrl,
    this.narrationUrlAm,
    this.sections = const [],
    this.keyFigures = const [],
    this.isFree = false,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
    id: json['id'],
    eraId: json['era_id'],
    title: json['title'],
    subtitle: json['subtitle'] ?? '',
    yearStart: json['year_start'] ?? 0,
    yearEnd: json['year_end'] ?? 0,
    location: json['location'] ?? '',
    narrationUrl: json['narration_url'],
    narrationUrlAm: json['narration_url_am'],
    sections: (json['sections'] as List? ?? [])
        .map((s) => ChapterSection.fromJson(s))
        .toList(),
    keyFigures: List<String>.from(json['key_figures'] ?? []),
    isFree: json['is_free'] ?? false,
  );
}

class BattleEvent {
  final String id;
  final String chapterId;
  final String name;
  final int year;
  final String description;
  final double latitude;
  final double longitude;
  final String? outcome;
  final List<BattlePhase> phases;

  const BattleEvent({
    required this.id,
    required this.chapterId,
    required this.name,
    required this.year,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.outcome,
    this.phases = const [],
  });

  factory BattleEvent.fromJson(Map<String, dynamic> json) => BattleEvent(
    id: json['id'],
    chapterId: json['chapter_id'],
    name: json['name'],
    year: json['year'],
    description: json['description'] ?? '',
    latitude: (json['latitude'] ?? 0).toDouble(),
    longitude: (json['longitude'] ?? 0).toDouble(),
    outcome: json['outcome'],
    phases: (json['phases'] as List? ?? [])
        .map((p) => BattlePhase.fromJson(p))
        .toList(),
  );
}

class BattlePhase {
  final String time;
  final String description;
  final double? attackerX;
  final double? attackerY;
  final double? defenderX;
  final double? defenderY;

  const BattlePhase({
    required this.time,
    required this.description,
    this.attackerX,
    this.attackerY,
    this.defenderX,
    this.defenderY,
  });

  factory BattlePhase.fromJson(Map<String, dynamic> json) => BattlePhase(
    time: json['time'] ?? '',
    description: json['description'] ?? '',
    attackerX: (json['attacker_x'] as num?)?.toDouble(),
    attackerY: (json['attacker_y'] as num?)?.toDouble(),
    defenderX: (json['defender_x'] as num?)?.toDouble(),
    defenderY: (json['defender_y'] as num?)?.toDouble(),
  );
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon; // emoji or icon name
  final String requirement;
  bool isUnlocked;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.requirement,
    this.isUnlocked = false,
  });
}
