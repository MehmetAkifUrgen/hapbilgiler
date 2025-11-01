import 'question.dart';

class SubjectCategory {
  final String key;
  final String displayName;
  final List<QuizQuestion> questions;

  SubjectCategory({
    required this.key,
    required this.displayName,
    required this.questions,
  });

  factory SubjectCategory.fromJson(String key, List<dynamic> questionsJson) {
    return SubjectCategory(
      key: key,
      displayName: _getDisplayName(key),
      questions: questionsJson
          .map((json) => QuizQuestion.fromJson(json))
          .toList(),
    );
  }

  static String _getDisplayName(String key) {
    switch (key) {
      case 'tarih_sorulari':
        return 'Tarih';
      case 'matematik_sorulari':
        return 'Matematik';
      case 'turkce_sorulari':
        return 'Türkçe';
      case 'cografya_sorulari':
        return 'Coğrafya';
      case 'fen_sorulari':
        return 'Fen Bilimleri';
      default:
        return key.replaceAll('_sorulari', '').replaceAll('_', ' ').toUpperCase();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'displayName': displayName,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

class QuizQuestion {
  final int soruId;
  final String soru;
  final String cevap;
  final List<String> ekBilgi;

  QuizQuestion({
    required this.soruId,
    required this.soru,
    required this.cevap,
    required this.ekBilgi,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      soruId: json['soru_id'] ?? 0,
      soru: json['soru'] ?? '',
      cevap: json['cevap'] ?? '',
      ekBilgi: List<String>.from(json['ek_bilgi'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soru_id': soruId,
      'soru': soru,
      'cevap': cevap,
      'ek_bilgi': ekBilgi,
    };
  }

  // Mevcut Question modeline dönüştürme
  Question toQuestion() {
    // KPSS sorularını boşluk doldurma şekline çevir
    String questionText = soru;
    String correctAnswer = cevap.toUpperCase();
    
    // Cevabı soru metninde bulup boşluk ile değiştir
    String modifiedQuestion = _createFillInTheBlankQuestion(questionText, correctAnswer);
    
    // Boşluk doldurma için hangi harflerin gizleneceğini belirle
    List<int> blankPositions = _generateBlankPositions(correctAnswer);

    return Question(
      id: soruId.toString(),
      questionText: modifiedQuestion,
      correctAnswer: correctAnswer,
      options: [], // Boşluk doldurma için seçenek yok
      type: QuestionType.fillInTheBlank,
      difficulty: DifficultyLevel.medium,
      hint: ekBilgi.isNotEmpty ? ekBilgi.first : 'İpucu mevcut değil',
      blankPositions: blankPositions,
      wordLength: correctAnswer.length,
    );
  }
  
  String _createFillInTheBlankQuestion(String question, String answer) {
    // Cevabı soru metninde bul ve boşluk ile değiştir
    String modifiedQuestion = question;
    
    // Farklı varyasyonları dene
    List<String> variations = [
      answer,
      answer.toLowerCase(),
      answer.toUpperCase(),
      '${answer.substring(0, 1).toUpperCase()}${answer.substring(1).toLowerCase()}',
    ];
    
    for (String variation in variations) {
      if (modifiedQuestion.contains(variation)) {
        modifiedQuestion = modifiedQuestion.replaceFirst(variation, '______');
        break;
      }
    }
    
    // Eğer cevap soru metninde bulunamazsa, soruyu boşluk doldurma formatına çevir
    if (!modifiedQuestion.contains('______')) {
      modifiedQuestion = '$question\n\nCevap: ______';
    }
    
    return modifiedQuestion;
  }
  
  List<int> _generateBlankPositions(String answer) {
    // Cevabın uzunluğuna göre hangi harflerin gizleneceğini belirle
    List<int> positions = [];
    int length = answer.length;
    
    if (length <= 3) {
      // Kısa kelimeler için ortadaki harfi gizle
      positions.add(1);
    } else if (length <= 6) {
      // Orta uzunlukta kelimeler için 2-3 harf gizle
      positions.addAll([1, length - 2]);
    } else {
      // Uzun kelimeler için daha fazla harf gizle
      for (int i = 1; i < length - 1; i += 2) {
        positions.add(i);
      }
    }
    
    return positions;
  }
}