import 'package:flutter/material.dart';
import '../models/carta.dart';

class WidgetCartaPrefab extends StatelessWidget {
  final CartaWiki carta;

  const WidgetCartaPrefab({super.key, required this.carta});

  // --- VENTANA DE DETALLE ---
void _mostrarDetalles(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth * 0.9;
          final isNarrow = maxWidth < 600;

          return Center(
            child: Container(
              width: isNarrow ? maxWidth : 700,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.orange.shade700,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black, width: 3),
              ),
              child: SingleChildScrollView(
                child: isNarrow
                    ? Column(
                        children: [
                          _detalleImagen(context),
                          const SizedBox(height: 12),
                          _detalleContenido(context),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(flex: 4, child: _detalleImagen(context)),
                          const SizedBox(width: 12),
                          Flexible(flex: 6, child: _detalleContenido(context)),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
// imagen a la izquierda con BoxFit.contain
Widget _detalleImagen(BuildContext context) {
  return Container(
    height: 260,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.yellowAccent.shade700, width: 4),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: carta.imagenUrl.isNotEmpty
          ? Image.network(
              carta.imagenUrl,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Icon(Icons.broken_image, size: 80, color: Colors.red));
              },
            )
          : const Center(child: Icon(Icons.image, size: 80, color: Colors.grey)),
    ),
  );
}

// contenido derecho con nombre, stats, habilidad, descripción y botón
Widget _detalleContenido(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(
            child: _etiquetaSuperior(carta.nombre, fontSize: 14, esIzquierda: true)),
          const SizedBox(width: 8),
          ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 60, maxWidth: 110),
          child: _etiquetaSuperior(carta.rareza, fontSize: 12, esIzquierda: false),
        ),
      ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          _cajaStat('ATK', carta.ataque.toString(), Colors.red.shade900),
          const SizedBox(width: 8),
          _cajaStat('MANA', carta.mana.toString(), Colors.black),
          const SizedBox(width: 8),
          _cajaStat('VIDA', carta.vida.toString(), Colors.black),
        ],
      ),
      const SizedBox(height: 12),
      _cajaTextoDetalle("HABILIDAD", carta.habilidad),
      const SizedBox(height: 10),
      _cajaTextoDetalle("HISTORIA", carta.descripcion, italic: true),
      const SizedBox(height: 12),
      Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
          onPressed: () => Navigator.pop(context),
          child: const Text("Cerrar", style: TextStyle(color: Colors.white)),
        ),
      ),
    ],
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
      borderRadius: BorderRadius.only(
        bottomRight: esIzquierda ? const Radius.circular(8) : Radius.zero,
        bottomLeft: !esIzquierda ? const Radius.circular(8) : Radius.zero,
      ),
    ),
    child: Tooltip(
      message: texto,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 60, maxHeight: 110),
        child: Text(
          texto,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            color: Colors.black,
          ),
        ),
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
          child: Tooltip(
            message: texto,
            child: Text(
              texto,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: fontSize, fontStyle: fontStyle, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  // Caja de texto para el detalle
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