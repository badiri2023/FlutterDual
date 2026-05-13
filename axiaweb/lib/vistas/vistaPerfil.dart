import 'package:flutter/material.dart';
import '../servicios/api_servicio.dart';

class VistaPerfil extends StatelessWidget {
  const VistaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    final bool esOscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiServicio.obtenerPerfilCompleto(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          }
          
          final datos = snapshot.data?['datos'];
          if (datos == null) return const Center(child: Text("Error al cargar perfil"));

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.amber,
                        child: Icon(Icons.person, size: 60, color: esOscuro ? Colors.black : Colors.white),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        datos['username'].toString().toUpperCase(),
                        style: TextStyle(
                          fontSize: 28, 
                          fontWeight: FontWeight.w900,
                          color: esOscuro ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        "Nivel ${datos['level']}",
                        style: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 30),
                      
                      // --- ESTADÍSTICAS ---
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: esOscuro ? Colors.white.withOpacity(0.05) : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.amber.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatColumn("CARTAS", datos['totalCards'].toString(), esOscuro),
                            _buildStatColumn("PARTIDAS", datos['played'].toString(), esOscuro),
                            _buildStatColumn("VICTORIAS", datos['wins'].toString(), esOscuro, colorExtra: Colors.orange),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 50)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, bool esOscuro, {Color? colorExtra}) {
    return Column(
      children: [
        Text(
          value, 
          style: TextStyle(
            color: colorExtra ?? (esOscuro ? Colors.white : Colors.black87), 
            fontSize: 24, 
            fontWeight: FontWeight.bold
          )
        ),
        const SizedBox(height: 5),
        Text(
          label, 
          style: TextStyle(
            color: esOscuro ? Colors.white70 : Colors.black54, 
            fontSize: 12, 
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold
          )
        ),
      ],
    );
  }
}
