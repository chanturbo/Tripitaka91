import 'package:shared_preferences/shared_preferences.dart';

void saveValueCorrect(int value) async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'valueCorrect';
  prefs.setInt(key, value);
}

Future<int> getValueCorrectFurture() async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'valueCorrect';
  final int value = prefs.getInt(key) ?? 0;
  return value;
}

void saveValueSpeech(int value) async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'valueSpeech';
  prefs.setInt(key, value);
}

Future<int> getValueSpeechFurture() async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'valueSpeech';
  final int value = prefs.getInt(key) ?? 0;
  return value;
}

void saveValueBeta(int value) async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'valueBeta';
  prefs.setInt(key, value);
}

void clearValueBeta() async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'valueBeta';
  prefs.remove(key); // ลบข้อมูลที่เก็บใน SharedPreferences ด้วย key
}

Future<int> getValueBetaFurture() async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'valueBeta';
  final int value = prefs.getInt(key) ?? 0;
  return value;
}

void saveValueBetaSpeech(int value) async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'valueBetaSpeech';
  prefs.setInt(key, value);
}

Future<int> getValueBetaSpeechFurture() async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'valueBetaSpeech';
  final int value = prefs.getInt(key) ?? 0;
  return value;
}
