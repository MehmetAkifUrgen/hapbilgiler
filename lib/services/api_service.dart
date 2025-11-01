import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';
import '../models/subject_category.dart';
import '../models/quick_fact.dart';

class ApiService {
  static const String _baseUrl = 'https://mehmetakifurgen.github.io/kpssApi';
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Headers for API requests
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Fetch all subject categories with their questions
  Future<List<SubjectCategory>> getAllSubjects() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/word_quiz.json'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        List<SubjectCategory> categories = [];
        
        // Her bir ders kategorisini işle
        data.forEach((key, value) {
          if (value is List) {
            categories.add(SubjectCategory.fromJson(key, value));
          }
        });
        
        return categories;
      } else {
        throw ApiException(
          'Failed to fetch subjects: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e', 0);
    }
  }

  /// Fetch questions for a specific subject
  Future<List<Question>> getQuestionsBySubject({
    required String subjectKey,
    int limit = 10,
  }) async {
    try {
      final subjects = await getAllSubjects();
      final subject = subjects.firstWhere(
        (s) => s.key == subjectKey,
        orElse: () => throw ApiException('Subject not found: $subjectKey', 404),
      );

      // Quiz sorularını Question modeline dönüştür
      List<Question> questions = subject.questions
          .map((quizQuestion) => quizQuestion.toQuestion())
          .toList();

      // Limit uygula
      if (questions.length > limit) {
        questions.shuffle();
        questions = questions.take(limit).toList();
      }

      return questions;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error fetching questions: $e', 0);
    }
  }

  /// Eski API ile uyumluluk için - type'a göre sorular getir
  Future<List<Question>> getQuestions({
    required QuestionType type,
    DifficultyLevel? difficulty,
    int limit = 10,
  }) async {
    // Şimdilik sadece tarih sorularını döndür
    // Gelecekte diğer dersler eklendiğinde bu metod genişletilebilir
    return await getQuestionsBySubject(
      subjectKey: 'tarih_sorulari',
      limit: limit,
    );
  }

  /// Submit answer and get feedback
  Future<AnswerResponse> submitAnswer({
    required String questionId,
    required String answer,
    required String userId,
  }) async {
    // Bu metod şimdilik local olarak çalışacak
    // Gerçek API implementasyonu gelecekte eklenebilir
    
    // Basit bir doğru/yanlış kontrolü
    // Gerçek implementasyonda API'den cevap alınacak
    return AnswerResponse(
      isCorrect: true, // Placeholder
      correctAnswer: answer,
      explanation: 'Cevabınız değerlendirildi.',
      pointsEarned: 10,
    );
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    // Local storage'dan veya cache'den istatistikleri getir
    // Şimdilik placeholder data döndür
    return {
      'totalQuestions': 0,
      'correctAnswers': 0,
      'totalPoints': 0,
      'averageScore': 0.0,
    };
  }

  /// Update user statistics
  Future<void> updateUserStats({
    required String userId,
    required Map<String, dynamic> stats,
  }) async {
    // Local storage'a veya cache'e istatistikleri kaydet
    // Şimdilik placeholder implementasyon
  }

  /// Get leaderboard
  Future<List<LeaderboardEntry>> getLeaderboard({
    QuestionType? type,
    int limit = 50,
  }) async {
    // Şimdilik boş liste döndür
    // Gerçek implementasyonda API'den leaderboard alınacak
    return [];
  }

  /// Fetch all quick facts (hap bilgiler) for all subjects
  Future<List<SubjectQuickFacts>> getAllQuickFacts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/word_quiz.json'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        List<SubjectQuickFacts> quickFacts = [];
        
        // "bilgiler" bölümünü işle
        if (data.containsKey('bilgiler') && data['bilgiler'] is Map) {
          final Map<String, dynamic> bilgiler = data['bilgiler'] as Map<String, dynamic>;
          
          bilgiler.forEach((key, value) {
            if (value is List) {
              quickFacts.add(SubjectQuickFacts.fromJson(key, value));
            }
          });
        }
        
        return quickFacts;
      } else {
        throw ApiException(
          'Failed to fetch quick facts: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e', 0);
    }
  }

  /// Fetch quick facts for a specific subject
  Future<SubjectQuickFacts?> getQuickFactsBySubject(String subjectKey) async {
    try {
      final allFacts = await getAllQuickFacts();
      return allFacts.firstWhere(
        (facts) => facts.subjectKey == subjectKey,
        orElse: () => throw ApiException('Quick facts not found for: $subjectKey', 404),
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error fetching quick facts: $e', 0);
    }
  }
}

class AnswerResponse {
  final bool isCorrect;
  final String correctAnswer;
  final String explanation;
  final int pointsEarned;

  AnswerResponse({
    required this.isCorrect,
    required this.correctAnswer,
    required this.explanation,
    required this.pointsEarned,
  });

  factory AnswerResponse.fromJson(Map<String, dynamic> json) {
    return AnswerResponse(
      isCorrect: json['isCorrect'] ?? false,
      correctAnswer: json['correctAnswer'] ?? '',
      explanation: json['explanation'] ?? '',
      pointsEarned: json['pointsEarned'] ?? 0,
    );
  }
}

class LeaderboardEntry {
  final String userId;
  final String username;
  final int score;
  final int rank;
  final String? avatarUrl;

  LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.score,
    required this.rank,
    this.avatarUrl,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      score: json['score'] ?? 0,
      rank: json['rank'] ?? 0,
      avatarUrl: json['avatarUrl'],
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}