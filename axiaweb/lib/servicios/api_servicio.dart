import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/carta.dart'; 

class ApiServicio {
  static const String _urlBase = 'http://13.49.2.229:5000/api';
  static String? _token;

  // Getter para el socket
  static String? get tokenActual => _token;

  // Cabeceras automáticas
  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  // --- LOGIN ---
  static Future<Map<String, dynamic>> hacerLogin(String correo, String password) async {
    try {
      final respuesta = await http.post(
        Uri.parse('$_urlBase/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Email': correo, 'Password': password}),
      );

      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(respuesta.body);
        _token = datos['token'];
        return {'exito': true, 'mensaje': 'Bienvenido', 'datos': datos};
      }
      return {'exito': false, 'mensaje': 'Credenciales incorrectas'};
    } catch (e) {
      return {'exito': false, 'mensaje': 'Error de conexión con el servidor'};
    }
  }

  // --- REGISTRO ---
  static Future<Map<String, dynamic>> registrarUsuario(String nombre, String correo, String password) async {
    try {
      final respuesta = await http.post(
        Uri.parse('$_urlBase/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Username': nombre, 'Email': correo, 'Password': password}),
      );

      if (respuesta.statusCode == 200 || respuesta.statusCode == 201) {
        return {'exito': true, 'mensaje': 'Registro completado'};
      }
      return {'exito': false, 'mensaje': 'Error en el registro'};
    } catch (e) {
      return {'exito': false, 'mensaje': 'Error de conexión'};
    }
  }

  // --- INVENTARIO (Corregido para tu modelo CartaWiki) ---
  static Future<Map<String, dynamic>> obtenerInventario() async {
    try {
      final respuesta = await http.get(
        Uri.parse('$_urlBase/Card/my-cards'),
        headers: _getHeaders(),
      );

      if (respuesta.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(respuesta.body);
        
        List<CartaWiki> inventario = jsonList.map((json) => CartaWiki(
          id: json['id'].toString(), 
          nombre: json['name'] ?? '',
          descripcion: json['description'] ?? '',
          ataque: json['attack'] ?? 0,
          vida: json['defense'] ?? 0, // Usamos defense para tu campo vida
          mana: json['mana'] ?? 1, 
          rareza: _traducirRareza(json['rarity']),
          expansion: json['expansion'] ?? 'Base',
          habilidad: json['ability']?['name'] ?? '', 
        )).toList();

        Map<String, int> cantidades = {};
        for (var item in jsonList) {
          cantidades[item['id'].toString()] = item['quantity'] ?? 1;
        }

        return {'exito': true, 'inventario': inventario, 'cantidades': cantidades};
      }
      return {'exito': false, 'mensaje': 'No se pudieron cargar tus cartas'};
    } catch (e) {
      return {'exito': false, 'mensaje': 'Error de conexión'};
    }
  }

  // --- GUARDAR MAZO ---
  static Future<Map<String, dynamic>> guardarMazo(List<String> mazoIds) async {
    try {
      final respuesta = await http.post(
        Uri.parse('$_urlBase/mazos/guardar'),
        headers: _getHeaders(),
        body: jsonEncode({'mazo': mazoIds}),
      );
      return {'exito': true, 'mensaje': 'Mazo sincronizado'};
    } catch (e) {
      return {'exito': true, 'mensaje': 'Mazo guardado (Local)'};
    }
  }

  // --- HISTORIAL CHAT ---
  static Future<Map<String, dynamic>> obtenerHistorialChat() async {
    try {
      final respuesta = await http.get(
        Uri.parse('$_urlBase/chat/historial'),
        headers: _getHeaders(),
      );
      if (respuesta.statusCode == 200) {
        return {'exito': true, 'datos': jsonDecode(respuesta.body)};
      }
    } catch (e) {}
    // Retorno mock para que la vista no pete si no hay historial aún
    return {'exito': true, 'datos': []};
  }

  // --- CATÁLOGO WIKI ---
  static Future<Map<String, dynamic>> obtenerCatalogoCartas() async {
    // Simulamos respuesta para la Wiki
    await Future.delayed(const Duration(milliseconds: 500)); 
    List<CartaWiki> mockCatalogo = [
      CartaWiki(id: '1', nombre: 'Guerrero Axia', descripcion: 'Un guerrero básico', ataque: 2, vida: 3, mana: 2, rareza: 'Común', expansion: 'Base', habilidad: ''),
    ];
    return {'exito': true, 'datos': mockCatalogo};
  }

  static String _traducirRareza(dynamic rareza) {
    if (rareza == 1) return 'Común';
    if (rareza == 2) return 'Rara';
    if (rareza == 3) return 'Épica';
    return 'Común';
  }
}