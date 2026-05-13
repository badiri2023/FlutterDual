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
  List<CartaWiki> _cartasBaseDatos = [];
  
  bool _cargando = true;
  String _mensajeError = '';

  @override
  void initState() {
    super.initState();
    _cargarCatalogo();
  }

  Future<void> _cargarCatalogo() async {
    final respuesta = await ApiServicio.obtenerCatalogoCartas();

    if (respuesta['exito']) {
      setState(() {
        _cartasBaseDatos = respuesta['datos']; 
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
      body: _construirCuerpo(),
    );
  }

  Widget _construirCuerpo() {
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

    if (_mensajeError.isNotEmpty) {
      return Center(
        child: Text('Error: $_mensajeError', style: const TextStyle(color: Colors.red)),
      );
    }

    if (_cartasBaseDatos.isEmpty) {
      return const Center(
        child: Text('No hay cartas disponibles en este momento.'),
      );
    }

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
