import 'package:axiaweb/vistas/vistaPerfil.dart';
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
import 'vistaRanking.dart';
import '../servicios/api_servicio.dart';


class VistaPrincipal extends StatefulWidget {
  const VistaPrincipal({super.key});

  @override
  State<VistaPrincipal> createState() => _VistaPrincipalState();
}

class _VistaPrincipalState extends State<VistaPrincipal> {
  int _indiceActual = 0;
  
  // --- LÓGICA DE ESTADO ---
  bool _usuarioLogueado = false; 
  String _nombreUsuario = "Invitado"; 

  // --- LAS VISTAS ---
  late final List<Widget> _todasLasVistas;

@override
void initState() {
  super.initState();
  _todasLasVistas = [
    const VistaInicio(),                       
    const VistaWiki(),                        
    const VistaRanking(),                     
    VistaChat(nombreUsuario: _nombreUsuario,
    estaLogueado: _usuarioLogueado),   
    const VistaAjustes(),                      
    const VistaMazos(),                       
    const VistaTienda(),      
    const VistaPerfil(),             
  ];
}


  void _cambiarVista(int indice) {
    setState(() {
      _indiceActual = indice;
    });
    Navigator.pop(context); 
  }

  // ---CERRAR SESIÓN ---
  void _cerrarSesion() {
    setState(() {
      _usuarioLogueado = false;
      _nombreUsuario = "Invitado";
      // Si cierra sesion, lo devolvemos al inicio
      _indiceActual = 0; 
      
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('AXIA', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (!_usuarioLogueado) ...[
            TextButton(
              onPressed: _ejecutarLogin, 
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
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('$_nombreUsuario', style: const TextStyle(fontWeight: FontWeight.bold)),
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
            // --- CABECERA DE USUARIO ---
            if (_usuarioLogueado)
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.amber,
                  child: Icon(Icons.person, size: 40, color: Colors.black),
                ),
                accountName: Text(
                  _nombreUsuario,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                ),
                accountEmail: const Text(
                  'Jugador de Axia',
                  style: TextStyle(color: Colors.white70),
                ),
                // La flechita redirige al perfil
                onDetailsPressed: () => _cambiarVista(7),
              )
            else
              const SizedBox(height: 50),
            ListTile(
              leading: const Icon(Icons.close, color: Colors.grey),
              title: const Text('Cerrar menú', style: TextStyle(color: Colors.grey)),
              onTap: () => Navigator.pop(context), // Cierra el Drawer al instante
            ),
            const Divider(),
            // --- RUTAS PÚBLICAS (Siempre visibles) ---
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              selected: _indiceActual == 0,
              onTap: () => _cambiarVista(0), // Índice 0
            ),
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('Wiki de Cartas'),
              selected: _indiceActual == 1,
              onTap: () => _cambiarVista(1), // Índice 1
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events, color: Colors.amber),
              title: const Text('Ranking'),
              selected: _indiceActual == 2, 
              onTap: () => _cambiarVista(2), // Índice 2
            ),

            // --- RUTAS PRIVADAS (Solo si _usuarioLogueado es true) ---
            if (_usuarioLogueado) ...[
              const Divider(),
              const Padding(
                padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                child: Text('ZONA DE JUEGO', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
              
              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text('Chat Global'),
                selected: _indiceActual == 3, 
                onTap: () => _cambiarVista(3), // Índice 3
              ),
              ListTile(
                leading: const Icon(Icons.dashboard_customize),
                title: const Text('Mis Mazos'),
                selected: _indiceActual == 5, 
                onTap: () => _cambiarVista(5), // Índice 5
              ),
              ListTile(
                leading: const Icon(Icons.store),
                title: const Text('Tienda'),
                selected: _indiceActual == 6, 
                onTap: () => _cambiarVista(6), // Índice 6
              ),
            ],

            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ajustes'),
              selected: _indiceActual == 4, 
              onTap: () => _cambiarVista(4), // Índice 4
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
      
      // Botón de Cerrar Sesión 
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


Future<void> _ejecutarLogin() async {
  final String? usuarioRecuperado = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const DialogoLogin(),
  );

  if (usuarioRecuperado != null) {
    setState(() {
      _usuarioLogueado = true;
    });

    // Intentamos obtener el username real desde el servidor
    try {
      final resPerfil = await ApiServicio.obtenerPerfilCompleto();
      if (resPerfil['exito'] == true && resPerfil['datos'] != null) {
        final datos = resPerfil['datos'];
        String usernameServidor = (datos['username'] ?? datos['Username'] ?? '').toString();

        if (usernameServidor.isNotEmpty) {
          // Normalizamos capitalización: Primera letra mayúscula, resto minúsculas
          final nombreLimpio = usernameServidor[0].toUpperCase() + usernameServidor.substring(1).toLowerCase();
          setState(() {
            _nombreUsuario = nombreLimpio;
          });
        } else {
          // Fallback: si no hay username en la respuesta, usar parte local del email
          final fallback = usuarioRecuperado.split('@')[0];
          setState(() {
            _nombreUsuario = fallback.isNotEmpty
                ? (fallback[0].toUpperCase() + fallback.substring(1).toLowerCase())
                : 'Invitado';
          });
        }
      } else {
        // Si la petición falla, usamos fallback y mostramos aviso
        final fallback = usuarioRecuperado.split('@')[0];
        setState(() {
          _nombreUsuario = fallback.isNotEmpty
              ? (fallback[0].toUpperCase() + fallback.substring(1).toLowerCase())
              : 'Invitado';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login correcto, pero no se pudo obtener el perfil: ${resPerfil['mensaje'] ?? 'Error'}')),
          );
        }
      }
    } catch (e) {
      // En caso de error de red u otro, usar fallback y notificar
      final fallback = usuarioRecuperado.split('@')[0];
      setState(() {
        _nombreUsuario = fallback.isNotEmpty
            ? (fallback[0].toUpperCase() + fallback.substring(1).toLowerCase())
            : 'Invitado';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login correcto, pero fallo al obtener perfil.')),
        );
      }
    }

    // Actualizamos la vista del chat con el nombre real
    setState(() {
      _todasLasVistas[3] = VistaChat(
        nombreUsuario: _nombreUsuario,
        estaLogueado: _usuarioLogueado,
      );
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Bienvenido, $_nombreUsuario!')),
      );
    }
  }
}


}