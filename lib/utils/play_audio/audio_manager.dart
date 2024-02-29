import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripitaka91/utils/api_connect/remote_service.dart';
import 'package:tripitaka91/utils/constants/api_constants.dart';
import 'package:tripitaka91/utils/models/sounds_getlink.dart';

class AudioPlayerManager {
  late AudioPlayer _audioPlayer;
  final RemoteServiceSoundsGetLink remoteService = RemoteServiceSoundsGetLink();
  bool chkPlay = false;
  bool chkPause = false;

  AudioPlayerManager() {
    _audioPlayer = AudioPlayer();
  }

  Future<void> playAudio(String title, String filename, String txtTitle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    txtTitle = txtTitle.replaceAll('', 'ฐ');
    txtTitle = txtTitle.replaceAll('', 'ญ');
    txtTitle = txtTitle.replaceAll(':-', ' ');
    String chkTxtTitle = prefs.getString('txtTitle') ?? '';

    if (_audioPlayer.playerState.playing) {
      pause();
    } else {
      // print('txtTitle$txtTitle');
      // print('chkTxtTitle$chkTxtTitle');

      if (txtTitle == chkTxtTitle) {
        if (chkPlay) {
          play();
        } else {
          prefs.setString('txtTitle', txtTitle);
          await _playAudioInternal(title, filename, txtTitle);
        }
      } else {
        prefs.setString('txtTitle', txtTitle);
        await _playAudioInternal(title, filename, txtTitle);
      }
    }
  }

  Future<void> _playAudioInternal(
      String title, String filename, String speechText) async {
    List<SoundsGetLink>? soundLink = await remoteService.getLink(
      title,
      filename,
      speechText,
      tSecretAPIKey, // แทนที่ด้วย token จริง
    );

    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String chkfilename = prefs.getString('chkfilename') ?? '';

    if (soundLink != null && soundLink.isNotEmpty) {
      String url = tURL + soundLink[0].message;
      await _audioPlayer.setUrl(url);
      // เพิ่ม listener ที่ตรวจสอบเมื่อการเล่นเสียงเสร็จสิ้น
      _audioPlayer.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          // ทำงานที่คุณต้องการหลังจากการเล่นเสร็จสิ้น
          //print('_playAudioInternal');
          chkPlay = false;
          stop();
          // นำโค้ดที่คุณต้องการใส่ที่นี่
        }
      });
      chkPlay = true;
      _audioPlayer.play();
    }
  }

  // Future<void> playAudioReal(
  //     String title, String filename, String txtTitle) async {
  //   txtTitle = txtTitle.replaceAll('', 'ฐ');
  //   txtTitle = txtTitle.replaceAll('', 'ญ');
  //   txtTitle = txtTitle.replaceAll(':-', ' ');

  //   await _playAudioInternalReal(title, filename, txtTitle);
  // }

  // Future<void> _playAudioInternalReal(
  //     String title, String filename, String speechText) async {
  //   List<SoundsGetLink>? soundLink = await remoteService.getLink(
  //     title,
  //     filename,
  //     speechText,
  //     tSecretAPIKey, // แทนที่ด้วย token จริง
  //   );

  //   if (soundLink != null && soundLink.isNotEmpty) {
  //     String url = tURL + soundLink[0].message;
  //     await _audioPlayer.setUrl(url);
  //     _audioPlayer.play();
  //   }
  // }

  double position() {
    double sliderValue = 0;
    _audioPlayer.positionStream.listen((position) {
      sliderValue = position.inMilliseconds.toDouble();
    });
    return sliderValue;
  }

  double maxvalue() {
    double maxsound = 0;
    maxsound = _audioPlayer.duration?.inMilliseconds.toDouble() ?? 0.0;
    return maxsound;
  }

  void seek(int value) {
    _audioPlayer.seek(Duration(seconds: value.toInt()));
    // _audioPlayer.seek(Duration(milliseconds: value.toInt()));
  }

  void play() {
    chkPause = false;
    _audioPlayer.play();
  }

  bool chkStatePlay() {
    if (_audioPlayer.playing) {
      return true;
    } else {
      return false;
    }
  }

  void pause() {
    chkPause = true;
    _audioPlayer.pause();
  }

  void stop() {
    _audioPlayer.stop();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}

class AudioPlayListManager {
  final RemoteServiceSoundsGetLink remoteService = RemoteServiceSoundsGetLink();
  late String url;

  AudioPlayListManager();

  Future<void> processSounds(
      String bookId, String pageId, int line, String speechText) async {
    String filename = '$bookId-$pageId-$line';
    await _processAudioData('0', filename, speechText);
  }

  Future<void> _processAudioData(
      String title, String filename, String speechText) async {
    List<SoundsGetLink>? soundLink = await remoteService.getLink(
      title,
      filename,
      speechText,
      tSecretAPIKey,
    );

    if (soundLink != null && soundLink.isNotEmpty) {
      url = tURL + soundLink[0].message;
    }
  }

  String getUrl() {
    return url;
  }
}
