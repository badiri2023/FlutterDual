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

void configurarMusica() {
  _audioPlayer.setReleaseMode(ReleaseMode.loop); // Bucle infinito

  // Escuchamos cuando cambies el switch en Ajustes
  musicaNotifier.addListener(() async {
    if (musicaNotifier.value) {
      await _audioPlayer.play(AssetSource('audio/musica_fondo.mp3'));
    } else {
      await _audioPlayer.pause();
    }
  });
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