import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VistaInicio extends StatelessWidget {
  const VistaInicio({super.key});

  Future<void> _lanzarURL() async {
    final Uri url1 = Uri.parse('https://aixec-game.s3.eu-north-1.amazonaws.com/AixecTheGame/Aixec.exe');
    await launchUrl(url1, mode: LaunchMode.externalApplication);
  }
  Future<void> _lanzarURL2() async {
    final Uri url2 = Uri.parse('https://aixec-game.s3.eu-north-1.amazonaws.com/AixecTheGame/Aixec.pck');
    await launchUrl(url2, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final bool esOscuro = Theme.of(context).brightness == Brightness.dark;

    final Color franjaColor = Colors.black;
    final Color cardColor = esOscuro
        ? const Color.fromARGB(40, 255, 255, 255)
        : const Color.fromARGB(255, 240, 240, 240);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            const Text(
              "WELCOME TO THE GAME",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "\"A strategic card‑dueling experience\"",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: Colors.black,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: _lanzarURL,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              label: const Text("DOWNLOAD .EXE"),
             ),     
                            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: _lanzarURL2,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              label: const Text("DOWNLOAD .pck"),
             ), 
            const SizedBox(height: 40),

            Container(
              height: 3,
              width: double.infinity,
              color: franjaColor,
            ),

            const SizedBox(height: 40),

            _buildOpcion(
              titulo: "Build Your Deck",
              descripcion: "Modifica tu Deck para enfrentarte a los combates mas feroces.",
              color: cardColor,
            ),

            const SizedBox(height: 15),

            _buildOpcion(
              titulo: "Connect to Other Players",
              descripcion: "Forma parte el mundo de AXIA y comparte estrategias con los demas jugadores para subir en el ranking y construir nuevos Deks",
              color: cardColor,
            ),

            const SizedBox(height: 15),

            _buildOpcion(
              titulo: "Ranking",
              descripcion: "Gana de forma constante para demostrar al Mundo lo buen que eres. Destacar sobre los demas!!",
              color: cardColor,
            ),
            const SizedBox(height: 15),

            _buildOpcion(
              titulo: "Shop",
              descripcion: "Construye tu deCk comprando nuevos sobres para obtener las mejores cartas disponibles!",
              color: cardColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpcion({
    required String titulo,
    required String descripcion,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            descripcion,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
