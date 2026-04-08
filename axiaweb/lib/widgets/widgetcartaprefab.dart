import 'package:flutter/material.dart';
import '../models/carta.dart'; 

class WidgetCartaPrefab extends StatelessWidget {
  final CartaWiki carta;

  const WidgetCartaPrefab({super.key, required this.carta});

  @override
  Widget build(BuildContext context) {
    // Proporción estándar de carta coleccionable
    return AspectRatio(
      aspectRatio: 2.5 / 3.5, 
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.orange.shade700, 
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Column(
          children: [
            // --- ZONA 1: IMAGEN, NOMBRE Y RAREZA ---
            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  border: Border.all(color: Colors.yellowAccent.shade700, width: 4),
                ),
                child: Column(
                  children: [
                    // Fila superior: Nombre y Rareza (Envuelta en FittedBox por si son muy largos)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _etiquetaSuperior(carta.nombre),
                            const SizedBox(width: 20), // Un poco de espacio entre las etiquetas
                            _etiquetaSuperior(carta.rareza),
                          ],
                        ),
                      ),
                    ),
                    // Imagen (Icono placeholder por ahora)
                    const Expanded(
                      child: Center(
                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // --- ZONA 2: HABILIDAD ---
            _cajaTexto(carta.habilidad, flex: 2),
            const SizedBox(height: 6),

            // --- ZONA 3: STATS (Ataque, Maná, Vida) ---
            // ¡NUEVO! Envolvemos la fila en FittedBox para evitar el Overflow
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _cajaStat('atk', carta.ataque.toString(), Colors.red.shade900),
                  const SizedBox(width: 4),
                  _cajaStat('Mana', carta.mana.toString(), Colors.black),
                  const SizedBox(width: 4),
                  _cajaStat('vida', carta.vida.toString(), Colors.black),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // --- ZONA 4: DESCRIPCIÓN PERSONAL ---
            _cajaTexto(carta.descripcion, flex: 2, fontSize: 10, fontStyle: FontStyle.italic),
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS DE APOYO PARA DIBUJAR LOS ELEMENTOS ---

  Widget _etiquetaSuperior(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.yellowAccent.shade700, width: 2),
        color: Colors.white,
      ),
      child: Text(
        texto, 
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black)
      ),
    );
  }

  Widget _cajaTexto(String texto, {required int flex, double fontSize = 12, FontStyle fontStyle = FontStyle.normal}) {
    return Expanded(
      flex: flex,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black, width: 3),
        ),
        child: Center(
          child: Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: fontSize, fontStyle: fontStyle, color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _cajaStat(String etiqueta, String valor, Color colorBorde) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: colorBorde, width: 3),
      ),
      child: Row(
        children: [
          if (etiqueta.isNotEmpty) ...[
            Text('$etiqueta: ', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
          Text(valor, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
    );
  }
}