import 'package:flutter/material.dart';
import '../models/carta.dart'; 
import '../servicios/api_servicio.dart';
import '../widgets/widgetcartaprefab.dart';

class VistaMazos extends StatefulWidget {
  const VistaMazos({super.key});

  @override
  State<VistaMazos> createState() => _VistaMazosState();
}

class _VistaMazosState extends State<VistaMazos> {
  bool _cargando = true;
  bool _guardando = false;

  // El mazo que estamos editando actualmente
  List<CartaWiki> _mazoTemporal = [];
  
  // Lo que el usuario posee
  Map<String, int> _inventarioCantidades = {};
  Map<String, CartaWiki> _bdCartas = {}; 

  @override
  void initState() {
    super.initState();
    _cargarDatos(); 
  }

  Future<void> _cargarDatos() async {
    final respuesta = await ApiServicio.obtenerInventario();

    if (respuesta['exito']) {
      List<CartaWiki> cartasInventario = respuesta['inventario'];
      Map<String, int> cantidades = respuesta['cantidades'];

      setState(() {
        for (var c in cartasInventario) {
          _bdCartas[c.id] = c;
        }
        _inventarioCantidades = cantidades;
        _cargando = false;
      });
    } else {
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${respuesta['mensaje']}"))
      );
    }
  }

  void _anadirAlMazo(String id) {
    int cantidadEnMazo = _mazoTemporal.where((c) => c.id == id).length;
    int totalPoseidas = _inventarioCantidades[id] ?? 0;

    if (cantidadEnMazo < totalPoseidas) {
      setState(() {
        _mazoTemporal.add(_bdCartas[id]!);
      });
    }
  }

  void _quitarDelMazo(int index) {
    setState(() {
      _mazoTemporal.removeAt(index);
    });
  }

  Future<void> _guardarCambios() async {
    setState(() => _guardando = true);
    
    List<String> idsParaEnviar = _mazoTemporal.map((c) => c.id).toList();
    final res = await ApiServicio.guardarMazo(idsParaEnviar);

    setState(() => _guardando = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res['mensaje']), backgroundColor: res['exito'] ? Colors.green : Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Mazos"),
        actions: [
          _guardando 
            ? const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(color: Colors.white)))
            : IconButton(
                icon: const Icon(Icons.save), 
                onPressed: _guardarCambios,
                tooltip: "Guardar mazo en el servidor",
              )
        ],
      ),
      body: Row(
        children: [
          // --- COLUMNA IZQUIERDA: INVENTARIO ---
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.black12,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("MI COLECCIÓN", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _bdCartas.length,
                      itemBuilder: (context, i) {
                        String id = _bdCartas.keys.elementAt(i);
                        CartaWiki carta = _bdCartas[id]!;
                        int enMazo = _mazoTemporal.where((c) => c.id == id).length;
                        int disponibles = (_inventarioCantidades[id] ?? 0) - enMazo;

                        return GestureDetector(
                          onTap: disponibles > 0 ? () => _anadirAlMazo(id) : null,
                          child: Stack(
                            children: [
                              Opacity(
                                opacity: disponibles > 0 ? 1.0 : 0.4,
                                child: WidgetCartaPrefab(carta: carta),
                              ),
                              Positioned(
                                bottom: 5, right: 5,
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.blue,
                                  child: Text('$disponibles', style: const TextStyle(fontSize: 12, color: Colors.white)),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const VerticalDivider(width: 1, thickness: 1),

          // --- COLUMNA DERECHA: MAZO ---
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("MI MAZO (${_mazoTemporal.length} cartas)", style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: _mazoTemporal.isEmpty 
                    ? const Center(child: Text("Pulsa cartas de la izquierda\npara añadirlas", textAlign: TextAlign.center))
                    : ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: _mazoTemporal.length,
                        itemBuilder: (context, index) {
                          final carta = _mazoTemporal[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Text("${carta.mana}💧", style: const TextStyle(fontWeight: FontWeight.bold)),
                              title: Text(carta.nombre, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              subtitle: Text("ATK: ${carta.ataque} | HP: ${carta.vida}"),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () => _quitarDelMazo(index),
                              ),
                            ),
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}