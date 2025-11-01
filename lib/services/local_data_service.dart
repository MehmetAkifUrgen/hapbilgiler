import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question.dart';
import '../models/user_stats.dart';

class LocalDataService {
  static const String _userStatsKey = 'user_stats';
  static const String _gameHistoryKey = 'game_history';
  
  // Singleton pattern
  static final LocalDataService _instance = LocalDataService._internal();
  factory LocalDataService() => _instance;
  LocalDataService._internal();

  /// Get mock questions for testing
  List<Question> getMockQuestions(QuestionType type, {int count = 10}) {
    final random = Random();
    final questions = <Question>[];
    
    if (type == QuestionType.word) {
      final wordQuestions = _getWordQuestions();
      wordQuestions.shuffle(random);
      questions.addAll(wordQuestions.take(count));
    } else {
      final flagQuestions = _getFlagQuestions();
      flagQuestions.shuffle(random);
      questions.addAll(flagQuestions.take(count));
    }
    
    return questions;
  }

  List<Question> _getWordQuestions() {
    return [
      // Fill-in-the-blank questions for animals
      Question(
        id: 'fb1',
        questionText: 'Bu hayvanın adını tamamla: Ormanda yaşayan, bal yapan böcek',
        correctAnswer: 'ARI',
        options: [], // Empty for fill-in-the-blank
        type: QuestionType.fillInTheBlank,
        difficulty: DifficultyLevel.easy,
        hint: 'Çiçeklerden nektar toplar ve bal yapar',
        blankPositions: [1], // Hide the middle letter 'R'
        wordLength: 3,
      ),
      Question(
        id: 'fb2',
        questionText: 'Bu hayvanın adını tamamla: Büyük, gri renkli, hortumlu hayvan',
        correctAnswer: 'FIL',
        options: [],
        type: QuestionType.fillInTheBlank,
        difficulty: DifficultyLevel.easy,
        hint: 'Afrika\'da yaşar ve çok büyük kulaklara sahiptir',
        blankPositions: [0, 2], // Hide first and last letters
        wordLength: 3,
      ),
      Question(
        id: 'fb3',
        questionText: 'Bu hayvanın adını tamamla: Ormanda yaşayan, kahverengi, balık yiyen hayvan',
        correctAnswer: 'AYI',
        options: [],
        type: QuestionType.fillInTheBlank,
        difficulty: DifficultyLevel.easy,
        hint: 'Kış uykusuna yatar ve bal sever',
        blankPositions: [0, 2], // Hide first and last letters
        wordLength: 3,
      ),
      Question(
        id: 'fb4',
        questionText: 'Bu hayvanın adını tamamla: Çiftlikte yaşayan, süt veren hayvan',
        correctAnswer: 'INEK',
        options: [],
        type: QuestionType.fillInTheBlank,
        difficulty: DifficultyLevel.easy,
        hint: 'Çayırlarda otlar ve "möö" sesi çıkarır',
        blankPositions: [1, 3], // Hide middle letters
        wordLength: 4,
      ),
      Question(
        id: 'fb5',
        questionText: 'Bu hayvanın adını tamamla: Denizde yaşayan, çok büyük memeli',
        correctAnswer: 'BALINA',
        options: [],
        type: QuestionType.fillInTheBlank,
        difficulty: DifficultyLevel.medium,
        hint: 'Dünyanın en büyük hayvanı, su fışkırtır',
        blankPositions: [1, 3, 5], // Hide some letters
        wordLength: 6,
      ),
      Question(
        id: 'fb6',
        questionText: 'Bu hayvanın adını tamamla: Çok hızlı koşan, sarı benekli büyük kedi',
        correctAnswer: 'ÇITA',
        options: [],
        type: QuestionType.fillInTheBlank,
        difficulty: DifficultyLevel.medium,
        hint: 'Dünyanın en hızlı kara hayvanı',
        blankPositions: [0, 2], // Hide first and third letters
        wordLength: 4,
      ),
      Question(
        id: 'fb7',
        questionText: 'Bu hayvanın adını tamamla: Uzun boyunlu, Afrika\'da yaşayan hayvan',
        correctAnswer: 'ZÜRAFA',
        options: [],
        type: QuestionType.fillInTheBlank,
        difficulty: DifficultyLevel.medium,
        hint: 'Ağaçların en yüksek yapraklarını yiyebilir',
        blankPositions: [1, 3, 5], // Hide some letters
        wordLength: 6,
      ),
      Question(
        id: 'fb8',
        questionText: 'Bu hayvanın adını tamamla: Siyah-beyaz çizgili, Afrika\'da yaşayan at benzeri',
        correctAnswer: 'ZEBRA',
        options: [],
        type: QuestionType.fillInTheBlank,
        difficulty: DifficultyLevel.medium,
        hint: 'Her birinin çizgi deseni farklıdır',
        blankPositions: [1, 3], // Hide some letters
        wordLength: 5,
      ),
      Question(
        id: 'fb9',
        questionText: 'Bu hayvanın adını tamamla: Büyük, güçlü, yeleli büyük kedi',
        correctAnswer: 'ASLAN',
        options: [],
        type: QuestionType.fillInTheBlank,
        difficulty: DifficultyLevel.easy,
        hint: 'Hayvanlar aleminin kralı olarak bilinir',
        blankPositions: [1, 3], // Hide some letters
        wordLength: 5,
      ),
      Question(
        id: 'fb10',
        questionText: 'Bu hayvanın adını tamamla: Suda ve karada yaşayabilen, yeşil renkli',
        correctAnswer: 'KURBAĞA',
        options: [],
        type: QuestionType.fillInTheBlank,
        difficulty: DifficultyLevel.hard,
        hint: 'Metamorfoza uğrar, önce iribaş olur',
        blankPositions: [1, 3, 5], // Hide some letters
        wordLength: 7,
      ),
    ];
  }

