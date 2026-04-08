import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/carta.dart'; 

class ApiServicio {
  static const String _urlBase = 'https://mi-servidor-axia.com/api';

  static Future<Map<String, dynamic>> hacerLogin(String correo, String password) async {
    try {
      final respuesta = await http.post(
        Uri.parse('$_urlBase/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': correo,
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


  // Añade esto dentro de tu clase ApiServicio:
  static Future<Map<String, dynamic>> obtenerCatalogoCartas() async {
    try {
      final url = Uri.parse('http://192.168.1.XX:3000/api/cartas/wiki'); 
      
      final respuesta = await http.get(url);

      if (respuesta.statusCode == 200) {
        // Si el servidor responde bien, convertimos el JSON a una lista
        final List<dynamic> datosDecodificados = json.decode(respuesta.body);
        
        // Mapeamos los datos del servidor a nuestros objetos CartaWiki
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
            // imagenUrl: item['imagen'] ?? '', // Descomenta esto cuando tengas las URLs de tus imágenes
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

  // --- MÉTODO PARA REGISTRARSE ---
  static Future<Map<String, dynamic>> registrarUsuario(String nombre, String correo, String password) async {
    try {
      final respuesta = await http.post(
        Uri.parse('$_urlBase/registro'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre,
          'correo': correo,
          'password': password,
        }),
      );

      if (respuesta.statusCode == 201) { // 201 significa "Creado"
        return {'exito': true, 'mensaje': 'Cuenta creada con éxito'};
      } else {
        // Capturamos el error que envíe el servidor (ej. "El correo ya existe")
        final error = jsonDecode(respuesta.body);
        return {'exito': false, 'mensaje': error['mensaje'] ?? 'Error al registrar'};
      }
    } catch (e) {
      return {'exito': false, 'mensaje': 'Error de conexión'};
    }
  }
}
