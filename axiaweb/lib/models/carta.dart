class CartaWiki {
  final String id;
  final String expansion;
  final String nombre;
  final String rareza;
  final int mana;
  final String habilidad;
  final int ataque;
  final int vida;
  final String descripcion;
  // Usaremos un icono temporal hasta que conectes tus imágenes reales
  final String imagenUrl; 

  CartaWiki({
    required this.id,
    required this.expansion,
    required this.nombre,
    required this.rareza,
    required this.mana,
    required this.habilidad,
    required this.ataque,
    required this.vida,
    required this.descripcion,
    this.imagenUrl = '',
  });
}