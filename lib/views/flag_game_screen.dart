import 'dart:math' show sin;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flag/flag.dart';
import 'package:confetti/confetti.dart';
import 'package:vibration/vibration.dart';
import '../controllers/game_controller.dart';
import '../models/question.dart';
import '../models/game_state.dart';
import '../utils/app_theme.dart';
import '../widgets/animated_button.dart';
import '../widgets/progress_indicator_widget.dart';

class FlagGameScreen extends StatefulWidget {
  const FlagGameScreen({super.key});

  @override
  State<FlagGameScreen> createState() => _FlagGameScreenState();
}

class _FlagGameScreenState extends State<FlagGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _feedbackController;
  late AnimationController _shakeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _feedbackAnimation;
  late Animation<double> _shakeAnimation;
  
  late ConfettiController _confettiController;
  
  String? _selectedAnswer;
  bool _showFeedback = false;
  Question? _cachedQuestion; // Feedback sırasında soruyu cache'le
  int? _cachedQuestionIndex; // Feedback sırasında soru index'ini cache'le

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
    
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
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
    
    _feedbackAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.elasticOut,
    ));
    
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticInOut,
    ));
  }

  void _startGame() {
    final gameController = context.read<GameController>();
    gameController.startGame(QuestionType.flag).then((_) {
      _slideController.forward();
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _feedbackController.dispose();
    _shakeController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Consumer<GameController>(
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
          // Konfeti widget'ı
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 3.14 / 2, // Yukarıdan aşağı
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              maxBlastForce: 20,
              minBlastForce: 10,
              gravity: 0.3,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.yellow,
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.getCardColor(context),
      elevation: 0,
      title: Text(
        'Bayrak Bulma',
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
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade400),
            strokeWidth: 3.0,
          ),
          SizedBox(height: 20.h),
          Text(
            'Bayrak oyunu hazırlanıyor...',
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
              backgroundColor: Colors.orange.shade600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameContent(GameController gameController) {
    final gameState = gameController.gameState;
    // Feedback gösterilirken cached question kullan, yoksa current question
    final currentQuestion = _cachedQuestion ?? gameState.currentQuestion;

    if (currentQuestion == null) {
      return const Center(
        child: Text(
          'Soru bulunamadı',
          style: TextStyle(color: Colors.white),
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
              _buildProgressSection(gameState, 
                displayIndex: _cachedQuestionIndex ?? gameState.currentQuestionIndex),
              SizedBox(height: 30.h),
              Expanded(
                child: _buildFlagQuestionCard(currentQuestion, gameController),
              ),
              SizedBox(height: 20.h),
              _buildActionButtons(gameController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(GameState gameState, {int? displayIndex}) {
    final questionIndex = displayIndex ?? gameState.currentQuestionIndex;
    
    return Column(
      children: [
        SimpleProgressIndicator(
          current: questionIndex,
          total: gameState.totalQuestions,
          primaryColor: Colors.orange.shade400,
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatCard(
              'Soru',
              '${questionIndex + 1}/${gameState.totalQuestions}',
              Icons.flag,
              Colors.orange.shade400,
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
        color: AppTheme.getCardColor(context),
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
              color: AppTheme.getTextSecondaryColor(context),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextPrimaryColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlagQuestionCard(Question question, GameController gameController) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: AppTheme.getCardGradient(context, null),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Colors.orange.withAlpha(76),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(51),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                question.questionText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
              SizedBox(height: 20.h),
              if (question.flagCode != null)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(76),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Flag.fromString(
                      question.flagCode!,
                      height: 120.h,
                      width: 180.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        Expanded(
          child: _buildAnswerOptions(question, gameController),
        ),
      ],
    );
  }

  Widget _buildAnswerOptions(Question question, GameController gameController) {
    // Oyun duraklatıldıysa veya feedback gösteriliyorsa seçim yapılamaz
    final canSelectAnswer = !_showFeedback && 
                            gameController.gameState.status == GameStatus.inProgress;
    
    return ListView.separated(
      itemCount: question.options.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final option = question.options[index];
        final isSelected = _selectedAnswer == option;
        final isCorrect = option.trim().toLowerCase() == question.correctAnswer.trim().toLowerCase();
        
        // Renk mantığı: seçiliyse ve feedback varsa
        Color backgroundColor = Colors.orange.shade600;
        IconData? icon;
        
        if (_showFeedback) {
          if (isSelected && isCorrect) {
            // Doğru seçim
            backgroundColor = Colors.green.shade600;
            icon = Icons.check_circle;
          } else if (isSelected && !isCorrect) {
            // Yanlış seçim
            backgroundColor = Colors.red.shade600;
            icon = Icons.cancel;
          } else if (!isSelected && isCorrect) {
            // Doğru cevabı göster
            backgroundColor = Colors.green.shade400;
            icon = Icons.check_circle_outline;
          }
        }
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: _buildOptionButton(
            option,
            backgroundColor,
            icon,
            canSelectAnswer ? () => _handleAnswerSelection(option, gameController, question) : null,
            isSelected && !isCorrect && _showFeedback,
          ),
        );
      },
    );
  }
  
  Widget _buildOptionButton(
    String text,
    Color backgroundColor,
    IconData? icon,
    VoidCallback? onPressed,
    bool shouldShake,
  ) {
    Widget button = AnimatedButton(
      text: text,
      onPressed: onPressed ?? () {},
      backgroundColor: backgroundColor,
      width: double.infinity,
      icon: icon,
    );
    
    // Yanlış cevaplarda shake animasyonu
    if (shouldShake) {
      return AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          final offset = sin(_shakeAnimation.value * 3.14 * 3) * 10;
          return Transform.translate(
            offset: Offset(offset, 0),
            child: child,
          );
        },
        child: button,
      );
    }
    
    return button;
  }

  Widget _buildActionButtons(GameController gameController) {
    return Row(
      children: [
        Expanded(
          child: AnimatedButton(
            text: 'İpucu',
            onPressed: () => _showHint(gameController),
            backgroundColor: Colors.blue.shade600,
            icon: Icons.lightbulb_outline,
          ),
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: AnimatedButton(
            text: 'Geç',
            onPressed: () => gameController.skipQuestion(),
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
                  colors: [Colors.orange.shade400, Colors.red.shade400],
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
              'Bayrak oyununu tamamladınız',
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
                    backgroundColor: Colors.orange.shade600,
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
        border: Border.all(color: Colors.orange.withAlpha(76), width: 1),
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

  void _handleAnswerSelection(String answer, GameController gameController, Question question) async {
    // Question ve index'i cache'le - feedback sırasında bu soru görünsün
    setState(() {
      _cachedQuestion = question;
      _cachedQuestionIndex = gameController.gameState.currentQuestionIndex;
      _selectedAnswer = answer;
      _showFeedback = true;
    });
    
    _feedbackController.forward();
    
    // Geri bildirim göster
    final isCorrect = answer.trim().toLowerCase() == question.correctAnswer.trim().toLowerCase();
    
    if (isCorrect) {
      // Doğru cevap
      _confettiController.play();
      _triggerVibration(VibrationPattern.success);
      _showSuccessFeedback();
    } else {
      // Yanlış cevap
      _shakeController.forward().then((_) => _shakeController.reset());
      _triggerVibration(VibrationPattern.error);
      _showErrorFeedback();
    }
    
    // Hemen cevabı işle - puan ve doğruluk güncellenir
    await gameController.submitAnswer(answer);
    
    // 2.5 saniye bekle, sonra sonraki soruya geç
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (mounted) {
      setState(() {
        _selectedAnswer = null;
        _showFeedback = false;
        _cachedQuestion = null; // Cache'leri temizle
        _cachedQuestionIndex = null;
      });
      _feedbackController.reset();
      
      // Animate to next question
      _slideController.reset();
      _slideController.forward();
    }
  }
  
  Future<void> _triggerVibration(VibrationPattern pattern) async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator != true) return;
    
    switch (pattern) {
      case VibrationPattern.success:
        // Kısa titreşim
        await Vibration.vibrate(duration: 100);
        break;
      case VibrationPattern.error:
        // Çift titreşim
        await Vibration.vibrate(duration: 50);
        await Future.delayed(const Duration(milliseconds: 100));
        await Vibration.vibrate(duration: 50);
        break;
    }
  }
  
  void _showSuccessFeedback() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => ScaleTransition(
        scale: _feedbackAnimation,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(40.w),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(242),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withAlpha(153),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 80.w,
                  color: Colors.white,
                ),
                SizedBox(height: 10.h),
                Text(
                  'DOĞRU!',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    // Dialog'u 1 saniye sonra kapat
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) Navigator.of(context).pop();
    });
  }
  
  void _showErrorFeedback() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => ScaleTransition(
        scale: _feedbackAnimation,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(40.w),
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(242),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withAlpha(153),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.close,
                  size: 80.w,
                  color: Colors.white,
                ),
                SizedBox(height: 10.h),
                Text(
                  'YANLIŞ!',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    // Dialog'u 1 saniye sonra kapat
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) Navigator.of(context).pop();
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
                style: TextStyle(color: Colors.orange.shade400),
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

enum VibrationPattern {
  success,
  error,
}