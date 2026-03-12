import 'package:flutter/material.dart';
import '../main.dart'; 
import 'vistaInicio.dart'; 
import 'vistaWiki.dart';
import 'vistaChat.dart';
import 'dialogoLogin.dart';
import 'dialogoRegistro.dart';

class VistaPrincipal extends StatefulWidget {
  const VistaPrincipal({super.key});

  @override
  State<VistaPrincipal> createState() => _VistaPrincipalState();
}

class _VistaPrincipalState extends State<VistaPrincipal> {
  int _indiceActual = 0;

  final List<Widget> _vistas = [
    const VistaInicio(), 
    const VistaWiki(),   
    const VistaChat(),   
  ];

  void _cambiarVista(int indice) {
    setState(() {
      _indiceActual = indice;
    });
    Navigator.pop(context); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('AxiaWeb', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
        TextButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => const DialogoLogin(), 
          );
        },
            child: Text('Iniciar sesión', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 157, 101, 10), foregroundColor: Colors.white),
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
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('MENU', style: TextStyle(color: Colors.white, fontSize: 24)),
                      ],
                    ),
                  ),
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
                ],
              ),
            ),
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
                      child: Text(
                        'Desarrollado por MoonShine Studio.',
                        style: TextStyle(fontSize: 14),
                      ),
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
      body: _vistas[_indiceActual],
    );
  }
}
