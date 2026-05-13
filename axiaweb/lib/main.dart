import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // Importante para el sonido
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
  
  // 1. Añadimos 'await' para forzar a que espere a aplicar el volumen
  // 0.1 equivale a un 10% del volumen total. Ajusta este número si es necesario.
  await _audioPlayer.setVolume(0.1);

  if (musicaNotifier.value) {
    await _audioPlayer.resume();
  }

  // 2. Convertimos el listener en asíncrono para asegurar el volumen al reanudar
  musicaNotifier.addListener(() async {
    if (musicaNotifier.value) {
      // Por seguridad, re-aplicamos el volumen bajo justo antes de darle al play
      await _audioPlayer.setVolume(0.1);
      await _audioPlayer.resume(); 
    } else {
      await _audioPlayer.pause();
    }
  });
}


void reproducirClick() async {
  // Solo suena si el switch de "Efectos de sonido" está activo
  if (sonidoNotifier.value) {
    // Usamos Source para sonidos rápidos
    await _efectosPlayer.play(AssetSource('sonidos/click.mp3'));
  }
}
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configurarMusica(); // Arrancamos el motor de audio
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