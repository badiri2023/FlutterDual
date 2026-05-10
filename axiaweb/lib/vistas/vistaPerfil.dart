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
                          fontWeight: FontWeight.w900, // Corregido: sin el .black54 que daba error
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

              // --- TÍTULO HISTORIAL ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Text(
                    "HISTORIAL DE PARTIDAS", 
                    style: TextStyle(
                      color: esOscuro ? Colors.amber : Colors.brown, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 16
                    )
                  ),
                ),
              ),

              // --- LISTA DE PARTIDAS ---
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final partida = datos['matchHistory'][index];
                    bool gano = partida['result'] == "Victoria" || partida['result'] == "win";
                    
                    return Card(
                      color: esOscuro ? Colors.white.withOpacity(0.05) : Colors.white,
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: gano ? Colors.orange.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                          child: Icon(
                            gano ? Icons.emoji_events : Icons.close,
                            color: gano ? Colors.orange : Colors.grey,
                          ),
                        ),
                        title: Text(
                          "Vs ${partida['opponent']}", 
                          style: TextStyle(fontWeight: FontWeight.bold, color: esOscuro ? Colors.white : Colors.black87)
                        ),
                        subtitle: Text(partida['date']),
                        trailing: Text(
                          partida['result'].toUpperCase(),
                          style: TextStyle(color: gano ? Colors.orange : Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                  childCount: (datos['matchHistory'] as List).length,
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
