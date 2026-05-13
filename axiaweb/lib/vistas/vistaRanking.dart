import 'package:flutter/material.dart';
import '../servicios/api_servicio.dart';

class VistaRanking extends StatefulWidget {
  const VistaRanking({super.key});

  @override
  State<VistaRanking> createState() => _VistaRankingState();
}

class _VistaRankingState extends State<VistaRanking> {
  bool _cargando = true;
  List<dynamic> _listaRanking = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _cargarRanking();
  }

  // Función para obtener los datos del servidor
  Future<void> _cargarRanking() async {
    setState(() => _cargando = true);

    final res = await ApiServicio.obtenerRanking();

    if (res['exito']) {
      // Filtramos aquí los usuarios que no queremos mostrar
      final List<dynamic> raw = res['ranking'] as List<dynamic>;
      final List<String> ocultar = ['bot', 'admin']; // nombres a ocultar (minúsculas)

      final List<dynamic> filtrado = raw.where((item) {
        final nombre = (item['username'] ?? item['Username'] ?? '').toString().toLowerCase();
        return !ocultar.contains(nombre);
      }).toList();

      setState(() {
        _listaRanking = filtrado;
        _cargando = false;
      });
    } else {
      setState(() {
        _error = res['mensaje'];
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RANKING MUNDIAL"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarRanking,
          )
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 60),
                      const SizedBox(height: 10),
                      Text("Error: $_error"),
                      ElevatedButton(
                        onPressed: _cargarRanking,
                        child: const Text("Reintentar"),
                      )
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarRanking,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _listaRanking.length,
                    itemBuilder: (context, index) {
                      final jugador = _listaRanking[index];
                      
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: _getIconoPosicion(index + 1),
                          title: Text(
                            jugador['username'].toString().toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text("Nivel: ${jugador['level']}"),
                              Text("Partidas Totales: ${jugador['playedMatches']}"),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${jugador['wonMatches']}",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              const Text(
                                "VICTORIAS",
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  // Widget para mostrar medallas en el Top 3 y números en el resto
  Widget _getIconoPosicion(int posicion) {
    if (posicion == 1) return const Icon(Icons.emoji_events, color: Colors.amber, size: 35);
    if (posicion == 2) return const Icon(Icons.emoji_events, color: Colors.grey, size: 30);
    if (posicion == 3) return const Icon(Icons.emoji_events, color: Colors.brown, size: 28);
    
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.orange.shade200)
      ),
      alignment: Alignment.center,
      child: Text(
        posicion.toString(),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}