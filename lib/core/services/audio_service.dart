import 'package:audioplayers/audioplayers.dart';

class AudioService {
  // Singleton Pattern
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  // ✅ التعديل هنا: الدالة الآن تقبل كائن "Source" مباشرة
  Future<void> play(Source source) async {
    await _audioPlayer.play(source);
  }

  // دالة للإيقاف المؤقت
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  // دالة لإيقاف التشغيل بالكامل
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  // خاصية لمعرفة حالة المشغل (يعمل، متوقف، إلخ)
  Stream<PlayerState> get onPlayerStateChanged =>
      _audioPlayer.onPlayerStateChanged;

  void dispose() {
    _audioPlayer.dispose();
  }
}
