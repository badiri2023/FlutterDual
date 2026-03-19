import 'package:flutter/material.dart';
import '../main.dart';

class VistaAjustes extends StatelessWidget {
  const VistaAjustes({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // --- SECCIÓN 1: DISEÑO ---
        _seccionTitulo("Apariencia"),
        ValueListenableBuilder<String>(
          valueListenable: disenoNotifier,
          builder: (context, estilo, _) {
            return DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Estilo de Interfaz"),
              value: estilo,
              items: const [
                DropdownMenuItem(value: 'Clásico', child: Text("Clásico (Bordes rectos)")),
                DropdownMenuItem(value: 'Moderno', child: Text("Moderno (Redondeado)")),
              ],
              onChanged: (val) => disenoNotifier.value = val!,
            );
          },
        ),

        const SizedBox(height: 30),

        // --- SECCIÓN 2: AUDIO ---
        _seccionTitulo("Sonido"),
        ValueListenableBuilder<bool>(
          valueListenable: musicaNotifier,
          builder: (context, musicaActiva, _) {
            return SwitchListTile(
              title: const Text("Música de fondo"),
              secondary: const Icon(Icons.music_note),
              value: musicaActiva,
              onChanged: (val) => musicaNotifier.value = val,
            );
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: sonidoNotifier,
          builder: (context, sonidoActivo, _) {
            return SwitchListTile(
              title: const Text("Efectos de sonido"),
              subtitle: const Text("Sonido al pulsar botones"),
              secondary: const Icon(Icons.volume_up),
              value: sonidoActivo,
              onChanged: (val) => sonidoNotifier.value = val,
            );
          },
        ),
      ],
    );
  }

  Widget _seccionTitulo(String titulo) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}