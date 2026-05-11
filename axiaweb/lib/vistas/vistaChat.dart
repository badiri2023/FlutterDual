import 'dart:convert';
import 'package:flutter/material.dart';
import '../servicios/socket_Servicio.dart';
import '../servicios/api_servicio.dart';

class VistaChat extends StatefulWidget {
  final String nombreUsuario; 
  final bool estaLogueado; 

  const VistaChat({
    super.key, 
    required this.nombreUsuario, 
    required this.estaLogueado,
  });

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
    // Al cargar por primera vez, si ya está logueado, conectamos
    if (widget.estaLogueado) {
      _conectarYEscuchar();
    }
    _cargarMensajesPrevios();
  }

  // Detecta cambios en los parámetros del Widget
  @override
  void didUpdateWidget(covariant VistaChat oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Si antes no estaba logueado y ahora sí -> CONECTAR
    if (!oldWidget.estaLogueado && widget.estaLogueado) {
      _conectarYEscuchar();
    } 
    // Si antes estaba logueado y ahora no -> DESCONECTAR
    else if (oldWidget.estaLogueado && !widget.estaLogueado) {
      _socket.desconectar();
      _mensajes.clear();
      _cargarMensajesPrevios(); 
    }
  }

  @override
  void dispose() {
    _socket.desconectar();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _conectarYEscuchar() {
    // Aseguramos que el token esté actualizado antes de conectar
    _socket.conectar(ApiServicio.tokenActual); 
    
    _socket.streamMensajes?.listen((datos) {
      if (!mounted) return;
      final nuevoMensaje = jsonDecode(datos);
      setState(() {
        _mensajes.add(nuevoMensaje);
      });
      _bajarAlFinal();
    });
  }

  Future<void> _cargarMensajesPrevios() async {
    final resultado = await ApiServicio.obtenerHistorialChat();
    if (resultado['exito'] && mounted) {
      setState(() {
        _mensajes.clear();
        final mensajesTraducidos = (resultado['datos'] as List).map((m) => {
          'usuario': m['username'] ?? 'Desconocido',
          'texto': m['text'] ?? '',
          'fecha': m['createdAt'] ?? DateTime.now().toIso8601String(),
        }).toList();
        _mensajes.addAll(mensajesTraducidos);
      });
      _bajarAlFinal();
    }
  }

  void _enviar() {
    if (_controller.text.trim().isNotEmpty && widget.estaLogueado) {
      _socket.enviarMensaje(widget.nombreUsuario, _controller.text.trim());
      _controller.clear();
      _bajarAlFinal();
    }
  }

  void _bajarAlFinal() {
    Future.delayed(const Duration(milliseconds: 100), () {
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
      return "${hora.hour}:${hora.minute.toString().padLeft(2, '0')}";
    } catch (e) { return ""; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 20),
              itemCount: _mensajes.length,
              // ASÍ DEBE QUEDAR
              itemBuilder: (context, index) {
                final m = _mensajes[index];
                return _buildBurbuja(m);
              },
            ),
          ),
          _buildBarraEscritura(),
        ],
      ),
    );
  }

// Busca esta función y reemplázala por esta versión mejorada
Widget _buildBurbuja(Map<String, dynamic> m) {
  // Aquí calculamos si el mensaje es nuestro comparando nombres
  final bool esMio = m['usuario'] == widget.nombreUsuario;

  return Align(
    alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
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
        crossAxisAlignment: esMio ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!esMio) // Solo mostramos el nombre si es de otra persona
            Text(
              m['usuario'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54),
            ),
          Text(
            m['texto'],
            style: TextStyle(color: esMio ? Colors.white : Colors.black87),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildBarraEscritura() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: widget.estaLogueado,
              decoration: InputDecoration(
                hintText: widget.estaLogueado ? "Escribe algo..." : "Inicia sesión para chatear",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onSubmitted: widget.estaLogueado ? (_) => _enviar() : null,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: widget.estaLogueado ? Colors.orange : Colors.grey),
            onPressed: widget.estaLogueado ? _enviar : null,
          )
        ],
      ),
    );
  }
}
