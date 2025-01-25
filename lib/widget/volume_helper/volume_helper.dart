import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_value.dart';

class VolumeHelper {
  Users? users;
  bool showVolume = false;

  VolumeHelper() {
    _initialize();
  }

  Future<void> _initialize() async {
    int valueBetaSpeech = await getValueBetaFurture();
    valueBetaSpeech == 0
        ? showVolume = false
        : showVolume = true; // หรือค่าอื่นที่เหมาะสม
  }
}