  List<Question> _getFlagQuestions() {
    // Tüm ülke havuzu
    final allCountries = _getAllCountries();
    
    // Random sorular üret
    final random = Random();
    allCountries.shuffle(random);
    
    List<Question> questions = [];
    
    for (int i = 0; i < allCountries.length; i++) {
      final correctCountry = allCountries[i];
      
      // Yanlış seçenekler için 3 random ülke seç
      final otherCountries = List<Map<String, String>>.from(allCountries)
        ..removeWhere((c) => c['code'] == correctCountry['code'])
        ..shuffle(random);
      
      final options = [
        correctCountry['name']!,
        otherCountries[0]['name']!,
        otherCountries[1]['name']!,
        otherCountries[2]['name']!,
      ]..shuffle(random);
      
      questions.add(Question(
        id: 'f${i + 1}',
        questionText: 'Bu bayrak hangi ülkeye ait?',
        correctAnswer: correctCountry['name']!,
        options: options,
        flagCode: correctCountry['code']!,
        type: QuestionType.flag,
        difficulty: _getDifficultyByIndex(i),
      ));
    }
    
    return questions;
  }
  
  DifficultyLevel _getDifficultyByIndex(int index) {
    if (index < 20) return DifficultyLevel.easy;
    if (index < 40) return DifficultyLevel.medium;
    return DifficultyLevel.hard;
  }
  
