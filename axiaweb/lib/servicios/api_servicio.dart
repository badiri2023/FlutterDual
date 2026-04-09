import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/carta.dart'; 

class ApiServicio {
  // 1. Dejamos la URL base hasta /api para que sirva para todos los controladores
  static const String _urlBase = 'http://13.49.2.229:5000/api';

  static Future<Map<String, dynamic>> hacerLogin(String correo, String password) async {
    try {
      final respuesta = await http.post(
        // Añadimos /auth/login aquí
        Uri.parse('$_urlBase/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': correo,       // 2. Cambiado de 'correo' a 'email' para que C# lo entienda
          'password': password,
        }),
      );

      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(respuesta.body);
        return {'exito': true, 'mensaje': 'Bienvenido', 'datos': datos};
      } else if (respuesta.statusCode == 401) {
        return {'exito': false, 'mensaje': 'Correo o contraseña incorrectos'};
      } else {
        return {'exito': false, 'mensaje': 'Error en el servidor: ${respuesta.statusCode}'};
      }
    } catch (e) {
      return {'exito': false, 'mensaje': 'No hay conexión a internet o el servidor está caído'};
    }
  }

  static Future<Map<String, dynamic>> registrarUsuario(String nombre, String correo, String password) async {
    try {
      final respuesta = await http.post(
        // 3. Cambiado a /register para coincidir con tu [HttpPost("register")] en C#
        Uri.parse('$_urlBase/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': nombre,    // 2. Cambiado a 'username'
          'email': correo,       // 2. Cambiado a 'email'
          'password': password,
        }),
      );

      if (respuesta.statusCode == 200 || respuesta.statusCode == 201) { 
        // C# devuelve Ok() que es 200, no 201 en tu código actual
        return {'exito': true, 'mensaje': 'Cuenta creada con éxito'};
      } else {
        final error = jsonDecode(respuesta.body);
        return {'exito': false, 'mensaje': error['mensaje'] ?? 'Error al registrar'};
      }
    } catch (e) {
      return {'exito': false, 'mensaje': 'Error de conexión'};
    }
  }

  static Future<Map<String, dynamic>> obtenerCatalogoCartas() async {
    try {
      // 4. Actualizado para usar _urlBase y quitar la IP vieja de 192.168...
      final url = Uri.parse('$_urlBase/cartas/wiki'); 
      
      final respuesta = await http.get(url);

      if (respuesta.statusCode == 200) {
        final List<dynamic> datosDecodificados = json.decode(respuesta.body);
        
        List<CartaWiki> listaCartas = datosDecodificados.map((item) {
          return CartaWiki(
            id: item['id']?.toString() ?? '0', 
            expansion: item['Expansión'] ?? 'Desconocida',
            nombre: item['Nombre'] ?? 'Sin nombre',
            rareza: item['Rareza'] ?? 'Común',
            mana: item['Maná'] ?? 0,
            habilidad: item['Habilidades'] ?? '',
            ataque: item['Ataque'] ?? 0,
            vida: item['Vida'] ?? 0,
            descripcion: item['Descripción'] ?? '',
          );
        }).toList();

        return {'exito': true, 'datos': listaCartas};
      } else {
        return {'exito': false, 'mensaje': 'Error del servidor: ${respuesta.statusCode}'};
      }
    } catch (e) {
      return {'exito': false, 'mensaje': 'Error de conexión: No se pudo conectar al servidor'};
    }
  }

  static Future<Map<String, dynamic>> obtenerMazoEInventario(String idJugador) async {
    try {
      final respuesta = await http.get(
        Uri.parse('$_urlBase/jugador/$idJugador/mazo_e_inventario'),
      ).timeout(const Duration(seconds: 10));

      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(respuesta.body);
        return {'exito': true, 'datos': datos};
      } else {
        return {'exito': false, 'mensaje': 'Error del servidor: ${respuesta.statusCode}'};
      }
    } catch (e) {
      return {'exito': false, 'mensaje': 'Error de conexión al cargar las cartas'};
    }
  }

  static Future<Map<String, dynamic>> guardarMazo(String idJugador, List<String> mazoIds) async {
    try {
      final respuesta = await http.post(
        Uri.parse('$_urlBase/mazos/guardar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idJugador': idJugador,
          'mazo': mazoIds,
        }),
      ).timeout(const Duration(seconds: 10));

      if (respuesta.statusCode == 200 || respuesta.statusCode == 201) {
        return {'exito': true, 'mensaje': '¡Mazo guardado con éxito!'};
      } else {
        return {'exito': false, 'mensaje': 'Error del servidor: no se pudo guardar'};
      }
    } catch (e) {
      return {'exito': false, 'mensaje': 'Error de conexión al guardar el mazo'};
    }
  }
}
