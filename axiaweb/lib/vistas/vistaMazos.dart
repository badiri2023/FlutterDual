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

  int? _deckIdActual;
  List<CartaWiki> _mazoTemporal = [];
  Map<String, int> _inventarioCantidades = {};
  Map<String, CartaWiki> _bdCartas = {};

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final resInventario = await ApiServicio.obtenerInventario();

    if (resInventario['exito']) {
      List<CartaWiki> cartasInventario = resInventario['inventario'];
      Map<String, int> cantidades = resInventario['cantidades'];

      setState(() {
        for (var c in cartasInventario) {
          _bdCartas[c.id] = c;
        }
        _inventarioCantidades = cantidades;
      });

      // Cargamos el Deck guardado del servidor
 final resDeck = await ApiServicio.obtenerMiDeck();
if (resDeck['exito']) {
  final datosDeck = resDeck['datos'];
  final List<String> cardIds = List<String>.from(datosDeck['cardIdsNormalized'] ?? []);
  final List<dynamic> cardsDetailedRaw = datosDeck['cardsDetailed'] ?? datosDeck['Cards'] ?? datosDeck['cards'] ?? [];

  // Normalizamos cardsDetailed a List<Map<String, dynamic>>
  final List<Map<String, dynamic>> cardsDetailed = cardsDetailedRaw
      .where((e) => e != null)
      .map((e) => Map<String, dynamic>.from(e as Map))
      .toList();

  setState(() {
    _deckIdActual = datosDeck['id'];
    _mazoTemporal = [];

    for (var idCarta in cardIds) {
      final idStr = idCarta.toString();

      if (_bdCartas.containsKey(idStr)) {
        _mazoTemporal.add(_bdCartas[idStr]!);
        continue;
      }

      // Buscamos en cardsDetailed usando indexWhere (evita orElse con null)
      final idx = cardsDetailed.indexWhere((c) {
        final cid = (c['Id'] ?? c['id'] ?? '').toString();
        return cid == idStr;
      });

      if (idx != -1) {
        final detalle = cardsDetailed[idx];
        _mazoTemporal.add(CartaWiki(
          id: idStr,
          expansion: (detalle['Expansion'] ?? detalle['expansion'] ?? 'Base').toString(),
          nombre: (detalle['Name'] ?? detalle['name'] ?? 'Sin nombre').toString(),
          rareza: (detalle['Rarity'] ?? detalle['rarity'] ?? 'Común').toString(),
          mana: (detalle['Mana'] ?? detalle['mana'] ?? 0) is int ? (detalle['Mana'] ?? detalle['mana'] ?? 0) as int : int.tryParse((detalle['Mana'] ?? detalle['mana'] ?? '0').toString()) ?? 0,
          habilidad: detalle['Ability'] != null
              ? "${detalle['Ability']['Name'] ?? detalle['Ability']['name'] ?? ''}: ${detalle['Ability']['Description'] ?? detalle['Ability']['description'] ?? ''}"
              : 'Sin habilidad',
          ataque: (detalle['Attack'] ?? detalle['attack'] ?? 0) is int ? (detalle['Attack'] ?? detalle['attack'] ?? 0) as int : int.tryParse((detalle['Attack'] ?? detalle['attack'] ?? '0').toString()) ?? 0,
          vida: (detalle['Defense'] ?? detalle['defense'] ?? 0) is int ? (detalle['Defense'] ?? detalle['defense'] ?? 0) as int : int.tryParse((detalle['Defense'] ?? detalle['defense'] ?? '0').toString()) ?? 0,
          descripcion: (detalle['Description'] ?? detalle['description'] ?? '').toString(),
          imagenUrl: (detalle['ImageUrl'] ?? detalle['imageUrl'] ?? '').toString(),
        ));
      } else {
        // Depuración: carta no encontrada en inventario ni en cardsDetailed
        print("DEBUG: carta del deck no encontrada: $idStr");
      }
    }
  });
}


      setState(() => _cargando = false);
    } else {
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar cartas: ${resInventario['mensaje']}")),
      );
    }
  }

  void _anadirAlMazo(String id) {
    int cantidadEnMazo = _mazoTemporal.where((c) => c.id == id).length;
    int totalPoseidas = _inventarioCantidades[id] ?? 0;

    // Máximo 3 copias O el total que poseas
    if (cantidadEnMazo < totalPoseidas && cantidadEnMazo < 3) {
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

  void _onGuardarPressed() {
    if (_mazoTemporal.length != 20) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Mazo incompleto'),
            content: Text('Tu mazo tiene ${_mazoTemporal.length} cartas. Se requieren 20 cartas para guardar.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Si llega aquí, tiene 20 cartas: procedemos a guardar
    _guardarCambios();
  }

  Future<void> _guardarCambios() async {
    setState(() => _guardando = true);

    // Mapeo perfecto a Integers para C#
    List<int> idsParaEnviar = _mazoTemporal.map((c) => int.parse(c.id)).toList();

    // Pasamos tanto la lista como el ID actual
    final res = await ApiServicio.guardarMazo(idsParaEnviar, _deckIdActual);

    setState(() => _guardando = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['mensaje']),
        backgroundColor: res['exito'] ? Colors.green : Colors.red,
      ),
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
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _onGuardarPressed,
                  tooltip: "Guardar mazo en el servidor",
                )
        ],
      ),

      // ---------- BODY RESPONSIVE ----------
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool pantallaPequena = constraints.maxWidth < 900;

          if (pantallaPequena) {
            // Diseño vertical: inventario arriba, mazo abajo
            return Column(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildInventario(),
                ),
                Container(height: 3, color: Colors.black12),
                Expanded(
                  flex: 1,
                  child: _buildMazo(),
                ),
              ],
            );
          }

          // Diseño horizontal: inventario a la izquierda, mazo a la derecha
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildInventario(),
              ),
              Container(width: 3, color: Colors.black12),
              Expanded(
                flex: 1,
                child: _buildMazo(),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------- INVENTARIO (GRID RESPONSIVE) ----------
  Widget _buildInventario() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220, // ancho máximo por carta; ajusta si quieres cartas más grandes/pequeñas
        childAspectRatio: 0.70,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _bdCartas.length,
      itemBuilder: (context, i) {
        String id = _bdCartas.keys.elementAt(i);
        CartaWiki carta = _bdCartas[id]!;
        int enMazo = _mazoTemporal.where((c) => c.id == id).length;
        int disponibles = (_inventarioCantidades[id] ?? 0) - enMazo;
        bool limiteAlcanzado = enMazo >= 3;
        bool puedeAnadir = disponibles > 0 && !limiteAlcanzado;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Opacity(
              opacity: puedeAnadir ? 1.0 : 0.45,
              child: WidgetCartaPrefab(carta: carta),
            ),

            // Indicador de cantidad
            Positioned(
              top: -5,
              left: -5,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: Text(
                  '$disponibles',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Botón de añadir
            Positioned(
              bottom: -2,
              right: -2,
              child: GestureDetector(
                onTap: puedeAnadir ? () => _anadirAlMazo(id) : null,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: puedeAnadir ? Colors.green : Colors.blueGrey,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: Icon(
                    puedeAnadir ? Icons.add : Icons.block,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------- MAZO (PANEL) ----------
  Widget _buildMazo() {
    return Column(
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
    );
  }
}
