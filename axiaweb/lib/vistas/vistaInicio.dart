import 'package:flutter/material.dart';

class VistaInicio extends StatelessWidget {
  const VistaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    final bool esOscuro = Theme.of(context).brightness == Brightness.dark;
    final Color colorAcero = esOscuro ? const Color.fromARGB(26, 0, 0, 0) : const Color.fromARGB(255, 255, 255, 255);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 60.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- TITULO ESTILIZADO ---
            const Text(
              'WELCOME',
              style: TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.w900,
                letterSpacing: 8, // Espaciado elegante
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 40),

            // --- BOTONES CUADRADOS DE DESCARGA ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBotonCuadrado(context, "GAME", Icons.computer),
                const SizedBox(width: 20),
                _buildBotonCuadrado(context, "APP", Icons.phone_android),
              ],
            ),

            const SizedBox(height: 40),

            // --- FRANJA DIVISORIA ---
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.orange.withOpacity(0.3),
            ),
            const SizedBox(height: 40),

            // --- TEXTO DE BIENVENIDA ---
            const Text(
              "¡Bienvenid@ a Aixec!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            const SizedBox(height: 15),
            const Text(
              "Prepárate para enfrentarte en duelos intelectuales y mágicos en un campo donde el azar y la fortuna es tan importante como la astucia.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, height: 1.5),
            ),

            const SizedBox(height: 40),

            // --- SECCIÓN INTRODUCCIÓN ---
            _buildSeccionInformativa(
              "Introducción",
              "El juego de Aixec consta de un duelo de cartas multijugador en el que dos jugadores tienen que desplegar cartas con diversos efectos y comportamientos para reducir la salud de su adversario a cero.\n\n"
              "El tablero consta de los mazos, las manos, los cementerios y campos de batalla de ambos jugadores. Un mazo consta de 20 cartas y al empezar la partida tendrás cinco cartas en la mano.\n\n"
              "Las cartas se dividen en tres tipos: Monstruos, Equipamientos y Hechizos. Los Monstruos se despliegan en el campo de batalla y son la fuente principal de daño y defensa. Los Equipamientos son cartas que solo se puede desplegar una por jugador en cada partida; los monstruos reciben mejoras de daño y defensa y algunas tienen efectos especiales que pueden cambiar el rumbo de la partida. Y por último, los Hechizos son cartas con habilidades que se consumen y van al cementerio en cuanto se resuelva su habilidad y, por tanto, saber cuándo gastar esa bala es esencial para ser el ganador.\n\n"
              "Cada jugador tiene su propio recurso de maná, que se rellena al final de cada turno y aumenta su capacidad máxima en uno hasta un límite de ocho. Y solo se puede desplegar un máximo de tres monstruos a la vez en el campo de batalla por cada jugador.",
              colorAcero
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonCuadrado(BuildContext context, String etiqueta, IconData icono) {
    return SizedBox(
      width: 120,
      height: 120,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.orange,
          elevation: 0,
          side: const BorderSide(color: Colors.orange, width: 2),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), // CUADRADO TOTAL
        ),
        onPressed: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 30),
            const SizedBox(height: 10),
            Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionInformativa(String titulo, String contenido, Color fondo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.orange, letterSpacing: 2),
          ),
          const SizedBox(height: 15),
          Text(
            contenido,
            textAlign: TextAlign.justify,
            style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}