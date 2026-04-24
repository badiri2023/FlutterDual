import 'package:flutter/material.dart';
import '../main.dart'; 
import 'vistaInicio.dart'; 
import 'vistaWiki.dart';
import 'vistaChat.dart';
import 'vistaMazos.dart'; 
import 'vistaTienda.dart'; 
import 'dialogoLogin.dart';
import 'dialogoRegistro.dart';
import 'vistaAjustes.dart';

class VistaPrincipal extends StatefulWidget {
  const VistaPrincipal({super.key});

  @override
  State<VistaPrincipal> createState() => _VistaPrincipalState();
}

class _VistaPrincipalState extends State<VistaPrincipal> {
  int _indiceActual = 0;
  
  // --- LÓGICA DE ESTADO ---
  bool _usuarioLogueado = true; // Empezamos en Modo Invitado
  String _nombreUsuario = "Invitado"; // Para mostrar en el Drawer

  // --- LAS VISTAS ---
  // Mantenemos una lista completa de todas las vistas posibles.
  // IMPORTANTE: El orden de esta lista determina el índice.
  late final List<Widget> _todasLasVistas;

  @override
  void initState() {
    super.initState();
    _todasLasVistas = [
      const VistaInicio(),   // Índice 0
      const VistaWiki(),     // Índice 1
      VistaChat(nombreUsuario: _nombreUsuario),      const VistaAjustes(),  // Índice 3
      const VistaMazos(), // Índice 4 (Requiere Login)
      //const VistaTienda(),// Índice 5 (Requiere Login)
      
      // Mocks temporales para evitar errores de compilación ahora mismo:
      const Center(child: Text('Editor de Mazos (En construcción)')), // Índice 4 temporal
      const Center(child: Text('Tienda (En construcción)')),          // Índice 5 temporal
    ];
  }

  void _cambiarVista(int indice) {
    setState(() {
      _indiceActual = indice;
    });
    Navigator.pop(context); // Cierra el Drawer
  }

  // --- FUNCIÓN PARA CONECTAR EL LOGIN ---
  void _abrirDialogoLogin() async {
    final resultado = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const DialogoLogin(),
    );

    // Si el diálogo nos devuelve un mapa indicando éxito (nuestro mock)
    if (resultado != null && resultado['exito'] == true) {
      setState(() {
        _usuarioLogueado = true;
        // Asignamos un nombre inventado por ahora (luego vendrá de la API)
        _nombreUsuario = "JugadorAxia"; 
      });
      // Opcional: Mostrar un pequeño aviso de bienvenida
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resultado['mensaje'] ?? 'Sesión iniciada')),
        );
      }
    }
  }

  // --- FUNCIÓN PARA CERRAR SESIÓN ---
  void _cerrarSesion() {
    setState(() {
      _usuarioLogueado = false;
      _nombreUsuario = "Invitado";
      // Si estaba en Mazos o Tienda, lo devolvemos a Inicio para no crashear
      if (_indiceActual >= 4) {
        _indiceActual = 0; 
      }
    });
    Navigator.pop(context); // Cierra el Drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('AxiaWeb', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Renderizado condicional en la AppBar
          if (!_usuarioLogueado) ...[
            TextButton(
              onPressed: _abrirDialogoLogin, // Usamos nuestra nueva función
              child: Text(
                'Iniciar sesión', 
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0, left: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 157, 101, 10), 
                  foregroundColor: Colors.white
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                    builder: (context) => const DialogoRegistro(),
                  );
                },
                child: const Text('Registrar'),
              ),
            ),
          ] else ...[
            // Si ESTÁ logueado, mostramos su nombre u opciones de perfil
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Hola, $_nombreUsuario', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(_usuarioLogueado ? 'MENÚ DE JUGADOR' : 'MENÚ', 
                          style: const TextStyle(color: Colors.white, fontSize: 24)),
                      ],
                    ),
                  ),
                  
                  // --- RUTAS PÚBLICAS (Siempre visibles) ---
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Inicio'),
                    selected: _indiceActual == 0,
                    onTap: () => _cambiarVista(0),
                  ),
                  ListTile(
                    leading: const Icon(Icons.menu_book),
                    title: const Text('Wiki de Cartas'),
                    selected: _indiceActual == 1,
                    onTap: () => _cambiarVista(1),
                  ),
                  ListTile(
                    leading: const Icon(Icons.chat),
                    title: const Text('Chat Global'),
                    selected: _indiceActual == 2,
                    onTap: () => _cambiarVista(2),
                  ),

                  // --- RUTAS PRIVADAS (Solo si _usuarioLogueado es true) ---
                  if (_usuarioLogueado) ...[
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                      child: Text('ZONA DE JUEGO', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.dashboard_customize),
                      title: const Text('Mis Mazos'),
                      selected: _indiceActual == 4,
                      onTap: () => _cambiarVista(4),
                    ),
                    ListTile(
                      leading: const Icon(Icons.store),
                      title: const Text('Tienda'),
                      selected: _indiceActual == 5,
                      onTap: () => _cambiarVista(5),
                    ),
                  ],

                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Ajustes'),
                    selected: _indiceActual == 3,
                    onTap: () => _cambiarVista(3),
                  ),
                ],
              ),
            ),
            
            // --- PARTE INFERIOR DEL DRAWER ---
            const Divider(),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: temaNotifier,
              builder: (context, modoActual, _) {
                bool esOscuro = modoActual == ThemeMode.dark;
                return SwitchListTile(
                  title: const Text('Modo Oscuro'),
                  secondary: Icon(esOscuro ? Icons.dark_mode : Icons.light_mode),
                  value: esOscuro,
                  onChanged: (bool valor) {
                    temaNotifier.value = valor ? ThemeMode.dark : ThemeMode.light;
                  },
                );
              },
            ),
            const Divider(),
            
            // Botón extra de Cerrar Sesión en el Drawer si está logueado
            if (_usuarioLogueado)
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                onTap: _cerrarSesion,
              ),

            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Acerca de AxiaWeb'),
              onTap: () {
                showAboutDialog(
                  // ... tu código del about dialog queda igual
                  context: context,
                  applicationName: 'Axia Plataform',
                  applicationVersion: '1.0.0+1',
                  applicationIcon: Icon(Icons.style, color: Theme.of(context).colorScheme.primary, size: 50),
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text('Desarrollado por MoonShine Studio.', style: TextStyle(fontSize: 14)),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            const Text(
              '© 2024 Axia - Todos los derechos reservados',
              style: TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: _todasLasVistas[_indiceActual],
    );
  }
}