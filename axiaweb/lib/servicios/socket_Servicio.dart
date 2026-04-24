import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketServicio {
  WebSocketChannel? _canal;
  final String _urlSocket = 'ws://13.49.2.229:5000/chat'; // IP de tu servidor C#

  Stream<dynamic>? get streamMensajes => _canal?.stream;

  void conectar(String? token) {
    if (token == null) return;
    
    // Conexión con token para SignalR/WebSockets en C#
    final urlFinal = '$_urlSocket?access_token=$token';
    
    try {
      _canal = WebSocketChannel.connect(Uri.parse(urlFinal));
      print("Conectado al Chat");
    } catch (e) {
      print("Error socket: $e");
    }
  }

  void desconectar() {
    _canal?.sink.close();
  }

  void enviarMensaje(String usuario, String texto) {
    if (_canal != null) {
      _canal!.sink.add(jsonEncode({
        'usuario': usuario,
        'texto': texto,
        'fecha': DateTime.now().toIso8601String(),
      }));
    }
  }
}