  List<Map<String, String>> _getAllCountries() {
    return [
      // Kolay - Popüler ülkeler
      {'code': 'TR', 'name': 'Türkiye'},
      {'code': 'US', 'name': 'Amerika'},
      {'code': 'GB', 'name': 'İngiltere'},
      {'code': 'FR', 'name': 'Fransa'},
      {'code': 'DE', 'name': 'Almanya'},
      {'code': 'IT', 'name': 'İtalya'},
      {'code': 'ES', 'name': 'İspanya'},
      {'code': 'RU', 'name': 'Rusya'},
      {'code': 'CN', 'name': 'Çin'},
      {'code': 'JP', 'name': 'Japonya'},
      {'code': 'BR', 'name': 'Brezilya'},
      {'code': 'CA', 'name': 'Kanada'},
      {'code': 'AU', 'name': 'Avustralya'},
      {'code': 'MX', 'name': 'Meksika'},
      {'code': 'NL', 'name': 'Hollanda'},
      {'code': 'KR', 'name': 'Güney Kore'},
      {'code': 'IN', 'name': 'Hindistan'},
      {'code': 'SA', 'name': 'Suudi Arabistan'},
      {'code': 'AR', 'name': 'Arjantin'},
      {'code': 'EG', 'name': 'Mısır'},
      
      // Orta - Bilinen ülkeler
      {'code': 'SE', 'name': 'İsveç'},
      {'code': 'NO', 'name': 'Norveç'},
      {'code': 'DK', 'name': 'Danimarka'},
      {'code': 'FI', 'name': 'Finlandiya'},
      {'code': 'PL', 'name': 'Polonya'},
      {'code': 'GR', 'name': 'Yunanistan'},
      {'code': 'PT', 'name': 'Portekiz'},
      {'code': 'BE', 'name': 'Belçika'},
      {'code': 'CH', 'name': 'İsviçre'},
      {'code': 'AT', 'name': 'Avusturya'},
      {'code': 'IE', 'name': 'İrlanda'},
      {'code': 'NZ', 'name': 'Yeni Zelanda'},
      {'code': 'ZA', 'name': 'Güney Afrika'},
      {'code': 'IL', 'name': 'İsrail'},
      {'code': 'AE', 'name': 'BAE'},
      {'code': 'TH', 'name': 'Tayland'},
      {'code': 'ID', 'name': 'Endonezya'},
      {'code': 'MY', 'name': 'Malezya'},
      {'code': 'SG', 'name': 'Singapur'},
      {'code': 'PH', 'name': 'Filipinler'},
      
      // Zor - Daha az bilinen ülkeler
      {'code': 'CZ', 'name': 'Çekya'},
      {'code': 'HU', 'name': 'Macaristan'},
      {'code': 'RO', 'name': 'Romanya'},
      {'code': 'BG', 'name': 'Bulgaristan'},
      {'code': 'HR', 'name': 'Hırvatistan'},
      {'code': 'RS', 'name': 'Sırbistan'},
      {'code': 'SK', 'name': 'Slovakya'},
      {'code': 'SI', 'name': 'Slovenya'},
      {'code': 'UA', 'name': 'Ukrayna'},
      {'code': 'BY', 'name': 'Belarus'},
      {'code': 'LT', 'name': 'Litvanya'},
      {'code': 'LV', 'name': 'Letonya'},
      {'code': 'EE', 'name': 'Estonya'},
      {'code': 'IS', 'name': 'İzlanda'},
      {'code': 'LU', 'name': 'Lüksemburg'},
      {'code': 'CL', 'name': 'Şili'},
      {'code': 'PE', 'name': 'Peru'},
      {'code': 'CO', 'name': 'Kolombiya'},
      {'code': 'VE', 'name': 'Venezuela'},
      {'code': 'CU', 'name': 'Küba'},
      {'code': 'JM', 'name': 'Jamaika'},
      {'code': 'NG', 'name': 'Nijerya'},
      {'code': 'KE', 'name': 'Kenya'},
      {'code': 'ET', 'name': 'Etiyopya'},
      {'code': 'MA', 'name': 'Fas'},
      {'code': 'DZ', 'name': 'Cezayir'},
      {'code': 'TN', 'name': 'Tunus'},
      {'code': 'LY', 'name': 'Libya'},
      {'code': 'IQ', 'name': 'Irak'},
      {'code': 'IR', 'name': 'İran'},
      {'code': 'PK', 'name': 'Pakistan'},
      {'code': 'BD', 'name': 'Bangladeş'},
      {'code': 'VN', 'name': 'Vietnam'},
      {'code': 'KZ', 'name': 'Kazakistan'},
      {'code': 'UZ', 'name': 'Özbekistan'},
    ];
  }

  /// Save user statistics to local storage
  Future<void> saveUserStats(UserStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(stats.toJson());
    await prefs.setString(_userStatsKey, jsonString);
  }

  /// Load user statistics from local storage
  Future<UserStats> loadUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userStatsKey);
    
    if (jsonString != null) {
      final jsonMap = json.decode(jsonString);
      return UserStats.fromJson(jsonMap);
    }
    
    return UserStats(); // Return default stats if none exist
  }

  /// Save game history
  Future<void> saveGameHistory(List<Map<String, dynamic>> history) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(history);
    await prefs.setString(_gameHistoryKey, jsonString);
  }

  /// Load game history
  Future<List<Map<String, dynamic>>> loadGameHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_gameHistoryKey);
    
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.cast<Map<String, dynamic>>();
    }
    
    return [];
  }

  /// Clear all local data
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Generate a unique user ID
  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    
    if (userId == null) {
      userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('user_id', userId);
    }
    
    return userId;
  }
}