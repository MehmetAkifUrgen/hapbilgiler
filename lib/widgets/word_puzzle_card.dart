import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/question.dart';
import '../utils/app_theme.dart';

class WordPuzzleCard extends StatefulWidget {
  final Question question;
  final Function(String)? onAnswerSubmitted;
  final bool isAnswered;
  final bool showFeedback;
  final bool isCorrect;

  const WordPuzzleCard({
    super.key,
    required this.question,
    this.onAnswerSubmitted,
    this.isAnswered = false,
    this.showFeedback = false,
    this.isCorrect = false,
  });

  @override
  State<WordPuzzleCard> createState() => _WordPuzzleCardState();
}

class _WordPuzzleCardState extends State<WordPuzzleCard>
    with TickerProviderStateMixin {
  late AnimationController _cardController;
  late AnimationController _letterController;
  late Animation<double> _cardAnimation;
  late Animation<double> _letterAnimation;

  List<String> _userInput = [];
  List<String> _previousInput = []; // Önceki değerleri takip etmek için
  List<TextEditingController> _controllers = [];
  List<FocusNode> _focusNodes = [];
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _letterController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    ));

    _letterAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _letterController,
      curve: Curves.easeOutCubic,
    ));

    _initializeInput();
    _cardController.forward();
    
    Future.delayed(const Duration(milliseconds: 400), () {
      _letterController.forward();
    });
  }

  void _initializeInput() {
    final wordLength = widget.question.correctAnswer.length;
    
    // Dispose existing controllers and focus nodes to prevent memory leaks
    if (_controllers.isNotEmpty) {
      for (var controller in _controllers) {
        controller.dispose();
      }
    }
    if (_focusNodes.isNotEmpty) {
      for (var focusNode in _focusNodes) {
        focusNode.dispose();
      }
    }
    
    // Initialize new lists with correct length
    _userInput = List.filled(wordLength, '');
    _previousInput = List.filled(wordLength, ''); // Önceki değerleri de initialize et
    
    // Create controllers and focus nodes for each letter
    _controllers = List.generate(
      wordLength, 
      (index) => TextEditingController(),
    );
    
    _focusNodes = List.generate(
      wordLength, 
      (index) => FocusNode(),
    );
  }

  @override
  void didUpdateWidget(WordPuzzleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Eğer soru değiştiyse, input'ları yeniden initialize et
    if (oldWidget.question.correctAnswer != widget.question.correctAnswer) {
      _initializeInput();
      _cardController.reset();
      _letterController.reset();
      _cardController.forward();
      
      Future.delayed(const Duration(milliseconds: 400), () {
        _letterController.forward();
      });
    }
  }

  @override
  void dispose() {
    _cardController.dispose();
    _letterController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onLetterChanged(int index, String value) {
    final previousValue = _previousInput[index];
    
    // Backspace algılaması: önceki değer doluydu, şimdi boş
    if (previousValue.isNotEmpty && value.isEmpty) {
      // Mevcut kutucuğu temizle
      setState(() {
        _userInput[index] = '';
        _previousInput[index] = '';
      });
      
      // Önceki kutucuğa geç ve onu temizle
      _moveToPreviousField(index);
      return;
    }
    
    // Normal harf girişi
    if (value.isNotEmpty && value.length == 1) {
      // Türkçe karakter desteği
      final upperValue = _convertToTurkishUpper(value);
      setState(() {
        _userInput[index] = upperValue;
        _previousInput[index] = upperValue;
      });
      
      // Update the controller to show uppercase letter
      _controllers[index].value = TextEditingValue(
        text: upperValue,
        selection: TextSelection.fromPosition(
          TextPosition(offset: upperValue.length),
        ),
      );
      
      // Otomatik olarak bir sonraki boş alana geç
      _moveToNextBlankField(index);
    } else if (value.isEmpty) {
      // Sadece temizle, hareket etme
      setState(() {
        _userInput[index] = '';
        _previousInput[index] = '';
      });
    }
  }

  void _moveToPreviousField(int currentIndex) {
    // Önceki input alanını bul (boşluk karakterlerini atla)
    for (int i = currentIndex - 1; i >= 0; i--) {
      if (widget.question.correctAnswer[i] != ' ') {
        // Önceki kutucuğu temizle ve odaklan
        setState(() {
          _userInput[i] = '';
        });
        _controllers[i].clear();
        _focusNodes[i].requestFocus();
        break;
      }
    }
  }

  void _handleBackspaceOnEmptyField(int currentIndex) {
    // Boş bir field'da backspace'e basıldığında önceki field'a geç ve onu sil
    for (int i = currentIndex - 1; i >= 0; i--) {
      if (widget.question.correctAnswer[i] != ' ' && !_isLetterVisible(i)) {
        // Önceki kutucuğu temizle ve odaklan
        setState(() {
          _userInput[i] = '';
          _previousInput[i] = '';
        });
        _controllers[i].clear();
        _focusNodes[i].requestFocus();
        break;
      }
    }
  }

  String _convertToTurkishUpper(String char) {
    switch (char.toLowerCase()) {
      case 'i':
        return 'İ';
      case 'ı':
        return 'I';
      case 'ş':
        return 'Ş';
      case 'ğ':
        return 'Ğ';
      case 'ü':
        return 'Ü';
      case 'ö':
        return 'Ö';
      case 'ç':
        return 'Ç';
      default:
        return char.toUpperCase();
    }
  }

  void _moveToNextBlankField(int currentIndex) {
    // Bir sonraki boş alanı bul (boşluk karakterlerini atla)
    for (int i = currentIndex + 1; i < _userInput.length; i++) {
      if (!_isLetterVisible(i) && widget.question.correctAnswer[i] != ' ') {
        _focusNodes[i].requestFocus();
        return;
      }
    }
    
    // Eğer sonraki boş alan yoksa, cevabı kontrol et
    _checkIfAnswerComplete();
  }

  void _checkIfAnswerComplete() {
    // Tüm boş alanlar dolduruldu mu kontrol et (boşluk karakterlerini atla)
    bool allBlanksFilled = true;
    for (int i = 0; i < _userInput.length; i++) {
      if (!_isLetterVisible(i) && widget.question.correctAnswer[i] != ' ' && _userInput[i].isEmpty) {
        allBlanksFilled = false;
        break;
      }
    }
    
    if (allBlanksFilled) {
      // Tüm boş alanlar doldurulduysa odağı kaldır
      FocusScope.of(context).unfocus();
    }
  }

  void _submitAnswer() {
    if (widget.onAnswerSubmitted == null) return;
    
    // Kullanıcının girdiği cevabı oluştur (boşluk karakterlerini de dahil et)
    String userAnswer = '';
    for (int i = 0; i < widget.question.correctAnswer.length; i++) {
      if (widget.question.correctAnswer[i] == ' ') {
        userAnswer += ' '; // Boşluk karakterini ekle
      } else if (_isLetterVisible(i)) {
        // Eğer harf görünürse (dolu geldiyse), doğrudan doğru cevaptan al
        userAnswer += widget.question.correctAnswer[i];
      } else {
        // Eğer harf boş bırakılmışsa, kullanıcının girdiğini al
        userAnswer += _userInput[i];
      }
    }
    
    // Cevabı gönder
    widget.onAnswerSubmitted!(userAnswer);
  }

  bool _isLetterVisible(int index) {
    final correctLetter = widget.question.correctAnswer[index];
    
    // Boşluk karakterleri her zaman görünür
    if (correctLetter == ' ') {
      return true;
    }
    
    final blankPositions = widget.question.blankPositions ?? [];
    return !blankPositions.contains(index);
  }

  Color _getLetterBoxColor(int index) {
    final showingFeedback = widget.showFeedback || widget.isAnswered;
    
    if (showingFeedback) {
      final correctLetter = _convertToTurkishUpper(widget.question.correctAnswer[index]);
      final userLetter = _userInput[index];
      
      if (userLetter == correctLetter) {
        return Colors.green.shade600;
      } else if (userLetter.isNotEmpty) {
        return Colors.red.shade600;
      }
    }
    
    return _userInput[index].isNotEmpty 
        ? Colors.blue.shade600 
        : Colors.grey.shade700;
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
                  _buildWordPuzzle(),
                  SizedBox(height: 20.h),
                  _buildHintSection(),
                  SizedBox(height: 20.h),
                  _buildActionButtons(),
                  SizedBox(height: 20.h),
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
                  color: Colors.purple.withAlpha(51),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: Colors.purple,
                    width: 1,
                  ),
                ),
                child: Text(
                  'Kelime Bulmaca',
                  style: TextStyle(
                    color: Colors.purple,
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

  Widget _buildWordPuzzle() {
    return AnimatedBuilder(
      animation: _letterAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade700
                  : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                'Kelimeyi Tamamla',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
              SizedBox(height: 20.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                alignment: WrapAlignment.center,
                children: List.generate(
                  widget.question.correctAnswer.length,
                  (index) => _buildLetterBox(index),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLetterBox(int index) {
    final isVisible = _isLetterVisible(index);
    final correctLetter = widget.question.correctAnswer[index];
    
    // Eğer karakter boşluk ise, görünür boşluk göster
    if (correctLetter == ' ') {
      return SizedBox(
        width: 20.w,
        height: 45.h,
        child: Center(
          child: Text(
            ' ',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.0,
            ),
          ),
        ),
      );
    }
    
    return Transform.scale(
      scale: _letterAnimation.value,
      child: Container(
        width: 45.w,
        height: 45.h,
        decoration: BoxDecoration(
          color: _getLetterBoxColor(index),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: Colors.white.withAlpha(51),
            width: 1,
          ),
        ),
        child: isVisible
            ? Center(
                child: Text(
                  correctLetter.toUpperCase(),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
              )
            : Center(
                child: Focus(
                  onKeyEvent: (FocusNode node, KeyEvent event) {
                    if (event is KeyDownEvent && 
                        event.logicalKey == LogicalKeyboardKey.backspace) {
                      // Eğer mevcut kutucuk boşsa, önceki kutucuğa geç ve onu sil
                      if (_controllers[index].text.isEmpty) {
                        _handleBackspaceOnEmptyField(index);
                        return KeyEventResult.handled;
                      }
                    }
                    return KeyEventResult.ignored;
                  },
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.0,
                    ),
                    maxLength: 1,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    onChanged: (value) => _onLetterChanged(index, value),
                    onTap: () {
                      _controllers[index].selection = TextSelection.fromPosition(
                        TextPosition(offset: _controllers[index].text.length),
                      );
                    },
                    textInputAction: TextInputAction.next,
                    enabled: !widget.isAnswered && !widget.showFeedback,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final showingFeedback = widget.isAnswered || widget.showFeedback;
    if (showingFeedback) return const SizedBox.shrink();
    
    return Row(
      children: [
        // Temizle Butonu
        Expanded(
          child: ElevatedButton(
            onPressed: widget.onAnswerSubmitted != null ? _clearAllFields : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 2,
            ),
            child: Text(
              'Temizle',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // Cevabı Gönder Butonu
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: (_canSubmitAnswer() && widget.onAnswerSubmitted != null) ? _submitAnswer : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _canSubmitAnswer() ? Colors.green.shade600 : Colors.grey.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: _canSubmitAnswer() ? 4 : 0,
            ),
            child: Text(
              'Cevabı Gönder',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _clearAllFields() {
    setState(() {
      for (int i = 0; i < _userInput.length; i++) {
        _userInput[i] = '';
        _previousInput[i] = ''; // Önceki değerleri de temizle
        _controllers[i].clear();
      }
    });
    
    // İlk boş alana odaklan
    _focusFirstBlankField();
  }

  void _focusFirstBlankField() {
    for (int i = 0; i < widget.question.correctAnswer.length; i++) {
      if (widget.question.correctAnswer[i] != ' ' && !_isLetterVisible(i)) {
        _focusNodes[i].requestFocus();
        break;
      }
    }
  }

  bool _canSubmitAnswer() {
    // Tüm boş alanlar dolduruldu mu kontrol et (boşluk karakterlerini atla)
    for (int i = 0; i < widget.question.correctAnswer.length; i++) {
      final correctChar = widget.question.correctAnswer[i];
      
      // Boşluk karakterlerini atla
      if (correctChar == ' ') {
        continue;
      }
      
      // Eğer bu pozisyon boş alan ise (görünür değilse) ve kullanıcı girmemişse
      if (!_isLetterVisible(i) && _userInput[i].isEmpty) {
        return false;
      }
    }
    return true;
  }

  Widget _buildHintSection() {
    if (widget.question.hint == null) return const SizedBox.shrink();
    
    return Column(
      children: [
        if (!_showHint)
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _showHint = true;
              });
            },
            icon: const Icon(Icons.lightbulb_outline),
            label: const Text('İpucu Göster'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
            ),
          ),
        if (_showHint)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.orange.shade600.withAlpha(51),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.orange.shade600,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Colors.orange.shade600,
                  size: 24.w,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    widget.question.hint!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.orange.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Color _getDifficultyColor() {
    switch (widget.question.difficulty) {
      case DifficultyLevel.easy:
        return Colors.green;
      case DifficultyLevel.medium:
        return Colors.orange;
      case DifficultyLevel.hard:
        return Colors.red;
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