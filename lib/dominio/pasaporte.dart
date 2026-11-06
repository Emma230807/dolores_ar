import 'lugar.dart';

/// Pasaporte turístico:
/// Ganas un sello al llegar a 40 metros o menos de un lugar.
class Pasaporte {
  static const double radioSello = 40;

  // Almacena los identificadores de los lugares visitados.
  final Set<String> _visitados = {};

  /// Registra un sello cuando el usuario está cerca.
  /// Devuelve true solamente cuando se obtiene
  /// el sello por primera vez.
  bool registrarSiCerca(Lugar lugar, double distanciaMetros) {
    if (distanciaMetros > radioSello) {
      return false;
    }

    return _visitados.add(lugar.id);
  }

  /// Comprueba si un lugar ya tiene su sello.
  bool visitado(String id) {
    return _visitados.contains(id);
  }

  /// Cantidad total de sellos conseguidos.
  int get total => _visitados.length;

  /// Progreso del pasaporte entre 0.0 y 1.0.
  double progreso(int totalLugares) {
    return totalLugares == 0 ? 0 : total / totalLugares;
  }
}
