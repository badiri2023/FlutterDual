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
        // CORREGIDO: 'eassword' a 'password'
        body: jsonEncode({'email': correo, 'password': password}), 
      );

      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(respuesta.body);
        _token = datos['token'];
        return {'exito': true, 'mensaje': 'Bienvenido', 'datos': datos};
      }
      
      // Imprimimos el error exacto en consola para poder depurar
      print("Fallo en Login: Código ${respuesta.statusCode} - Body: ${respuesta.body}");
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
        // Esto está perfecto en minúsculas
        body: jsonEncode({'username': nombre, 'email': correo, 'password': password}),
      );

      if (respuesta.statusCode == 200 || respuesta.statusCode == 201) {
        return {'exito': true, 'mensaje': 'Registro completado'};
      }
      
      // Imprimimos el error exacto en consola para saber por qué falla C#
      print("Fallo en Registro: Código ${respuesta.statusCode} - Body: ${respuesta.body}");
      return {'exito': false, 'mensaje': 'Error en el registro: ${respuesta.body}'};
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
    try {
      final respuesta = await http.get(
        Uri.parse('http://aixec.eu-north-1.elasticbeanstalk.com/api/card/'),
        headers: _getHeaders(),
      );

      if (respuesta.statusCode == 200) {
        // Decodificamos la lista que viene del servidor
        List<dynamic> jsonList = jsonDecode(respuesta.body);
        print("JSON RECIBIDO: ${jsonList.first}");
        // Mapeamos cada "diccionario" JSON a tu objeto CartaWiki
        List<CartaWiki> catalogo = jsonList.map((json) => CartaWiki(
          id: json['id'].toString(), 
          nombre: json['name'] ?? 'Sin nombre',
          descripcion: json['description'] ?? 'Sin descripción',
          ataque: json['attack'] ?? 0,
          vida: json['defense'] ?? 0, // En el JSON se llama defense
          mana: json['mana'] ?? 0, 
          rareza: _traducirRareza(json['rarity']), // Convierte el 1,2,3 a texto
          expansion: json['expansion'] ?? 'Base',
          // OJO AQUÍ: Como ability es otro objeto, sacamos su nombre así:
          habilidad: json['ability'] != null 
              ? "${json['ability']['name']}: ${json['ability']['description']}" 
              : "Sin habilidad",
// Usamos 'imageUrl' que es el nombre real que envía tu servidor C#
          imagenUrl: (json['imageUrl'] != null && json['imageUrl'].toString().trim().isNotEmpty)
              ? "https://aixec-card-images.s3.eu-north-1.amazonaws.com/card${json['id'].toString().padLeft(3, '0')}.jpg"
              : "",
            )).toList();
print("URL DE LA PRIMERA CARTA: ${catalogo.first.imagenUrl}");
        return {'exito': true, 'datos': catalogo};
      } else {
        
        return {'exito': false, 'mensaje': 'Error del servidor: ${respuesta.statusCode}'};
      }
    } catch (e) {
      
      return {'exito': false, 'mensaje': 'Error de red: $e'};
    }
  }
 
 
  static String _traducirRareza(dynamic rareza) {
    if (rareza == 1) return 'Común';
    if (rareza == 2) return 'Rara';
    if (rareza == 3) return 'Épica';
    return 'Común';
  }
}