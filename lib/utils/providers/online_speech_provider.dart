import 'package:flutter/material.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_value.dart';

/// Single source of truth for the ONLINE read-aloud disclaimer
/// acknowledgment (valueBeta) and the device-level voice choice
/// (valueBetaSpeech). Widgets that watch this provider (e.g. the AppBar's
/// ONLINE pill) update immediately when consent is granted from anywhere
/// in the app — a speaker icon on any screen, not just the AppBar itself.
class OnlineSpeechProvider extends ChangeNotifier {
  int _acknowledged = 0; // 0 = ยังไม่เคยยอมรับ, 1 = ยอมรับแล้ว
  int _voiceChoice = 0; // 0 = ชาย, 1 = หญิง

  bool get isAcknowledged => _acknowledged == 1;
  int get voiceChoice => _voiceChoice;

  OnlineSpeechProvider() {
    _load();
  }

  Future<void> _load() async {
    _acknowledged = await getValueBetaFurture();
    _voiceChoice = await getValueBetaSpeechFurture();
    notifyListeners();
  }

  Future<void> acknowledge(int voiceChoice) async {
    _acknowledged = 1;
    _voiceChoice = voiceChoice;
    await saveValueBeta(1);
    await saveValueBetaSpeech(voiceChoice);
    notifyListeners();
  }

  Future<void> setVoiceChoice(int voiceChoice) async {
    _voiceChoice = voiceChoice;
    await saveValueBetaSpeech(voiceChoice);
    notifyListeners();
  }
}
