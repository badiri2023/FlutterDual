import 'package:flutter/material.dart';
import '../models/carta.dart';

class WidgetCartaPrefab extends StatelessWidget {
  final CartaWiki carta;

  const WidgetCartaPrefab({super.key, required this.carta});

  // --- VENTANA DE DETALLE (AL PULSAR) ---
  void _mostrarDetalles(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.orange.shade700,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black, width: 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // NOMBRE (Izquierda) y RAREZA (Derecha) - PEGADOS A LAS ESQUINAS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _etiquetaSuperior(carta.nombre, fontSize: 16, esIzquierda: true),
                    _etiquetaSuperior(carta.rareza, fontSize: 16, esIzquierda: false),
                  ],
                ),
                const SizedBox(height: 15),
                
                // Imagen grande con red de AWS
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.yellowAccent.shade700, width: 4),
                  ),
                  child: carta.imagenUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6), // Recorta la imagen para no tapar el borde
                          child: Image.network(
                            carta.imagenUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100, color: Colors.red),
                          ),
                        )
                      : const Icon(Icons.image, size: 100, color: Colors.grey),
                ),
                const SizedBox(height: 15),

                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _cajaStat('ATK', carta.ataque.toString(), Colors.red.shade900),
                    const SizedBox(width: 10),
                    _cajaStat('MANA', carta.mana.toString(), Colors.black),
                    const SizedBox(width: 10),
                    _cajaStat('VIDA', carta.vida.toString(), Colors.black),
                  ],
                ),
                const SizedBox(height: 15),

                // Habilidad Completa
                _cajaTextoDetalle("HABILIDAD", carta.habilidad),
                const SizedBox(height: 10),

                // Descripción Completa
                _cajaTextoDetalle("HISTORIA", carta.descripcion, italic: true),
                
                const SizedBox(height: 15),
                
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cerrar", style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _mostrarDetalles(context),
      child: AspectRatio(
        aspectRatio: 2.5 / 3.7,
        child: Container(
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            color: Colors.orange.shade700,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Column(
            children: [
              // --- ZONA SUPERIOR: NOMBRE Y RAREZA EN LAS ESQUINAS ---
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.yellowAccent.shade700, width: 3),
                  ),
                  child: Column(
                    children: [
                      // AQUÍ ESTÁ EL CAMBIO: Row con spaceBetween y sin padding horizontal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _etiquetaSuperior(carta.nombre, esIzquierda: true),
                          _etiquetaSuperior(carta.rareza, esIzquierda: false),
                        ],
                      ),
                      // Imagen de la carta en la miniatura de la Wiki
                      Expanded(
                        child: Center(
                          child: carta.imagenUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Image.network(
                                    carta.imagenUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 45, color: Colors.red),
                                  ),
                                )
                              : const Icon(Icons.image, size: 45, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),

              _cajaTexto(carta.habilidad, flex: 2),
              const SizedBox(height: 4),

              // Stats compactos
              FittedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _cajaStat('atk', carta.ataque.toString(), Colors.red.shade900),
                    const SizedBox(width: 2),
                    _cajaStat('mana', carta.mana.toString(), Colors.black),
                    const SizedBox(width: 2),
                    _cajaStat('vida', carta.vida.toString(), Colors.black),
                  ],
                ),
              ),
              const SizedBox(height: 4),

              _cajaTexto(carta.descripcion, flex: 2, fontSize: 9, fontStyle: FontStyle.italic),
            ],
          ),
        ),
      ),
    );
  }

  // --- DISEÑO DE LAS ETIQUETAS PEGADAS A LAS ESQUINAS ---
  Widget _etiquetaSuperior(String texto, {double fontSize = 10, required bool esIzquierda}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.yellowAccent.shade700, width: 2),
        // Redondeamos solo la esquina interna para que parezca pegada al borde
        borderRadius: BorderRadius.only(
          bottomRight: esIzquierda ? const Radius.circular(8) : Radius.zero,
          bottomLeft: !esIzquierda ? const Radius.circular(8) : Radius.zero,
        ),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontWeight: FontWeight.bold, 
          fontSize: fontSize, 
          color: Colors.black
        ),
      ),
    );
  }

  // Cajas de texto para la miniatura
  Widget _cajaTexto(String texto, {required int flex, double fontSize = 11, FontStyle fontStyle = FontStyle.normal}) {
    return Expanded(
      flex: flex,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Center(
          child: Text(
            texto,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: fontSize, fontStyle: fontStyle, color: Colors.black),
          ),
        ),
      ),
    );
  }

  // Caja de texto para el detalle (SIN LÍMITE DE ALTURA)
  Widget _cajaTextoDetalle(String titulo, String contenido, {bool italic = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
          const Divider(height: 8, color: Colors.black26),
          Text(
            contenido,
            style: TextStyle(
              fontSize: 14, 
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
              color: Colors.black
            ),
          ),
        ],
      ),
    );
  }

  Widget _cajaStat(String etiqueta, String valor, Color colorBorde) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: colorBorde, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$etiqueta: ', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black)),
          Text(valor, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
    );
  }
}