import 'question.dart';

class UserStats {
  final int totalGamesPlayed;
  final int totalCorrectAnswers;
  final int totalWrongAnswers;
  final Map<QuestionType, GameTypeStats> gameTypeStats;
  final List<Achievement> achievements;
  final int currentStreak;
  final int bestStreak;
  final DateTime? lastPlayedDate;

  UserStats({
    this.totalGamesPlayed = 0,
    this.totalCorrectAnswers = 0,
    this.totalWrongAnswers = 0,
    this.gameTypeStats = const {},
    this.achievements = const [],
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastPlayedDate,
  });

  UserStats copyWith({
    int? totalGamesPlayed,
    int? totalCorrectAnswers,
    int? totalWrongAnswers,
    Map<QuestionType, GameTypeStats>? gameTypeStats,
    List<Achievement>? achievements,
    int? currentStreak,
    int? bestStreak,
    DateTime? lastPlayedDate,
  }) {
    return UserStats(
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      totalWrongAnswers: totalWrongAnswers ?? this.totalWrongAnswers,
      gameTypeStats: gameTypeStats ?? this.gameTypeStats,
      achievements: achievements ?? this.achievements,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
    );
  }

  double get overallAccuracy {
    final total = totalCorrectAnswers + totalWrongAnswers;
    if (total == 0) return 0.0;
    return totalCorrectAnswers / total;
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      totalCorrectAnswers: json['totalCorrectAnswers'] ?? 0,
      totalWrongAnswers: json['totalWrongAnswers'] ?? 0,
      gameTypeStats: (json['gameTypeStats'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              QuestionType.values.firstWhere(
                (e) => e.toString().split('.').last == key,
              ),
              GameTypeStats.fromJson(value),
            ),
          ) ??
          {},
      achievements: (json['achievements'] as List?)
              ?.map((e) => Achievement.fromJson(e))
              .toList() ??
          [],
      currentStreak: json['currentStreak'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
      lastPlayedDate: json['lastPlayedDate'] != null
          ? DateTime.parse(json['lastPlayedDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalGamesPlayed': totalGamesPlayed,
      'totalCorrectAnswers': totalCorrectAnswers,
      'totalWrongAnswers': totalWrongAnswers,
      'gameTypeStats': gameTypeStats.map(
        (key, value) => MapEntry(key.toString().split('.').last, value.toJson()),
      ),
      'achievements': achievements.map((e) => e.toJson()).toList(),
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'lastPlayedDate': lastPlayedDate?.toIso8601String(),
    };
  }
}

class GameTypeStats {
  final int gamesPlayed;
  final int correctAnswers;
  final int wrongAnswers;
  final Duration? bestTime;
  final int highestScore;

  GameTypeStats({
    this.gamesPlayed = 0,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.bestTime,
    this.highestScore = 0,
  });

  GameTypeStats copyWith({
    int? gamesPlayed,
    int? correctAnswers,
    int? wrongAnswers,
    Duration? bestTime,
    int? highestScore,
  }) {
    return GameTypeStats(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      bestTime: bestTime ?? this.bestTime,
      highestScore: highestScore ?? this.highestScore,
    );
  }

  double get accuracy {
    final total = correctAnswers + wrongAnswers;
    if (total == 0) return 0.0;
    return correctAnswers / total;
  }

  factory GameTypeStats.fromJson(Map<String, dynamic> json) {
    return GameTypeStats(
      gamesPlayed: json['gamesPlayed'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      wrongAnswers: json['wrongAnswers'] ?? 0,
      bestTime: json['bestTime'] != null
          ? Duration(milliseconds: json['bestTime'])
          : null,
      highestScore: json['highestScore'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gamesPlayed': gamesPlayed,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'bestTime': bestTime?.inMilliseconds,
      'highestScore': highestScore,
    };
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconPath;
  final DateTime unlockedDate;
  final AchievementType type;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.unlockedDate,
    required this.type,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      iconPath: json['iconPath'] ?? '',
      unlockedDate: DateTime.parse(json['unlockedDate']),
      type: AchievementType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => AchievementType.general,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconPath': iconPath,
      'unlockedDate': unlockedDate.toIso8601String(),
      'type': type.toString().split('.').last,
    };
  }
}

enum AchievementType {
  general,
  streak,
  accuracy,
  speed,
  games,
}