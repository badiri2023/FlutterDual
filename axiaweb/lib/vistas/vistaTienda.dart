import 'package:flutter/material.dart';
import '../models/carta.dart';
import '../widgets/widgetcartaprefab.dart';
import '../servicios/api_servicio.dart';

class VistaTienda extends StatefulWidget {
  const VistaTienda({super.key});

  @override
  State<VistaTienda> createState() => _VistaTiendaState();
}

class _VistaTiendaState extends State<VistaTienda> {
  // CONFIGURACIÓN GLOBAL DEL PRECIO
  final int _precioSobreEstandar = 100;

  int _monedasUsuario = 0;
  bool _cargandoMonedas = true;
  bool _comprando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  Future<void> _cargarDatosIniciales() async {
    int monedas = await ApiServicio.obtenerMonedasUsuario();
    if (mounted) {
      setState(() {
        _monedasUsuario = monedas;
        _cargandoMonedas = false;
      });
    }
  }

  Future<void> _abrirSobreReal(String nombreExpansion) async {
    if (_monedasUsuario < _precioSobreEstandar) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No tienes suficientes monedas 🪙")),
      );
      return;
    }

    setState(() => _comprando = true);

    final resultado = await ApiServicio.abrirSobre(nombreExpansion);

    if (mounted) {
      setState(() => _comprando = false);
    }

    if (resultado['exito']) {
      _cargarDatosIniciales();
      // Aquí llamamos a TU función de animación con las cartas reales
      _mostrarAnimacionSobre(nombreExpansion, resultado['datos']); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${resultado['mensaje']}")),
      );
    }
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tienda de Sobres"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Chip(
              avatar: const Icon(Icons.monetization_on, color: Colors.amber),
              label: Text(_cargandoMonedas ? "..." : "$_monedasUsuario"),
            ),
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 40,
            runSpacing: 40,
            alignment: WrapAlignment.center,
            children: [
              // AQUÍ PONEMOS LAS RUTAS DE TUS IMÁGENES
              // Cambia los nombres por los que tengas exactamente en tu carpeta assets
              _buildCardSobre("juguetes", "assets/jugetes.png"),
              _buildCardSobre("futuristico", "assets/futurista.png"),
              _buildCardSobre("fantasticas ", "assets/slimes.png"),
            ],
          ),
        ),
      ),
    );
  }

  // Plantilla actualizada para usar imágenes de tus assets
  Widget _buildCardSobre(String nombre, String rutaImagen) {
    return Card(
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 280,
        child: Column(
          children: [
            // Usamos Image.asset en lugar de Icon
            Image.asset(
              rutaImagen, 
              height: 180, // Ajusta este tamaño según veas
              fit: BoxFit.contain, // Para que la imagen no se deforme
            ),
            const SizedBox(height: 15),
            Text(nombre, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _comprando ? null : () => _abrirSobreReal(nombre),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              child: _comprando 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text("$_precioSobreEstandar ", style: const TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
  // ¡TU LÓGICA DE INTERFAZ ORIGINAL RECUPERADA!
  void _mostrarAnimacionSobre(String expansion, List<CartaWiki> cartas) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.9),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "¡HAS ABIERTO UN SOBRE ${expansion.toUpperCase()}!",
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 400,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: cartas.map((carta) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: SizedBox(
                          width: 240,
                          child: WidgetCartaPrefab(carta: carta),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("GUARDAR EN MI COLECCIÓN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }
}