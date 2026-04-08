import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // ¡Importante para decodificar el JSON del servidor!
import '../models/carta.dart'; 

class Carta {
  final String id;
  final String nombre;
  final int atk;
  final int hp;

  Carta({required this.id, required this.nombre, required this.atk, required this.hp});
}

// --- VISTA PRINCIPAL ---
class VistaMazos extends StatefulWidget {
  const VistaMazos({super.key});

  @override
  State<VistaMazos> createState() => _VistaMazosState();
}

class _VistaMazosState extends State<VistaMazos> {
  bool _editando = false;
  bool _guardando = false;
  bool _cargando = true; // NUEVO: Controla la pantalla de carga al inicio

  // Ahora empiezan vacíos. El servidor los llenará.
  List<Carta> _mazo = [];
  Map<String, int> _inventarioBase = {};
  Map<String, Carta> _bdCartas = {};

  @override
  void initState() {
    super.initState();
    _cargarDatosServidor(); // NUEVO: Llamamos a tu API al entrar
  }

  // --- LÓGICA DE CONEXIÓN (GET) ---
  Future<void> _cargarDatosServidor() async {
    try {
      // 1. Llamada a tu servidor (Ajusta la URL a la tuya real)
      final url = Uri.parse('https://tu-api-axia.com/api/jugador/123/mazo_e_inventario');
      final respuesta = await http.get(url).timeout(const Duration(seconds: 10));

      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(respuesta.body);

        Map<String, Carta> bdTemporal = {};
        Map<String, int> inventarioTemporal = {};
        List<Carta> mazoTemporal = [];

        // 2. Parsear el Catálogo Global (Las stats de las cartas)
        for (var item in datos['catalogo']) {
          bdTemporal[item['id']] = Carta(
            id: item['id'],
            nombre: item['nombre'],
            atk: item['atk'],
            hp: item['hp'],
          );
        }

        // 3. Parsear el Inventario (Cuántas tiene de cada una)
        for (var item in datos['inventario']) {
          inventarioTemporal[item['idCarta']] = item['cantidad'];
        }

        // 4. Parsear el Mazo Actual guardado
        for (var idCarta in datos['mazoActual']) {
          if (bdTemporal.containsKey(idCarta)) {
            mazoTemporal.add(bdTemporal[idCarta]!);
          }
        }

        // 5. Actualizar la interfaz
        setState(() {
          _bdCartas = bdTemporal;
          _inventarioBase = inventarioTemporal;
          _mazo = mazoTemporal;
          _cargando = false; // Ocultamos la rueda de carga
        });
      } else {
        _mostrarAviso('Error al cargar datos (${respuesta.statusCode}).');
        setState(() => _cargando = false);
      }
    } catch (e) {
      _mostrarAviso('Error de conexión al cargar el inventario.');
      setState(() => _cargando = false);
      print('Error en GET: $e');
    }
  }

  // --- LÓGICA DE CARTAS ---
  int _copiasEnMazo(String idCarta) {
    return _mazo.where((c) => c.id == idCarta).length;
  }

  int _copiasDisponibles(String idCarta) {
    int totalQuePosee = _inventarioBase[idCarta] ?? 0;
    return totalQuePosee - _copiasEnMazo(idCarta);
  }

  void _anadirAlMazo(String idCarta) {
    if (_mazo.length >= 20) {
      _mostrarAviso('El mazo ya tiene 20 cartas.');
      return;
    }
    if (_copiasEnMazo(idCarta) >= 3) {
      _mostrarAviso('No puedes tener más de 3 copias de la misma carta.');
      return;
    }
    if (_copiasDisponibles(idCarta) <= 0) {
      _mostrarAviso('No tienes más copias de esta carta en tu inventario.');
      return;
    }

    setState(() {
      _mazo.add(_bdCartas[idCarta]!);
      _mazo.sort((a, b) => a.id.compareTo(b.id)); 
    });
  }

  void _quitarDelMazo(Carta carta) {
    setState(() {
      _mazo.remove(carta);
    });
  }

  void _mostrarAviso(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensaje),
      duration: const Duration(seconds: 2),
    ));
  }

  // --- LÓGICA DE GUARDADO (POST) ---
  Future<void> _guardarMazo() async {
    if (_mazo.length != 20) {
      _mostrarAviso('¡Error! El mazo debe tener exactamente 20 cartas.');
      return;
    }

    setState(() => _guardando = true);

    try {
      final listaIds = _mazo.map((carta) => carta.id).toList();
      final cuerpoPeticion = jsonEncode({
        'idJugador': 'jugador_123', 
        'mazo': listaIds
      });

      final url = Uri.parse('https://tu-api-axia.com/api/mazos/guardar');
      
      final respuesta = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: cuerpoPeticion,
      ).timeout(const Duration(seconds: 10)); 

      if (respuesta.statusCode == 200 || respuesta.statusCode == 201) {
        setState(() => _editando = false);
        if (mounted) _mostrarAviso('¡Mazo guardado en el servidor con éxito!');
      } else {
        if (mounted) _mostrarAviso('Error del servidor: No se pudo guardar (${respuesta.statusCode}).');
      }

    } catch (error) {
      if (mounted) _mostrarAviso('Error de conexión al guardar el mazo.');
      print('Detalle del error: $error'); 
    } finally {
      setState(() => _guardando = false);
    }
  }

  // --- INTERFAZ GRÁFICA ---
  @override
  Widget build(BuildContext context) {
    // NUEVO: Pantalla de carga inicial
    if (_cargando) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando tu mazo y cartas...'),
          ],
        ),
      );
    }

    return _editando ? _construirModoEdicion() : _construirModoVista();
  }

  // 1. MODO VISTA
  Widget _construirModoVista() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mazo Inicial', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              FilledButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Editar Mazo'),
                onPressed: () => setState(() => _editando = true),
              ),
            ],
          ),
        ),
        const Text('Cartas en el mazo:'),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _mazo.length,
            itemBuilder: (context, index) {
              final carta = _mazo[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.image, size: 40), 
                  title: Text(carta.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('⚔️ ${carta.atk}  |  ❤️ ${carta.hp}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 2. MODO EDICIÓN
  Widget _construirModoEdicion() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Editando Mazo (${_mazo.length}/20)', 
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: _mazo.length == 20 ? Colors.green : Colors.red,
                )
              ),
              if (_guardando)
                const CircularProgressIndicator()
              else
                FilledButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar'),
                  onPressed: _guardarMazo,
                  style: FilledButton.styleFrom(backgroundColor: Colors.green),
                ),
            ],
          ),
        ),
        
        Expanded(
          child: Row(
            children: [
              // IZQUIERDA: EL MAZO
              Expanded(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('TU MAZO', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _mazo.length,
                        itemBuilder: (context, index) {
                          final carta = _mazo[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                                  onPressed: () => _quitarDelMazo(carta),
                                  tooltip: 'Mover al inventario',
                                ),
                                const Icon(Icons.image, size: 30),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(carta.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      Text('⚔️${carta.atk} ❤️${carta.hp}', style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              const VerticalDivider(width: 1, thickness: 2),

              // DERECHA: EL INVENTARIO
              Expanded(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('INVENTARIO', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _inventarioBase.keys.length,
                        itemBuilder: (context, index) {
                          String idCarta = _inventarioBase.keys.elementAt(index);
                          Carta carta = _bdCartas[idCarta]!;
                          int disponibles = _copiasDisponibles(idCarta);
                          int totales = _inventarioBase[idCarta]!;

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            color: disponibles > 0 ? null : Colors.grey.withOpacity(0.2),
                            child: Row(
                              children: [
                                const SizedBox(width: 8),
                                const Icon(Icons.image, size: 30),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(carta.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      Text('⚔️${carta.atk} ❤️${carta.hp}', style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Text(
                                  '$disponibles/$totales', 
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: disponibles > 0 ? Colors.blue : Colors.red
                                  )
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_back_ios, size: 16),
                                  onPressed: disponibles > 0 ? () => _anadirAlMazo(idCarta) : null,
                                  tooltip: 'Añadir al mazo',
                                ),
                              ],
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
        ),
      ],
    );
  }
}