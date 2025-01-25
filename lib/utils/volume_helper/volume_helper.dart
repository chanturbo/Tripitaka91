import 'package:tripitaka91/utils/models/users.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_user.dart';
import 'package:tripitaka91/utils/shared_preferences/shared_value.dart';

class VolumeHelper {
  Users? users;
  bool showVolume = false;

  VolumeHelper() {
    _initialize();
  }

  Future<void> _initialize() async {
    users = await getUsersList();
    if (users != null) {
      showVolume = true; // ตั้งค่าตามเงื่อนไขที่คุณต้องการ
    } else {
      int valueBetaSpeech = await getValueBetaFurture();
      valueBetaSpeech == 0
          ? showVolume = false
          : showVolume = true; // หรือค่าอื่นที่เหมาะสม
    }
  }
}
