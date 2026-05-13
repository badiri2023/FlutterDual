import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'vistas/vistaPrincipal.dart'; 

// Notificadores globales que usa tu vistaAjustes.dart
final ValueNotifier<ThemeMode> temaNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<String> disenoNotifier = ValueNotifier('Moderno'); 
final ValueNotifier<bool> musicaNotifier = ValueNotifier(false);
final ValueNotifier<bool> sonidoNotifier = ValueNotifier(true);

// Instancia global del reproductor
final AudioPlayer _audioPlayer = AudioPlayer();

// Segundo reproductor para efectos (clicks, alertas, etc.)
final AudioPlayer _efectosPlayer = AudioPlayer();

void configurarMusica() async {
  await _audioPlayer.setSource(AssetSource('sonidos/backgroundMusic.mp3'));
  await _audioPlayer.setReleaseMode(ReleaseMode.loop); 
  

  await _audioPlayer.setVolume(0.1);

  if (musicaNotifier.value) {
    await _audioPlayer.resume();
  }

  musicaNotifier.addListener(() async {
    if (musicaNotifier.value) {
      await _audioPlayer.setVolume(0.1);
      await _audioPlayer.resume(); 
    } else {
      await _audioPlayer.pause();
    }
  });
}

void reproducirClick() async {
  if (sonidoNotifier.value) {
    await _efectosPlayer.play(AssetSource('sonidos/click.mp3'));
  }
}
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configurarMusica(); 
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el cambio de Tema (Claro/Oscuro)
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaNotifier,
      builder: (_, modoActual, __) {
        // Escuchamos el cambio de Estilo (Clásico/Moderno)
        return ValueListenableBuilder<String>(
          valueListenable: disenoNotifier,
          builder: (_, estiloActual, __) {
            
            // Definimos el borde según el estilo seleccionado
            final OutlinedBorder bordeGlobal = estiloActual == 'Clásico' 
                ? const RoundedRectangleBorder(borderRadius: BorderRadius.zero)
                : RoundedRectangleBorder(borderRadius: BorderRadius.circular(20));

            return MaterialApp(
              title: 'Juego de Cartas Axia',
              debugShowCheckedModeBanner: false,
              themeMode: modoActual,
              
              // TEMA CLARO
              theme: ThemeData(
                useMaterial3: true,
                colorSchemeSeed: Colors.orange,
                brightness: Brightness.light,
                // Aplicamos el estilo a todas las cartas de la app
                cardTheme: CardThemeData(shape: bordeGlobal), 
                // Aplicamos el estilo a todos los botones elevados
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(shape: bordeGlobal),
                ),
              ),

              // TEMA OSCURO
              darkTheme: ThemeData(
                useMaterial3: true,
                colorSchemeSeed: Colors.orange,
                brightness: Brightness.dark,
                cardTheme: CardThemeData(shape: bordeGlobal),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(shape: bordeGlobal),
                ),
              ),
              
              home: const VistaPrincipal(),
            );
          },
        );
      },
    );
  }
}