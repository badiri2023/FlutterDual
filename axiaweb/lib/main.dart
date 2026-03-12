import 'package:flutter/material.dart';
import 'vistas/vistaPrincipal.dart'; // Le dices que entre a la carpeta primero

final ValueNotifier<ThemeMode> temaNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(const MiAppDual());
}

class MiAppDual extends StatelessWidget {
  const MiAppDual({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaNotifier,
      builder: (_, ThemeMode modoActual, __) {
        return MaterialApp(
          title: 'AxiaWeb Dual',
          debugShowCheckedModeBanner: false,
          themeMode: modoActual, 
          
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 157, 101, 10), brightness: Brightness.light),
            useMaterial3: true,
          ),
          
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 77, 52, 1), brightness: Brightness.dark),
            useMaterial3: true,
          ),
          
          // La app arranca directamente en tu esqueleto principal
          home: const VistaPrincipal(),
        );
      },
    );
  }
}