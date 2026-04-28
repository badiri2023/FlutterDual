import 'dart:async';
import 'package:signalr_netcore/signalr_client.dart';

class SocketServicio {
  HubConnection? _hubConnection;
  
  // OJO: Usamos http:// en lugar de ws:// para SignalR
  final String _urlSocket = 'http://13.49.2.229:5000/ws/chat'; 

  final _streamController = StreamController<String>.broadcast();
  Stream<dynamic>? get streamMensajes => _streamController.stream;

  Future<void> conectar(String? token) async {
    if (token == null) return;
    
    _hubConnection = HubConnectionBuilder()
        .withUrl(_urlSocket, options: HttpConnectionOptions(
          accessTokenFactory: () async => token,
        ))
        .withAutomaticReconnect()
        .build();

    // Escuchamos el evento "RecibirMensaje" que emite C#
    _hubConnection?.on("RecibirMensaje", (List<dynamic>? parametros) {
      if (parametros != null && parametros.length >= 2) {
        final usuario = parametros[0].toString();
        final texto = parametros[1].toString();
        
        final mensajeJson = '{"usuario": "$usuario", "texto": "$texto", "fecha": "${DateTime.now().toIso8601String()}"}';
        _streamController.sink.add(mensajeJson);
      }
    });

    try {
      await _hubConnection?.start();
      print("¡Conectado al ChatHub de SignalR!");
    } catch (e) {
      print("Error conectando a SignalR: $e");
    }
  }

  void desconectar() {
    _hubConnection?.stop();
    _streamController.close();
  }

  void enviarMensaje(String usuario, String texto) {
    if (_hubConnection?.state == HubConnectionState.Connected) {
      // Llamamos a la función "EnviarMensaje" de nuestro ChatHub en C#
      _hubConnection?.invoke("EnviarMensaje", args: [usuario, texto])
        .catchError((error) => print("Error al enviar: $error"));
    }
  }
}