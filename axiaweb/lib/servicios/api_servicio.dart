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
  // Borramos el token fantasma
  static void cerrarSesion() {
      _token = null; 
    }
  // --- RANKING ---
  static Future<Map<String, dynamic>> obtenerRanking() async {
    try {
      final respuesta = await http.get(Uri.parse('$_urlBase/Ranking'), headers: _getHeaders());
      if (respuesta.statusCode == 200) {
        return {'exito': true, 'ranking': jsonDecode(respuesta.body)}; // Clave 'ranking'
      }
      return {'exito': false, 'mensaje': 'Error del servidor'};
    } catch (e) {
      return {'exito': false, 'mensaje': e.toString()};
    }
  }
  // --- REGISTRO ---
  static Future<Map<String, dynamic>> registrarUsuario(String nombre, String correo, String password) async {
    try {
      final respuesta = await http.post(
        Uri.parse('$_urlBase/auth/register'),
        headers: {'Content-Type': 'application/json'},
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
static Future<Map<String, dynamic>> generarMazoInicial(String nombreMazo) async {
  try {
    final respuesta = await http.post(
      Uri.parse('$_urlBase/deck/generate'),
      headers: _getHeaders(),
      body: jsonEncode({'name': nombreMazo}),
    );

    if (respuesta.statusCode == 200) {
      return {'exito': true, 'mensaje': '¡Mazo inicial creado!'};
    }
    return {'exito': false, 'mensaje': 'Error al generar mazo'};
  } catch (e) {
    return {'exito': false, 'mensaje': 'Error de conexión al generar mazo'};
  }
}

// Obtener monedas
static Future<int> obtenerMonedasUsuario() async {
  try {
    final respuesta = await http.get(Uri.parse('$_urlBase/auth/perfil'), headers: _getHeaders());
    if (respuesta.statusCode == 200) {
      final datos = jsonDecode(respuesta.body);
      return datos['money'] ?? datos['Money'] ?? 0;
    }
  } catch (e) {
    print("Error obteniendo monedas: $e");
  }
  return 500;
}
// --- OBTENER PERFIL COMPLETO  ---
static Future<Map<String, dynamic>> obtenerPerfilCompleto() async {
  try {
    // Disparamos las 3 peticiones de forma SIMULTÁNEA
    final respuestas = await Future.wait([
      http.get(Uri.parse('$_urlBase/auth/perfil'), headers: _getHeaders()),
      http.get(Uri.parse('$_urlBase/Ranking'), headers: _getHeaders()),
      http.get(Uri.parse('$_urlBase/Card/my-cards'), headers: _getHeaders()),
    ]);

    final resPerfil = respuestas[0];
    final resRanking = respuestas[1];
    final resCartas = respuestas[2];

    if (resPerfil.statusCode == 200) {
      final datosPerfil = jsonDecode(resPerfil.body);
      String miUsuario = datosPerfil['username'] ?? datosPerfil['Username'];

      // Extraemos Victorias y Nivel del Ranking
      int victorias = 0;
      int partidasJugadas = 0;
      int nivel = 1;
      
      if (resRanking.statusCode == 200) {
        List<dynamic> rankingCompleto = jsonDecode(resRanking.body);
        // Buscamos a nuestro usuario dentro de la lista del ranking
        var misDatosRanking = rankingCompleto.firstWhere(
          (user) => user['username'] == miUsuario || user['Username'] == miUsuario, 
          orElse: () => null
        );
        
        if (misDatosRanking != null) {
          victorias = misDatosRanking['wonMatches'] ?? misDatosRanking['WonMatches'] ?? 0;
          partidasJugadas = misDatosRanking['playedMatches'] ?? misDatosRanking['PlayedMatches'] ?? 0;
          nivel = misDatosRanking['level'] ?? misDatosRanking['Level'] ?? 1;
        }
      }

      //Calculamos el Total de Cartas sumando las cantidades del inventario
      int totalCartas = 0;
      if (resCartas.statusCode == 200) {
        List<dynamic> misCartas = jsonDecode(resCartas.body);
        for (var item in misCartas) {
          totalCartas += (item['quantity'] ?? item['Quantity'] ?? 0) as int;
        }
      }

      //Devolvemos un solo objeto JSON unificado a la vista
      return {
        'exito': true, 
        'datos': {
          'username': miUsuario,
          'level': nivel,
          'wins': victorias,
          'played': partidasJugadas,
          'totalCards': totalCartas,
          // El historial es falso por ahora, ya que el server aún no guarda partidas terminadas
          'matchHistory': [
            {'opponent': 'Bot_Alpha', 'result': 'Victoria', 'date': 'Hoy'},
            {'opponent': 'Jugador_Misterioso', 'result': 'Derrota', 'date': 'Ayer'},
          ]
        }
      };
    }
    
    return {'exito': false, 'mensaje': 'No se pudo cargar el perfil'};
  } catch (e) {
    return {'exito': false, 'mensaje': 'Error de conexión: $e'};
  }
}
// --- ABRIR SOBRE DE LA TIENDA ---
  static Future<Map<String, dynamic>> abrirSobre(String expansion) async {
    try {
      // Limpiamos la URL por seguridad
      String expansionLimpia = Uri.encodeComponent(expansion.trim());
      final respuesta = await http.get(
        Uri.parse('$_urlBase/Card/open/$expansionLimpia'), 
        headers: _getHeaders(),
      );

      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(respuesta.body);
        
        List<dynamic> listaJson = [];
        
        // Verifica si la API devuelve una lista directa o un objeto con clave 'cards'
        if (datos is List) {
          listaJson = datos;
        } else if (datos['cards'] != null) {
          listaJson = datos['cards'];
        }

        List<CartaWiki> cartasObtenidas = listaJson.map((json) => CartaWiki(
          id: json['id'].toString(),
          nombre: json['name'] ?? 'Sin nombre',
          descripcion: json['description'] ?? '',
          ataque: json['attack'] ?? 0,
          vida: json['defense'] ?? 0,
          mana: json['mana'] ?? 0,
          rareza: _traducirRareza(json['rarity']), 
          expansion: json['expansion'] ?? expansion,
          habilidad: json['ability'] != null 
              ? "${json['ability']['name'] ?? ''}: ${json['ability']['description'] ?? ''}" 
              : "Sin habilidad",
          imagenUrl: (json['imageUrl'] != null && json['imageUrl'].toString().trim().isNotEmpty)
              ? "https://aixec-card-images.s3.eu-north-1.amazonaws.com/card${json['id'].toString().padLeft(3, '0')}.jpg"
              : "",
        )).toList();

        return {'exito': true, 'cartas': cartasObtenidas};
      } else {
        print("Error del servidor al abrir sobre: ${respuesta.statusCode} - ${respuesta.body}");
        return {'exito': false, 'mensaje': 'Error del servidor: ${respuesta.statusCode}'};
      }
    } catch (e) {
      print("Fallo crítico en la app (abrirSobre): $e");
      return {'exito': false, 'mensaje': 'Error de conexión: $e'};
    }
  }


// --- INVENTARIO ---
static Future<Map<String, dynamic>> obtenerInventario() async {
  try {
    final respuesta = await http.get(
      Uri.parse('$_urlBase/card/my-cards'),
      headers: _getHeaders(),
    );

    if (respuesta.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(respuesta.body);

      List<CartaWiki> inventario = jsonList.map((json) => CartaWiki(
        id: json['id'].toString(),
        nombre: json['name'] ?? '',
        descripcion: json['description'] ?? '',
        ataque: json['attack'] ?? 0,
        vida: json['defense'] ?? 0,
        mana: json['mana'] ?? 1,
        rareza: _traducirRareza(json['rarity']),
        expansion: json['expansion'] ?? 'Base',
        habilidad: json['ability']?['name'] ?? '',
        imagenUrl: "https://aixec-card-images.s3.eu-north-1.amazonaws.com/card${json['id'].toString().padLeft(3, '0')}.jpg",

        /*imagenUrl: (json['imageUrl'] != null && json['imageUrl'].toString().trim().isNotEmpty)
            ? "https://aixec-card-images.s3.eu-north-1.amazonaws.com/card${json['id'].toString().padLeft(3, '0')}.jpg"
            : "",*/
      )).toList();

      Map<String, int> cantidades = {};
      for (var item in jsonList) {
        cantidades[item['id'].toString()] = item['quantity'] ?? 1;
      }
      if (inventario.isNotEmpty) {
        print("DEBUG inventario[0].imagenUrl = ${inventario.first.imagenUrl}");
        // imprime algunas más por si acaso
        for (int i = 0; i < (inventario.length < 5 ? inventario.length : 5); i++) {
          print("DEBUG inventario[$i].id=${inventario[i].id} url=${inventario[i].imagenUrl}");
        }
      }

      return {'exito': true, 'inventario': inventario, 'cantidades': cantidades};
    }
    return {'exito': false, 'mensaje': 'No se pudieron cargar tus cartas'};
  } catch (e) {
    return {'exito': false, 'mensaje': 'Error de conexión'};
  }
}

  
  // obtener historial del chat
  static Future<Map<String, dynamic>> obtenerHistorialChat() async {
    try {
      final response = await http.get(Uri.parse('$_urlBase/chat/history'),
      headers: _getHeaders(),);
      
      if (response.statusCode == 200) {
        return {'exito': true, 'datos': json.decode(response.body)};
      }
      return {'exito': false, 'mensaje': 'Error al cargar historial'};
    } catch (e) {
      return {'exito': false, 'mensaje': e.toString()};
    }
  }

// --- GUARDAR O ACTUALIZAR DECK ---
  static Future<Map<String, dynamic>> guardarMazo(List<int> cardIds, int? deckId) async {
    try {
      final url = deckId == null 
          ? '$_urlBase/Deck' 
          : '$_urlBase/Deck/$deckId';

      final body = jsonEncode({
        "name": "mazo principal", 
        "cardIds": cardIds           
      });

      http.Response respuesta;
      if (deckId == null) {
        respuesta = await http.post(Uri.parse(url), headers: _getHeaders(), body: body);
      } else {
        respuesta = await http.put(Uri.parse(url), headers: _getHeaders(), body: body);
      }

      if (respuesta.statusCode == 200) {
        return {'exito': true, 'mensaje': 'Mazo guardado correctamente'};
      }
      return {'exito': false, 'mensaje': 'Error al guardar: ${respuesta.statusCode}'};
    } catch (e) {
      return {'exito': false, 'mensaje': e.toString()};
    }
  }
  
// --- OBTENER MI DECK ---
static Future<Map<String, dynamic>> obtenerMiDeck() async {
  try {
    final respuesta = await http.get(
      Uri.parse('$_urlBase/Deck'),
      headers: _getHeaders(),
    );

    if (respuesta.statusCode == 200) {
      final List<dynamic> decks = jsonDecode(respuesta.body);

      // ver qué devuelve el servidor
      print("obtenerMiDeck body: ${respuesta.body}");

      if (decks.isEmpty) {
        return {'exito': false, 'mensaje': 'No tienes mazos creados'};
      }

      final raw = decks[0] as Map<String, dynamic>;

      //Intentamos extraer una lista de objetos de carta (Cards)
      final dynamic posiblesCards = raw['Cards'] ?? raw['cards'] ?? raw['CardIds'] ?? raw['cardIds'];

      List<String> cardIdsNormalizados = [];
      List<Map<String, dynamic>> cardsDetailed = [];

      if (posiblesCards is List) {
        for (var item in posiblesCards) {
          if (item == null) continue;

          if (item is Map) {
            final idVal = item['Id'] ?? item['id'] ?? item['Id'.toLowerCase()];
            if (idVal != null) {
              cardIdsNormalizados.add(idVal.toString());
            }
            // Guardamos el objeto detallado para uso directo
            cardsDetailed.add(Map<String, dynamic>.from(item));
          } else {
            // Si es int o string (lista de ids)
            cardIdsNormalizados.add(item.toString());
          }
        }
      }

      if (cardIdsNormalizados.isEmpty) {
        final dynamic alt = raw['cardIds'] ?? raw['CardIds'] ?? raw['cards'] ?? raw['Cards'];
        if (alt is List) {
          for (var it in alt) {
            if (it == null) continue;
            cardIdsNormalizados.add(it.toString());
          }
        }
      }

      // Devolvemos el deck original y las dos estructuras normalizadas
      final datosDeck = Map<String, dynamic>.from(raw);
      datosDeck['cardIdsNormalized'] = cardIdsNormalizados;
      datosDeck['cardsDetailed'] = cardsDetailed;

      return {'exito': true, 'datos': datosDeck};
    }

    return {'exito': false, 'mensaje': 'Error del servidor: ${respuesta.statusCode}'};
  } catch (e) {
    return {'exito': false, 'mensaje': 'Error de conexión: $e'};
  }
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
        List<CartaWiki> catalogo = jsonList.map((json) => CartaWiki(
          id: json['id'].toString(), 
          nombre: json['name'] ?? 'Sin nombre',
          descripcion: json['description'] ?? 'Sin descripción',
          ataque: json['attack'] ?? 0,
          vida: json['defense'] ?? 0,
          mana: json['mana'] ?? 0, 
          rareza: _traducirRareza(json['rarity']),
          expansion: json['expansion'] ?? 'Base',
          habilidad: json['ability'] != null 
              ? "${json['ability']['name']}: ${json['ability']['description']}" 
              : "Sin habilidad",
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