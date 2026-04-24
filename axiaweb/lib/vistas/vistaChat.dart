import 'dart:convert';
import 'package:flutter/material.dart';
import '../servicios/socket_Servicio.dart';
import '../servicios/api_servicio.dart';

class VistaChat extends StatefulWidget {
  final String nombreUsuario; // Recibimos el nombre para saber cuáles son "mis" mensajes

  const VistaChat({super.key, required this.nombreUsuario});

  @override
  State<VistaChat> createState() => _VistaChatState();
}

class _VistaChatState extends State<VistaChat> {
  final List<Map<String, dynamic>> _mensajes = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SocketServicio _socket = SocketServicio();

  @override
  void initState() {
    super.initState();
    _conectarYEscuchar();
    _cargarMensajesPrevios();
  }

  @override
  void dispose() {
    _socket.desconectar(); // Cerramos conexión al salir para ahorrar datos
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 1. CARGAR HISTORIAL (Lo que ya pasó)
  Future<void> _cargarMensajesPrevios() async {
    // Nota: Debes implementar 'obtenerHistorialChat' en ApiServicio
    final resultado = await ApiServicio.obtenerHistorialChat();
    if (resultado['exito']) {
      setState(() {
        _mensajes.addAll(List<Map<String, dynamic>>.from(resultado['datos']));
      });
      _bajarAlFinal();
    }
  }

  // 2. CONECTAR SOCKET Y ESCUCHAR (Lo que está pasando ahora)
void _conectarYEscuchar() {
    // Pasamos el token guardado en el ApiServicio
    _socket.conectar(ApiServicio.tokenActual); 
    
    _socket.streamMensajes?.listen((datos) {
      final nuevoMensaje = jsonDecode(datos);
      setState(() {
        _mensajes.add(nuevoMensaje);
      });
      _bajarAlFinal();
    });
  }
  // 3. ENVIAR MENSAJE
  void _enviar() {
    if (_controller.text.trim().isNotEmpty) {
      _socket.enviarMensaje(widget.nombreUsuario, _controller.text.trim());
      _controller.clear();
      _bajarAlFinal();
    }
  }

  // 4. LÓGICA DE INTERFAZ (Scroll y Hora)
  void _bajarAlFinal() {
    // Pequeño delay para dejar que Flutter renderice el nuevo mensaje antes de scrollear
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatearHora(String fechaIso) {
    try {
      DateTime hora = DateTime.parse(fechaIso).toLocal();
      // Retorna formato "4:30" o "16:30"
      return "${hora.hour}:${hora.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ÁREA DE MENSAJES
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _mensajes.length,
              itemBuilder: (context, index) {
                final m = _mensajes[index];
                bool esMio = m['usuario'] == widget.nombreUsuario;

                return Align(
                  alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: esMio ? Colors.orange.shade700 : Colors.grey.shade300,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: Radius.circular(esMio ? 15 : 0),
                        bottomRight: Radius.circular(esMio ? 0 : 15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!esMio)
                          Text(
                            m['usuario'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey),
                          ),
                        Text(
                          m['texto'],
                          style: TextStyle(color: esMio ? Colors.white : Colors.black87, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        // LA HORA EN LA PARTE INFERIOR
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            _formatearHora(m['fecha']),
                            style: TextStyle(
                              fontSize: 10,
                              color: esMio ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // BARRA DE ESCRITURA
          Container(
            padding: const EdgeInsets.all(10),
            color: Theme.of(context).cardColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Escribe un mensaje...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onSubmitted: (_) => _enviar(),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.orange.shade700,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _enviar,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}