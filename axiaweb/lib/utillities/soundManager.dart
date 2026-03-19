import 'package:audioplayers/audioplayers.dart';
import '../main.dart';

class SoundManager {
  static final AudioPlayer _playerMusica = AudioPlayer();

  static void gestionarMusica() async {
    if (musicaNotifier.value) {
      await _playerMusica.setReleaseMode(ReleaseMode.loop);
      await _playerMusica.play(AssetSource('sonidos/musica_fondo.mp3'));
    } else {
      await _playerMusica.stop();
    }
  }
}