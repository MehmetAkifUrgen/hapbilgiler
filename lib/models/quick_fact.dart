class QuickFact {
  final String fact;

  QuickFact({
    required this.fact,
  });

  factory QuickFact.fromJson(Map<String, dynamic> json) {
    return QuickFact(
      fact: json['fact'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fact': fact,
    };
  }
}

class QuickFactSection {
  final String title;
  final List<QuickFact> items;

  QuickFactSection({
    required this.title,
    required this.items,
  });

  factory QuickFactSection.fromJson(Map<String, dynamic> json) {
    return QuickFactSection(
      title: json['title'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => QuickFact.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class SubjectQuickFacts {
  final String subjectName;
  final String subjectKey;
  final List<QuickFactSection> sections;

  SubjectQuickFacts({
    required this.subjectName,
    required this.subjectKey,
    required this.sections,
  });

  factory SubjectQuickFacts.fromJson(String subjectKey, List<dynamic> data) {
    List<QuickFactSection> sections = [];
    
    // data is a list of section objects
    for (var item in data) {
      if (item is Map<String, dynamic>) {
        try {
          sections.add(QuickFactSection.fromJson(item));
        } catch (e) {
          // Error parsing section - skip it
        }
      }
    }

    return SubjectQuickFacts(
      subjectName: _getSubjectDisplayName(subjectKey),
      subjectKey: subjectKey,
      sections: sections,
    );
  }

  static String _getSubjectDisplayName(String key) {
    switch (key) {
      case 'Tarih':
        return 'Tarih';
      case 'Coğrafya':
        return 'Coğrafya';
      case 'Vatandaşlık':
        return 'Vatandaşlık';
      case 'Türkçe':
        return 'Türkçe';
      default:
        return key;
    }
  }
}