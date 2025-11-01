import 'question.dart';

class GameState {
  final int currentQuestionIndex;
  final int score;
  final int totalQuestions;
  final List<Question> questions;
  final List<String> userAnswers;
  final GameStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final QuestionType gameType;

  GameState({
    this.currentQuestionIndex = 0,
    this.score = 0,
    this.totalQuestions = 0,
    this.questions = const [],
    this.userAnswers = const [],
    this.status = GameStatus.notStarted,
    this.startTime,
    this.endTime,
    required this.gameType,
  });

  GameState copyWith({
    int? currentQuestionIndex,
    int? score,
    int? totalQuestions,
    List<Question>? questions,
    List<String>? userAnswers,
    GameStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    QuestionType? gameType,
  }) {
    return GameState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      questions: questions ?? this.questions,
      userAnswers: userAnswers ?? this.userAnswers,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      gameType: gameType ?? this.gameType,
    );
  }

  bool get isGameCompleted => currentQuestionIndex >= questions.length;
  
  Question? get currentQuestion {
    if (currentQuestionIndex < questions.length) {
      return questions[currentQuestionIndex];
    }
    return null;
  }

  double get progressPercentage {
    if (questions.isEmpty) return 0.0;
    return currentQuestionIndex / questions.length;
  }

  Duration? get gameDuration {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!);
    }
    return null;
  }

  double get accuracy {
    if (userAnswers.isEmpty) return 0.0;
    return score / userAnswers.length;
  }
}

enum GameStatus {
  notStarted,
  inProgress,
  paused,
  completed,
  failed,
}