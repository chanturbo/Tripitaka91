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
