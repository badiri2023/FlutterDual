import 'package:flutter/material.dart';
import '../models/carta.dart'; 
import '../widgets/widgetcartaprefab.dart';
import '../servicios/api_servicio.dart'; 

class VistaWiki extends StatefulWidget {
  const VistaWiki({super.key});

  @override
  State<VistaWiki> createState() => _VistaWikiState();
}

class _VistaWikiState extends State<VistaWiki> {
  // Ahora la lista empieza vacía
  List<CartaWiki> _cartasBaseDatos = [];
  
  // Controlamos si está cargando o si hubo un error
  bool _cargando = true;
  String _mensajeError = '';

  @override
  void initState() {
    super.initState();
    // Nada más abrir la vista, pedimos las cartas al servidor
    _cargarCatalogo();
  }

  Future<void> _cargarCatalogo() async {
    // Usamos el servicio (tendremos que añadir esta función allí)
    final respuesta = await ApiServicio.obtenerCatalogoCartas();

    if (respuesta['exito']) {
      setState(() {
        _cartasBaseDatos = respuesta['datos']; // Guardamos las cartas reales
        _cargando = false;
      });
    } else {
      setState(() {
        _mensajeError = respuesta['mensaje'];
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wiki de Cartas'),
        centerTitle: true,
      ),
      // Mostramos el contenido dependiendo del estado
      body: _construirCuerpo(),
    );
  }

  Widget _construirCuerpo() {
    // 1. Si está cargando, mostramos la rueda
    if (_cargando) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Descargando catálogo de cartas...'),
          ],
        ),
      );
    }

    // 2. Si hubo un error (ej. servidor caído)
    if (_mensajeError.isNotEmpty) {
      return Center(
        child: Text('Error: $_mensajeError', style: const TextStyle(color: Colors.red)),
      );
    }

    // 3. Si no hay cartas en el servidor
    if (_cartasBaseDatos.isEmpty) {
      return const Center(
        child: Text('No hay cartas disponibles en este momento.'),
      );
    }

    // 4. Si todo fue bien, mostramos el Grid con el redimensionado automático
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220, 
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5 / 3.5, 
      ),
      itemCount: _cartasBaseDatos.length,
      itemBuilder: (context, index) {
        final carta = _cartasBaseDatos[index];
        return WidgetCartaPrefab(carta: carta); 
      },
    );
  }
}