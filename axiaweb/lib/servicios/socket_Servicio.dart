import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketServicio {
  WebSocketChannel? _canal;

  // Cambia 'ws://' o 'wss://' según tu servidor
  final String _urlSocket = 'wss://axiaserver.com/chat';

  // Conectar al chat
  void conectar() {
    _canal = WebSocketChannel.connect(Uri.parse(_urlSocket));
    print("Conectado al Chat Global");
  }

  // Desconectar (importante para no gastar batería/datos cuando el usuario sale de la vista)
  void desconectar() {
    _canal?.sink.close();
    print("Desconectado del Chat Global");
  }

  // Enviar un mensaje
  void enviarMensaje(String usuario, String texto) {
    if (_canal != null) {
      // Enviamos el mensaje en formato JSON
      final mensajeJson = jsonEncode({
        'usuario': usuario,
        'texto': texto,
        'fecha': DateTime.now().toIso8601String(),
      });
      _canal!.sink.add(mensajeJson);
    }
  }

  // Escuchar los mensajes que llegan del servidor
  Stream<dynamic>? get streamMensajes => _canal?.stream;
}