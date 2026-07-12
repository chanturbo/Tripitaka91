import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveValueCorrect(int value) async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'valueCorrect';
  await prefs.setInt(key, value);
}

Future<int> getValueCorrectFurture() async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'valueCorrect';
  final int value = prefs.getInt(key) ?? 0;
  return value;
}

Future<void> saveValueSpeech(int value) async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'valueSpeech';
  await prefs.setInt(key, value);
}

Future<int> getValueSpeechFurture() async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'valueSpeech';
  final int value = prefs.getInt(key) ?? 0;
  return value;
}

Future<void> saveValueBeta(int value) async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'valueBeta';
  await prefs.setInt(key, value);
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

Future<void> saveValueBetaSpeech(int value) async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'valueBetaSpeech';
  await prefs.setInt(key, value);
}

Future<int> getValueBetaSpeechFurture() async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'valueBetaSpeech';
  final int value = prefs.getInt(key) ?? 0;
  return value;
}
