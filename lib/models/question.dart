class Question {
  final String id;
  final String questionText;
  final String correctAnswer;
  final List<String> options;
  final String? imageUrl;
  final String? flagCode;
  final QuestionType type;
  final DifficultyLevel difficulty;
  
  // New fields for fill-in-the-blank questions
  final String? hint;
  final List<int>? blankPositions; // Positions of letters to hide
  final int? wordLength; // Length of the word to guess

  Question({
    required this.id,
    required this.questionText,
    required this.correctAnswer,
    required this.options,
    this.imageUrl,
    this.flagCode,
    required this.type,
    required this.difficulty,
    this.hint,
    this.blankPositions,
    this.wordLength,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      questionText: json['questionText'] ?? '',
      correctAnswer: json['correctAnswer'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      imageUrl: json['imageUrl'],
      flagCode: json['flagCode'],
      type: QuestionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => QuestionType.word,
      ),
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.toString().split('.').last == json['difficulty'],
        orElse: () => DifficultyLevel.easy,
      ),
      hint: json['hint'],
      blankPositions: json['blankPositions'] != null 
          ? List<int>.from(json['blankPositions']) 
          : null,
      wordLength: json['wordLength'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionText': questionText,
      'correctAnswer': correctAnswer,
      'options': options,
      'imageUrl': imageUrl,
      'flagCode': flagCode,
      'type': type.toString().split('.').last,
      'difficulty': difficulty.toString().split('.').last,
      'hint': hint,
      'blankPositions': blankPositions,
      'wordLength': wordLength,
    };
  }
}

enum QuestionType {
  word,
  flag,
  fillInTheBlank,
}

enum DifficultyLevel {
  easy,
  medium,
  hard,
}