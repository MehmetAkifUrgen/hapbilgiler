import 'package:flutter/widgets.dart';
import '../models/question.dart';
import '../models/game_state.dart';
import '../models/user_stats.dart';
import '../services/local_data_service.dart';
import '../services/api_service.dart';

class GameController extends ChangeNotifier {
  final LocalDataService _localDataService = LocalDataService();
  final ApiService _apiService = ApiService();
  
  GameState _gameState = GameState(gameType: QuestionType.word);
  UserStats _userStats = UserStats();
  bool _isLoading = false;
  String? _error;

  // Getters
  GameState get gameState => _gameState;
  UserStats get userStats => _userStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize the controller
  Future<void> initialize() async {
    _setLoading(true);
    try {
      _userStats = await _localDataService.loadUserStats();
      _clearError();
    } catch (e) {
      _setError('Failed to load user data: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Start a new game
  Future<void> startGame(QuestionType gameType, {DifficultyLevel? difficulty}) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Get questions from local data service (mock data)
      final questions = _localDataService.getMockQuestions(gameType, count: 10);
      
      if (questions.isEmpty) {
        throw Exception('No questions available for this game type');
      }

      _gameState = GameState(
        gameType: gameType,
        questions: questions,
        totalQuestions: questions.length,
        status: GameStatus.inProgress,
        startTime: DateTime.now(),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _setError('Failed to start game: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Submit an answer
  Future<void> submitAnswer(String answer) async {
    if (_gameState.currentQuestion == null) return;

    final currentQuestion = _gameState.currentQuestion!;
    final isCorrect = _compareTurkishStrings(answer.trim(), currentQuestion.correctAnswer.trim());
    
    // Update user answers
    final updatedAnswers = List<String>.from(_gameState.userAnswers)..add(answer);
    
    // Update score if correct
    final newScore = isCorrect ? _gameState.score + 1 : _gameState.score;
    
    // Move to next question
    final nextIndex = _gameState.currentQuestionIndex + 1;
    
    // Check if game is completed
    final isGameCompleted = nextIndex >= _gameState.questions.length;
    
    _gameState = _gameState.copyWith(
      currentQuestionIndex: nextIndex,
      score: newScore,
      userAnswers: updatedAnswers,
      status: isGameCompleted ? GameStatus.completed : GameStatus.inProgress,
      endTime: isGameCompleted ? DateTime.now() : null,
    );

    // Update user stats if game is completed
    if (isGameCompleted) {
      await _updateUserStats();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  /// Pause the game
  void pauseGame() {
    if (_gameState.status == GameStatus.inProgress) {
      _gameState = _gameState.copyWith(status: GameStatus.paused);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  /// Resume the game
  void resumeGame() {
    if (_gameState.status == GameStatus.paused) {
      _gameState = _gameState.copyWith(status: GameStatus.inProgress);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  /// Restart the current game
  Future<void> restartGame() async {
    await startGame(_gameState.gameType);
  }

  /// End the current game
  void endGame() {
    _gameState = _gameState.copyWith(
      status: GameStatus.completed,
      endTime: DateTime.now(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  /// Reset to initial state
  void resetGame() {
    _gameState = GameState(gameType: QuestionType.word);
    _clearError();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  /// Get hint for current question
  String? getHint() {
    final currentQuestion = _gameState.currentQuestion;
    if (currentQuestion == null) return null;
    
    // Simple hint: show first letter and length
    final answer = currentQuestion.correctAnswer;
    return '${answer[0]}${'*' * (answer.length - 1)} (${answer.length} harf)';
  }

  /// Skip current question
  void skipQuestion() {
    submitAnswer(''); // Submit empty answer to move to next question
  }

  /// Update user statistics
  Future<void> _updateUserStats() async {
    try {
      final gameTypeStats = _userStats.gameTypeStats[_gameState.gameType] ?? GameTypeStats();
      
      final updatedGameTypeStats = gameTypeStats.copyWith(
        gamesPlayed: gameTypeStats.gamesPlayed + 1,
        correctAnswers: gameTypeStats.correctAnswers + _gameState.score,
        wrongAnswers: gameTypeStats.wrongAnswers + (_gameState.userAnswers.length - _gameState.score),
        highestScore: gameTypeStats.highestScore < _gameState.score 
            ? _gameState.score 
            : gameTypeStats.highestScore,
        bestTime: _gameState.gameDuration != null && 
                 (gameTypeStats.bestTime == null || _gameState.gameDuration! < gameTypeStats.bestTime!)
            ? _gameState.gameDuration
            : gameTypeStats.bestTime,
      );

      final updatedGameTypeStatsMap = Map<QuestionType, GameTypeStats>.from(_userStats.gameTypeStats);
      updatedGameTypeStatsMap[_gameState.gameType] = updatedGameTypeStats;

      // Calculate streak
      final isAllCorrect = _gameState.score == _gameState.questions.length;
      final newCurrentStreak = isAllCorrect ? _userStats.currentStreak + 1 : 0;
      final newBestStreak = newCurrentStreak > _userStats.bestStreak 
          ? newCurrentStreak 
          : _userStats.bestStreak;

      _userStats = _userStats.copyWith(
        totalGamesPlayed: _userStats.totalGamesPlayed + 1,
        totalCorrectAnswers: _userStats.totalCorrectAnswers + _gameState.score,
        totalWrongAnswers: _userStats.totalWrongAnswers + (_gameState.userAnswers.length - _gameState.score),
        gameTypeStats: updatedGameTypeStatsMap,
        currentStreak: newCurrentStreak,
        bestStreak: newBestStreak,
        lastPlayedDate: DateTime.now(),
      );

      await _localDataService.saveUserStats(_userStats);
    } catch (e) {
      debugPrint('Failed to update user stats: $e');
    }
  }

  /// Compare strings with Turkish character support
  bool _compareTurkishStrings(String str1, String str2) {
    return _toTurkishLowerCase(str1) == _toTurkishLowerCase(str2);
  }

  /// Convert string to lowercase and normalize Turkish characters (ı=i, ş=s, etc.)
  String _toTurkishLowerCase(String str) {
    return str
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ş', 's')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');
  }

  /// Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _setError(String error) {
    _error = error;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _clearError() {
    _error = null;
  }

  /// Start a KPSS game with specific subject
  Future<void> startKpssGame(String subjectKey) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Get questions from API for the specific subject
      final questions = await _apiService.getQuestionsBySubject(
        subjectKey: subjectKey,
      );
      
      if (questions.isEmpty) {
        throw Exception('Bu ders için soru bulunamadı');
      }

      _gameState = GameState(
        gameType: QuestionType.fillInTheBlank, // KPSS soruları artık boşluk doldurma
        questions: questions,
        totalQuestions: questions.length,
        status: GameStatus.inProgress,
        startTime: DateTime.now(),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _setError('KPSS oyunu başlatılamadı: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Remove unnecessary override
  // @override
  // void dispose() {
  //   super.dispose();
  // }
}