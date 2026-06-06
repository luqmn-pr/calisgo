import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BattleResult {
  final String date;
  final String blueName;
  final String redName;
  final int blueScore;
  final int redScore;

  BattleResult({
    required this.date,
    required this.blueName,
    required this.redName,
    required this.blueScore,
    required this.redScore,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'blueName': blueName,
        'redName': redName,
        'blueScore': blueScore,
        'redScore': redScore,
      };

  factory BattleResult.fromJson(Map<String, dynamic> json) => BattleResult(
        date: json['date'] as String,
        blueName: json['blueName'] as String,
        redName: json['redName'] as String,
        blueScore: json['blueScore'] as int,
        redScore: json['redScore'] as int,
      );
}

class BattleDatabase {
  static const String _key = 'calisgo_battle_history';

  static Future<void> saveResult(BattleResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyJson = prefs.getStringList(_key) ?? [];
    
    // Add new result
    historyJson.insert(0, jsonEncode(result.toJson()));
    
    // Keep only last 20 battles
    if (historyJson.length > 20) {
      historyJson.removeLast();
    }
    
    await prefs.setStringList(_key, historyJson);
  }

  static Future<List<BattleResult>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyJson = prefs.getStringList(_key) ?? [];
    
    return historyJson.map((jsonStr) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return BattleResult.fromJson(map);
    }).toList();
  }
}
