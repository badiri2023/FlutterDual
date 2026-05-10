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
    // 1. Doble comprobación de seguridad
    if (_monedasUsuario < _precioSobreEstandar) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No tienes suficientes monedas 🪙")),
      );
      return;
    }

    setState(() => _comprando = true);

    // 2. Llamamos al backend
    final resultado = await ApiServicio.abrirSobre(nombreExpansion);

    if (mounted) {
      setState(() => _comprando = false);
    }

    if (resultado['exito']) {
      // 3. ACTUALIZAMOS LAS MONEDAS AL INSTANTE EN LA PANTALLA
      setState(() {
        _monedasUsuario -= _precioSobreEstandar;
      });
      
      // (Opcional) Refrescamos el dato real en segundo plano por seguridad
      _cargarDatosIniciales(); 

      // 4. ¡EL TRUCO! Transformamos el dynamic a una lista estricta de CartaWiki.
      List<CartaWiki> cartasNuevas = List<CartaWiki>.from(resultado['datos'] ?? resultado['cartas']);

      // 5. Ahora sí, le pasamos la lista con el formato correcto al diálogo
      _mostrarAnimacionSobre(nombreExpansion, cartasNuevas); 
      
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
              _buildCardSobre("juguetes", "assets/jugetes.png"),
              _buildCardSobre("futuristico", "assets/futurista.png"),
              _buildCardSobre("fantasticas", "assets/slimes.png"),
            ],
          ),
        ),
      ),
    );
  }

  // Plantilla actualizada con LÓGICA DE DESACTIVACIÓN DE BOTÓN
  Widget _buildCardSobre(String nombre, String rutaImagen) {
    // Comprobamos si el usuario tiene dinero suficiente para este sobre
    bool tieneDinero = _monedasUsuario >= _precioSobreEstandar;

    return Card(
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 280,
        child: Column(
          children: [
            Image.asset(
              rutaImagen, 
              height: 180, 
              fit: BoxFit.contain, 
            ),
            const SizedBox(height: 15),
            Text(nombre, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ElevatedButton(
              // Lógica: Si está comprando O no tiene dinero, el botón es null (desactivado)
              onPressed: (_comprando || !tieneDinero) ? null : () => _abrirSobreReal(nombre),
              style: ElevatedButton.styleFrom(
                backgroundColor: tieneDinero ? Colors.amber : Colors.grey.shade400,
                disabledBackgroundColor: Colors.grey.shade300, // Color cuando está en null
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: _comprando 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(
                    "$_precioSobreEstandar 🪙", 
                    style: TextStyle(
                      color: tieneDinero ? Colors.black : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

void _mostrarAnimacionSobre(String expansion, List<CartaWiki> cartas) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, 
      builder: (context) {
        return _CarruselCartasSobre(expansion: expansion, cartas: cartas);
      },
    );
  }

}
class _CarruselCartasSobre extends StatefulWidget {
  final String expansion;
  final List<CartaWiki> cartas;

  const _CarruselCartasSobre({required this.expansion, required this.cartas});

  @override
  State<_CarruselCartasSobre> createState() => _CarruselCartasSobreState();
}

class _CarruselCartasSobreState extends State<_CarruselCartasSobre> {
  final PageController _pageController = PageController();
  int _indiceActual = 0;

  void _irSiguiente() {
    if (_indiceActual < widget.cartas.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400), 
        curve: Curves.easeInOut,
      );
    }
  }

  void _irAnterior() {
    if (_indiceActual > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400), 
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool esOscuro = Theme.of(context).brightness == Brightness.dark;

    // 1. Usamos Dialog para que flote sobre la tienda
    return Dialog(
      backgroundColor: Colors.transparent, // Transparente para usar nuestro Container
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        // 2. REESCALADO: Max ancho 450 para PC, se adapta en móvil
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 650),
        child: Container(
          // 3. COLOR SÓLIDO: Eliminamos el RadialGradient
          decoration: BoxDecoration(
            color: esOscuro ? const Color(0xFF121212) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber, width: 2), // Borde sólido
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // El diálogo se ajusta al contenido
              children: [
                // --- CABECERA ---
                Text(
                  "Sobre: ${widget.expansion.toUpperCase()}",
                  style: const TextStyle(color: Colors.amber, fontSize: 24),
                ),
                const Divider(color: Colors.amber, height: 30, thickness: 1),
                
                // --- ZONA DEL CARRUSEL ---
                Expanded(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 24),
                        color: _indiceActual > 0 ? Colors.amber : Colors.grey.withOpacity(0.3),
                        onPressed: _indiceActual > 0 ? _irAnterior : null,
                      ),
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          physics: const BouncingScrollPhysics(),
                          onPageChanged: (index) => setState(() => _indiceActual = index),
                          itemCount: widget.cartas.length,
                          itemBuilder: (context, index) {
                            return Center(
                              child: WidgetCartaPrefab(carta: widget.cartas[index]),
                            );
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 24),
                        color: _indiceActual < widget.cartas.length - 1 ? Colors.amber : Colors.grey.withOpacity(0.3),
                        onPressed: _indiceActual < widget.cartas.length - 1 ? _irSiguiente : null,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 15),
                Text(
                  "Carta ${_indiceActual + 1} de ${widget.cartas.length}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                
                // --- BOTÓN DE CONFIRMACIÓN SÓLIDO ---
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      _indiceActual == widget.cartas.length - 1 ? "Guardar" : "Cerrar", 
                      style: const TextStyle(fontWeight: FontWeight.bold)
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

