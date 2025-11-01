import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/game_controller.dart';
import '../models/question.dart';
import '../models/game_state.dart';
import '../utils/app_theme.dart';
import '../widgets/animated_button.dart';
import '../widgets/question_card.dart';
import '../widgets/word_puzzle_card.dart';

class WordGameScreen extends StatefulWidget {
  final String? subjectKey;
  final String? subjectName;
  
  const WordGameScreen({
    super.key,
    this.subjectKey,
    this.subjectName,
  });

  @override
  State<WordGameScreen> createState() => _WordGameScreenState();
}

class _WordGameScreenState extends State<WordGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Feedback state
  bool _showFeedback = false;
  bool _isCorrect = false;
  Question? _cachedQuestion;
  int? _cachedQuestionIndex;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    
    // Defer game start to avoid build-time state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startGame();
    });
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
  }

  void _startGame() {
    final gameController = context.read<GameController>();
    
    // KPSS oyunu için subjectKey varsa onu kullan, yoksa normal kelime oyunu başlat
    if (widget.subjectKey != null) {
      gameController.startKpssGame(widget.subjectKey!).then((_) {
        _slideController.forward();
        _fadeController.forward();
      });
    } else {
      gameController.startGame(QuestionType.word).then((_) {
        _slideController.forward();
        _fadeController.forward();
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: _buildAppBar(),
      body: Consumer<GameController>(
        builder: (context, gameController, child) {
          if (gameController.isLoading) {
            return _buildLoadingWidget();
          }

          if (gameController.error != null) {
            return _buildErrorWidget(gameController.error!);
          }

          if (gameController.gameState.status == GameStatus.completed) {
            return _buildGameCompletedWidget(gameController.gameState);
          }

          return _buildGameContent(gameController);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.getCardColor(context),
      elevation: 0,
      title: Text(
        widget.subjectName ?? 'Kelime Bulma',
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: AppTheme.getTextPrimaryColor(context),
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: AppTheme.getTextPrimaryColor(context)),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        Consumer<GameController>(
          builder: (context, gameController, child) {
            return IconButton(
              icon: Icon(
                gameController.gameState.status == GameStatus.paused
                    ? Icons.play_arrow
                    : Icons.pause,
                color: AppTheme.getTextPrimaryColor(context),
              ),
              onPressed: () {
                if (gameController.gameState.status == GameStatus.paused) {
                  gameController.resumeGame();
                } else {
                  gameController.pauseGame();
                }
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
            strokeWidth: 3.0,
          ),
          SizedBox(height: 20.h),
          Text(
            'Oyun hazırlanıyor...',
            style: TextStyle(
              fontSize: 18.sp,
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.w,
              color: Colors.red.shade400,
            ),
            SizedBox(height: 20.h),
            Text(
              'Bir hata oluştu',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: AppTheme.getTextSecondaryColor(context),
              ),
            ),
            SizedBox(height: 30.h),
            AnimatedButton(
              text: 'Tekrar Dene',
              onPressed: _startGame,
              backgroundColor: Colors.blue.shade600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameContent(GameController gameController) {
    final gameState = gameController.gameState;
    // Use cached question during feedback, otherwise use current question
    final currentQuestion = _cachedQuestion ?? gameState.currentQuestion;

    if (currentQuestion == null) {
      return Center(
        child: Text(
          'Soru bulunamadı',
          style: TextStyle(color: AppTheme.getTextPrimaryColor(context)),
        ),
      );
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              _buildProgressSection(gameState, displayIndex: _cachedQuestionIndex ?? gameState.currentQuestionIndex),
              SizedBox(height: 30.h),
              Expanded(
                child: _buildQuestionWidget(currentQuestion, gameController),
              ),
              SizedBox(height: 20.h),
              _buildActionButtons(gameController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionWidget(Question question, GameController gameController) {
    final gameState = gameController.gameState;
    final canSelectAnswer = !_showFeedback && gameState.status == GameStatus.inProgress;
    
    // Check if this is a fill-in-the-blank question
    if (question.type == QuestionType.fillInTheBlank) {
      return WordPuzzleCard(
        question: question,
        onAnswerSubmitted: canSelectAnswer 
            ? (answer) => _handleAnswerSelection(answer, gameController)
            : null,
        isAnswered: _showFeedback,
        showFeedback: _showFeedback,
        isCorrect: _isCorrect,
      );
    } else {
      // Use the original QuestionCard for multiple choice questions
      return QuestionCard(
        question: question,
        onAnswerSelected: canSelectAnswer 
            ? (answer) => _handleAnswerSelection(answer, gameController)
            : null,
        showFeedback: _showFeedback,
        isCorrect: _isCorrect,
      );
    }
  }

  Widget _buildProgressSection(GameState gameState, {int? displayIndex}) {
    final questionIndex = displayIndex ?? gameState.currentQuestionIndex;
    return Column(
      children: [
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatCard(
              'Soru',
              '${questionIndex + 1}/${gameState.totalQuestions}',
              Icons.quiz,
              Colors.blue.shade400,
            ),
            _buildStatCard(
              'Puan',
              '${gameState.score}',
              Icons.star,
              Colors.amber.shade400,
            ),
            _buildStatCard(
              'Doğruluk',
              '${(gameState.accuracy * 100).toInt()}%',
              Icons.trending_up,
              Colors.green.shade400,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withAlpha(76), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20.w),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(GameController gameController) {
    final gameState = gameController.gameState;
    final canInteract = !_showFeedback && gameState.status == GameStatus.inProgress;
    
    return Row(
      children: [
        Expanded(
          child: AnimatedButton(
            text: 'İpucu',
            onPressed: canInteract ? () => _showHint(gameController) : () {},
            backgroundColor: Colors.orange.shade600,
            icon: Icons.lightbulb_outline,
          ),
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: AnimatedButton(
            text: 'Geç',
            onPressed: canInteract ? () => gameController.skipQuestion() : () {},
            backgroundColor: Colors.grey.shade600,
            icon: Icons.skip_next,
          ),
        ),
      ],
    );
  }

  Widget _buildGameCompletedWidget(GameState gameState) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.purple.shade400],
                ),
              ),
              child: Icon(
                Icons.emoji_events,
                size: 60.w,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30.h),
            Text(
              'Tebrikler!',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Oyunu tamamladınız',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 30.h),
            _buildResultCard(gameState),
            SizedBox(height: 30.h),
            Row(
              children: [
                Expanded(
                  child: AnimatedButton(
                    text: 'Tekrar Oyna',
                    onPressed: () => context.read<GameController>().restartGame(),
                    backgroundColor: Colors.blue.shade600,
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: AnimatedButton(
                    text: 'Ana Menü',
                    onPressed: () => Navigator.of(context).pop(),
                    backgroundColor: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(GameState gameState) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.blue.withAlpha(76), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildResultItem('Doğru Cevap', '${gameState.score}'),
              _buildResultItem('Toplam Soru', '${gameState.totalQuestions}'),
            ],
          ),
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildResultItem('Doğruluk Oranı', '${(gameState.accuracy * 100).toInt()}%'),
              _buildResultItem('Süre', _formatDuration(gameState.gameDuration)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white70,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  String _normalizeTurkish(String text) {
    // Normalize Turkish characters - make ı and i same, ş and s same, etc.
    return text
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ş', 's')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' '); // Replace multiple spaces with single space
  }

  void _handleAnswerSelection(String answer, GameController gameController) async {
    if (_showFeedback) return; // Prevent double submission
    
    final gameState = gameController.gameState;
    final question = gameState.currentQuestion;
    final currentQuestionIndex = gameState.currentQuestionIndex;
    
    if (question == null) return;
    
    // Cache current question and index for display during feedback
    _cachedQuestion = question;
    _cachedQuestionIndex = currentQuestionIndex;
    
    // Check if answer is correct (case-insensitive comparison with Turkish character handling)
    final isCorrect = _normalizeTurkish(answer) == _normalizeTurkish(question.correctAnswer);
    
    setState(() {
      _showFeedback = true;
      _isCorrect = isCorrect;
    });
    
    // Submit answer immediately (updates score and accuracy in real-time)
    await gameController.submitAnswer(answer);
    
    // Show feedback dialog
    if (mounted) {
      _showFeedbackDialog(isCorrect, question.correctAnswer);
    }
    
    // Wait for feedback period
    await Future.delayed(const Duration(milliseconds: 2500));
    
    // Clear feedback state and show next question
    if (mounted) {
      setState(() {
        _showFeedback = false;
        _cachedQuestion = null;
        _cachedQuestionIndex = null;
      });
      
      // Animate to next question
      _slideController.reset();
      _slideController.forward();
    }
  }
  
  void _showFeedbackDialog(bool isCorrect, String correctAnswer) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: isCorrect 
                  ? Colors.green.withAlpha(242)  // 0.95 * 255
                  : Colors.red.withAlpha(242),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: (isCorrect ? Colors.green : Colors.red).withAlpha(153),  // 0.6 * 255
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 64.w,
                ),
                SizedBox(height: 16.h),
                Text(
                  isCorrect ? 'DOĞRU!' : 'YANLIŞ!',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (!isCorrect) ...[
                  SizedBox(height: 12.h),
                  Text(
                    'Doğru Cevap:',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    correctAnswer,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
    
    // Auto-dismiss after 2.3 seconds
    Future.delayed(const Duration(milliseconds: 2300), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  void _showHint(GameController gameController) {
    final hint = gameController.getHint();
    if (hint != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF16213E),
          title: const Text(
            'İpucu',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            hint,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16.sp,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Tamam',
                style: TextStyle(color: Colors.blue.shade400),
              ),
            ),
          ],
        ),
      );
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '0:00';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}