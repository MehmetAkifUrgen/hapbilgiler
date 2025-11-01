import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/question.dart';
import '../utils/app_theme.dart';

class QuestionCard extends StatefulWidget {
  final Question question;
  final Function(String)? onAnswerSelected;
  final bool showFeedback;
  final bool isCorrect;

  const QuestionCard({
    super.key,
    required this.question,
    this.onAnswerSelected,
    this.showFeedback = false,
    this.isCorrect = false,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard>
    with TickerProviderStateMixin {
  late AnimationController _cardController;
  late AnimationController _optionsController;
  late Animation<double> _cardAnimation;
  late Animation<double> _optionsAnimation;
  String? _selectedAnswer;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _optionsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    ));

    _optionsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _optionsController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() {
    _cardController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _optionsController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _resetAnimations();
    }
  }

  void _resetAnimations() {
    _selectedAnswer = null;
    _isAnswered = false;
    _cardController.reset();
    _optionsController.reset();
    _startAnimations();
  }

  @override
  void dispose() {
    _cardController.dispose();
    _optionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: Opacity(
            opacity: _cardAnimation.value.clamp(0.0, 1.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildQuestionCard(),
                  SizedBox(height: 30.h),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: _buildAnswerOptions(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: AppTheme.getCardGradient(context, null),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.blue.withAlpha(76),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _getTypeColor().withAlpha(51),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: _getTypeColor(),
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.question.type == QuestionType.word ? 'Kelime' : 'Bayrak',
                  style: TextStyle(
                    color: _getTypeColor(),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _getDifficultyColor().withAlpha(51),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: _getDifficultyColor(),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getDifficultyText(),
                  style: TextStyle(
                    color: _getDifficultyColor(),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          if (widget.question.imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                widget.question.imageUrl!,
                height: 150.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey.shade600,
                      size: 48.w,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20.h),
          ],
          Text(
            widget.question.questionText,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextPrimaryColor(context),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions() {
    return AnimatedBuilder(
      animation: _optionsAnimation,
      builder: (context, child) {
        return ListView.separated(
          itemCount: widget.question.options.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final option = widget.question.options[index];
            final isSelected = _selectedAnswer == option;
            final isCorrect = option.trim().toLowerCase() == widget.question.correctAnswer.trim().toLowerCase();
            
            return Transform.translate(
              offset: Offset(
                (1 - _optionsAnimation.value) * 100,
                0,
              ),
              child: Opacity(
                opacity: _optionsAnimation.value.clamp(0.0, 1.0),
                child: _buildOptionButton(
                  option,
                  index,
                  isSelected,
                  isCorrect,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOptionButton(
    String option,
    int index,
    bool isSelected,
    bool isCorrect,
  ) {
    final showingFeedback = widget.showFeedback || _isAnswered;
    Color backgroundColor;
    Color textColor = Colors.white;
    Color borderColor;

    if (showingFeedback) {
      if (isCorrect) {
        backgroundColor = Colors.green.shade600;
        borderColor = Colors.green.shade400;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red.shade600;
        borderColor = Colors.red.shade400;
      } else {
        backgroundColor = const Color(0xFF16213E);
        borderColor = Colors.grey.shade600;
        textColor = Colors.grey.shade400;
      }
    } else {
      backgroundColor = isSelected
          ? Colors.blue.shade600
          : const Color(0xFF16213E);
      borderColor = isSelected
          ? Colors.blue.shade400
          : Colors.grey.shade600;
    }

    return GestureDetector(
      onTap: (showingFeedback || widget.onAnswerSelected == null) ? null : () => _selectAnswer(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: isSelected && !_isAnswered
              ? [
                  BoxShadow(
                    color: backgroundColor.withAlpha(102),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: borderColor.withAlpha(51),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (_isAnswered && isCorrect)
              Icon(
                Icons.check_circle,
                color: Colors.green.shade400,
                size: 24.w,
              )
            else if (_isAnswered && isSelected && !isCorrect)
              Icon(
                Icons.cancel,
                color: Colors.red.shade400,
                size: 24.w,
              ),
          ],
        ),
      ),
    );
  }

  void _selectAnswer(String answer) {
    if (_isAnswered || widget.onAnswerSelected == null) return;

    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
    });

    // Wait for animation to complete before calling callback
    Future.delayed(const Duration(milliseconds: 300), () {
      widget.onAnswerSelected?.call(answer);
    });
  }

  Color _getTypeColor() {
    switch (widget.question.type) {
      case QuestionType.word:
        return Colors.blue.shade400;
      case QuestionType.flag:
        return Colors.orange.shade400;
      case QuestionType.fillInTheBlank:
        return Colors.purple.shade400;
    }
  }

  Color _getDifficultyColor() {
    switch (widget.question.difficulty) {
      case DifficultyLevel.easy:
        return Colors.green.shade400;
      case DifficultyLevel.medium:
        return Colors.orange.shade400;
      case DifficultyLevel.hard:
        return Colors.red.shade400;
    }
  }

  String _getDifficultyText() {
    switch (widget.question.difficulty) {
      case DifficultyLevel.easy:
        return 'Kolay';
      case DifficultyLevel.medium:
        return 'Orta';
      case DifficultyLevel.hard:
        return 'Zor';
    }
  }
}